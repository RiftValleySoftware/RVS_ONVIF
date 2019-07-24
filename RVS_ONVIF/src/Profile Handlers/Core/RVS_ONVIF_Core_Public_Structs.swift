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
 These are the public structs, used to provide the core data to the delegate.
 */
extension RVS_ONVIF_Core {
    /* ################################################################################################################################## */
    // MARK: - Public Structs
    /* ################################################################################################################################## */
    /**
     This protocol will allow scopes to hold ancillary information, which is used when parsing them.
     */
    public struct Scope: OwnedInstanceProtocol {
        /* ###################################################################################################################################### */
        /**
         This enum designates the various profiles.
         */
        public enum ProfileType {
            /// The profile type is unknown (Should never happen).
            case Unknown(String)
            /// Core profile (implicit)
            case Core(String)
            /// Profile G (Recording)
            case G(String)
            /// Profile Q (Easy Setup)
            case Q(String)
            /// Profile S (Streaming)
            case S(String)
            /// Profile T (Advanced Streaming)
            case T(String)

            /* ############################################################## */
            /**
             This allows us to compare without taking the associated values into consideration.
             */
            public static func == (lhs: ProfileType, rhs: ProfileType) -> Bool {
                switch (lhs, rhs) {
                case (.Unknown, .Unknown),
                     (.Core, .Core),
                     (.G, .G),
                     (.Q, .Q),
                     (.S, .S),
                     (.T, .T):
                    return true
                default:
                    return false
                }
            }
        }

        /* ############################################################## */
        /**
         This enumerates our various scope categories.
         */
        public enum Category {
            /// This enumerates a profile. The associated value is the profile type.
            case Profile(ProfileType)
            /// The location defines the physical location of the device. The location value might be any string describing the physical location of the device.
            case Location(String)
            /// A string or path value describing the hardware of the device. A device shall include at least one hardware entry into its scope list.
            case Hardware(String)
            /// The searchable name of the device. A device shall include at least one name entry into its scope list.
            case Name(String)
            /// Device manufacturer's "Junk Drawer." The name of the scope, as well as its value, are provided.
            case Custom(name: String, value: String)
        }
        
        /* ############################################################## */
        /**
         This is us.
         */
        public let owner: RVS_ONVIF!
        /* ############################################################## */
        /**
         True, if the scope is configurable.
         */
        public let isConfigurable: Bool
        /* ############################################################## */
        /**
         The scope, as a ScopeCategory.
         */
        public let category: Category
    }
    
    /* ###################################################################################################################################### */
    /**
     This struct is the response from the GetDNS command.
     */
    public struct DNSRecord: OwnedInstanceProtocol {
        /* ############################################################## */
        /**
         This is us.
         */
        public let owner: RVS_ONVIF!
        /* ############################################################## */
        /**
         This is the search domain string.
         */
        public let searchDomain: [String]
        /* ############################################################## */
        /**
         This is true, if it came from a DHCP server.
         */
        public let isFromDHCP: Bool
        /* ############################################################## */
        /**
         This is an array of IP addresses. They can be either IPv4 or IPv6.
         */
        public let addresses: [RVS_IPAddress]
        /* ############################################################## */
        /**
         This is the structure, as sendable parameters in the appropriate namespace[s].
         */
        public var asParameters: [String: Any]! {
            var params: [String: Any] = [:]
            
            params["trt:FromDHCP"] = isFromDHCP ? "true" : "false"
            
            if !searchDomain.isEmpty {
                params["trt:SearchDomain"] = searchDomain
            }
            
            if !addresses.isEmpty {
                var ips: [[String: String]] = []
                for ip in addresses where ip.isValidAddress {
                    let type = ip.isV6 ? "IPv6" : "IPv4"
                    let key = type + "Address"
                    let val: [String: String] = ["Type": type, key: ip.address]
                    ips.append(val)
                }
                
                params["trt:DNSManual"] = ips
            }
            
            return params
        }

        /* ############################################################## */
        /**
         We declare this, because we need it to be public.
         
         - parameter owner: The ONVIF handler instance that "owns" this struct instance.
         - parameter searchDomain: An Array of String, that contains one or more search domains.
         - parameter isFromDHCP: True, if the DNS should be assigned by DHCP
         - parameter addresses: An Array of IP addresses (as special String extension embedded classes) to be used for manual DNS.
         */
        public init(owner inOwner: RVS_ONVIF, searchDomain inSearchDomain: [String], isFromDHCP inIsFromDHCP: Bool, addresses inAddresses: [RVS_IPAddress]) {
            owner = inOwner
            searchDomain = inSearchDomain
            isFromDHCP = inIsFromDHCP
            addresses = inAddresses
        }
    }
    
    /* ###################################################################################################################################### */
    /**
     This struct is the response from the GetDynamicDNS command.
     */
    public struct DynamicDNSRecord: OwnedInstanceProtocol {
        /**
         An internal enum that is used to define the type of dynamic DNS service.
         */
        public enum DynDNSType: Equatable {
            /// There will be no DynDNS updates from either the client or the server.
            case NoUpdate
            /// The server updates.
            /// - parameter ttl: The time to live, as a DateComponents object.
            case ServerUpdates(ttl: DateComponents!)
            /// The client updtaes.
            /// - parameter name: The name the client will send.
            /// - parameter ttl: The time to live, as a DateComponents object.
            case ClientUpdates(name: String, ttl: DateComponents!)

            /* ############################################################## */
            /**
             This allows us to compare without taking the associated values into consideration.
             */
            public static func == (lhs: DynDNSType, rhs: DynDNSType) -> Bool {
                switch (lhs, rhs) {
                case (.NoUpdate, .NoUpdate), (.ServerUpdates, .ServerUpdates), (.ClientUpdates, .ClientUpdates):
                    return true
                default:
                    return false
                }
            }
            
            /* ############################################################## */
            /**
             */
            public var description: String {
                var ret: String = ""
                switch self {
                case .ClientUpdates(let name, let ttl):
                    ret = "ClientUpdates"
                    if !name.isEmpty {
                        ret += "\n\tName: \(name)"
                    }
                    if let ttl = ttl {
                        ret += "\n\tTTL: \(ttl)"
                    }

                case .ServerUpdates(let ttl):
                    ret = "ServerUpdates"
                    if let ttl = ttl {
                        ret += "\n\tTTL: \(ttl)"
                    }
                    
                case .NoUpdate:
                    ret = "NoUpdate"
                }
                return ret
            }
        }
        
