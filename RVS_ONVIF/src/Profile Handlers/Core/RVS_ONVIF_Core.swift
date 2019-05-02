/**
 © Copyright 2019, The Great Rift Valley Software Company. All rights reserved.
 
 This code is proprietary and confidential code,
 It is NOT to be reused or combined into any application,
 unless done so, specifically under written license from The Great Rift Valley Software Company.
 
 The Great Rift Valley Software Company: https://riftvalleysoftware.com
 */

import Foundation
import SOAPEngine64

/* ###################################################################################################################################### */
/**
 This file contains methods, data structures and callbacks for the ONVIF Core Profile.
 */
public class RVS_ONVIF_Core: ProfileHandlerProtocol {
    /* ################################################################################################################################## */
    // MARK: - Private Static Properties
    /* ###################################################################################################################################### */
    /* ################################################################## */
    /**
     This is the key name for this class.
     */
    private static let _profileName = "CORE"
    
    /* ################################################################################################################################## */
    // MARK: - Private Instance Properties
    /* ###################################################################################################################################### */
    /* ################################################################## */
    /**
     This is the RVS_ONVIF instance that "owns" this instance.
     */
    private let _owner: RVS_ONVIF!

    /* ############################################################################################################################## */
    // MARK: - GetCapabilities Parsers
    /* ############################################################################################################################## */
    /* ################################################################## */
    /**
     - parameter inResponseDictionary: The Dictionary ([String: Any]) of the response data.
     - returns: A new Analytics Capability instance.
     */
    private func _parseAnalyticsResponse(_ inResponseDictionary: [String: Any]) -> AnalyticsCapabilities {
        #if DEBUG
            print("\nDevice Analytics Capabilities Response: \(String(describing: inResponseDictionary))")
        #endif
        var ret = AnalyticsCapabilities(owner: owner)
        if let xAddrStr = owner._parseString(inResponseDictionary, key: "XAddr"), let uri = URL(string: xAddrStr) {
            ret.xAddr = uri
        }
        ret.isRuleSupport = owner._parseBoolean(inResponseDictionary, key: "RuleSupport")
        ret.isAnalyticsModuleSupport = owner._parseBoolean(inResponseDictionary, key: "AnalyticsModuleSupport")
        
        return ret
    }
 
    /* ################################################################## */
    /**
     This is called to parse a Dynamic DNS request (GetDynamicDNS)
     
     - parameter inResponseDictionary: The Dictionary ([String: Any]) of the response data.
     - parameter soapRequest: The SOAP request object call, as a String
     - parameter soapEngine: The SOAPEngine object that executed the request.
     - returns: the parsed DNS record, or nil, if there was an error.
     */
    private func _parseDynamicDNSRecord(_ inResponseDictionary: [String: Any], soapRequest inSOAPRequest: String, soapEngine inSOAPEngine: SOAPEngine) -> DynamicDNSRecord! {
        #if DEBUG
            print("\nDNS Response: \(String(describing: inResponseDictionary))")
        #endif
        // The reason for all this byzantine crap, is because different manufacturers return markedly different XML, and we need to be flexible enough to deal with what they send.
        if  let responseDict = inResponseDictionary["GetDynamicDNSResponse"] as? [String: Any],
            let responseWrapper = responseDict["DynamicDNSInformation"] as? [String: Any],
            let responseType = owner._parseString(responseWrapper, key: "Type") {
            var type: DynamicDNSRecord.DynDNSType!
        
            switch responseType {
            case "ServerUpdates":
                if let ttl = owner._parseDuration(responseWrapper, key: "TTL") {
                    type = .ServerUpdates(ttl: ttl)
                } else {
                    fallthrough
                }

            case "ClientUpdates":
                if let name = owner._parseString(responseWrapper, key: "Name") {
                    if let ttl = owner._parseDuration(responseWrapper, key: "TTL") {
                        type = .ClientUpdates(name: name, ttl: ttl)
                    } else {
                        type = .ClientUpdates(name: name, ttl: nil)
                    }
                } else {
                    fallthrough
                }

            default:
                type = .NoUpdate
            }
            
            return DynamicDNSRecord(owner: owner, type: type)
        } else if let responseType = inResponseDictionary["GetDynamicDNSResponse"] as? String {
            var type: DynamicDNSRecord.DynDNSType!
            
            switch responseType {
            case "ServerUpdates":
                type = .ServerUpdates(ttl: nil)
                
            case "ClientUpdates":
                type = .ClientUpdates(name: "", ttl: nil)
                
            default:
                type = .NoUpdate
            }
            
            return DynamicDNSRecord(owner: owner, type: type)
        }
        
        owner._errorCallback(RVS_ONVIF.RVS_Fault(faultCode: .UnknownSOAPError(error: nil)), soapRequest: inSOAPRequest, soapEngine: inSOAPEngine)
        return nil
    }
    
    /* ################################################################## */
    /**
     This is called to parse a DNS request (GetDNS)
     
     - parameter inResponseDictionary: The Dictionary ([String: Any]) of the response data.
     - parameter soapRequest: The SOAP request object call, as a String
     - parameter soapEngine: The SOAPEngine object that executed the request.
     - returns: the parsed DNS record, or nil, if there was an error.
     */
    private func _parseDNSRecord(_ inResponseDictionary: [String: Any], soapRequest inSOAPRequest: String, soapEngine inSOAPEngine: SOAPEngine) -> RVS_ONVIF_Core.DNSRecord! {
        #if DEBUG
        print("\nDNS Response: \(String(describing: inResponseDictionary))")
        #endif
        // The reason for all this byzantine crap, is because different manufacturers return markedly different XML, and we need to be flexible enough to deal with what they send.
        guard   let responseDict = inResponseDictionary["GetDNSResponse"] as? [String: Any],
            let responseWrapper = ((responseDict["DNSInformation"] ?? responseDict["DNS"])) as? [String: Any] else {
                owner._errorCallback(RVS_ONVIF.RVS_Fault(faultCode: .UnknownSOAPError(error: nil)), soapRequest: inSOAPRequest, soapEngine: inSOAPEngine)
                return nil
        }
        
        let fromDHCP = "true" == owner._parseString(responseWrapper, key: "FromDHCP")?.lowercased()
        let searchDomain = responseWrapper["SearchDomain"] as? [String] ?? [owner._parseString(responseWrapper, key: "SearchDomain") ?? ""]
        
        // This is the part where they play dirty.
        var addresses: [RVS_IPAddress] = []
        
        // It could be either or.
        if let dnsAddresses = (responseWrapper["DNSManual"] ?? responseWrapper["DNSFromDHCP"]) as? [[String: Any]] {
            addresses = dnsAddresses.compactMap {
                let ipAddress = owner._parseIPAddress($0)
                return (ipAddress?.isValidAddress ?? false) ? ipAddress : nil
            }
            // Some manufacturers return single values as simple elements, others, as Array elements. Need to grab both.
        } else if let dnsAddress = (responseWrapper["DNSManual"] ?? responseWrapper["DNSFromDHCP"]) as? [String: Any], let address = owner._parseIPAddress(dnsAddress) {
            addresses = [address]
        }
        
        return RVS_ONVIF_Core.DNSRecord(owner: owner, searchDomain: searchDomain, isFromDHCP: fromDHCP, addresses: addresses)
    }

