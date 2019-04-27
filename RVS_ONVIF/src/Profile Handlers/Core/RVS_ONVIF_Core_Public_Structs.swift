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
 This is the delegate protocol for use with the RVS_ONVIF_Core. It has all required methods.
 
 This is a "pure" Swift protocol, requiring that it be applied to a class.
 
 These methods are all called in the main thread.
 */
public protocol RVS_ONVIF_CoreDelegate: RVS_ONVIFDelegate {
    /* ################################################################## */
    /**
     This is called to deliver the WSDL URI.
     
     - parameter instance: The RVS_ONVIF instance that is calling the delegate.
     - parameter getWSDLURI: The WSDL URI as a String. Nil, if there is none available.
     */
    func onvifInstance(_ instance: RVS_ONVIF, getWSDLURI: String!)
    
    /* ################################################################## */
    /**
     This is called to deliver the Hostname.
     
     - parameter instance: The RVS_ONVIF instance that is calling the delegate.
     - parameter getHostname: The returned hostname tuple. Nil, if there is none available.
     */
    func onvifInstance(_ instance: RVS_ONVIF, getHostname: RVS_ONVIF_Core.HostnameResponse!)
    
    /* ################################################################## */
    /**
     This is called to deliver the DNS.
     
     - parameter instance: The RVS_ONVIF instance that is calling the delegate.
     - parameter getDNS: The DNS Response. Nil, if there is none available.
     */
    func onvifInstance(_ instance: RVS_ONVIF, getDNS: RVS_ONVIF_Core.DNSRecord!)
    
    /* ################################################################## */
    /**
     This is called to deliver the Dynamic DNS.
     
     - parameter instance: The RVS_ONVIF instance that is calling the delegate.
     - parameter getDynamicDNS: The Dynamic DNS Response. Nil, if there is none available.
     */
    func onvifInstance(_ instance: RVS_ONVIF, getDynamicDNS: RVS_ONVIF_Core.DynamicDNSRecord!)

    /* ################################################################## */
    /**
     This is called to deliver the NTP Record.
     
     - parameter instance: The RVS_ONVIF instance that is calling the delegate.
     - parameter getNTP: The GetNTP Response. Nil, if there is none available.
     */
    func onvifInstance(_ instance: RVS_ONVIF, getNTP: RVS_ONVIF_Core.NTPRecord!)
}

/* ###################################################################################################################################### */
/**
 These are just here to make the protocol optional. They deliberately do not do anything.
 */
public extension RVS_ONVIF_CoreDelegate {
    /* ################################################################## */
    /**
     This is called to deliver the WSDL URI.
     
     - parameter instance: The RVS_ONVIF instance that is calling the delegate.
     - parameter getWSDLURI: The WSDL URI instance. Nil, if there is none available.
     */
    func onvifInstance(_ instance: RVS_ONVIF, getWSDLURI: String!) {
        #if DEBUG
            print("onvifInstance:getWSDLURI:\(String(describing: getWSDLURI))")
        #endif
    }
    
    /* ################################################################## */
    /**
     This is called to deliver the Hostname.
     
     - parameter instance: The RVS_ONVIF instance that is calling the delegate.
     - parameter getHostname: The returned hostname tuple. Nil, if there is none available.
     */
    func onvifInstance(_ instance: RVS_ONVIF, getHostname: RVS_ONVIF_Core.HostnameResponse!) {
        #if DEBUG
            print("onvifInstance:getHostname:\(String(describing: getHostname))")
        #endif
    }
    
    /* ################################################################## */
    /**
     This is called to deliver the DNS.
     
     - parameter instance: The RVS_ONVIF instance that is calling the delegate.
     - parameter getDNS: The DNS Response. Nil, if there is none available.
     */
    func onvifInstance(_ instance: RVS_ONVIF, getDNS: RVS_ONVIF_Core.DNSRecord!) {
        #if DEBUG
            print("onvifInstance:getDNS:\(String(describing: getDNS))")
        #endif
    }
    