        /* ############################################################## */
        /**
         This is us.
         */
        public let owner: RVS_ONVIF!
        /* ############################################################## */
        /**
         This is the type of dynamic DNS relationship.
         */
        public let type: DynDNSType
        /* ############################################################## */
        /**
         This returns the parameters in a fashion suitable for sending to the device.
         */
        public var asParameters: [String: Any]! {
            var params: [String: Any] = [:]
            switch type {
            case .ServerUpdates(let ttl):
                params["trt:Type"] = "ServerUpdates"
                if nil != ttl {
                    params["trt:TTL"] = ttl?.asXMLDuration
                }
            case .ClientUpdates(let name, let ttl):
                params["trt:Type"] = "ClientUpdates"
                if !name.isEmpty {
                    params["trt:Name"] = name
                }
                if nil != ttl {
                    params["trt:TTL"] = ttl?.asXMLDuration
                }
            case .NoUpdate:
                params["trt:Type"] = "NoUpdate"
            }
            return params
        }

        /* ############################################################## */
        /**
         We declare this, because we need it to be public.
         
         - parameter owner: The ONVIF handler instance that "owns" this struct instance.
         - parameter type: The type of DynDNS
         */
        public init(owner inOwner: RVS_ONVIF, type inType: DynDNSType) {
            owner = inOwner
            type = inType
        }
    }

    /* ###################################################################################################################################### */
    /**
     This struct is the response from the GetNTP command.
     */
    public struct NTPRecord: OwnedInstanceProtocol {
        /* ############################################################## */
        /**
         This is us.
         */
        public let owner: RVS_ONVIF!
        /* ############################################################## */
        /**
         This is true, if it came from a DHCP server.
         */
        public let isFromDHCP: Bool
        /* ############################################################## */
        /**
         This is an array of IP addresses. They can be either IPv4 or IPv6.
         */
        public let addresses: [RVS_IPAddress]
        /* ############################################################## */
        /**
         This is an array of Names (not IP Addresses). These should be valid DNS names, but they are not vetted.
         */
        public let names: [String]
        /* ############################################################## */
        /**
         This returns the parameters in a fashion suitable for sending to the device.
         */
        public var asParameters: [String: Any]! {
            var params: [String: Any] = [:]
            
            params["trt:FromDHCP"] = isFromDHCP ? "true" : "false"
            
            if !addresses.isEmpty || !names.isEmpty {
                var ips: [[String: String]] = []
                for ip in addresses where ip.isValidAddress {
                    let type = ip.isV6 ? "IPv6" : "IPv4"
                    let key = type + "Address"
                    let val: [String: String] = ["Type": type, key: ip.address]
                    ips.append(val)
                }
                
                for name in names {
                    let val: [String: String] = ["Type": "DNS", "DNSname": name]
                    ips.append(val)
                }
                
                params["trt:NTPManual"] = ips
            }
            
            return params
        }
        
        /* ############################################################## */
        /**
         We declare this, because we need it to be public.
         
         - parameter owner: The ONVIF handler instance that "owns" this struct instance.
         - parameter isFromDHCP: True, if the DNS should be assigned by DHCP
         - parameter addresses: An Array of IP addresses (as special String extension embedded classes) to be used for manual DNS.
         */
        public init(owner inOwner: RVS_ONVIF, isFromDHCP inIsFromDHCP: Bool, addresses inAddresses: [RVS_IPAddress], names inNames: [String] = []) {
            owner = inOwner
            isFromDHCP = inIsFromDHCP
            addresses = inAddresses
            names = inNames
        }
    }

    /* ###################################################################################################################################### */
    /**
     This struct describes a single service (response to "fetchServices()")
     */
    public struct Service: OwnedInstanceProtocol {
        /* ############################################################## */
        /**
         This is us.
         */
        public let owner: RVS_ONVIF!
        /* ############################################################## */
        /**
         This is the namespace for the service (usually a URI string).
         */
        public let namespace: String!
        /* ############################################################## */
        /**
         This is the XAddr (a URI).
         */
        public let xAddr: URL!
        /* ############################################################## */
        /**
         This is the Version (a String).
         */
        public let version: String!
        /* ############################################################## */
        /**
         This is the Capabilities. It is optional, and may be nil. If supplied, we return it as a simple Dictionary, to be interpreted by the caller.
         */
        public let capabilities: [String: Any]!
    }

    /* ###################################################################################################################################### */
    /**
     This struct describes all our service capabilities (response to "fetchServiceCapabilities()")
     */
    public struct ServiceCapabilities: OwnedInstanceProtocol {
        /* ############################################################## */
        /**
         This is us.
         */
        public let owner: RVS_ONVIF!
        /* ############################################################## */
        /**
         The various network capabilities for this device.
         */
        public var networkCapabilities: NetworkCapabilities!
        /* ############################################################## */
        /**
         The various security capabilities for this device.
         */
        public var securityCapabilities: SecurityCapabilities!
        /* ############################################################## */
        /**
         The various system capabilities for this device.
         */
        public var systemCapabilities: SystemCapabilities!
        /* ############################################################## */
        /**
         Lists of commands supported by SendAuxiliaryCommand. It is optional, and may be nil.
         */
        public var auxiliaryCommands: [String]!
        
        /* ############################################################## */
        /**
         Simple Initializer that sets our only non-mutable property.
         */
        init(owner inOwner: RVS_ONVIF) {
            owner = inOwner
            networkCapabilities = NetworkCapabilities(owner: inOwner)
            securityCapabilities = SecurityCapabilities(owner: inOwner)
            systemCapabilities = SystemCapabilities(owner: inOwner)
        }
    }

    /* ###################################################################################################################################### */
    /**
     This struct describes a single service network capability
     */
    public struct NetworkCapabilities: OwnedInstanceProtocol {
        /* ############################################################## */
        /**
         This is us.
         */
        public let owner: RVS_ONVIF!
        /* ############################################################## */
        /**
         Indicates support for IP filtering.
         */
        public var isIPFilter: Bool = false
        /* ############################################################## */
        /**
         Indicates support for zeroconf.
         */
        public var isZeroConfiguration: Bool = false
        /* ############################################################## */
        /**
         Indicates support for IPv6.
         */
        public var isIPVersion6: Bool = false
        /* ############################################################## */
        /**
         Indicates support for dynamic DNS configuration.
         */
        public var isDynDNS: Bool = false
        /* ############################################################## */
        /**
         Indicates support for IEEE 802.11 configuration.
         */
        public var isDot11Configuration: Bool = false
        /* ############################################################## */
        /**
         Indicates the maximum number of Dot1X configurations supported by the device. It is optional, and may be nil.
         */
        public var dot1XConfiguration: Int!
        /* ############################################################## */
        /**
         Indicates support for retrieval of hostname from DHCP.
         */
        public var isHostnameFromDHCP: Bool = false
        /* ############################################################## */
        /**
         Maximum number of NTP servers supported by the devices SetNTP command. It is optional, and may be nil.
         */
        public var ntp: Int!
        /* ############################################################## */
        /**
         Indicates support for Stateful IPv6 DHCP.
         */
        public var isDHCPv6: Bool = false
        
        /* ############################################################## */
        /**
         Simple Initializer that sets our only non-mutable property.
         */
        init(owner inOwner: RVS_ONVIF) {
            owner = inOwner
        }
    }