    /* ################################################################## */
    /**
     This is called to parse an NTP request (GetNTP)
     
     - parameter inResponseDictionary: The Dictionary ([String: Any]) of the response data.
     - parameter soapRequest: The SOAP request object call, as a String
     - parameter soapEngine: The SOAPEngine object that executed the request.
     - returns: the parsed NTP record, or nil, if there was an error.
     */
    private func _parseNTPRecord(_ inResponseDictionary: [String: Any], soapRequest inSOAPRequest: String, soapEngine inSOAPEngine: SOAPEngine) -> RVS_ONVIF_Core.NTPRecord! {
        #if DEBUG
            print("\nNTP Response: \(String(describing: inResponseDictionary))")
        #endif
        // The reason for all this byzantine crap, is because different manufacturers return markedly different XML, and we need to be flexible enough to deal with what they send.
        guard   let responseDict = inResponseDictionary["GetNTPResponse"] as? [String: Any],
            let responseWrapper = ((responseDict["NTPInformation"] ?? responseDict["NTP"])) as? [String: Any] else {
                owner._errorCallback(RVS_ONVIF.RVS_Fault(faultCode: .UnknownSOAPError(error: nil)), soapRequest: inSOAPRequest, soapEngine: inSOAPEngine)
                return nil
        }
        
        let fromDHCP = "true" == owner._parseString(responseWrapper, key: "FromDHCP")?.lowercased()
        
        // This is the part where they play dirty.
        var addresses: [RVS_IPAddress] = []
        var names: [String] = []

        // It could be either or
        if let ntpAddresses = (responseWrapper["NTPManual"] ?? responseWrapper["NTPFromDHCP"]) as? [[String: Any]] {
            addresses = ntpAddresses.compactMap {
                // If we have a valid IP address, we return that. Otherwise, return nil, and it won't be added.
                guard let ipAddress = owner._parseIPAddress($0), ipAddress.isValidAddress else {
                    return nil
                }
                return ipAddress
            }
            // Some manufacturers return single values as simple elements, others, as Array elements. Need to grab both.
        } else if let ntpAddress = (responseWrapper["NTPManual"] ?? responseWrapper["NTPFromDHCP"]) as? [String: Any], let address = owner._parseIPAddress(ntpAddress) {
            addresses = [address]
        }
        
        // It could be either or
        if let ntpAddresses = (responseWrapper["NTPManual"] ?? responseWrapper["NTPFromDHCP"]) as? [[String: Any]] {
            names = ntpAddresses.compactMap {
                return owner._parseString($0, key: "DNSname")
            }
            // Some manufacturers return single values as simple elements, others, as Array elements. Need to grab both.
        } else if let ntpAddresses = (responseWrapper["NTPManual"] ?? responseWrapper["NTPFromDHCP"]) as? [String: Any], let name = owner._parseString(ntpAddresses, key: "DNSname") {
            names = [name]
        }

        return RVS_ONVIF_Core.NTPRecord(owner: owner, isFromDHCP: fromDHCP, addresses: addresses, names: names)
    }

    /* ################################################################## */
    /**
     - parameter inResponseDictionary: The Dictionary ([String: Any]) of the response data.
     - returns: A new Device Capability instance.
     */
    private func _parseDeviceResponse(_ inResponseDictionary: [String: Any]) -> DeviceCapabilities {
        #if DEBUG
            print("\nDevice Capabilities Response: \(String(describing: inResponseDictionary))")
        #endif
        var ret = DeviceCapabilities(owner: owner)
        
        if let xAddrStr = owner._parseString(inResponseDictionary, key: "XAddr"), let uri = URL(string: xAddrStr) {
            ret.xAddr = uri
        }
        
        if let networkCapabilities = inResponseDictionary["Network"] as? [String: Any] {
            ret.networkCapabilities = _parseNetworkServiceCapabilitiesDictionary(networkCapabilities)
        }
        
        if let systemCapabilities = inResponseDictionary["System"] as? [String: Any] {
            ret.systemCapabilities = _parseSystemServiceCapabilitiesDictionary(systemCapabilities)
        }
        
        if let securityCapabilities = inResponseDictionary["Security"] as? [String: Any] {
            ret.securityCapabilities = _parseSecurityServiceCapabilitiesDictionary(securityCapabilities)
        }
        
        if let ioCapabilities = inResponseDictionary["IO"] as? [String: Any] {
            if let value = owner._parseInteger(ioCapabilities, key: "InputConnectors") {
                ret.ioCapabilities.inputConnectors = value
            }
            if let value = owner._parseInteger(ioCapabilities, key: "RelayOutputs") {
                ret.ioCapabilities.relayOutputs = value
            }
            if let value = owner._parseString(ioCapabilities, key: "Auxiliary") {
                ret.ioCapabilities.auxiliary = value
            }
        }
        
        return ret
    }
    
    /* ################################################################## */
    /**
     - parameter inResponseDictionary: The Dictionary ([String: Any]) of the response data.
     - returns: A new Device I/O Capability instance.
     */
    private func _parseDeviceIOResponse(_ inResponseDictionary: [String: Any]) -> InternalDeviceIOCapabilities {
        #if DEBUG
            print("\nDevice I/O Capabilities Response: \(String(describing: inResponseDictionary))")
        #endif
        var ret = InternalDeviceIOCapabilities(owner: owner)
        if let xAddr = inResponseDictionary["XAddr"] as? [String: Any], let xAddrStr = xAddr["value"] as? String, let uri = URL(string: xAddrStr) {
            ret.xAddr = uri
        }
        
        ret.videoSources = owner._parseInteger(inResponseDictionary, key: "VideoSources")
        ret.videoOutputs = owner._parseInteger(inResponseDictionary, key: "VideoOutputs")
        ret.audioSources = owner._parseInteger(inResponseDictionary, key: "AudioSources")
        ret.audioOutputs = owner._parseInteger(inResponseDictionary, key: "AudioOutputs")
        ret.relayOutputs = owner._parseInteger(inResponseDictionary, key: "RelayOutputs")
        
        return ret
    }
    
    /* ################################################################## */
    /**
     - parameter inResponseDictionary: The Dictionary ([String: Any]) of the response data.
     - returns: A new Device I/O Capability instance.
     */
    private func _parseDisplayResponse(_ inResponseDictionary: [String: Any]) -> DisplayCapabilities {
        #if DEBUG
            print("\nDevice Display Capabilities Response: \(String(describing: inResponseDictionary))")
        #endif
        var ret = DisplayCapabilities(owner: owner)
        if let xAddr = inResponseDictionary["XAddr"] as? [String: Any], let xAddrStr = xAddr["value"] as? String, let uri = URL(string: xAddrStr) {
            ret.xAddr = uri
        }
        
        ret.isFixedLayout = owner._parseBoolean(inResponseDictionary, key: "FixedLayout")
        
        return ret
    }
    