    /* ################################################################## */
    /**
     This is called to deliver the Dynamic DNS.
     
     - parameter instance: The RVS_ONVIF instance that is calling the delegate.
     - parameter getDynamicDNS: The Dynamic DNS Response. Nil, if there is none available.
     */
    func onvifInstance(_ instance: RVS_ONVIF, getDynamicDNS: RVS_ONVIF_Core.DynamicDNSRecord!) {
        #if DEBUG
            print("onvifInstance:getDynamicDNS:\(String(describing: getDynamicDNS))")
        #endif
    }

    /* ################################################################## */
    /**
     This is called to deliver the NTP Record.
     
     - parameter instance: The RVS_ONVIF instance that is calling the delegate.
     - parameter getNTP: The NTP Response. Nil, if there is none available.
     */
    func onvifInstance(_ instance: RVS_ONVIF, getNTP: RVS_ONVIF_Core.NTPRecord!) {
        #if DEBUG
            print("onvifInstance:getNTP:\(String(describing: getNTP))")
        #endif
    }
}

/* ###################################################################################################################################### */
/**
 These are the public structs, used to provide the core data to the delegate.
 */
extension RVS_ONVIF_Core {
    /* ################################################################################################################################## */
    // MARK: - Public Structs
    /* ################################################################################################################################## */
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
            /// Profile S (Streaming)
            case S(String)
            /// Profile G (Recording)
            case G(String)
            /// Profile Q (Easy Setup)
            case Q(String)

            /* ############################################################## */
            /**
             This allows us to compare without taking the associated values into consideration.
             */
            public static func == (lhs: ProfileType, rhs: ProfileType) -> Bool {
                switch (lhs, rhs) {
                case (.Unknown, .Unknown), (.Core, .Core), (.S, .S), (.G, .G), (.Q, .Q):
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
        public enum DynDNSType: Equatable {
            case NoUpdate
            case ServerUpdates(ttl: DateComponents!)
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
         */
        public let type: DynDNSType
        
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
         This is the Capabilities. It is optional, and may be nil.
         */
        public let capabilities: ServiceCapabilities!
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
}

/* ################################################################################################################################## */
// MARK: - Dispatch Core Functions
/* ################################################################################################################################## */
public protocol RVS_ONVIF_CoreDispatcher: RVS_ONVIF_Dispatcher {
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

    /* ############################################################################################################################## */
    // MARK: - Dispatch Profile S Function Placeholders (NOP Methods).
    /* ############################################################################################################################## */
    /* ################################################################## */
    /**
     This is called to deliver the device ONVIF profiles.
     
     - parameter instance: The RVS_ONVIF instance that is calling the delegate.
     - parameter getProfiles: An Array of Profile objects.
     */
    public func onvifInstance(_ instance: RVS_ONVIF, getProfiles: [RVS_ONVIF_Profile_S.Profile]) {
        #if DEBUG
            print("RVS_ONVIF_CoreDispatcher::onvifInstance:simpleResponseToRequest(\(String(describing: getProfiles))")
        #endif
    }

    /* ################################################################## */
    /**
     This is called to deliver the device stream URI.
     
     - parameter instance: The RVS_ONVIF instance that is calling the delegate.
     - parameter getStreamURI: The Stream_URI instance that contains the ONVIF response.
     */
    public func onvifInstance(_ instance: RVS_ONVIF, getStreamURI: RVS_ONVIF_Profile_S.Stream_URI) {
        #if DEBUG
            print("RVS_ONVIF_CoreDispatcher::onvifInstance:simpleResponseToRequest(\(String(describing: getStreamURI))")
        #endif
    }

    /* ################################################################## */
    /**
     This is called to deliver the device stream URI.
     
     - parameter instance: The RVS_ONVIF instance that is calling the delegate.
     - parameter getVideoSourceConfigurations: An Array of video source configuration structs.
     */
    public func onvifInstance(_ instance: RVS_ONVIF, getVideoSourceConfigurations: [RVS_ONVIF_Profile_S.VideoSourceConfiguration]) {
        #if DEBUG
            print("RVS_ONVIF_CoreDispatcher::onvifInstance:simpleResponseToRequest(\(String(describing: getVideoSourceConfigurations))")
        #endif
    }
}