    /* ###################################################################################################################################### */
    /**
     This struct describes a single service security capability
     */
    public struct SecurityCapabilities: OwnedInstanceProtocol {
        /* ############################################################## */
        /**
         This is us.
         */
        public let owner: RVS_ONVIF!
        /* ############################################################## */
        /**
         Indicates support for TLS 1.0.
         */
        public var isTLS10: Bool = false
        /* ############################################################## */
        /**
         Indicates support for TLS 1.1.
         */
        public var isTLS11: Bool = false
        /* ############################################################## */
        /**
         Indicates support for TLS 1.2.
         */
        public var isTLS12: Bool = false
        /* ############################################################## */
        /**
         Indicates support for onboard key generation.
         */
        public var isOnboardKeyGeneration: Bool = false
        /* ############################################################## */
        /**
         Indicates support for access policy configuration.
         */
        public var isAccessPolicyConfig: Bool = false
        /* ############################################################## */
        /**
         Indicates support for the ONVIF default access policy.
         */
        public var isDefaultAccessPolicy: Bool = false
        /* ############################################################## */
        /**
         Indicates support for IEEE 802.1X configuration.
         */
        public var isDot1X: Bool = false
        /* ############################################################## */
        /**
         Indicates support for remote user configuration. Used when accessing another device.
         */
        public var isRemoteUserHandling: Bool = false
        /* ############################################################## */
        /**
         Indicates support for WS-Security X.509 token.
         */
        public var isX509Token: Bool = false
        /* ############################################################## */
        /**
         Indicates support for WS-Security SAML token.
         */
        public var isSAMLToken: Bool = false
        /* ############################################################## */
        /**
         Indicates support for WS-Security Kerberos token.
         */
        public var isKerberosToken: Bool = false
        /* ############################################################## */
        /**
         Indicates support for WS-Security Username token.
         */
        public var isUsernameToken: Bool = false
        /* ############################################################## */
        /**
         Indicates support for WS over HTTP digest authenticated communication layer.
         */
        public var isHttpDigest: Bool = false
        /* ############################################################## */
        /**
         Indicates support for WS-Security REL token.
         */
        public var isRELToken: Bool = false
        /* ############################################################## */
        /**
         EAP Methods supported by the device. The int values refer to the IANA EAP Registry (http://www.iana.org/assignments/eap-numbers/eap-numbers.xhtml). It is optional, and may be nil.
         */
        public var supportedEAPMethods: [Int]!
        /* ############################################################## */
        /**
         The maximum number of users that the device supports. It is optional, and may be nil.
         */
        public var maxUsers: Int!
        /* ############################################################## */
        /**
         Maximum number of characters supported for the username by CreateUsers. It is optional, and may be nil.
         */
        public var maxUserNameLength: Int!
        /* ############################################################## */
        /**
         Maximum number of characters supported for the password by CreateUsers and SetUser. It is optional, and may be nil.
         */
        public var maxPasswordLength: Int!
        
        /* ############################################################## */
        /**
         Simple Initializer that sets our only non-mutable property.
         */
        init(owner inOwner: RVS_ONVIF) {
            owner = inOwner
        }
    }

    /* ###################################################################################################################################### */
    /**
     This struct describes a single service system capability
     */
    public struct SystemCapabilities: OwnedInstanceProtocol {
        /* ############################################################## */
        /**
         This is us.
         */
        public let owner: RVS_ONVIF!
        /* ############################################################## */
        /**
         Indicates support for WS Discovery resolve requests.
         */
        public var isDiscoveryResolve: Bool = false
        /* ############################################################## */
        /**
         Indicates support for WS-Discovery Bye.
         */
        public var isDiscoveryBye: Bool = false
        /* ############################################################## */
        /**
         Indicates support for remote discovery.
         */
        public var isRemoteDiscovery: Bool = false
        /* ############################################################## */
        /**
         Indicates support for system backup through MTOM.
         */
        public var isSystemBackup: Bool = false
        /* ############################################################## */
        /**
         Indicates support for retrieval of system logging through MTOM.
         */
        public var isSystemLogging: Bool = false
        /* ############################################################## */
        /**
         Indicates support for firmware upgrade through MTOM.
         */
        public var isFirmwareUpgrade: Bool = false
        /* ############################################################## */
        /**
         Indicates support for firmware upgrade through HTTP.
         */
        public var isHttpFirmwareUpgrade: Bool = false
        /* ############################################################## */
        /**
         Indicates support for system backup through HTTP.
         */
        public var isHttpSystemBackup: Bool = false
        /* ############################################################## */
        /**
         Indicates support for retrieval of system logging through HTTP.
         */
        public var isHttpSystemLogging: Bool = false
        /* ############################################################## */
        /**
         Indicates support for retrieving support information through HTTP.
         */
        public var isHttpSupportInformation: Bool = false
        /* ############################################################## */
        /**
         Indicates support for storage configuration interfaces.
         */
        public var isStorageConfiguration: Bool = false
        /* ############################################################## */
        /**
         Indicates maximum number of storage configurations supported. It is optional, and may be nil.
         */
        public var maxStorageConfigurations: Int!
        /* ############################################################## */
        /**
         If present, signals support for geo location. The value signals the supported number of entries. It is optional, and may be nil.
         */
        public var geoLocationEntries: Int!
        /* ############################################################## */
        /**
         List of supported automatic GeoLocation adjustments supported by the device. Valid items are defined by tds:AutoGeoMode. It is optional, and may be nil.
         */
        public var autoGeo: [String]!
        /* ############################################################## */
        /**
         Enumerates the supported StorageTypes, see ("NFS", "CIFS", "CDMI" or "FTP"). It is optional, and may be nil.
         */
        public var storageTypesSupported: [String]!
        
        /* ############################################################## */
        /**
         Simple Initializer that sets our only non-mutable property.
         */
        init(owner inOwner: RVS_ONVIF) {
            owner = inOwner
        }
    }

    /* ###################################################################################################################################### */
    /**
     This struct describes all our capabilities (response to "fetchDeviceCapabilities()")
     */
    public struct Capabilities: OwnedInstanceProtocol {
        /* ############################################################## */
        /**
         This is us.
         */
        public let owner: RVS_ONVIF!
        /* ############################################################## */
        /**
         The various analytics capabilities for this device.
         */
        public var analyticsCapabilities: AnalyticsCapabilities!
        /* ############################################################## */
        /**
         The Analytics Device capabilities for this device.
         */
        public var analyticsDeviceCapabilities: AnalyticsDeviceCapabilities!
        /* ############################################################## */
        /**
         The various device capabilities for this device.
         */
        public var deviceCapabilities: DeviceCapabilities!
        /* ############################################################## */
        /**
         The Device I/O capabilities for this device.
         */
        public var deviceIOCapabilities: InternalDeviceIOCapabilities!
        /* ############################################################## */
        /**
         The Display capabilities for this device.
         */
        public var displayCapabilities: DisplayCapabilities!
        /* ############################################################## */
        /**
         The events capabilities for this device.
         */
        public var eventsCapabilities: EventsCapabilities!
        /* ############################################################## */
        /**
         The imaging capabilities for this device.
         */
        public var imagingCapabilities: ImagingCapabilities!
        /* ############################################################## */
        /**
         The media capabilities for this device.
         */
        public var mediaCapabilities: MediaCapabilities!
        /* ############################################################## */
        /**
         The PTZ capabilities for this device.
         */
        public var ptzCapabilities: PTZCapabilities!
        /* ############################################################## */
        /**
         The Receiver capabilities for this device.
         */
        public var receiverCapabilities: ReceiverCapabilities!
        /* ############################################################## */
        /**
         The Recording capabilities for this device.
         */
        public var recordingCapabilities: RecordingCapabilities!
        /* ############################################################## */
        /**
         The Replay capabilities for this device.
         */
        public var replayCapabilities: ReplayCapabilities!
        /* ############################################################## */
        /**
         The Search capabilities for this device.
         */
        public var searchCapabilities: SearchCapabilities!
        