    /* ################################################################## */
    /**
     - parameter inResponseDictionary: The Dictionary ([String: Any]) of the response data.
     - returns: A new Device Events instance.
     */
    private func _parseEventsResponse(_ inResponseDictionary: [String: Any]) -> EventsCapabilities {
        #if DEBUG
            print("\nDevice Events Capabilities Response: \(String(describing: inResponseDictionary))")
        #endif
        var ret = EventsCapabilities(owner: owner)
        if let xAddr = inResponseDictionary["XAddr"] as? [String: Any], let xAddrStr = xAddr["value"] as? String, let uri = URL(string: xAddrStr) {
            ret.xAddr = uri
        }
        
        ret.isWSSubscriptionPolicySupport = owner._parseBoolean(inResponseDictionary, key: "WSSubscriptionPolicySupport")
        ret.isWSPullPointSupport = owner._parseBoolean(inResponseDictionary, key: "WSPullPointSupport")
        ret.isWSPausableSubscriptionManagerInterfaceSupport = owner._parseBoolean(inResponseDictionary, key: "WSPausableSubscriptionManagerInterfaceSupport")
        
        return ret
    }
    
    /* ################################################################## */
    /**
     - parameter inResponseDictionary: The Dictionary ([String: Any]) of the response data.
     - returns: A new Device Media Capabilities instance.
     */
    private func _parseMediaResponse(_ inResponseDictionary: [String: Any]) -> MediaCapabilities {
        #if DEBUG
            print("\nDevice Media Capabilities Response: \(String(describing: inResponseDictionary))")
        #endif
        var ret = MediaCapabilities(owner: owner)
        if let xAddr = inResponseDictionary["XAddr"] as? [String: Any], let xAddrStr = xAddr["value"] as? String, let uri = URL(string: xAddrStr) {
            ret.xAddr = uri
        }
        
        ret.isRTPMulticast = owner._parseBoolean(inResponseDictionary, key: "RTPMulticast")
        ret.isRTP_TCP = owner._parseBoolean(inResponseDictionary, key: "RTP_TCP")
        ret.isRTP_RTSP_TCP = owner._parseBoolean(inResponseDictionary, key: "RTP_RTSP_TCP")
        ret.maximumNumberOfProfiles = owner._parseInteger(inResponseDictionary, key: "MaximumNumberOfProfiles")
        
        return ret
    }
    
    /* ################################################################## */
    /**
     - parameter inResponseDictionary: The Dictionary ([String: Any]) of the response data.
     - returns: A new Device Receiver Capabilities instance.
     */
    private func _parseReceiverResponse(_ inResponseDictionary: [String: Any]) -> ReceiverCapabilities {
        #if DEBUG
            print("\nDevice Receiver Capabilities Response: \(String(describing: inResponseDictionary))")
        #endif
        var ret = ReceiverCapabilities(owner: owner)
        if let xAddr = inResponseDictionary["XAddr"] as? [String: Any], let xAddrStr = xAddr["value"] as? String, let uri = URL(string: xAddrStr) {
            ret.xAddr = uri
        }
        
        ret.isRTP_Multicast = owner._parseBoolean(inResponseDictionary, key: "RTP_Multicast")
        ret.isRTP_TCP = owner._parseBoolean(inResponseDictionary, key: "RTP_TCP")
        ret.isRTP_RTSP_TCP = owner._parseBoolean(inResponseDictionary, key: "RTP_RTSP_TCP")
        ret.supportedReceivers = owner._parseInteger(inResponseDictionary, key: "SupportedReceivers")
        ret.maximumRTSPURILength = owner._parseInteger(inResponseDictionary, key: "MaximumRTSPURILength")
        
        return ret
    }
    
    /* ################################################################## */
    /**
     - parameter inResponseDictionary: The Dictionary ([String: Any]) of the response data.
     - returns: A new Device Recording Capabilities instance.
     */
    private func _parseRecordingResponse(_ inResponseDictionary: [String: Any]) -> RecordingCapabilities {
        #if DEBUG
            print("\nDevice Recording Capabilities Response: \(String(describing: inResponseDictionary))")
        #endif
        var ret = RecordingCapabilities(owner: owner)
        if let xAddr = inResponseDictionary["XAddr"] as? [String: Any], let xAddrStr = xAddr["value"] as? String, let uri = URL(string: xAddrStr) {
            ret.xAddr = uri
        }
        
        ret.isDynamicRecordings = owner._parseBoolean(inResponseDictionary, key: "DynamicRecordings")
        ret.isDynamicTracks = owner._parseBoolean(inResponseDictionary, key: "DynamicTracks")
        ret.isDeleteData = owner._parseBoolean(inResponseDictionary, key: "DeleteData")
        
        return ret
    }
    
    /* ################################################################## */
    /**
     - parameter inResponseDictionary: The Dictionary ([String: Any]) of the response data.
     - returns: A new Search Capabilities instance.
     */
    private func _parseSearchResponse(_ inResponseDictionary: [String: Any]) -> SearchCapabilities {
        #if DEBUG
            print("\nDevice Search Capabilities Response: \(String(describing: inResponseDictionary))")
        #endif
        var ret = SearchCapabilities(owner: owner)
        if let xAddr = inResponseDictionary["XAddr"] as? [String: Any], let xAddrStr = xAddr["value"] as? String, let uri = URL(string: xAddrStr) {
            ret.xAddr = uri
        }
        
        ret.isMetadataSearch = owner._parseBoolean(inResponseDictionary, key: "MetadataSearch")
        
        return ret
    }
    
    /* ################################################################## */
    /**
     - parameter inResponseDictionary: The Dictionary ([String: Any]) of the response data.
     - returns: A new Capabilities instance.
     */
    private func _parseAnalyticDeviceResponse(_ inResponseDictionary: [String: Any]) -> AnalyticsDeviceCapabilities! {
        #if DEBUG
            print("\nDevice Analytics Device Capabilities Response: \(String(describing: inResponseDictionary))")
        #endif
        if let xAddr = inResponseDictionary["XAddr"] as? [String: Any], let xAddrStr = xAddr["value"] as? String, let uri = URL(string: xAddrStr) {
            var ret = AnalyticsDeviceCapabilities(owner: owner)
            ret.xAddr = uri
            return ret
        }
        
        return nil
    }
    
    /* ################################################################## */
    /**
     - parameter inResponseDictionary: The Dictionary ([String: Any]) of the response data.
     - returns: A new Capabilities instance.
     */
    private func _parseImagingResponse(_ inResponseDictionary: [String: Any]) -> ImagingCapabilities! {
        #if DEBUG
            print("\nDevice Imaging Capabilities Response: \(String(describing: inResponseDictionary))")
        #endif
        if let xAddr = inResponseDictionary["XAddr"] as? [String: Any], let xAddrStr = xAddr["value"] as? String, let uri = URL(string: xAddrStr) {
            var ret = ImagingCapabilities(owner: owner)
            ret.xAddr = uri
            return ret
        }
        
        return nil
    }
    
