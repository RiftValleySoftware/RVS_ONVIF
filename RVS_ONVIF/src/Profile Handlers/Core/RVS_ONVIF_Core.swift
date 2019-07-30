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
open class RVS_ONVIF_Core: ProfileHandlerProtocol {
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
        /// Get Basic Device Information
        case GetDeviceInformation
        /// Get the Hostname
        case GetHostname
        /// Get the Various ONVIF Services Available
        case GetServices
        /// Get Service Capabilities
        case GetServiceCapabilities
        /// Get All ONVIF Capabilities
        case GetCapabilities
        /// Get the WSDL URI for the Device
        case GetWsdlUrl
        /// Get the Scopes Available From the Device
        case GetScopes
        /// Get the Device DNS Settings
        case GetDNS
        /// Get the Device NTP (Time Server) Settings
        case GetNTP
        /// Get the Device Dynamic DNS Service Settings
        case GetDynamicDNS
        /// Get Information About the Device Network Interfaces
        case GetNetworkInterfaces
        /// Get the network protocols configurations.
        case GetNetworkProtocols
        /// Get the default gateway[s] for the network.
        case GetNetworkDefaultGateway
        /// Get Dot11 (WiFi) Capabilities
        case GetDot11Capabilities
        /// Get Dot11 (WiFi) Status
        case GetDot11Status