        /* ############################################################## */
        /**
         Simple Initializer that sets our only non-mutable property.
         */
        init(owner inOwner: RVS_ONVIF) {
            owner = inOwner
        }
    }

    /* ###################################################################################################################################### */
    /**
     This struct describes the analytics Capabilities
     */
    public struct AnalyticsCapabilities: OwnedInstanceProtocol {
        /* ############################################################## */
        /**
         This is us.
         */
        public let owner: RVS_ONVIF!
        /* ############################################################## */
        /**
         This is the URL for the XAddr.
         */
        public var xAddr: URL!
        /* ############################################################## */
        /**
         Indication if the device supports rules interface and rules syntax as specified in the Video Analytics Service Specification.
         */
        public var isRuleSupport: Bool = false
        /* ############################################################## */
        /**
         Indication if the device supports the scene analytics module interface as specified in the Video Analytics Service Specification.
         */
        public var isAnalyticsModuleSupport: Bool = false
        
        /* ############################################################## */
        /**
         Simple Initializer that sets our only non-mutable property.
         */
        init(owner inOwner: RVS_ONVIF) {
            owner = inOwner
        }
    }

    /* ###################################################################################################################################### */
    /**
     This struct describes our Analytics Device capabilities
     */
    public struct AnalyticsDeviceCapabilities: OwnedInstanceProtocol {
        /* ############################################################## */
        /**
         This is us.
         */
        public let owner: RVS_ONVIF!
        /* ############################################################## */
        /**
         This is the URL for the XAddr.
         */
        public var xAddr: URL!
        
        /* ############################################################## */
        /**
         Simple Initializer that sets our only non-mutable property.
         */
        init(owner inOwner: RVS_ONVIF) {
            owner = inOwner
        }
    }

    /* ###################################################################################################################################### */
    /**
     This struct describes all our device capabilities (devices response to "fetchDeviceCapabilities()")
     */
    public struct DeviceCapabilities: OwnedInstanceProtocol {
        /* ############################################################## */
        /**
         This is us.
         */
        public let owner: RVS_ONVIF!
        /* ############################################################## */
        /**
         This is the URL for the XAddr.
         */
        public var xAddr: URL!
        /* ############################################################## */
        /**
         The various network capabilities for this device.
         */
        public var networkCapabilities: NetworkCapabilities!
        /* ############################################################## */
        /**
         The various system capabilities for this device.
         */
        public var systemCapabilities: SystemCapabilities!
        /* ############################################################## */
        /**
         The various IO capabilities for this device.
         */
        public var ioCapabilities: DeviceIOCapabilities!
        /* ############################################################## */
        /**
         The various security capabilities for this device.
         */
        public var securityCapabilities: SecurityCapabilities!
        
        /* ############################################################## */
        /**
         Simple Initializer that sets our only non-mutable property.
         */
        init(owner inOwner: RVS_ONVIF) {
            owner = inOwner
            
            networkCapabilities = NetworkCapabilities(owner: inOwner)
            systemCapabilities = SystemCapabilities(owner: inOwner)
            ioCapabilities = DeviceIOCapabilities(owner: inOwner)
            securityCapabilities = SecurityCapabilities(owner: inOwner)
        }
    }

    /* ###################################################################################################################################### */
    /**
     This struct describes a single I/O capability for the Device Capabilities
     */
    public struct DeviceIOCapabilities: OwnedInstanceProtocol {
        /* ############################################################## */
        /**
         This is us.
         */
        public let owner: RVS_ONVIF!
        /* ############################################################## */
        /**
         The number of input connectors
         */
        public var inputConnectors: Int!
        /* ############################################################## */
        /**
         The number of relay outputs
         */
        public var relayOutputs: Int!
        /* ############################################################## */
        /**
         Indication of support for auxiliary service along with list of supported auxiliary commands
         */
        public var auxiliary: String!
        
        /* ############################################################## */
        /**
         Simple Initializer that sets our only non-mutable property.
         */
        init(owner inOwner: RVS_ONVIF) {
            owner = inOwner
        }
    }

    /* ###################################################################################################################################### */
    /**
     This struct describes our Display capabilities
     */
    public struct DisplayCapabilities: OwnedInstanceProtocol {
        /* ############################################################## */
        /**
         This is us.
         */
        public let owner: RVS_ONVIF!
        /* ############################################################## */
        /**
         This is the URL for the XAddr.
         */
        public var xAddr: URL!
        /* ############################################################## */
        /**
         Indication that the SetLayout command supports only predefined layouts..
         */
        public var isFixedLayout: Bool = false
        
        /* ############################################################## */
        /**
         Simple Initializer that sets our only non-mutable property.
         */
        init(owner inOwner: RVS_ONVIF) {
            owner = inOwner
        }
    }

    /* ###################################################################################################################################### */
    /**
     This struct describes the events Capabilities
     */
    public struct EventsCapabilities: OwnedInstanceProtocol {
        /* ############################################################## */
        /**
         This is us.
         */
        public let owner: RVS_ONVIF!
        /* ############################################################## */
        /**
         This is the URL for the XAddr.
         */
        public var xAddr: URL!
        /* ############################################################## */
        /**
         Indication if the device supports the WS Subscription policy according to Section 9.3.2
         */
        public var isWSSubscriptionPolicySupport: Bool = false
        /* ############################################################## */
        /**
         Indication if the device supports the WS Pull Point according to Section 9.3.2
         */
        public var isWSPullPointSupport: Bool = false
        /* ############################################################## */
        /**
         Indication if the device supports the WS Pausable Subscription Manager Interface according to Section 9.3.2
         */
        public var isWSPausableSubscriptionManagerInterfaceSupport: Bool = false
        
        /* ############################################################## */
        /**
         Simple Initializer that sets our only non-mutable property.
         */
        init(owner inOwner: RVS_ONVIF) {
            owner = inOwner
        }
    }