    /* ################################################################## */
    /**
     - parameter inResponseDictionary: The Dictionary ([String: Any]) of the response data.
     - returns: A new Capabilities instance.
     */
    private func _parsePTZResponse(_ inResponseDictionary: [String: Any]) -> PTZCapabilities! {
        #if DEBUG
            print("\nDevice PTZ Capabilities Response: \(String(describing: inResponseDictionary))")
        #endif
        if let xAddr = inResponseDictionary["XAddr"] as? [String: Any], let xAddrStr = xAddr["value"] as? String, let uri = URL(string: xAddrStr) {
            var ret = PTZCapabilities(owner: owner)
            ret.xAddr = uri
            return ret
        }
        
        return nil
    }
    
    /* ################################################################## */
    /**
     - parameter inResponseDictionary: The Dictionary ([String: Any]) of the response data.
     - returns: A new Capabilities instance.
     */
    private func _parseReplayResponse(_ inResponseDictionary: [String: Any]) -> ReplayCapabilities! {
        #if DEBUG
            print("\nDevice Replay Capabilities Response: \(String(describing: inResponseDictionary))")
        #endif
        if let xAddr = inResponseDictionary["XAddr"] as? [String: Any], let xAddrStr = xAddr["value"] as? String, let uri = URL(string: xAddrStr) {
            var ret = ReplayCapabilities(owner: owner)
            ret.xAddr = uri
            return ret
        }
        
        return nil
    }
    
    /* ################################################################## */
    /**
     This parses the response to the GetServiceCapabilities Network Capabilities request, and returns a capability instance for the device.
     
     - parameter inResponseDictionary: The Network Dictionary ([String: Any]) of the response data.
     - returns: A new Network Capability Instance
     */
    private func _parseNetworkServiceCapabilitiesDictionary(_ networkCapabilities: [String: Any]) -> NetworkCapabilities {
        var ret = NetworkCapabilities(owner: owner)
        #if DEBUG
            print("Network Capabilities Response: \(String(describing: networkCapabilities))")
        #endif
        ret.isIPFilter = owner._parseBoolean(networkCapabilities, key: "IPFilter")
        ret.isZeroConfiguration = owner._parseBoolean(networkCapabilities, key: "ZeroConfiguration")
        ret.isIPVersion6 = owner._parseBoolean(networkCapabilities, key: "IPVersion6")
        ret.isDynDNS = owner._parseBoolean(networkCapabilities, key: "DynDNS")
        ret.isDot11Configuration = owner._parseBoolean(networkCapabilities, key: "Dot11Configuration")
        ret.dot1XConfiguration = owner._parseInteger(networkCapabilities, key: "Dot1XConfigurations")
        ret.isHostnameFromDHCP = owner._parseBoolean(networkCapabilities, key: "HostnameFromDHCP")
        ret.ntp = owner._parseInteger(networkCapabilities, key: "NTP")
        ret.isDHCPv6 = owner._parseBoolean(networkCapabilities, key: "DHCPv6")
        
        return ret
    }
    
    /* ################################################################## */
    /**
     This parses the response to the GetServiceCapabilities Security Capabilities request, and returns a capability instance for the device.
     
     - parameter inResponseDictionary: The Security Dictionary ([String: Any]) of the response data.
     - returns: A new Security Capability Instance
     */
    private func _parseSecurityServiceCapabilitiesDictionary(_ securityCapabilities: [String: Any]) -> SecurityCapabilities {
        var ret = SecurityCapabilities(owner: owner)
        #if DEBUG
            print("Security Capabilities Response: \(String(describing: securityCapabilities))")
        #endif
        ret.isTLS10 = owner._parseBoolean(securityCapabilities, key: "TLS1.0")
        ret.isTLS11 = owner._parseBoolean(securityCapabilities, key: "TLS1.1")
        ret.isTLS12 = owner._parseBoolean(securityCapabilities, key: "TLS1.2")
        ret.isOnboardKeyGeneration = owner._parseBoolean(securityCapabilities, key: "OnboardKeyGeneration")
        ret.isAccessPolicyConfig = owner._parseBoolean(securityCapabilities, key: "AccessPolicyConfig")
        ret.isDefaultAccessPolicy = owner._parseBoolean(securityCapabilities, key: "DefaultAccessPolicy")
        ret.isDot1X = owner._parseBoolean(securityCapabilities, key: "Dot1X")
        ret.isRemoteUserHandling = owner._parseBoolean(securityCapabilities, key: "RemoteUserHandling")
        ret.isX509Token = owner._parseBoolean(securityCapabilities, key: "X.509Token")
        ret.isSAMLToken = owner._parseBoolean(securityCapabilities, key: "SAMLToken")
        ret.isKerberosToken = owner._parseBoolean(securityCapabilities, key: "KerberosToken")
        ret.isUsernameToken = owner._parseBoolean(securityCapabilities, key: "UsernameToken")
        ret.isHttpDigest = owner._parseBoolean(securityCapabilities, key: "HttpDigest")
        ret.isRELToken = owner._parseBoolean(securityCapabilities, key: "RELToken")
        if let val = owner._parseString(securityCapabilities, key: "SupportedEAPMethods") {
            ret.supportedEAPMethods = val.components(separatedBy: ",").compactMap({ Int($0) })
        }
        ret.maxUsers = owner._parseInteger(securityCapabilities, key: "MaxUsers")
        ret.maxUserNameLength = owner._parseInteger(securityCapabilities, key: "MaxUserNameLength")
        ret.maxPasswordLength = owner._parseInteger(securityCapabilities, key: "MaxPasswordLength")
        
        return ret
    }
    
