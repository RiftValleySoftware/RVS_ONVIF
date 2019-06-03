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
        case GetNetworkInterfaces
        
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
    // MARK: - GetCapabilities Parsers
    /* ############################################################################################################################## */
    /* ################################################################## */
    /**
     - parameter inResponseDictionary: The Dictionary ([String: Any]) of the response data.
     - returns: A new Analytics Capability instance.
     */
    private func _transformAnalyticsResponse(_ inResponseDictionary: [String: Any]) -> AnalyticsCapabilities {
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
    private func _transformDynamicDNSRecord(_ inResponseDictionary: [String: Any], soapRequest inSOAPRequest: String, soapEngine inSOAPEngine: SOAPEngine) -> DynamicDNSRecord! {
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
    private func _transformDNSRecord(_ inResponseDictionary: [String: Any], soapRequest inSOAPRequest: String, soapEngine inSOAPEngine: SOAPEngine) -> RVS_ONVIF_Core.DNSRecord! {
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
    private func _transformNTPRecord(_ inResponseDictionary: [String: Any], soapRequest inSOAPRequest: String, soapEngine inSOAPEngine: SOAPEngine) -> RVS_ONVIF_Core.NTPRecord! {
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
    private func _transformDeviceResponse(_ inResponseDictionary: [String: Any]) -> DeviceCapabilities {
        #if DEBUG
            print("\nDevice Capabilities Response: \(String(describing: inResponseDictionary))")
        #endif
        var ret = DeviceCapabilities(owner: owner)
        
        if let xAddrStr = owner._parseString(inResponseDictionary, key: "XAddr"), let uri = URL(string: xAddrStr) {
            ret.xAddr = uri
        }
        
        if let networkCapabilities = inResponseDictionary["Network"] as? [String: Any] {
            ret.networkCapabilities = _transformNetworkServiceCapabilitiesDictionary(networkCapabilities)
        }
        
        if let systemCapabilities = inResponseDictionary["System"] as? [String: Any] {
            ret.systemCapabilities = _transformSystemServiceCapabilitiesDictionary(systemCapabilities)
        }
        
        if let securityCapabilities = inResponseDictionary["Security"] as? [String: Any] {
            ret.securityCapabilities = _transformSecurityServiceCapabilitiesDictionary(securityCapabilities)
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
    private func _transformDeviceIOResponse(_ inResponseDictionary: [String: Any]) -> InternalDeviceIOCapabilities {
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
    private func _transformDisplayResponse(_ inResponseDictionary: [String: Any]) -> DisplayCapabilities {
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
    private func _transformEventsResponse(_ inResponseDictionary: [String: Any]) -> EventsCapabilities {
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
    private func _transformMediaResponse(_ inResponseDictionary: [String: Any]) -> MediaCapabilities {
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
    private func _transformReceiverResponse(_ inResponseDictionary: [String: Any]) -> ReceiverCapabilities {
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
    private func _transformRecordingResponse(_ inResponseDictionary: [String: Any]) -> RecordingCapabilities {
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
    private func _transformSearchResponse(_ inResponseDictionary: [String: Any]) -> SearchCapabilities {
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
    private func _transformAnalyticDeviceResponse(_ inResponseDictionary: [String: Any]) -> AnalyticsDeviceCapabilities! {
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
    private func _transformImagingResponse(_ inResponseDictionary: [String: Any]) -> ImagingCapabilities! {
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
    private func _transformPTZResponse(_ inResponseDictionary: [String: Any]) -> PTZCapabilities! {
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
    private func _transformReplayResponse(_ inResponseDictionary: [String: Any]) -> ReplayCapabilities! {
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
    private func _transformNetworkServiceCapabilitiesDictionary(_ networkCapabilities: [String: Any]) -> NetworkCapabilities {
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
    private func _transformSecurityServiceCapabilitiesDictionary(_ securityCapabilities: [String: Any]) -> SecurityCapabilities {
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
    private func _transformSystemServiceCapabilitiesDictionary(_ systemCapabilities: [String: Any]) -> SystemCapabilities {
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
            ret.analyticsCapabilities = _transformAnalyticsResponse(analyticsResponse)
        }
        
        if let response = inCapabilitiesDictionary["AnalyticsDevice"] as? [String: Any] {
            ret.analyticsDeviceCapabilities = _transformAnalyticDeviceResponse(response)
        }
        
        if let deviceResponse = inCapabilitiesDictionary["Device"] as? [String: Any] {
            ret.deviceCapabilities = _transformDeviceResponse(deviceResponse)
        }
        
        if let response = inCapabilitiesDictionary["DeviceIO"] as? [String: Any] {
            ret.deviceIOCapabilities = _transformDeviceIOResponse(response)
        }
        
        if let response = inCapabilitiesDictionary["Display"] as? [String: Any] {
            ret.displayCapabilities = _transformDisplayResponse(response)
        }
        
        if let response = inCapabilitiesDictionary["Events"] as? [String: Any] {
            ret.eventsCapabilities = _transformEventsResponse(response)
        }
        
        if let response = inCapabilitiesDictionary["Imaging"] as? [String: Any] {
            ret.imagingCapabilities = _transformImagingResponse(response)
        }
        
        if let response = inCapabilitiesDictionary["Media"] as? [String: Any] {
            ret.mediaCapabilities = _transformMediaResponse(response)
        }
        
        if let response = inCapabilitiesDictionary["PTZ"] as? [String: Any] {
            ret.ptzCapabilities = _transformPTZResponse(response)
        }
        
        if let response = inCapabilitiesDictionary["Receiver"] as? [String: Any] {
            ret.receiverCapabilities = _transformReceiverResponse(response)
        }
        
        if let response = inCapabilitiesDictionary["Recording"] as? [String: Any] {
            ret.recordingCapabilities = _transformRecordingResponse(response)
        }
        
        if let response = inCapabilitiesDictionary["Replay"] as? [String: Any] {
            ret.replayCapabilities = _transformReplayResponse(response)
        }
        
        if let response = inCapabilitiesDictionary["Search"] as? [String: Any] {
            ret.searchCapabilities = _transformSearchResponse(response)
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
                ret.networkCapabilities = _transformNetworkServiceCapabilitiesDictionary(networkCapabilities)
            }
            
            if let securityResponse = capabilities["Security"] as? [String: Any], let securityCapabilities = securityResponse["attributes"] as? [String: Any] {
                ret.securityCapabilities = _transformSecurityServiceCapabilitiesDictionary(securityCapabilities)
            }
            
            if let systemResponse = capabilities["System"] as? [String: Any], let systemCapabilities = systemResponse["attributes"] as? [String: Any] {
                ret.systemCapabilities = _transformSystemServiceCapabilitiesDictionary(systemCapabilities)
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
                            case "t":
                                profile = .T(leftover)
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
    
    /* ############################################################################################################################## */
    // MARK: - GetNetworkInterfaces Parser
    /* ############################################################################################################################## */
    /* ################################################################## */
    /**
     This parses the response from the GetNetworkInterfaces command.
     
     - parameter inResponseDictionary: The Dictionary containing the partially-parsed response from SOAPEngine.
     - returns: an Array of NetworkInterface instances.
     */
    internal func _transformNetworkInterfacesResponse(_ inResponseDictionary: [String: Any]) -> [NetworkInterface] {
        #if DEBUG
            print("Parsing the Network Interfaces Response")
        #endif
        
        var ret: [NetworkInterface] = []
        
        var outerWrapperArray: [[String: Any]] = []
        
        if let outerWrapperArrayTemp = inResponseDictionary["NetworkInterfaces"] as? [[String: Any]] {
            outerWrapperArray = outerWrapperArrayTemp
        } else if let outerWrapperArrayTemp = inResponseDictionary["NetworkInterfaces"] as? [String: Any] {
            outerWrapperArray = [outerWrapperArrayTemp]
        }
        
        outerWrapperArray.forEach {
            let token = owner._parseString($0, key: "token") ?? ""
            let isEnabled = owner._parseBoolean($0, key: "Enabled")
            let info = _transformNetworkInterfaceInfo($0)
            let link = _transformNetworkInterfaceLink($0)
            let ipv4 = _transformNetworkInterfaceIP($0, key: "IPv4")
            let ipv6 = _transformNetworkInterfaceIP($0, key: "IPv6")
            let networkInterfaceExtension = _transformNetworkInterfaceExtension($0)
            
            #if DEBUG
                print("\tNetwork Interface Info: \(token)")
                print("\t\ttoken: \(token)")
                print("\t\tisEnabled: \(isEnabled)")
                print("\t\tinfo: \(String(describing: info))")
                print("\t\tlink: \(String(describing: link))")
                print("\t\tipv4: \(String(describing: ipv4))")
                print("\t\tipv6: \(String(describing: ipv6))")
                print("\t\tnetworkInterfaceExtension: \(String(describing: networkInterfaceExtension))\n")
            #endif
            
            ret.append(NetworkInterface(owner: owner, token: token, isEnabled: isEnabled, info: info, link: link, ipV4: ipv4, ipV6: ipv6, networkInterfaceExtension: networkInterfaceExtension))
        }
        
        return ret
    }
    
    /* ################################################################## */
    /**
     This parses the Info response from the GetNetworkInterfaces command.
     
     - parameter inResponseDictionary: The Dictionary containing the partially-parsed response from SOAPEngine.
     - returns: a NetworkInterfaceInfo instance, or nil (if none)
     */
    internal func _transformNetworkInterfaceInfo(_ inResponseDictionary: [String: Any]) -> NetworkInterfaceInfo! {
        
        if let info = inResponseDictionary["Info"] as? [String: Any] {
            let name = owner._parseString(info, key: "Name") ?? ""
            let hwAddress = owner._parseString(info, key: "HwAddress") ?? ""
            let mtu = owner._parseInteger(info, key: "MTU") ?? 0
            
            return NetworkInterfaceInfo(name: name, hwAddress: hwAddress, mtu: mtu)
        }
        
        return nil
    }
    
    /* ################################################################## */
    /**
     This parses the Link response from the GetNetworkInterfaces command.
     
     - parameter inResponseDictionary: The Dictionary containing the partially-parsed response from SOAPEngine.
     - returns: a NetworkInterfaceLink instance, or nil (if none)
     */
    internal func _transformNetworkInterfaceLink(_ inResponseDictionary: [String: Any]) -> NetworkInterfaceLink! {
        
        if let link = inResponseDictionary["Link"] as? [String: Any] {
            var interfaceType = IANA_Types.other
            
            if let interfaceTypeInt = owner._parseInteger(link, key: "InterfaceType") {
                interfaceType = IANA_Types(rawValue: interfaceTypeInt) ?? .other
            }
            
            let adminSettings = _transformNetworkInterfaceConnectionSetting(link, key: "AdminSettings")
            let operSettings = _transformNetworkInterfaceConnectionSetting(link, key: "OperSettings")
            
            return NetworkInterfaceLink(adminSettings: adminSettings, operSettings: operSettings, interfaceType: interfaceType)
        }
        
        return nil
    }
    
    /* ################################################################## */
    /**
     This parses the Connection Setting Type response from the GetNetworkInterfaces command.
     
     - parameter inResponseDictionary: The Dictionary containing the partially-parsed response from SOAPEngine.
     - parameter key: The key to be used to fetch the data.
     - returns: a NetworkInterfaceConnectionSetting instance
     */
    internal func _transformNetworkInterfaceConnectionSetting(_ inResponseDictionary: [String: Any], key inKey: String) -> NetworkInterfaceConnectionSetting {
        if let link = inResponseDictionary[inKey] as? [String: Any] {
            let speed = owner._parseInteger(link, key: "Speed") ?? 0
            let autoNegotiation = owner._parseBoolean(link, key: "AutoNegotiation")
            let duplexString = owner._parseString(link, key: "Duplex") ?? ""
            let duplex = NetworkInterfaceConnectionSetting.Duplex(rawValue: duplexString) ?? .Full
            return NetworkInterfaceConnectionSetting(owner: owner, autoNegotiation: autoNegotiation, speed: speed, duplex: duplex)
        }
        
        return NetworkInterfaceConnectionSetting(owner: owner, autoNegotiation: false, speed: 0, duplex: .Full)
    }
    
    /* ################################################################## */
    /**
     This parses the IPv4/6 response from the GetNetworkInterfaces command.
     
     - parameter inResponseDictionary: The Dictionary containing the partially-parsed response from SOAPEngine.
     - parameter key: The key to be used to fetch the data.
     - returns: an IPNetworkInterface instance (with IPv4/6 info), or nil (if none)
     */
    internal func _transformNetworkInterfaceIP(_ inResponseDictionary: [String: Any], key inKey: String) -> IPNetworkInterface! {
        if let ipConfig = inResponseDictionary[inKey] as? [String: Any], let configDict = ipConfig["Config"] as? [String: Any] {
            let isEnabled = owner._parseBoolean(ipConfig, key: "Enabled")
            let config = _transformNetworkInterfaceIPIndividual(configDict)
            return IPNetworkInterface(isEnabled: isEnabled, configuration: config)
        }
        
        return nil
    }
    
    /* ################################################################## */
    /**
     This parses an individual IPv4/6 configuration from the GetNetworkInterfaces command.
     
     - parameter inResponseDictionary: The Dictionary containing the partially-parsed response from SOAPEngine.
     - returns: an IPConfiguration instance (with IPv4/6 info)
     */
    internal func _transformNetworkInterfaceIPIndividual(_ inResponseDictionary: [String: Any]) -> IPConfiguration {
        let ipv6ConfigurationExtension = inResponseDictionary["Extension"]
        var isDHCP: Bool = false
        var isAbleToAcceptRouterAdvert: Bool! = nil
        
        var manual: [IPAddressEntry]! = nil
        var linkLocal: [IPAddressEntry]! = nil
        var fromDHCP: [IPAddressEntry]! = nil
        var fromRA: [IPAddressEntry]! = nil

        // Have to do this, because IPv6 and IPv4 are different (what a mess).
        if let dhcpStatusStr = inResponseDictionary["DHCP"] as? String {
            let isDHCPBoolStr = dhcpStatusStr.lowercased().trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
            let isDHCPBool = "true" == isDHCPBoolStr || "on" == isDHCPBoolStr
            isDHCP = isDHCPBool
        }
        
        if let manualArray = inResponseDictionary["Manual"] as? [[String: String]] {
            manual = []
            manualArray.forEach {
                manual.append(_transformIPAddressEntry($0))
            }
        } else if let manualStr = inResponseDictionary["Manual"] as? [String: String] {
            manual = [_transformIPAddressEntry(manualStr)]
        }
        
        if let linkLocalArray = inResponseDictionary["LinkLocal"] as? [[String: String]] {
            linkLocal = []
            linkLocalArray.forEach {
                linkLocal.append(_transformIPAddressEntry($0))
            }
        } else if let linkLocalStr = inResponseDictionary["LinkLocal"] as? [String: String] {
            linkLocal = [_transformIPAddressEntry(linkLocalStr)]
        }
        
        if let fromDHCPArray = inResponseDictionary["FromDHCP"] as? [[String: String]] {
            fromDHCP = []
            fromDHCPArray.forEach {
                fromDHCP.append(_transformIPAddressEntry($0))
            }
        } else if let fromDHCPStr = inResponseDictionary["FromDHCP"] as? [String: String] {
            fromDHCP = [_transformIPAddressEntry(fromDHCPStr)]
        }
        
        if let fromRAArray = inResponseDictionary["FromRA"] as? [[String: String]] {
            fromRA = []
            fromRAArray.forEach {
                fromRA.append(_transformIPAddressEntry($0))
            }
        } else if let fromRAStr = inResponseDictionary["FromRA"] as? [String: String] {
            fromRA = [_transformIPAddressEntry(fromRAStr)]
        }
        
        if nil != inResponseDictionary["AcceptRouterAdvert"] as? String {
            isAbleToAcceptRouterAdvert = owner._parseBoolean(inResponseDictionary, key: "AcceptRouterAdvert")
        }
        
        return IPConfiguration(isDHCP: isDHCP, manual: manual, linkLocal: linkLocal, fromDHCP: fromDHCP, fromRA: fromRA, isAbleToAcceptRouterAdvert: isAbleToAcceptRouterAdvert, ipv6ConfigurationExtension: ipv6ConfigurationExtension)
    }

    /* ################################################################## */
    /**
     This parses the Extension response from the GetNetworkInterfaces command.
     
     - parameter inResponseDictionary: The Dictionary containing the partially-parsed response from SOAPEngine.
     - returns: an NetworkInterfaceExtension instance (with IPv6 info), or nil (if none)
     */
    internal func _transformNetworkInterfaceExtension(_ inResponseDictionary: [String: Any]) -> NetworkInterfaceExtension! {
        if let networkInterfaceExtension = inResponseDictionary["Extension"] as? [String: Any] {
            #if DEBUG
                print("Parsing the Network Extension Link: \(String(reflecting: networkInterfaceExtension))")
            #endif
            
            if let interfaceTypeInt = owner._parseInteger(networkInterfaceExtension, key: "InterfaceType"), let interfaceType = RVS_ONVIF_Core.IANA_Types(rawValue: interfaceTypeInt) {
                
                return NetworkInterfaceExtension(interfaceType: interfaceType, dot3Configuration: networkInterfaceExtension["Dot3"], dot11: _transformNetworkInterfaceDot11Configuration(networkInterfaceExtension["Dot11"] as? [String: Any]), networkInterfaceSetConfigurationExtension2: networkInterfaceExtension["NetworkInterfaceSetConfigurationExtension2"])
            }
        }
        
        return nil
    }

    /* ################################################################## */
    /**
     This parses the 802.11 response from the GetNetworkInterfaces command.
     
     - parameter inResponseDictionary: The Dictionary containing the partially-parsed response from SOAPEngine.
     - returns: a Dot11Configuration instance, or nil (if none)
     */
    internal func _transformNetworkInterfaceDot11Configuration(_ inResponseDictionary: [String: Any]!) -> Dot11Configuration! {
        if let ssid = inResponseDictionary["SSID"] as? String, let modeStr = owner._parseString(inResponseDictionary, key: "Mode"), let mode = Dot11Configuration.Dot11StationMode(rawValue: modeStr) {
            let alias = owner._parseString(inResponseDictionary, key: "Alias") ?? ""
            let priority = owner._parseInteger(inResponseDictionary, key: "Priority") ?? 0
            let securityConfiguration = _transformNetworkInterfaceDot11SecurityConfiguration(inResponseDictionary["Security"] as? [String: Any])
            
            return Dot11Configuration(ssid: ssid, mode: mode, alias: alias, priority: priority, security: securityConfiguration)
        }
        
        return nil
    }

    /* ################################################################## */
    /**
     This parses the 802.11 security configuration response from the GetNetworkInterfaces command.
     
     - parameter inResponseDictionary: The Dictionary containing the partially-parsed response from SOAPEngine.
     - returns: a Dot11Configuration.Dot11SecurityConfiguration instance, or nil (if none)
     */
    internal func _transformNetworkInterfaceDot11SecurityConfiguration(_ inResponseDictionary: [String: Any]!) -> Dot11Configuration.Dot11SecurityConfiguration {
        if let modeStr = owner._parseString(inResponseDictionary, key: "Mode"), let mode = Dot11Configuration.Dot11SecurityConfiguration.Dot11SecurityMode(rawValue: modeStr), let algorithmStr = owner._parseString(inResponseDictionary, key: "Algorithm"), let algorithm = Dot11Configuration.Dot11SecurityConfiguration.Dot11Cipher(rawValue: algorithmStr) {
            
            let psk = _transformNetworkInterfaceDot11PSKSet(inResponseDictionary["PSK"] as? [String: Any])
            
            return Dot11Configuration.Dot11SecurityConfiguration(mode: mode, algorithm: algorithm, psk: psk, dot1XToken: owner._parseString(inResponseDictionary, key: "Dot1X"), dot11SecurityConfigurationExtension: inResponseDictionary["Extension"])
        }
        
        return Dot11Configuration.Dot11SecurityConfiguration(mode: .none, algorithm: .any, psk: nil, dot1XToken: nil, dot11SecurityConfigurationExtension: nil)
    }

    /* ################################################################## */
    /**
     This parses the 802.11 security configuration PSK Set response from the GetNetworkInterfaces command.
     
     - parameter inResponseDictionary: The Dictionary containing the partially-parsed response from SOAPEngine.
     - returns: a Dot11Configuration.Dot11SecurityConfiguration instance, or nil (if none)
     */
    internal func _transformNetworkInterfaceDot11PSKSet(_ inResponseDictionary: [String: Any]!) -> Dot11Configuration.Dot11SecurityConfiguration.Dot11PSKSet! {
        if let key = owner._parseString(inResponseDictionary, key: "Key"), let passphrase = owner._parseString(inResponseDictionary, key: "Passphrase") {
            return Dot11Configuration.Dot11SecurityConfiguration.Dot11PSKSet(key: key, passphrase: passphrase, dot11PSKSetExtension: inResponseDictionary["Extension"])
        }
        
        return nil
    }
    
    /* ################################################################## */
    /**
     This parses an IP Address response from the GetNetworkInterfaces command.
     
     - parameter inResponseDictionary: The Dictionary containing the partially-parsed response from SOAPEngine.
     - returns: an IPAddressEntry instance (with IPv6 info)
     */
    internal func _transformIPAddressEntry(_ inResponseDictionary: [String: Any]) -> IPAddressEntry {
        let ipAddress = owner._parseIPAddress(inResponseDictionary)
        let prefixLength = owner._parseInteger(inResponseDictionary, key: "PrefixLength") ?? 0

        return IPAddressEntry(address: ipAddress, prefixLength: prefixLength)
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
    
    /* ################################################################## */
    /**
     This is the cache for the device network interface information. It is filled at initialization time.
     */
    public var networkInterfaces: [NetworkInterface]!

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
            case .GetDeviceInformation, .GetScopes, .GetServices, .GetCapabilities, .GetServiceCapabilities, .GetNetworkInterfaces:
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
                        $0.deliverResponse(_DeviceRequest.GetDynamicDNS, params: _transformDynamicDNSRecord(inResponseDictionary, soapRequest: inSOAPRequest, soapEngine: inSOAPEngine))
                    }
                }
            }
        
        case _DeviceRequest.GetDNS.soapAction:
            // We give the caller the opportunity to vet the data. Default just passes through.
            if !(owner.delegate?.onvifInstance(owner, rawDataPreview: inResponseDictionary, deviceRequest: _DeviceRequest.GetDNS) ?? false) {
                owner.dispatchers.forEach {
                    if $0.isAbleToHandleThisCommand(_DeviceRequest.GetDNS) {
                        $0.deliverResponse(_DeviceRequest.GetDNS, params: _transformDNSRecord(inResponseDictionary, soapRequest: inSOAPRequest, soapEngine: inSOAPEngine))
                    }
                }
            }
            
        case _DeviceRequest.GetNTP.soapAction:
            // We give the caller the opportunity to vet the data. Default just passes through.
            if !(owner.delegate?.onvifInstance(owner, rawDataPreview: inResponseDictionary, deviceRequest: _DeviceRequest.GetNTP) ?? false) {
                owner.dispatchers.forEach {
                    if $0.isAbleToHandleThisCommand(_DeviceRequest.GetNTP) {
                        $0.deliverResponse(_DeviceRequest.GetNTP, params: _transformNTPRecord(inResponseDictionary, soapRequest: inSOAPRequest, soapEngine: inSOAPEngine))
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
            owner.performRequest(_DeviceRequest.GetNetworkInterfaces)    // Cascade to get the device network interfaces.
            
        case _DeviceRequest.GetNetworkInterfaces.soapAction:
            // We do one extra unwind here, to reduce the CC of the parser method.
            guard let mainResponse = inResponseDictionary["GetNetworkInterfacesResponse"] as? [String: Any] else {
                owner._errorCallback(RVS_ONVIF.RVS_Fault(faultCode: .UnknownSOAPError(error: nil)), soapRequest: inSOAPRequest, soapEngine: inSOAPEngine)
                break
            }
            
            networkInterfaces = _transformNetworkInterfacesResponse(mainResponse)
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