    /* ###################################################################################################################################### */
    /**
     This struct describes our imaging capabilities
     */
    public struct ImagingCapabilities: OwnedInstanceProtocol {
        /* ############################################################## */
        /**
         This is us.
         */
        public let owner: RVS_ONVIF!
        /* ############################################################## */
        /**
         This is the URL for the XAddr.
         */
        public var xAddr: URL!
        
        /* ############################################################## */
        /**
         Simple Initializer that sets our only non-mutable property.
         */
        init(owner inOwner: RVS_ONVIF) {
            owner = inOwner
        }
    }

    /* ###################################################################################################################################### */
    /**
     This struct describes our Device I/O capabilities
     */
    public struct InternalDeviceIOCapabilities: OwnedInstanceProtocol {
        /* ############################################################## */
        /**
         This is us.
         */
        public let owner: RVS_ONVIF!
        /* ############################################################## */
        /**
         This is the URL for the XAddr.
         */
        public var xAddr: URL!
        /* ############################################################## */
        /**
         The number of video sources.
         */
        public var videoSources: Int!
        /* ############################################################## */
        /**
         The number of video outputs.
         */
        public var videoOutputs: Int!
        /* ############################################################## */
        /**
         The number of audio sources.
         */
        public var audioSources: Int!
        /* ############################################################## */
        /**
         The number of audio outputs.
         */
        public var audioOutputs: Int!
        /* ############################################################## */
        /**
         The number of relay outputs.
         */
        public var relayOutputs: Int!
        
        /* ############################################################## */
        /**
         Simple Initializer that sets our only non-mutable property.
         */
        init(owner inOwner: RVS_ONVIF) {
            owner = inOwner
        }
    }

    /* ###################################################################################################################################### */
    /**
     This struct describes our Media capabilities
     */
    public struct MediaCapabilities: OwnedInstanceProtocol {
        /* ############################################################## */
        /**
         This is us.
         */
        public let owner: RVS_ONVIF!
        /* ############################################################## */
        /**
         This is the URL for the XAddr.
         */
        public var xAddr: URL!
        /* ############################################################## */
        /**
         Indication of support of UDP multicasting as described in the ONVIF Streaming Specification.
         */
        public var isRTPMulticast: Bool = false
        /* ############################################################## */
        /**
         Indication if the device supports RTP over TCP, see ONVIF Streaming Specification.
         */
        public var isRTP_TCP: Bool = false
        /* ############################################################## */
        /**
         Indication if the device supports RTP/RTSP/TCP transport, see ONVIF Streaming Specification.
         */
        public var isRTP_RTSP_TCP: Bool = false
        /* ############################################################## */
        /**
         The maximum Number of MediaProfiles the device supports.
         */
        public var maximumNumberOfProfiles: Int!
        
        /* ############################################################## */
        /**
         Simple Initializer that sets our only non-mutable property.
         */
        init(owner inOwner: RVS_ONVIF) {
            owner = inOwner
        }
    }

    /* ###################################################################################################################################### */
    /**
     This struct describes our PTZ capabilities
     */
    public struct PTZCapabilities: OwnedInstanceProtocol {
        /* ############################################################## */
        /**
         This is us.
         */
        public let owner: RVS_ONVIF!
        /* ############################################################## */
        /**
         This is the URL for the XAddr.
         */
        public var xAddr: URL!
        
        /* ############################################################## */
        /**
         Simple Initializer that sets our only non-mutable property.
         */
        init(owner inOwner: RVS_ONVIF) {
            owner = inOwner
        }
    }

    /* ###################################################################################################################################### */
    /**
     This struct describes our receiver capabilities
     */
    public struct ReceiverCapabilities: OwnedInstanceProtocol {
        /* ############################################################## */
        /**
         This is us.
         */
        public let owner: RVS_ONVIF!
        /* ############################################################## */
        /**
         This is the URL for the XAddr.
         */
        public var xAddr: URL!
        /* ############################################################## */
        /**
         Indication if the device supports receiving of RTP Multicast.
         */
        public var isRTP_Multicast: Bool = false
        /* ############################################################## */
        /**
         Indication if the device supports receiving of RTP over TCP.
         */
        public var isRTP_TCP: Bool = false
        /* ############################################################## */
        /**
         Indication if the device supports receiving of RTP over RTSP over TCP
         */
        public var isRTP_RTSP_TCP: Bool = false
        /* ############################################################## */
        /**
         The maximum number of receivers the device supports.
         */
        public var supportedReceivers: Int!
        /* ############################################################## */
        /**
         The maximum length allowed for RTSP URIs.
         */
        public var maximumRTSPURILength: Int!
        
        /* ############################################################## */
        /**
         Simple Initializer that sets our only non-mutable property.
         */
        init(owner inOwner: RVS_ONVIF) {
            owner = inOwner
        }
    }

    /* ###################################################################################################################################### */
    /**
     This struct describes our recording capabilities
     */
    public struct RecordingCapabilities: OwnedInstanceProtocol {
        /* ############################################################## */
        /**
         This is us.
         */
        public let owner: RVS_ONVIF!
        /* ############################################################## */
        /**
         This is the URL for the XAddr.
         */
        public var xAddr: URL!
        /* ############################################################## */
        /**
         Indication if the device supports dynamic creation and deletion of recordings, see ONVIF Recording Configuration Specification.
         */
        public var isDynamicRecordings: Bool = false
        /* ############################################################## */
        /**
         Indication if the device supports dynamic creation and deletion of tracks, see ONVIF Recording Configuration Specification.
         */
        public var isDynamicTracks: Bool = false
        /* ############################################################## */
        /**
         Indication if the device supports explicit deletion of data, see ONVIF Recording Configuration Specification.
         */
        public var isDeleteData: Bool = false
        
        /* ############################################################## */
        /**
         Simple Initializer that sets our only non-mutable property.
         */
        init(owner inOwner: RVS_ONVIF) {
            owner = inOwner
        }
    }

    /* ###################################################################################################################################### */
    /**
     This struct describes our replay capabilities
     */
    public struct ReplayCapabilities: OwnedInstanceProtocol {
        /* ############################################################## */
        /**
         This is us.
         */
        public let owner: RVS_ONVIF!
        /* ############################################################## */
        /**
         This is the URL for the XAddr.
         */
        public var xAddr: URL!
        
        /* ############################################################## */
        /**
         Simple Initializer that sets our only non-mutable property.
         */
        init(owner inOwner: RVS_ONVIF) {
            owner = inOwner
        }
    }

    /* ###################################################################################################################################### */
    /**
     This struct describes our search capabilities
     */
    public struct SearchCapabilities: OwnedInstanceProtocol {
        /* ############################################################## */
        /**
         This is us.
         */
        public let owner: RVS_ONVIF!
        /* ############################################################## */
        /**
         This is the URL for the XAddr.
         */
        public var xAddr: URL!
        /* ############################################################## */
        /**
         Indication if the device supports generic search of recorded metadata as defined in the ONVIF Recording Search Specification.
         */
        public var isMetadataSearch: Bool = false
        