    /* ################################################################## */
    /**
     This parses the response to the GetServiceCapabilities Security Capabilities request, and returns a capability instance for the device.
     
     - parameter inResponseDictionary: The Security Dictionary ([String: Any]) of the response data.
     - returns: A new Security Capability Instance
     */
    private func _parseSystemServiceCapabilitiesDictionary(_ systemCapabilities: [String: Any]) -> SystemCapabilities {
        var ret = SystemCapabilities(owner: owner)
        #if DEBUG
            print("System Capabilities Response: \(String(describing: systemCapabilities))")
        #endif
        ret.isDiscoveryResolve = owner._parseBoolean(systemCapabilities, key: "DiscoveryResolve")
        ret.isDiscoveryBye = owner._parseBoolean(systemCapabilities, key: "DiscoveryBye")
        ret.isRemoteDiscovery = owner._parseBoolean(systemCapabilities, key: "RemoteDiscovery")
        ret.isSystemBackup = owner._parseBoolean(systemCapabilities, key: "SystemBackup")
        ret.isSystemLogging = owner._parseBoolean(systemCapabilities, key: "SystemLogging")
        ret.isFirmwareUpgrade = owner._parseBoolean(systemCapabilities, key: "FirmwareUpgrade")
        ret.isHttpFirmwareUpgrade = owner._parseBoolean(systemCapabilities, key: "HttpFirmwareUpgrade")
        ret.isHttpSystemBackup = owner._parseBoolean(systemCapabilities, key: "HttpSystemBackup")
        ret.isHttpSystemLogging = owner._parseBoolean(systemCapabilities, key: "HttpSystemLogging")
        ret.isHttpSupportInformation = owner._parseBoolean(systemCapabilities, key: "HttpSupportInformation")
        ret.isStorageConfiguration = owner._parseBoolean(systemCapabilities, key: "StorageConfiguration")
        ret.maxStorageConfigurations = owner._parseInteger(systemCapabilities, key: "MaxStorageConfigurations")
        ret.geoLocationEntries = owner._parseInteger(systemCapabilities, key: "GeoLocationEntries")
        if let val = owner._parseString(systemCapabilities, key: "AutoGeo") {
            ret.autoGeo = val.components(separatedBy: ",")
        }
        if let val = owner._parseString(systemCapabilities, key: "StorageTypesSupported") {
            ret.storageTypesSupported = val.components(separatedBy: ",")
        }
        
        return ret
    }

    /* ############################################################################################################################## */
    // MARK: - Internal Enums
    /* ############################################################################################################################## */
    /* ################################################################## */
    /**
     This is inspired by the ONVIFCamera library, by Rémy Virin, but I'm a jerk, and couldn't leave well enough alone.
     These use ONVIF TitleCase, as opposed to the standard Swift camelCase, in order to match the SOAP request.
     */
    internal enum _DeviceRequest: String, RVS_ONVIF_DeviceRequestProtocol, CaseIterable {
        case GetDeviceInformation
        case GetHostname
        case GetServices
        case GetServiceCapabilities
        case GetCapabilities
        case GetWsdlUrl
        case GetScopes
        case GetDNS
        case GetNTP
        case GetDynamicDNS

        case SetHostname
        case SetHostnameFromDHCP
        case SetDNS
        case SetNTP
        case SetDynamicDNS

        /* ############################################################## */
        /**
         This is the profile key (for looking up in the profile hander list).
         */
        var profileKey: String {
            return "RVS_ONVIF_Core"
        }
        
        /* ############################################################## */
        /**
         Return whether or not the particular call requires additional parameters, or can be called standalone.
         */
        var isRequiresParameters: Bool {
            var ret = false
            
            switch self {
            case .GetServices, .SetHostname, .SetHostnameFromDHCP, .SetDNS, .SetNTP, .SetDynamicDNS:
                ret = true
                
            default:
                break
            }
            
            return ret
        }

        /* ########################################################################################################################## */
        // MARK: - Internal Structs
        /* ########################################################################################################################## */
        /* ############################################################## */
        /**
         Indicate if we should retrieve the attributes inside the xml element, for instance it's needed
         in `getProfiles` to retrieve the token: `<Profiles token="MediaProfile000" fixed="true">`
         */
        var isRetrieveAttributes: Bool {
            return .GetServiceCapabilities == self || .GetCapabilities == self
        }
    }

    /* ################################################################################################################################## */
    // MARK: - Internal Instance Initializer
    /* ###################################################################################################################################### */
    /* ################################################################## */
    /**
     We make this internal, so it doesn't get instantiated willy-nilly.
     
     - parameter owner: The "Owning" main ONVIF instance. It is guaranteed to have an instance of this class in its ".profileCore" variable.
     */
    internal init(owner inOwner: RVS_ONVIF) {
        _owner = inOwner
    }

    /* ################################################################################################################################## */
    // MARK: - Internal Instance Methods
    /* ################################################################################################################################## */
    /* ################################################################## */
    /**
     This begins the process of getting the basic camera information from the device.
     It needs to be internal, as it is called by the factory.
     */
    internal func _fetchDeviceInformation() {
        owner.performRequest(_DeviceRequest.GetDeviceInformation)
    }
    
    /* ############################################################################################################################## */
    // MARK: - GetCapabilities Parser
    /* ############################################################################################################################## */
    /* ################################################################## */
    /**
     This parses the response to the GetCapabilities request, and returns a capability instance for the device.
     
     - parameter inCapabilitiesDictionary: The Dictionary ([String: Any]) of the response data.
     - returns: A new Device Capability instance.
     */
    internal func _transformDeviceCapabilitiesDictionary(_ inCapabilitiesDictionary: [String: Any]) -> Capabilities {
        var ret = Capabilities(owner: owner)
        
        if let analyticsResponse = inCapabilitiesDictionary["Analytics"] as? [String: Any] {
            ret.analyticsCapabilities = _parseAnalyticsResponse(analyticsResponse)
        }
        
        if let response = inCapabilitiesDictionary["AnalyticsDevice"] as? [String: Any] {
            ret.analyticsDeviceCapabilities = _parseAnalyticDeviceResponse(response)
        }
        
        if let deviceResponse = inCapabilitiesDictionary["Device"] as? [String: Any] {
            ret.deviceCapabilities = _parseDeviceResponse(deviceResponse)
        }
        
        if let response = inCapabilitiesDictionary["DeviceIO"] as? [String: Any] {
            ret.deviceIOCapabilities = _parseDeviceIOResponse(response)
        }
        
        if let response = inCapabilitiesDictionary["Display"] as? [String: Any] {
            ret.displayCapabilities = _parseDisplayResponse(response)
        }
        
        if let response = inCapabilitiesDictionary["Events"] as? [String: Any] {
            ret.eventsCapabilities = _parseEventsResponse(response)
        }
        
        if let response = inCapabilitiesDictionary["Imaging"] as? [String: Any] {
            ret.imagingCapabilities = _parseImagingResponse(response)
        }
        
        if let response = inCapabilitiesDictionary["Media"] as? [String: Any] {
            ret.mediaCapabilities = _parseMediaResponse(response)
        }
        
        if let response = inCapabilitiesDictionary["PTZ"] as? [String: Any] {
            ret.ptzCapabilities = _parsePTZResponse(response)
        }
        
        if let response = inCapabilitiesDictionary["Receiver"] as? [String: Any] {
            ret.receiverCapabilities = _parseReceiverResponse(response)
        }
        
        if let response = inCapabilitiesDictionary["Recording"] as? [String: Any] {
            ret.recordingCapabilities = _parseRecordingResponse(response)
        }
        
        if let response = inCapabilitiesDictionary["Replay"] as? [String: Any] {
            ret.replayCapabilities = _parseReplayResponse(response)
        }
        
        if let response = inCapabilitiesDictionary["Search"] as? [String: Any] {
            ret.searchCapabilities = _parseSearchResponse(response)
        }
        
        #if DEBUG
            print("\nCapabilities Response: \(String(describing: ret))")
        #endif
        
        return ret
    }
    