        /// Set a New Hostname for the Device
        case SetHostname
        /// Enable Hostname From DHCP Server
        case SetHostnameFromDHCP
        /// Set the Device DNS Settings
        case SetDNS
        /// Set the Device NTP Settings
        case SetNTP
        /// Set the Dynamic DNS Service Settings.
        case SetDynamicDNS
        /// Set a network interface configuration.
        case SetNetworkInterfaces
        /// Set the network protocols configuration.
        case SetNetworkProtocols
        /// Set the default gateway[s] for the network.
        case SetNetworkDefaultGateway

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
            case .GetServices, .SetHostname, .SetHostnameFromDHCP, .SetDNS, .SetNTP, .SetDynamicDNS, .SetNetworkInterfaces, .SetNetworkProtocols, .SetNetworkDefaultGateway:
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
            return .GetServiceCapabilities == self || .GetCapabilities == self || .GetServices == self || .GetNetworkInterfaces == self
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
     - parameter soapEngine: The SOAPEngine object that executed the request. This can be nil
     - returns: the parsed DNS record, or nil, if there was an error.
     */
    private func _parseDynamicDNSRecord(_ inResponseDictionary: [String: Any], soapRequest inSOAPRequest: String, soapEngine inSOAPEngine: SOAPEngine?) -> DynamicDNSRecord! {
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
     - parameter soapEngine: The SOAPEngine object that executed the request. This can be nil.
     - returns: the parsed DNS record, or nil, if there was an error.
     */
    private func _parseDNSRecord(_ inResponseDictionary: [String: Any], soapRequest inSOAPRequest: String, soapEngine inSOAPEngine: SOAPEngine?) -> RVS_ONVIF_Core.DNSRecord! {
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
     - parameter soapEngine: The SOAPEngine object that executed the request. This can be nil.
     - returns: the parsed NTP record, or nil, if there was an error.
     */
    private func _parseNTPRecord(_ inResponseDictionary: [String: Any], soapRequest inSOAPRequest: String, soapEngine inSOAPEngine: SOAPEngine?) -> RVS_ONVIF_Core.NTPRecord! {
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
        if let ext = _parseNetworkInterfaceExtension(networkCapabilities) {
            print("Extension: \(String(describing: ext))")
        }
        
        #if DEBUG
            print("\tDNetwork Services Capabilities Info: \(ret)")
        #endif

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
        
        #if DEBUG
            print("\tSecurity Service Capabilities Info: \(ret)")
        #endif

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
        
        #if DEBUG
            print("\tSystem Service Capabilities Info: \(ret)")
        #endif

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
    internal func _parseDeviceCapabilitiesDictionary(_ inCapabilitiesDictionary: [String: Any]) -> Capabilities {
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
    internal func _parseServiceCapabilitiesDictionary(_ inResponseDictionary: [String: Any]) -> ServiceCapabilities {
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
        
        #if DEBUG
            print("\tService Capabilities Info: \(ret)")
        #endif

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
    internal func _parseServicesDictionary(_ inResponseDictionary: [String: Any]) -> [Service] {
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
                    var version: String = ""
                    var namespace: String = ""
                    var xAddr = URL(string: "")
                    var capabilities: [String: Any]!

                    if let v = element["Version"] as? [String: Any], let major = owner._parseInteger(v, key: "Major"), let minor = owner._parseInteger(v, key: "Minor") {
                        version = String(format: "%d.%02d", major, minor)
                    }
                    
                    if  let value = owner._parseString(element, key: "XAddr") {
                        xAddr = URL(string: value)
                    }
                    
                    if  let value = owner._parseString(element, key: "Namespace") {
                        namespace = value
                    }
                
                    // We do all this weirdness, because manufacturers can pick and choose how they return their capabilities.
                    if let capabilitiesAny = element["Capabilities"] as? [String: Any], 0 < capabilitiesAny.count {
                        if let capabilitiesAsAttributes = capabilitiesAny["attributes"] as? [String: Any], 0 < capabilitiesAsAttributes.count {
                            capabilities = capabilitiesAsAttributes
                        } else if let capabilitiesAsValues = capabilitiesAny["value"] as? [String: Any], 0 < capabilitiesAsValues.count {
                            if let internalAttributes = capabilitiesAsValues["attributes"] as? [String: Any], 0 < internalAttributes.count {
                                capabilities = internalAttributes
                            } else if let internalValues = capabilitiesAsValues["value"] as? [String: Any], 0 < internalValues.count {
                                capabilities = internalValues
                            } else if 0 < capabilitiesAsValues.count {
                                capabilities = capabilitiesAsValues
                            }
                        } else if let capabilitiesAsValues = capabilitiesAny["Capabilities"] as? [String: Any], 0 < capabilitiesAsValues.count {
                            print(String(describing: capabilitiesAsValues))
                            if let internalAttributes = capabilitiesAsValues["attributes"] as? [String: Any], 0 < internalAttributes.count {
                                capabilities = internalAttributes
                            } else if let internalValues = capabilitiesAsValues["value"] as? [String: Any], 0 < internalValues.count {
                                capabilities = internalValues
                            } else if 0 < capabilitiesAsValues.count {
                                capabilities = capabilitiesAsValues
                            }
                        } else {
                            capabilities = capabilitiesAny
                        }
                    }
                        
                    ret.append(Service(owner: self.owner, namespace: namespace, xAddr: xAddr, version: version, capabilities: capabilities))
                }
            }
        }
        
        #if DEBUG
            print("\tServices Info: \(ret)")
        #endif

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
    internal func _parseScopesDictionary(_ inResponseDictionary: [String: Any]) -> [Scope] {
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
        
        #if DEBUG
            print("\tScopes Info: \(ret)")
        #endif

        return ret
    }
    
    /* ############################################################################################################################## */
    // MARK: - GetNetworkProtocols Parser
    /* ############################################################################################################################## */
    /* ################################################################## */
    /**
     This parses the response from the GetNetworkProtocols command.
     
     - parameter inResponseDictionary: The Dictionary containing the partially-parsed response from SOAPEngine.
     - returns: an Array of NetworkProtocol enum values.
     */
    internal func _parseNetworkProtocolsResponse(_ inResponseDictionary: [String: Any]) -> [NetworkProtocol] {
        #if DEBUG
            print("Parsing the Network Protocols Response: \(String(describing: inResponseDictionary))")
        #endif
        
        var ret: [NetworkProtocol] = []
        
        var outerWrapperArray: [[String: Any]] = []
        
        if let outerWrapperArrayTemp = inResponseDictionary["NetworkProtocols"] as? [[String: Any]] {
            outerWrapperArray = outerWrapperArrayTemp
        } else if let outerWrapperArrayTemp = inResponseDictionary["NetworkProtocols"] as? [String: Any] {
            outerWrapperArray = [outerWrapperArrayTemp]
        }
        
        outerWrapperArray.forEach {
            if  let name = owner._parseString($0, key: "Name"),
                let port = owner._parseInteger($0, key: "Port") {
                let isEnabled = owner._parseBoolean($0, key: "Enabled")
                
                switch name {
                case "HTTP":
                    ret.append(NetworkProtocol.HTTP(port: port, isEnabled: isEnabled))
                case "HTTPS":
                    ret.append(NetworkProtocol.HTTPS(port: port, isEnabled: isEnabled))
                case "RTSP":
                    ret.append(NetworkProtocol.RTSP(port: port, isEnabled: isEnabled))
                default:
                    ()
                }
            }
        }
        
        #if DEBUG
            print("\tNetwork Protocol Info: \(ret)")
        #endif

        return ret
    }
    
    /* ############################################################################################################################## */
    // MARK: - GetNetworkDefaultGateway Parser
    /* ############################################################################################################################## */
    /* ################################################################## */
    /**
     This parses the response from the GetNetworkDefaultGateway command.
     
     - parameter inResponseDictionary: The Dictionary containing the partially-parsed response from SOAPEngine.
     - returns: an Array of RVS_IPAddress values.
     */
    internal func _parseNetworkDefaultGatewayResponse(_ inResponseDictionary: [String: Any]) -> [RVS_IPAddress] {
        #if DEBUG
            print("Parsing the Network Default Gateway Response: \(String(describing: inResponseDictionary))")
        #endif
        
        var ret: [RVS_IPAddress] = []
        
        var outerWrapperArray: [String: String] = [:]
        
        if let outerWrapperArrayTemp = inResponseDictionary["NetworkGateway"] as? [String: String] {
            outerWrapperArray = outerWrapperArrayTemp
        }
        
        outerWrapperArray.forEach {
            if let ipAddress = $0.value.ipAddress {
                ret.append(ipAddress)
            }
        }
        
        #if DEBUG
            print("\tDefault Network Gateway Info: \(ret)")
        #endif

        return ret
    }
    
    /* ############################################################################################################################## */
    // MARK: - GetDot11Capabilities Parser
    /* ############################################################################################################################## */
    /* ################################################################## */
    /**
     This parses the response from the GetDot11Capabilities command.
     
     - parameter inResponseDictionary: The Dictionary containing the partially-parsed response from SOAPEngine.
     - returns: a Dot11Capabilities struct. Nil, if there was a problem
     */
    internal func _parseGetDot11CapabilitiesResponse(_ inResponseDictionary: [String: Any]) -> Dot11Capabilities! {
        #if DEBUG
            print("Parsing the Dot 11 Capabilities Response: \(String(describing: inResponseDictionary))")
        #endif
        
        var outerWrapper: [String: String] = [:]
        
        if let outerWrapperArrayTemp = inResponseDictionary["Capabilities"] as? [String: String] {
            outerWrapper = outerWrapperArrayTemp
        } else if let outerWrapperArrayTemp = inResponseDictionary["Dot11Capabilities"] as? [String: String] {
            outerWrapper = outerWrapperArrayTemp
        }
        
        if  !outerWrapper.isEmpty {
            let tkip = owner._parseBoolean(outerWrapper, key: "TKIP")
            let wep = owner._parseBoolean(outerWrapper, key: "WEP")
            let scanAvailableNetworks = owner._parseBoolean(outerWrapper, key: "ScanAvailableNetworks")
            let multipleConfiguration = owner._parseBoolean(outerWrapper, key: "MultipleConfiguration")
            let adHocStationMode = owner._parseBoolean(outerWrapper, key: "AdHocStationMode")
            
            return Dot11Capabilities(supportsTKIP: tkip, supportsWEP: wep, canScanAvailableNetworks: scanAvailableNetworks, supportsMultipleConfigurations: multipleConfiguration, supportsAdHocStationMode: adHocStationMode)
        }

        return nil
    }
    
    /* ############################################################################################################################## */
    // MARK: - GetDot11Status Parser
    /* ############################################################################################################################## */
    /* ################################################################## */
    /**
     This parses the response from the GetDot11Status command.
     
     - parameter inResponseDictionary: The Dictionary containing the partially-parsed response from SOAPEngine.
     - returns: a Dot11Capabilities struct. Nil, if there was a problem
     */
    internal func _parseGetDot11StatusResponse(_ inResponseDictionary: [String: Any]) -> Dot11Capabilities! {
        #if DEBUG
            print("Parsing the Dot 11 Status Response: \(String(describing: inResponseDictionary))")
        #endif
        return nil
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
    internal func _parseNetworkInterfacesResponse(_ inResponseDictionary: [String: Any]) -> [NetworkInterface] {
        #if DEBUG
            print("Parsing the Network Interfaces Response: \(String(describing: inResponseDictionary))")
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
            let info = _parseNetworkInterfaceInfo($0)
            let link = _parseNetworkInterfaceLink($0)
            let ipv4 = _parseNetworkInterfaceIP($0, key: "IPv4")
            let ipv6 = _parseNetworkInterfaceIP($0, key: "IPv6")
            let networkInterfaceExtension = _parseNetworkInterfaceExtension($0)
            
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
        
        #if DEBUG
            print("\tNetwork Interfaces Info: \(ret)")
        #endif

        return ret
    }
    
    /* ################################################################## */
    /**
     This parses the Info response from the GetNetworkInterfaces command.
     
     - parameter inResponseDictionary: The Dictionary containing the partially-parsed response from SOAPEngine.
     - returns: a NetworkInterfaceInfo instance, or nil (if none)
     */
    internal func _parseNetworkInterfaceInfo(_ inResponseDictionary: [String: Any]) -> NetworkInterfaceInfo! {
        
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
    internal func _parseNetworkInterfaceLink(_ inResponseDictionary: [String: Any]) -> NetworkInterfaceLink! {
        
        if let link = inResponseDictionary["Link"] as? [String: Any] {
            var interfaceType = IANA_Types.other
            
            if let interfaceTypeInt = owner._parseInteger(link, key: "InterfaceType") {
                interfaceType = IANA_Types(rawValue: interfaceTypeInt) ?? .other
            }
            
            let adminSettings = _parseNetworkInterfaceConnectionSetting(link, key: "AdminSettings")
            let operSettings = _parseNetworkInterfaceConnectionSetting(link, key: "OperSettings")
            
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
    internal func _parseNetworkInterfaceConnectionSetting(_ inResponseDictionary: [String: Any], key inKey: String) -> NetworkInterfaceConnectionSetting {
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
    internal func _parseNetworkInterfaceIP(_ inResponseDictionary: [String: Any], key inKey: String) -> IPNetworkInterface! {
        if let ipConfig = inResponseDictionary[inKey] as? [String: Any], let configDict = ipConfig["Config"] as? [String: Any] {
            let isEnabled = owner._parseBoolean(ipConfig, key: "Enabled")
            let config = _parseNetworkInterfaceIPIndividual(configDict, isIPv6: "IPv6" == inKey)
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
    internal func _parseNetworkInterfaceIPIndividual(_ inResponseDictionary: [String: Any], isIPv6 inIsIPv6: Bool = false) -> IPConfiguration {
        let ipv6ConfigurationExtension = inResponseDictionary["Extension"]
        var dhcp: IPConfiguration.IPDHCPConfiguration = .Off
        var isAbleToAcceptRouterAdvert: Bool! = nil
        
        var manual: [IPAddressEntry]! = nil
        var linkLocal: [IPAddressEntry]! = nil
        var fromDHCP: [IPAddressEntry]! = nil
        var fromRA: [IPAddressEntry]! = nil

        if inIsIPv6, let dhcpString = owner._parseString(inResponseDictionary, key: "DHCP") {
            dhcp = IPConfiguration.IPDHCPConfiguration(rawValue: dhcpString.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)) ?? .Off
        } else {
            dhcp = owner._parseBoolean(inResponseDictionary, key: "DHCP") ? .On : .Off
        }
        
        print(String(describing: inResponseDictionary["Manual"]))
        if let manualArray = inResponseDictionary["Manual"] as? [[String: Any]] {
            manual = []
            manualArray.forEach {
                manual.append(_parseIPAddressEntry($0))
            }
        } else if let manualStr = inResponseDictionary["Manual"] as? [String: Any] {
            manual = [_parseIPAddressEntry(manualStr)]
        }
        
        if let linkLocalArray = inResponseDictionary["LinkLocal"] as? [[String: Any]] {
            linkLocal = []
            linkLocalArray.forEach {
                linkLocal.append(_parseIPAddressEntry($0))
            }
        } else if let linkLocalStr = inResponseDictionary["LinkLocal"] as? [String: Any] {
            linkLocal = [_parseIPAddressEntry(linkLocalStr)]
        }
        
        if let fromDHCPArray = inResponseDictionary["FromDHCP"] as? [[String: Any]] {
            fromDHCP = []
            fromDHCPArray.forEach {
                fromDHCP.append(_parseIPAddressEntry($0))
            }
        } else if let fromDHCPStr = inResponseDictionary["FromDHCP"] as? [String: Any] {
            fromDHCP = [_parseIPAddressEntry(fromDHCPStr)]
        }
        
        if let fromRAArray = inResponseDictionary["FromRA"] as? [[String: Any]] {
            fromRA = []
            fromRAArray.forEach {
                fromRA.append(_parseIPAddressEntry($0))
            }
        } else if let fromRAStr = inResponseDictionary["FromRA"] as? [String: Any] {
            fromRA = [_parseIPAddressEntry(fromRAStr)]
        }
        
        if nil != inResponseDictionary["AcceptRouterAdvert"] as? String {
            isAbleToAcceptRouterAdvert = owner._parseBoolean(inResponseDictionary, key: "AcceptRouterAdvert")
        }
        
        return IPConfiguration(isIPv6: inIsIPv6, dhcp: dhcp, manual: manual, linkLocal: linkLocal, fromDHCP: fromDHCP, fromRA: fromRA, isAbleToAcceptRouterAdvert: isAbleToAcceptRouterAdvert, ipv6ConfigurationExtension: ipv6ConfigurationExtension)
    }

    /* ################################################################## */
    /**
     This parses the Extension response from the GetNetworkInterfaces command.
     
     - parameter inResponseDictionary: The Dictionary containing the partially-parsed response from SOAPEngine.
     - returns: an NetworkInterfaceExtension instance (with IPv6 info), or nil (if none)
     */
    internal func _parseNetworkInterfaceExtension(_ inResponseDictionary: [String: Any]) -> NetworkInterfaceExtension! {
        if let networkInterfaceExtension = inResponseDictionary["Extension"] as? [String: Any] {
            #if DEBUG
                print("Parsing the Network Extension Link: \(String(reflecting: networkInterfaceExtension))")
            #endif
            
            if let interfaceTypeInt = owner._parseInteger(networkInterfaceExtension, key: "InterfaceType"), let interfaceType = RVS_ONVIF_Core.IANA_Types(rawValue: interfaceTypeInt) {
                
                return NetworkInterfaceExtension(interfaceType: interfaceType, dot3Configuration: networkInterfaceExtension["Dot3"], dot11: _parseNetworkInterfaceDot11Configuration(networkInterfaceExtension["Dot11"] as? [String: Any]), networkInterfaceSetConfigurationExtension2: networkInterfaceExtension["NetworkInterfaceSetConfigurationExtension2"])
            } else {
                return NetworkInterfaceExtension(interfaceType: .other, dot3Configuration: networkInterfaceExtension["Dot3"], dot11: _parseNetworkInterfaceDot11Configuration(networkInterfaceExtension["Dot11"] as? [String: Any]), networkInterfaceSetConfigurationExtension2: networkInterfaceExtension["NetworkInterfaceSetConfigurationExtension2"])
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
    internal func _parseNetworkInterfaceDot11Configuration(_ inResponseDictionary: [String: Any]!) -> Dot11Configuration! {
        if nil != inResponseDictionary, let ssid = inResponseDictionary["SSID"] as? String, let modeStr = owner._parseString(inResponseDictionary, key: "Mode"), let mode = Dot11Configuration.Dot11StationMode(rawValue: modeStr) {
            let alias = owner._parseString(inResponseDictionary, key: "Alias") ?? ""
            let priority = owner._parseInteger(inResponseDictionary, key: "Priority") ?? 0
            let securityConfiguration = _parseNetworkInterfaceDot11SecurityConfiguration(inResponseDictionary["Security"] as? [String: Any])
            
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
    internal func _parseNetworkInterfaceDot11SecurityConfiguration(_ inResponseDictionary: [String: Any]!) -> Dot11Configuration.Dot11SecurityConfiguration {
        if let modeStr = owner._parseString(inResponseDictionary, key: "Mode"), let mode = Dot11Configuration.Dot11SecurityConfiguration.Dot11SecurityMode(rawValue: modeStr), let algorithmStr = owner._parseString(inResponseDictionary, key: "Algorithm"), let algorithm = Dot11Configuration.Dot11SecurityConfiguration.Dot11Cipher(rawValue: algorithmStr) {
            
            let psk = _parseNetworkInterfaceDot11PSKSet(inResponseDictionary["PSK"] as? [String: Any])
            
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
    internal func _parseNetworkInterfaceDot11PSKSet(_ inResponseDictionary: [String: Any]!) -> Dot11Configuration.Dot11SecurityConfiguration.Dot11PSKSet! {
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
    internal func _parseIPAddressEntry(_ inResponseDictionary: [String: Any]) -> IPAddressEntry {
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
    
    /* ################################################################## */
    /**
     This is the cache for the device network protocol information. It is filled at initialization time.
     */
    public var networkProtocols: [NetworkProtocol]!
    
    /* ################################################################## */
    /**
     This is the cache for the default network gateways information. It is filled at initialization time.
     */
    public var networkDefaultGateways: [RVS_IPAddress]!
    
    /* ################################################################## */
    /**
     This is the cache for the device's Dot 11 (WiFi) capabilities. It is filled at initialization time.
     */
    public var dot11Capabilities: Dot11Capabilities!

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
            case .GetDeviceInformation,
                 .GetScopes,
                 .GetServices,
                 .GetCapabilities,
                 .GetServiceCapabilities,
                 .GetNetworkInterfaces,
                 .GetNetworkProtocols,
                 .GetNetworkDefaultGateway,
                 .GetDot11Capabilities:
                break
                
            case .GetDynamicDNS, .SetDynamicDNS:    // Only supplied if the device supports DynDNS.
                if serviceCapabilities.networkCapabilities.isDynDNS {
                    ret.append($0)
                }

            case .SetHostnameFromDHCP:  // Only supplied if we have the capability in our services configuration.
                if serviceCapabilities.networkCapabilities.isHostnameFromDHCP {
                    ret.append($0)
                }
                
            case .GetDot11Status:   // Only if we have WiFi available.
                if hasWiFi {
                    ret.append($0)
                }

            default:
                ret.append($0)
            }
        }
        
        return ret
    }
    
    /* ############################################################## */
    /**
     i returns: true, if this device has WiFi capabilities.
     */
    public var hasWiFi: Bool {
        if let hasWiFi = capabilities?.hasWiFi {
            return hasWiFi
        }
        
        return false
    }

    /* ################################################################################################################################## */
    // MARK: - Public Callback Handler Instance Method
    /* ################################################################################################################################## */
    /* ################################################################## */
    /**
     This is called upon a successful SOAP call. It must be public, because the protocol is public, but it will only be used internally.

     - parameter inResponseDictionary: The Dictionary ([String: Any]) of the response data.
     - parameter soapRequest: The SOAP request object call, as a String
     - parameter soapEngine: The SOAPEngine object that executed the request. This can be nil.
     - returns: true, if the callback was handled (including as an error).
     */
    public func callbackHandler(_ inResponseDictionary: [String: Any], soapRequest inSOAPRequest: String, soapEngine inSOAPEngine: SOAPEngine?) -> Bool {
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
     
     This contains simple response handlers to "set" commands, as well as a couple more "get" commands.
     
     - parameter inResponseDictionary: The Dictionary ([String: Any]) of the response data.
     - parameter soapRequest: The SOAP request object call, as a String
     - parameter soapEngine: The SOAPEngine object that executed the request. This can be nil.
     - returns: true, if the callback was handled (including as an error).
     */
    internal func _callbackHandlerPartDeux(_ inResponseDictionary: [String: Any], soapRequest inSOAPRequest: String, soapEngine inSOAPEngine: SOAPEngine?) -> Bool {
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
             _DeviceRequest.SetNetworkInterfaces.soapAction,
             _DeviceRequest.SetNetworkProtocols.soapAction,
             _DeviceRequest.SetDynamicDNS.soapAction,
             _DeviceRequest.SetNetworkDefaultGateway.soapAction:
            // Make sure to strip off any namespace tag.
            var commandString = inSOAPRequest
            if let colonIndex = inSOAPRequest.firstIndex(of: ":") {
                commandString = String(inSOAPRequest[inSOAPRequest.index(after: colonIndex)...])
            }
            // Create the approriate request enum case for the command.
            if  let request = _DeviceRequest(rawValue: commandString),
                !(owner.delegate?.onvifInstance(owner, rawDataPreview: inResponseDictionary, deviceRequest: request) ?? false) {
                owner.dispatchers.forEach {
                    if $0.isAbleToHandleThisCommand(request) {
                        if  let responseDict = inResponseDictionary["SetNetworkInterfacesResponse"] as? [String: Any],
                            let response = responseDict["RebootNeeded"] as? String {
                            let rebootNeededResponse: [String: Bool] = ["RebootNeeded": "true" == response.lowercased()]
                            $0.deliverResponse(request, params: rebootNeededResponse)
                        } else {
                            $0.deliverResponse(request, params: nil)
                        }
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
     This just ties things up, and calls the delegate to say we're done.
     */
    internal func _wrapUp() {
        owner._setUpProfileHandlers()   // We ask our handler to establish its profile handlers, based on our available services.
        
        // Let the delegate know that we're finally ready.
        owner.delegate?.onvifInstanceInitialized(owner)
    }
    
    /* ################################################################## */
    /**
     This is an overflow handler, to reduce CC.
     
     This contains all of the initial calls that are made upon initialization, in the order they are made.
     These calls do not call the preview callback.
     
     - parameter inResponseDictionary: The Dictionary ([String: Any]) of the response data.
     - parameter soapRequest: The SOAP request object call, as a String
     - parameter soapEngine: The SOAPEngine object that executed the request. This can be nil.
     - returns: true, if the callback was handled (including as an error).
     */
    internal func _callbackHandlerPartTroix(_ inResponseDictionary: [String: Any], soapRequest inSOAPRequest: String, soapEngine inSOAPEngine: SOAPEngine?) -> Bool {
        switch inSOAPRequest {
        case _DeviceRequest.GetDeviceInformation.soapAction:    // First, we get the initial device information call.
            guard let deviceInfo = inResponseDictionary["GetDeviceInformationResponse"] as? [String: Any] else {
                owner._errorCallback(RVS_ONVIF.RVS_Fault(faultCode: .UnknownSOAPError(error: nil)), soapRequest: inSOAPRequest, soapEngine: inSOAPEngine)
                break
            }
            
            deviceInformation = deviceInfo
            
            owner.performRequest(_DeviceRequest.GetServices, params: ["IncludeCapability": "true"]) // Cascade to get the services.
            
        case _DeviceRequest.GetServices.soapAction: // Get the ONVIF services for the device.
            let serviceArray = _parseServicesDictionary(inResponseDictionary)
            // Load up our cache.
            services = [:]
            serviceArray.forEach { [unowned self] in    // We do this, so that it's easy to look up a service by its namespace.
                self.services[$0.namespace] = $0
            }
            
            owner.performRequest(_DeviceRequest.GetServiceCapabilities) // Cascade to get the service capabilities.
            
        case _DeviceRequest.GetServiceCapabilities.soapAction:  // Get the service capabilities.
            let returnedCapabilities: ServiceCapabilities = _parseServiceCapabilitiesDictionary(inResponseDictionary)
            serviceCapabilities = returnedCapabilities
            owner.performRequest(_DeviceRequest.GetScopes)  // Cascade to get the scopes.
            
        case _DeviceRequest.GetScopes.soapAction:   // Get the device scopes.
            // We do one extra unwind here, to reduce the CC of the parser method.
            guard let mainResponse = inResponseDictionary["GetScopesResponse"] as? [String: Any] else {
                owner._errorCallback(RVS_ONVIF.RVS_Fault(faultCode: .UnknownSOAPError(error: nil)), soapRequest: inSOAPRequest, soapEngine: inSOAPEngine)
                break
            }
            
            scopes = _parseScopesDictionary(mainResponse)
            owner.performRequest(_DeviceRequest.GetNetworkInterfaces)    // Cascade to get the device network interfaces.
            
        case _DeviceRequest.GetNetworkInterfaces.soapAction:
            // We do one extra unwind here, to reduce the CC of the parser method.
            guard let mainResponse = inResponseDictionary["GetNetworkInterfacesResponse"] as? [String: Any] else {
                owner._errorCallback(RVS_ONVIF.RVS_Fault(faultCode: .UnknownSOAPError(error: nil)), soapRequest: inSOAPRequest, soapEngine: inSOAPEngine)
                break
            }
            
            networkInterfaces = _parseNetworkInterfacesResponse(mainResponse)
            owner.performRequest(_DeviceRequest.GetNetworkProtocols)    // Cascade to get the network protocols.
            
        case _DeviceRequest.GetNetworkProtocols.soapAction:
            // We do one extra unwind here, to reduce the CC of the parser method.
            guard let mainResponse = inResponseDictionary["GetNetworkProtocolsResponse"] as? [String: Any] else {
                owner._errorCallback(RVS_ONVIF.RVS_Fault(faultCode: .UnknownSOAPError(error: nil)), soapRequest: inSOAPRequest, soapEngine: inSOAPEngine)
                break
            }
            
            networkProtocols = _parseNetworkProtocolsResponse(mainResponse)
            owner.performRequest(_DeviceRequest.GetNetworkDefaultGateway)    // Cascade to get the device default gateways.
            
        case _DeviceRequest.GetNetworkDefaultGateway.soapAction:
            guard let mainResponse = inResponseDictionary["GetNetworkDefaultGatewayResponse"] as? [String: Any] else {
                owner._errorCallback(RVS_ONVIF.RVS_Fault(faultCode: .UnknownSOAPError(error: nil)), soapRequest: inSOAPRequest, soapEngine: inSOAPEngine)
                break
            }
            
            networkDefaultGateways = _parseNetworkDefaultGatewayResponse(mainResponse)
            owner.performRequest(_DeviceRequest.GetCapabilities)    // Cascade to get the device capabilities.

        case _DeviceRequest.GetCapabilities.soapAction:
            // We do one extra unwind here, to reduce the CC of the parser method.
            guard let mainResponse = inResponseDictionary["GetCapabilitiesResponse"] as? [String: Any], let capabilitiesResponse = mainResponse["Capabilities"] as? [String: Any] else {
                owner._errorCallback(RVS_ONVIF.RVS_Fault(faultCode: .UnknownSOAPError(error: nil)), soapRequest: inSOAPRequest, soapEngine: inSOAPEngine)
                break
            }
            
            capabilities = _parseDeviceCapabilitiesDictionary(capabilitiesResponse)
            // We only look for dot 11 capabilities if the capabilities say we have it.
            if !hasWiFi {
                _wrapUp()
            } else {
                owner.performRequest(_DeviceRequest.GetDot11Capabilities)    // Cascade to get the device capabilities.
            }

        default:    // If we don't recognize the call we made, we go on to the next batch of commands.
            return _callbackHandlerPartFo(inResponseDictionary, soapRequest: inSOAPRequest, soapEngine: inSOAPEngine)
        }
        
        return true
    }
    
    /* ################################################################## */
    /**
     This is an overflow handler, to reduce CC.
     This method handles the "only if we have WiFi" stuff.
     
     This contains all of the initial calls that are made upon initialization, in the order they are made.
     These calls do not call the preview callback.
     
     - parameter inResponseDictionary: The Dictionary ([String: Any]) of the response data.
     - parameter soapRequest: The SOAP request object call, as a String
     - parameter soapEngine: The SOAPEngine object that executed the request. This can be nil.
     - returns: true, if the callback was handled (including as an error).
     */
    internal func _callbackHandlerPartFo(_ inResponseDictionary: [String: Any], soapRequest inSOAPRequest: String, soapEngine inSOAPEngine: SOAPEngine?) -> Bool {
        switch inSOAPRequest {
        case _DeviceRequest.GetDot11Capabilities.soapAction:
            guard let mainResponse = inResponseDictionary["GetDot11CapabilitiesResponse"] as? [String: Any] else {
                owner._errorCallback(RVS_ONVIF.RVS_Fault(faultCode: .UnknownSOAPError(error: nil)), soapRequest: inSOAPRequest, soapEngine: inSOAPEngine)
                break
            }
            
            dot11Capabilities = _parseGetDot11CapabilitiesResponse(mainResponse)
            _wrapUp()
        
            // Ask the device for its
        case _DeviceRequest.GetDot11Status.soapAction:
            guard let mainResponse = inResponseDictionary["GetDot11StatusResponse"] as? [String: Any] else {
                owner._errorCallback(RVS_ONVIF.RVS_Fault(faultCode: .UnknownSOAPError(error: nil)), soapRequest: inSOAPRequest, soapEngine: inSOAPEngine)
                break
            }
            
            // We give the caller the opportunity to vet the data. Default just passes through.
            if !(owner.delegate?.onvifInstance(owner, rawDataPreview: inResponseDictionary, deviceRequest: _DeviceRequest.GetDot11Status) ?? false) {
                owner.dispatchers.forEach {
                    if $0.isAbleToHandleThisCommand(_DeviceRequest.GetDot11Status) {
                        $0.deliverResponse(_DeviceRequest.GetDot11Status, params: _parseGetDot11StatusResponse(mainResponse))
                    }
                }
            }
            
        default:    // If we don't recognize the call we made, we drop out.
            return false
        }
        
        return true
    }
}