        /* ############################################################## */
        /**
         Simple Initializer that sets our only non-mutable property.
         */
        init(owner inOwner: RVS_ONVIF) {
            owner = inOwner
        }
    }
    
    /* ###################################################################################################################################### */
    /**
     This struct describes a single network interface data model
     */
    public struct NetworkInterface: OwnedInstanceProtocol {
        /* ############################################################## */
        /**
         This is us.
         */
        public let owner: RVS_ONVIF!
        
        /* ############################################################## */
        /**
         The interface token
         */
        public var token: String = ""
        
        /* ############################################################## */
        /**
         The enabled flag. If true, the interface is enabled.
         */
        public var isEnabled: Bool = false
        
        /* ############################################################## */
        /**
         Returns the parameters in a fashion suitable for sending to the device.
         */
        public var asParameters: [String: Any]! {
            var networkInterfaceParams: [String: Any] = [:]
            networkInterfaceParams["tt:Enabled"] = isEnabled ? "true" : "false"
            
            if let ipV4 = ipV4 {
                networkInterfaceParams["tt:IPv4"] = ipV4.asParameters
            }
            
            if let ipV6 = ipV6 {
                networkInterfaceParams["tt:IPv6"] = ipV6.asParameters
            }

            if let networkInterfaceExtension = networkInterfaceExtension {
                networkInterfaceParams["tt:Extension"] = networkInterfaceExtension.asParameters
            }
            
            var params: [String: Any] = [:]
            
            params["trt:InterfaceToken"] = token
            params["trt:NetworkInterface"] = networkInterfaceParams
            
            return params
        }

        /* ############################################################## */
        /**
         OPTIONAL: The newtwork interface general info. This may be nil.
         */
        public var info: NetworkInterfaceInfo!

        /* ############################################################## */
        /**
         OPTIONAL: The newtwork interface link info. This may be nil.
         */
        public var link: NetworkInterfaceLink!

        /* ############################################################## */
        /**
         OPTIONAL: The IPv4 newtwork interface info. This may be nil.
         */
        public var ipV4: IPNetworkInterface!

        /* ############################################################## */
        /**
         OPTIONAL: The IPv6 newtwork interface info. This may be nil.
         */
        public var ipV6: IPNetworkInterface!
        
        /* ############################################################## */
        /**
         OPTIONAL: Any extension to the interface. This may be nil.
         */
        public var networkInterfaceExtension: NetworkInterfaceExtension!
    }
    
    /* ###################################################################################################################################### */
    /**
     This struct describes the model for the "info" item of the newtork interface struct
     */
    public struct NetworkInterfaceInfo {
        /* ############################################################## */
        /**
         The interface name. This is optional, and may be empty
         */
        public var name: String = ""
        
        /* ############################################################## */
        /**
         The hardware MAC address. It is a string in the format 00-FF\:00-FF\:00-FF\:00-FF\:00-FF\:00-FF
         */
        public var hwAddress: String = ""
        
        /* ############################################################## */
        /**
         The maximum transmission unit (MTU) size. 0 is undefined.
         */
        public var mtu: Int = 0
        
        /* ############################################################## */
        /**
         Returns the parameters in a fashion suitable for sending to the device.
         */
        public var asParameters: [String: Any]! {
            var params: [String: Any] = [:]
            params["tt:Name"] = name
            params["tt:MTU"] = mtu
            
            return params
        }
   }
    
    /* ###################################################################################################################################### */
    /**
     This struct describes the model for the "link" item of the newtork interface struct
     */
    public struct NetworkInterfaceLink {
        /* ############################################################## */
        /**
         The admin settings.
         */
        public var adminSettings: NetworkInterfaceConnectionSetting
        
        /* ############################################################## */
        /**
         The operator settings.
         */
        public var operSettings: NetworkInterfaceConnectionSetting
        
        /* ############################################################## */
        /**
         The interface type.
         */
        public var interfaceType: RVS_ONVIF_Core.IANA_Types
        
        /* ############################################################## */
        /**
         Returns the parameters in a fashion suitable for sending to the device.
         */
        public var asParameters: [String: Any]! {
            var params: [String: Any] = [:]

            params["tt:AdminSettings"] = adminSettings.asParameters
            params["tt:OperSettings"] = operSettings.asParameters
            
            return params
        }
    }
    
    /* ###################################################################################################################################### */
    /**
     This struct describes the model for a network interface extension record.
     */
    public struct NetworkInterfaceExtension {
        /* ############################################################## */
        /**
         The interface type.
         */
        public var interfaceType: RVS_ONVIF_Core.IANA_Types
        
        /* ############################################################## */
        /**
         A placeholder for 802.3 configuration. This is optional, and may be nil.
         */
        public var dot3Configuration: Any!
        
        /* ############################################################## */
        /**
         802.11 configuration. This is optional, and may be nil.
         */
        public var dot11: Dot11Configuration!
        
        /* ############################################################## */
        /**
         Optional extension placeholder.
         */
        public var networkInterfaceSetConfigurationExtension2: Any!
        
        /* ############################################################## */
        /**
         Returns the parameters in a fashion suitable for sending to the device.
         */
        public var asParameters: [String: Any]! {
            var params: [String: Any] = [:]

            if let dot11 = dot11 {
                params["tt:Dot11"] = dot11.asParameters
            }

            if let dot3Configuration = dot3Configuration {
                params["tt:Dot3Configuration"] = dot3Configuration
            }
            
            if let networkInterfaceSetConfigurationExtension2 = networkInterfaceSetConfigurationExtension2 {
                params["tt:NetworkInterfaceExtension2"] = networkInterfaceSetConfigurationExtension2
            }
            
            return params
        }
    }
    
    /* ###################################################################################################################################### */
    /**
     This struct describes the model for a network interface 802.11 configuration extension record.
     */
    public struct Dot11Configuration {
        /* ################################################################################################################################## */
        /**
         This struct describes the model for the security (login) info for an 802.11 WiFi network.
         */
        public struct Dot11SecurityConfiguration {
            /* ############################################################################################################################## */
            /**
             This struct has the key and/or passphrase for a login.
             All properties are optional, and may be empty.
             */
            public struct Dot11PSKSet {
                /// The key (256 bits, presented as 64 hex octets).
                public var key: String = ""
                /// The passphrase (a String).
                public var passphrase: String = ""
                /// This is optional, and contains any extension info.
                public var dot11PSKSetExtension: Any!
                
                /* ############################################################## */
                /**
                 Returns the parameters in a fashion suitable for sending to the device.
                 */
                public var asParameters: [String: Any]! {
                    var params: [String: Any] = [:]
                    if !key.isEmpty {
                        params["tt:Key"] = key
                    }
                    
                    if !passphrase.isEmpty {
                        params["tt:Passphrase"] = passphrase
                    }
                    
                    if let dot11PSKSetExtension = dot11PSKSetExtension {
                        params["tt:Extension"] = dot11PSKSetExtension
                    }

                    return params
                }
            }
            