    /* ############################################################################################################################## */
    // MARK: - GetServiceCapabilities Parser
    /* ############################################################################################################################## */
    /* ################################################################## */
    /**
     This parses the response to the GetServiceCapabilities request, and returns a capability instance for the device.
     
     - parameter inResponseDictionary: The Dictionary ([String: Any]) of the response data.
     - returns: A new Service Capability instance.
     */
    internal func _transformServiceCapabilitiesDictionary(_ inResponseDictionary: [String: Any]) -> ServiceCapabilities {
        var ret = ServiceCapabilities(owner: owner)
        
        if let servicesResponse = inResponseDictionary["GetServiceCapabilitiesResponse"] as? [String: Any], let capabilities = servicesResponse["Capabilities"] as? [String: Any] {
            #if DEBUG
                print("Service Capabilities Response: \(String(describing: capabilities))")
            #endif
            if let networkResponse = capabilities["Network"] as? [String: Any], let networkCapabilities = networkResponse["attributes"] as? [String: Any] {
                ret.networkCapabilities = _parseNetworkServiceCapabilitiesDictionary(networkCapabilities)
            }
            
            if let securityResponse = capabilities["Security"] as? [String: Any], let securityCapabilities = securityResponse["attributes"] as? [String: Any] {
                ret.securityCapabilities = _parseSecurityServiceCapabilitiesDictionary(securityCapabilities)
            }
            
            if let systemResponse = capabilities["System"] as? [String: Any], let systemCapabilities = systemResponse["attributes"] as? [String: Any] {
                ret.systemCapabilities = _parseSystemServiceCapabilitiesDictionary(systemCapabilities)
            }
            
            if let miscResponse = capabilities["Misc"] as? [String: Any], let auxCommands = miscResponse["AuxiliaryCommands"] as? String {
                let auxiliaryCommands: [String] = auxCommands.components(separatedBy: ",")
                ret.auxiliaryCommands = auxiliaryCommands
            }
        }
        
        return ret
    }
    
    /* ############################################################################################################################## */
    // MARK: - GetServices Parser
    /* ############################################################################################################################## */
    /* ################################################################## */
    /**
     This parses the response to the GetServices request, and builds up a list of services for the device.
     
     - parameter inResponseDictionary: The Dictionary ([String: Any]) of the response data.
     - returns: An Array of Service struct instances, created from the response data.
     */
    internal func _transformServicesDictionary(_ inResponseDictionary: [String: Any]) -> [Service] {
        #if DEBUG
            print("Transforming Services Dictionary: \(String(describing: inResponseDictionary))")
        #endif
        var ret: [Service] = []
        
        if let servicesResponse = inResponseDictionary["GetServicesResponse"] as? [String: Any] {
            #if DEBUG
            print("Services Response: \(String(describing: servicesResponse))")
            #endif
            if let servicesList = servicesResponse["Service"] as? [[String: Any]] {
                #if DEBUG
                print("Services List: \(String(describing: servicesList))")
                #endif
                servicesList.forEach { [unowned self] (element) in
                    if  let version = element["Version"] as? [String: String],
                        let major = Int(version["Major"] ?? "0"),
                        // Weird rule for versioning. If the major version is over 15, then the minor is a leading-zero month index (https://www.onvif.org/ver10/device/wsdl/devicemgmt.wsdl).
                        let minor = Int(version["Minor"] ?? "0"),
                        let xAddr = element["XAddr"] as? String,
                        let uri = URL(string: xAddr),
                        let namespace = element["Namespace"] as? String {
                        var capabilities: ServiceCapabilities!
                        
                        if let capabilitiesAny = element["Capabilities"] as? [String: Any] {  // This is optional, so we check for it seperately.
                            capabilities = _transformServiceCapabilitiesDictionary(["GetServiceCapabilitiesResponse": capabilitiesAny])
                        }
                        
                        ret.append(Service(owner: self.owner, namespace: namespace, xAddr: uri, version: String(format: "%d.%02d", major, minor), capabilities: capabilities))
                    }
                }
            }
        }
        
        return ret
    }
    
    /* ############################################################################################################################## */
    // MARK: - GetScopes Parser
    /* ############################################################################################################################## */
    /* ################################################################## */
    /**
     This parses the response from the GetScopes command.
     
     - parameter inResponseDictionary: The Dictionary containing the partially-parsed response from SOAPEngine.
     - returns: an Array of Scope enum instances, containing interpreted versions of the device scopes.
     */
    internal func _transformScopesDictionary(_ inResponseDictionary: [String: Any]) -> [Scope] {
        #if DEBUG
            print("Transforming Scopes Dictionary: \(String(describing: inResponseDictionary))")
        #endif
        
        var ret: [Scope] = []
        
        if let scopes = inResponseDictionary["Scopes"] as? [[String: Any]] {
            #if DEBUG
                print("Scopes Response: \(String(describing: scopes))")
            #endif
            
            ret = scopes.compactMap { [unowned self] in // We simply use compactMap to create a list of our scopes, as Scope instances.
                if let owner = self.owner, let def = ($0["ScopeDef"] as? String)?.lowercased(), var item = $0["ScopeItem"] as? String, let itemStartOffset = item.index(of: "onvif.org/") {
                    item = String(item[item.index(itemStartOffset, offsetBy: 10)...])
                    let isConfigurable = "configurable" == def
                    // What we do here, is parse out the category (first path component), and lowercase that to allow matching, and then just leave the rest alone.
                    var itemArray = item.components(separatedBy: "/")
                    let category = itemArray.removeFirst().lowercased()
                    // The "leftover" is the portion of the scope that happens after the category. We associate that with the category enum.
                    if let leftover = itemArray.joined(separator: "/").urlDecodedString {
                        var scopeCategory: Scope.Category
                        // Remember that we are comparing lowercased Strings, as different manufacturers can return different cases, even though the spec says it should be TitleCase.
                        switch category {
                        case "location":
                            scopeCategory = .Location(leftover)
                        case "profile": // Profiles are further broken down into the profile type.
                            var profile: Scope.ProfileType
                            switch itemArray[0].lowercased() {  // We look at the first leg of the leftovers.
                            case "s", "streaming":
                                profile = .S(leftover)
                            case "q", "q/operational", "operational":
                                profile = .Q(leftover)
                            case "g", "recording":
                                profile = .G(leftover)
                            default:
                                profile = .Unknown(leftover)
                            }
                            scopeCategory = .Profile(profile)
                        case "hardware":
                            scopeCategory = .Hardware(leftover)
                        case "name":
                            scopeCategory = .Name(leftover)
                        default:    // In case of a "none of the above," we create a custom scope element.
                            scopeCategory = .Custom(name: category.firstUppercased, value: leftover)
                        }
                        
                        return Scope(owner: owner, isConfigurable: isConfigurable, category: scopeCategory)
                    }
                }
                
                return nil
            }
        }
        
        return ret
    }