            /// The network security mode.
            public enum Dot11SecurityMode: String {
                /// No Dot11 security
                case none = "None"
                /// Standard Wired Equivalent Privacy
                case wep = "WEP"
                /// Pre-Shared Key
                case psk = "PSK"
                /// Dot1X Encryption
                case dot1x = "Dot1X"
                /// Extra Extension
                case extended = "Extended"
            }
            
            /// The encryption type.
            public enum Dot11Cipher: String {
                /// Counter Mode Cipher Block Chaining Message Authentication
                case ccmp = "CCMP"
                /// Temporal Key Integrity Protocol
                case tkip = "TKIP"
                /// Any (Undefined) Protocol
                case any = "Any"
                /// Extra Extension
                case extended = "Extended"
            }
            
            /// The security mode to be used.
            public var mode: Dot11SecurityMode = .none
            
            /// The algorithm. This is optional, and may be nil.
            public var algorithm: Dot11Cipher!
            
            /// The PSK. This is optional, and may be nil.
            public var psk: Dot11PSKSet!
            
            /// The Dot.1X reference token. This is optional, and may be nil.
            public var dot1XToken: String!
            
            /// This is optional, and contains any extension info.
            public var dot11SecurityConfigurationExtension: Any!
            
            /* ############################################################## */
            /**
             Returns the parameters in a fashion suitable for sending to the device.
             */
            public var asParameters: [String: Any]! {
                var params: [String: Any] = [:]
                params["Mode"] = mode.rawValue
                if let algorithm = algorithm {
                    params["tt:Algorithm"] = algorithm.rawValue
                }
                if let psk = psk {
                    params["tt:PSK"] = psk.asParameters
                }
                if let dot1XToken = dot1XToken {
                    params["tt:Dot1X"] = dot1XToken
                }
                if let dot11SecurityConfigurationExtension = dot11SecurityConfigurationExtension {
                    params["tt:Extension"] = dot11SecurityConfigurationExtension
                }
                
                return params
            }
        }
        
       /// The connection mode for this network.
        public enum Dot11StationMode: String {
            /// Ad-Hoc Network
            case adHoc = "Ad-hoc"
            /// Infrastructure Network Mode
            case infrastructure = "Infrastructure"
            /// Extra Extension
            case extended = "Extended"
            /// Error
            case error
        }
        
        /// The SSID of the network, as a String.
        public var ssid: String
        
        /// The mode of this WiFi connection.
        public var mode: Dot11StationMode = .error
        
        /// An alias for this network.
        public var alias: String = ""
        
        /// The priority for this network. Type is unknown.
        public var priority: Any!
        
        /// The security login info for this network.
        public var security: Dot11SecurityConfiguration
        
        /* ############################################################## */
        /**
         Returns the parameters in a fashion suitable for sending to the device.
         */
        public var asParameters: [String: Any]! {
            var params: [String: Any] = [:]
            params["tt:SSID"] = ssid
            params["tt:Mode"] = mode.rawValue
            params["tt:Alias"] = alias
            if let priority = priority {
                params["tt:Priority"] = priority
            }
            params["tt:Security"] = security.asParameters
            
            return params
        }
    }
    
    /* ###################################################################################################################################### */
    /**
     This struct describes the model for an IPv4 or IPv6 address, as used in the Network Interface Info List.
     */
    public struct IPAddressEntry {
        /// This will be either a RVS_IPAddressV4 or RVS_IPAddressV6 address. It can be nil (undefined)
        public var address: RVS_IPAddress!
        
        /// The length of the address submask.
        public var prefixLength: Int
        
        /* ############################################################## */
        /**
         Returns the parameters in a fashion suitable for sending to the device.
         */
        public var asParameters: [String: Any]! {
            var params: [String: Any] = [:]
            if let address = address {
                params["tt:Address"] = address.address
                params["tt:PrefixLength"] = prefixLength
            }
            
            return params
        }
        
        /* ############################################################## */
        /**
         We declare this here to make it public.
         */
        public init(address inAddress: RVS_IPAddress!, prefixLength inPrefixLength: Int) {
            address = inAddress
            prefixLength = inPrefixLength
        }
    }
    
    /* ###################################################################################################################################### */
    /**
     This struct describes the model for an IPv4 or IPv6 interface configuration. It has a couple of fields which are not filled for IPv4.
     */
    public struct IPConfiguration {
        public enum IPDHCPConfiguration: String {
            case On, Off, Auto, Stateful, Stateless
        }
        
        /* ############################################################## */
        /**
         This is true, if the interface uses DHCP.
         */
        public var isDHCP: Bool {
            return .Off != dhcp
        }
        
        /* ############################################################## */
        /**
         This is set to true, if this is an IPv6 configuration.
         */
        public var isIPv6: Bool = false
        
        /* ############################################################## */
        /**
         This contains any specific DHCP setup. For IPv4, it is simply "On" or "Off".
         */
        public var dhcp: IPDHCPConfiguration = .Off

        /* ############################################################## */
        /**
         OPTIONAL -This contains any IP addresses manually entered. It is optional, and can be nil
         */
        public var manual: [IPAddressEntry]!
        
        /* ############################################################## */
        /**
         OPTIONAL -This contains any IP addresses available for local loopback link. It is optional, and can be nil
         */
        public var linkLocal: [IPAddressEntry]!
        
        /* ############################################################## */
        /**
         OPTIONAL -This contains any IP addresses assigned by DHCP. It is optional, and can be nil
         */
        public var fromDHCP: [IPAddressEntry]!
        
        /* ############################################################## */
        /**
         OPTIONAL -ONLY FOR IPV6: This is a list of addresses from Router Advertisement.
         This will always be nil for IPv4 interfaces.
         */
        public var fromRA: [IPAddressEntry]!
        
        /* ############################################################## */
        /**
         ONLY FOR IPV6: This is true, if the interface will accept router advertisement.
         This will always be nil for IPv4 interfaces.
         */
        public var isAbleToAcceptRouterAdvert: Bool!

        /* ############################################################## */
        /**
         ONLY FOR IPV6: The IPv6 extension interface info. It is optional, and can be nil
         This will always be nil for IPv4 interfaces.
         */
        public var ipv6ConfigurationExtension: Any!
        
        /* ############################################################## */
        /**
         Returns the parameters in a fashion suitable for sending to the device.
         */
        public var asParameters: [String: Any]! {
            var params: [String: Any] = [:]
            
            params["tt:DHCP"] = isIPv6 ? dhcp.rawValue : .On == dhcp ? "true" : "false"
            
            if let isAbleToAcceptRouterAdvert = isAbleToAcceptRouterAdvert {
                params["tt:AcceptRouterAdvert"] = isAbleToAcceptRouterAdvert ? "true" : "false"
            }
            
            if let ipv6ConfigurationExtension = ipv6ConfigurationExtension {
                params["tt:Extension"] = ipv6ConfigurationExtension
            }
            
            if let array = manual, !array.isEmpty {
                params["tt:Manual"] = array.compactMap { return $0.asParameters }
            }

            return params
        }
    }