    /* ################################################################################################################################## */
    // MARK: - Public Static Properties
    /* ################################################################################################################################## */
    /* ############################################################## */
    /**
     These are the namespaces handled by this profile handler.
     */
    public static var namespaces: [String] {
        return ["http://www.onvif.org/ver10/device/wsdl"]
    }
    
    /* ############################################################## */
    /**
     This is the scope enum for this handler.
     */
    public static var scopeProfile: RVS_ONVIF_Core.Scope.ProfileType = RVS_ONVIF_Core.Scope.ProfileType.Core("")
    
    /* ################################################################################################################################## */
    // MARK: - Public Typealiases
    /* ################################################################################################################################## */
    /* ############################################################## */
    /**
     The response from GetHostname
     */
    public typealias HostnameResponse = (fromDHCP: Bool, name: String)
    
    /* ################################################################################################################################## */
    // MARK: - Public Instance Stored Properties
    /* ################################################################################################################################## */
    /* ############################################################## */
    /**
     This is which of the profile namespaces are supported by this device. Latest version is last.
     */
    public var supportedNamespaces: [String] = []
    
    /* ################################################################## */
    /**
     This is the cache for the device scopes. It is filled at initialization time.
     */
    public var scopes: [Scope] = []

    /* ################################################################## */
    /**
     This is a cache of the device information. It is filled at initialization time.
     */
    public var deviceInformation: [String: Any] = [:]

    /* ################################################################## */
    /**
     This is a cache of services that are returned from the GetServices call. It is filled at initialization time.
     */
    public var services: [String: RVS_ONVIF_Core.Service] = [:]
    
    /* ################################################################## */
    /**
     This is the cache for the device capabilities. It is filled at initialization time.
     */
    public var capabilities: Capabilities!
    
    /* ################################################################## */
    /**
     This is the cache for the device service capabilities. It is filled at initialization time.
     */
    public var serviceCapabilities: ServiceCapabilities!

    /* ################################################################################################################################## */
    // MARK: - Public Instance Calculated Properties
    /* ################################################################################################################################## */
    /* ############################################################## */
    /**
     This is the profile name key.
     */
    public var profileName: String {
        return type(of: self)._profileName
    }

    /* ################################################################## */
    /**
     This is the RVS_ONVIF instance that "owns" this instance.
     */
    public var owner: RVS_ONVIF! {
        return _owner
    }
    
    /* ############################################################## */
    /**
     This is a list of the commands (as enum values) available for this handler
     */
    public var availableCommands: [RVS_ONVIF_DeviceRequestProtocol] {
        var ret: [RVS_ONVIF_DeviceRequestProtocol] = []
        
        _DeviceRequest.allCases.forEach {
            switch $0 {
            // We already got these.
            case .GetDeviceInformation, .GetScopes, .GetServices, .GetCapabilities, .GetServiceCapabilities:
                break
                
            case .GetDynamicDNS, .SetDynamicDNS:    // Only supplied if the device supports DynDNS.
                if serviceCapabilities.networkCapabilities.isDynDNS {
                    ret.append($0)
                }

            case .SetHostnameFromDHCP:  // Only supplied if we have the capability in our services configuration.
                if serviceCapabilities.networkCapabilities.isHostnameFromDHCP {
                    ret.append($0)
                }
            default:
                ret.append($0)
            }
        }
        
        return ret
    }

    /* ################################################################################################################################## */
    // MARK: - Public Callback Handler Instance Method
    /* ################################################################################################################################## */
    /* ################################################################## */
    /**
     This is called upon a successful SOAP call. It must be public, because the protocol is public, but it will only be used internally.

     - parameter inResponseDictionary: The Dictionary ([String: Any]) of the response data.
     - parameter soapRequest: The SOAP request object call, as a String
     - parameter soapEngine: The SOAPEngine object that executed the request.
     - returns: true, if the callback was handled (including as an error).
     */
    public func callbackHandler(_ inResponseDictionary: [String: Any], soapRequest inSOAPRequest: String, soapEngine inSOAPEngine: SOAPEngine) -> Bool {
        switch inSOAPRequest {
        case _DeviceRequest.GetDynamicDNS.soapAction:
            // We give the caller the opportunity to vet the data. Default just passes through.
            if !(owner.delegate?.onvifInstance(owner, rawDataPreview: inResponseDictionary, deviceRequest: _DeviceRequest.GetDynamicDNS) ?? false) {
                owner.dispatchers.forEach {
                    if $0.isAbleToHandleThisCommand(_DeviceRequest.GetDynamicDNS) {
                        $0.deliverResponse(_DeviceRequest.GetDynamicDNS, params: _parseDynamicDNSRecord(inResponseDictionary, soapRequest: inSOAPRequest, soapEngine: inSOAPEngine))
                    }
                }
            }
            
        case _DeviceRequest.GetDNS.soapAction:
            // We give the caller the opportunity to vet the data. Default just passes through.
            if !(owner.delegate?.onvifInstance(owner, rawDataPreview: inResponseDictionary, deviceRequest: _DeviceRequest.GetDNS) ?? false) {
                owner.dispatchers.forEach {
                    if $0.isAbleToHandleThisCommand(_DeviceRequest.GetDNS) {
                        $0.deliverResponse(_DeviceRequest.GetDNS, params: _parseDNSRecord(inResponseDictionary, soapRequest: inSOAPRequest, soapEngine: inSOAPEngine))
                    }
                }
            }
            
        case _DeviceRequest.GetNTP.soapAction:
            // We give the caller the opportunity to vet the data. Default just passes through.
            if !(owner.delegate?.onvifInstance(owner, rawDataPreview: inResponseDictionary, deviceRequest: _DeviceRequest.GetNTP) ?? false) {
                owner.dispatchers.forEach {
                    if $0.isAbleToHandleThisCommand(_DeviceRequest.GetNTP) {
                        $0.deliverResponse(_DeviceRequest.GetNTP, params: _parseNTPRecord(inResponseDictionary, soapRequest: inSOAPRequest, soapEngine: inSOAPEngine))
                    }
                }
            }

        default:    // If we don't recognize the call we made, we try our overflow.
            return _callbackHandlerPartDeux(inResponseDictionary, soapRequest: inSOAPRequest, soapEngine: inSOAPEngine)
        }
        
        return true
    }
    
    /* ################################################################## */
    /**
     This is an overflow handler, to reduce CC.
     
     This contains simple response handlers to "set" commands.
     
     - parameter inResponseDictionary: The Dictionary ([String: Any]) of the response data.
     - parameter soapRequest: The SOAP request object call, as a String
     - parameter soapEngine: The SOAPEngine object that executed the request.
     - returns: true, if the callback was handled (including as an error).
     */
    internal func _callbackHandlerPartDeux(_ inResponseDictionary: [String: Any], soapRequest inSOAPRequest: String, soapEngine inSOAPEngine: SOAPEngine) -> Bool {
        switch inSOAPRequest {
        case _DeviceRequest.GetWsdlUrl.soapAction:
            // No need for a separate parser. This is a simple one.
            guard let responseDict = inResponseDictionary["GetWsdlUrlResponse"] as? [String: String], let response = responseDict["WsdlUrl"] else {
                let fault = RVS_ONVIF.RVS_Fault(faultCode: .UnknownSOAPError(error: nil))
                owner._errorCallback(fault, soapRequest: inSOAPRequest, soapEngine: inSOAPEngine)
                break
            }
            
            if !(owner.delegate?.onvifInstance(owner, rawDataPreview: inResponseDictionary, deviceRequest: _DeviceRequest.GetWsdlUrl) ?? false) {
                owner.dispatchers.forEach {
                    if $0.isAbleToHandleThisCommand(_DeviceRequest.GetWsdlUrl) {
                        $0.deliverResponse(_DeviceRequest.GetWsdlUrl, params: response)
                    }
                }
            }
            
        case _DeviceRequest.GetHostname.soapAction:
            // No need for a separate parser. This is a simple one.
            guard let responseDict = inResponseDictionary["GetHostnameResponse"] as? [String: Any], let info = responseDict["HostnameInformation"] as? [String: Any], let fromDHCP = info["FromDHCP"] as? String, let name = info["Name"] as? String else {
                let fault = RVS_ONVIF.RVS_Fault(faultCode: .UnknownSOAPError(error: nil))
                owner._errorCallback(fault, soapRequest: inSOAPRequest, soapEngine: inSOAPEngine)
                break
            }
            
            if !(owner.delegate?.onvifInstance(owner, rawDataPreview: inResponseDictionary, deviceRequest: _DeviceRequest.GetHostname) ?? false) {
                // If the service capability isn't there, then it's never from DHCP.
                let dhcp = serviceCapabilities.networkCapabilities.isHostnameFromDHCP ? "true" == fromDHCP.lowercased() : false
                owner.dispatchers.forEach {
                    if $0.isAbleToHandleThisCommand(_DeviceRequest.GetHostname) {
                        $0.deliverResponse(_DeviceRequest.GetHostname, params: HostnameResponse(fromDHCP: dhcp, name: name))
                    }
                }
            }
            
        case _DeviceRequest.SetHostname.soapAction,
             _DeviceRequest.SetHostnameFromDHCP.soapAction,
             _DeviceRequest.SetDNS.soapAction,
             _DeviceRequest.SetNTP.soapAction,
             _DeviceRequest.SetDynamicDNS.soapAction:
            if let request = _DeviceRequest(rawValue: inSOAPRequest), !(owner.delegate?.onvifInstance(owner, rawDataPreview: inResponseDictionary, deviceRequest: request) ?? false) {
                owner.dispatchers.forEach {
                    if $0.isAbleToHandleThisCommand(_DeviceRequest.GetHostname) {
                        $0.deliverResponse(request, params: nil)
                    }
                }
            }

        default:    // If we don't recognize the call we made, we try our overflow.
            return _callbackHandlerPartTroix(inResponseDictionary, soapRequest: inSOAPRequest, soapEngine: inSOAPEngine)
        }
        
        return true
    }
    
    /* ################################################################## */
    /**
     This is an overflow handler, to reduce CC.
     
     This contains all of the initial calls that are made upon initialization, in the order they are made.
     These calls do not call the preview callback.
     
     - parameter inResponseDictionary: The Dictionary ([String: Any]) of the response data.
     - parameter soapRequest: The SOAP request object call, as a String
     - parameter soapEngine: The SOAPEngine object that executed the request.
     - returns: true, if the callback was handled (including as an error).
     */
    internal func _callbackHandlerPartTroix(_ inResponseDictionary: [String: Any], soapRequest inSOAPRequest: String, soapEngine inSOAPEngine: SOAPEngine) -> Bool {
        switch inSOAPRequest {
        case _DeviceRequest.GetDeviceInformation.soapAction:    // First, we get the initial device information call.
            guard let deviceInfo = inResponseDictionary["GetDeviceInformationResponse"] as? [String: Any] else {
                owner._errorCallback(RVS_ONVIF.RVS_Fault(faultCode: .UnknownSOAPError(error: nil)), soapRequest: inSOAPRequest, soapEngine: inSOAPEngine)
                break
            }
            
            deviceInformation = deviceInfo
            
            owner.performRequest(_DeviceRequest.GetServices, params: ["IncludeCapability": "true"]) // Cascade to get the services.
            
        case _DeviceRequest.GetServices.soapAction: // Get the ONVIF services for the device.
            let serviceArray = _transformServicesDictionary(inResponseDictionary)
            // Load up our cache.
            services = [:]
            serviceArray.forEach { [unowned self] in    // We do this, so that it's easy to look up a service by its namespace.
                self.services[$0.namespace] = $0
            }
            
            owner.performRequest(_DeviceRequest.GetServiceCapabilities) // Cascade to get the service capabilities.
            
        case _DeviceRequest.GetServiceCapabilities.soapAction:  // Get the service capabilities.
            let returnedCapabilities: ServiceCapabilities = _transformServiceCapabilitiesDictionary(inResponseDictionary)
            serviceCapabilities = returnedCapabilities
            owner.performRequest(_DeviceRequest.GetScopes)  // Cascade to get the scopes.
            
        case _DeviceRequest.GetScopes.soapAction:   // Get the device scopes.
            // We do one extra unwind here, to reduce the CC of the parser method.
            guard let mainResponse = inResponseDictionary["GetScopesResponse"] as? [String: Any] else {
                owner._errorCallback(RVS_ONVIF.RVS_Fault(faultCode: .UnknownSOAPError(error: nil)), soapRequest: inSOAPRequest, soapEngine: inSOAPEngine)
                break
            }
            
            scopes = _transformScopesDictionary(mainResponse)
            owner.performRequest(_DeviceRequest.GetCapabilities)    // Cascade to get the device capabilities.

        case _DeviceRequest.GetCapabilities.soapAction:
            // We do one extra unwind here, to reduce the CC of the parser method.
            guard let mainResponse = inResponseDictionary["GetCapabilitiesResponse"] as? [String: Any], let capabilitiesResponse = mainResponse["Capabilities"] as? [String: Any] else {
                owner._errorCallback(RVS_ONVIF.RVS_Fault(faultCode: .UnknownSOAPError(error: nil)), soapRequest: inSOAPRequest, soapEngine: inSOAPEngine)
                break
            }
            
            capabilities = _transformDeviceCapabilitiesDictionary(capabilitiesResponse)
            
            owner._setUpProfileHandlers()   // We ask our handler to establish its profile handlers, based on our available services.
            
            // Let the delegate know that we're finally ready.
            owner.delegate?.onvifInstanceInitialized(owner)
        
        default:    // If we don't recognize the call we made, we drop out.
            return false
        }
        
        return true
    }
}