    /* ###################################################################################################################################### */
    /**
     This struct describes the model for an IPv4 interface.
     */
    public struct IPNetworkInterface {
        /* ############################################################## */
        /**
         The enabled flag. If true, the interface is enabled.
         */
        public var isEnabled: Bool = false
        
        /* ############################################################## */
        /**
         The IPv4 configuration for this interface.
         */
        public var configuration: IPConfiguration
        
        /* ############################################################## */
        /**
         Returns the parameters in a fashion suitable for sending to the device.
         */
        public var asParameters: [String: Any]! {
            var params: [String: Any] = configuration.asParameters
            
            params["tt:Enabled"] = isEnabled ? "true" : "false"
            
            return params
        }
    }

    /* ###################################################################################################################################### */
    /**
     This struct describes the settings for an admin or operator of a link.
     */
    public struct NetworkInterfaceConnectionSetting: OwnedInstanceProtocol {
        /* ############################################################## */
        /**
         This enum describes the duplex type (Half or Full).
         */
        public enum Duplex: String {
            /// Half Duplex Mode
            case Half
            /// Full Duplex Mode
            case Full
        }
        
        /* ############################################################## */
        /**
         This is us.
         */
        public let owner: RVS_ONVIF!
        
        /* ############################################################## */
        /**
         True, if auto speed negotiation is on.
         */
        public var autoNegotiation: Bool = false
        
        /* ############################################################## */
        /**
         The interface speed.
         */
        public var speed: Int = 0
        
        /* ############################################################## */
        /**
         The duplex type.
         */
        public var duplex: Duplex
        
        /* ############################################################## */
        /**
         Returns the parameters in a fashion suitable for sending to the device.
         */
        public var asParameters: [String: Any]! {
            var params: [String: Any] = [:]
            
            params["tt:AutoNegotiation"] = autoNegotiation ? "true" : "false"
            params["tt:Speed"] = speed
            params["tt:Duplex"] = duplex.rawValue
            
            return params
        }
    }
}

/* ################################################################################################################################## */
// MARK: - Dispatch Core Functions
/* ################################################################################################################################## */
/**
 This is the protocol that defines the dispatcher for the Core ONVIF Profile.
 */
public protocol RVS_ONVIF_CoreDispatcher: RVS_ONVIF_Dispatcher {
    /* ################################################################## */
    /**
     This sends an explicit hostname to the device.
     
     - parameter inHostname: The new hostname to be set.
     */
    func setHostname(_ inHostname: String)
    
    /* ################################################################## */
    /**
     This tells the device to fetch its hostname from DHCP.
     
     - parameter isOn: True, if the device is to fetch its hostname from DHCP.
     */
    func setHostnameFromDHCP(_ isOn: Bool)
    
    /* ################################################################## */
    /**
     This sends DNS data to the device.
     
     - parameter inDNSEntry: This is the new DNS information to send to the device.
     */
    func setDNS(_ inDNSEntry: RVS_ONVIF_Core.DNSRecord)
    
    /* ################################################################## */
    /**
     This sends NTP data to the device.
     
     - parameter inNTPEntry: This is the new NTP information to send to the device.
     */
    func setNTP(_ inNTPEntry: RVS_ONVIF_Core.NTPRecord)
    
    /* ################################################################## */
    /**
     This sends Dynamic DNS data to the device.
     
     - parameter inDynDNSEntry: This is the new Dynamic DNS information to send to the device.
     */
    func setDynamicDNS(_ inDynDNSEntry: RVS_ONVIF_Core.DynamicDNSRecord)
    
    /* ################################################################## */
    /**
     This sends a network interface setting to the device
     
     - parameter inNetworkInterfaceRecord: This is the new network interface information to send to the device.
     */
    func setNetworkInterfaces(_ inNetworkInterfaceRecord: RVS_ONVIF_Core.NetworkInterface)
}

/* ################################################################################################################################## */
// MARK: - Dispatch Profile Defaults.
/* ################################################################################################################################## */
extension RVS_ONVIF_CoreDispatcher {
    /* ################################################################## */
    /**
     This is a String, returned by the dispatcher, that indicates which profile handler to use for it. It is implemented by the "first level" protocol override.
     
     - returns: "RVS_ONVIF_Core"
     */
    public var profileSig: String {
        return "RVS_ONVIF_Core"
    }

    /* ################################################################## */
    /**
     This sends an explicit hostname to the device.
     
     - parameter inHostname: The new hostname to be set.
     */
    public func setHostname(_ inHostname: String) {
        owner.performRequest(RVS_ONVIF_Core._DeviceRequest.SetHostname, params: ["Name": inHostname])
    }

    /* ################################################################## */
    /**
     This tells the device to fetch its hostname from DHCP.
     
     - parameter isOn: True, if the device is to fetch its hostname from DHCP.
     */
    public func setHostnameFromDHCP(_ isOn: Bool) {
        owner.performRequest(RVS_ONVIF_Core._DeviceRequest.SetHostnameFromDHCP, params: ["FromDHCP": isOn ? "true" : "false"])
    }

    /* ################################################################## */
    /**
     This sends DNS data to the device.
     
     - parameter inDNSEntry: This is the new DNS information to send to the device.
     */
    public func setDNS(_ inDNSEntry: RVS_ONVIF_Core.DNSRecord) {
        owner.performRequest(RVS_ONVIF_Core._DeviceRequest.SetDNS, params: inDNSEntry.asParameters)
    }
    
    /* ################################################################## */
    /**
     This sends NTP data to the device.
     
     - parameter inNTPEntry: This is the new NTP information to send to the device.
     */
    public func setNTP(_ inNTPEntry: RVS_ONVIF_Core.NTPRecord) {
        owner.performRequest(RVS_ONVIF_Core._DeviceRequest.SetNTP, params: inNTPEntry.asParameters)
    }
    
    /* ################################################################## */
    /**
     This sends Dynamic DNS data to the device.
     
     - parameter inDynDNSEntry: This is the new Dynamic DNS information to send to the device.
     */
    public func setDynamicDNS(_ inDynDNSEntry: RVS_ONVIF_Core.DynamicDNSRecord) {
        owner.performRequest(RVS_ONVIF_Core._DeviceRequest.SetDynamicDNS, params: inDynDNSEntry.asParameters)
    }
    
    /* ################################################################## */
    /**
     This sends a network interface setting to the device
     
     - parameter inNetworkInterfaceRecord: This is the new network interface information to send to the device.
     */
    public func setNetworkInterfaces(_ inNetworkInterfaceRecord: RVS_ONVIF_Core.NetworkInterface) {
        owner.performRequest(RVS_ONVIF_Core._DeviceRequest.SetNetworkInterfaces, params: inNetworkInterfaceRecord.asParameters)
    }
}
