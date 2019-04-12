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
 This is an ONVIF Swift Framework driver.
 This is inspired by the ONVIFCamera library, by Rémy Virin, but is a great deal more robust. He did an excellent job, but I'm a "fiddler."

 It uses SOAPEngine, by Danilo Priore (http://www.prioregroup.com) to handle the stuff below the session layer.
 If you want to use this on a device (as opposed to the simulator), you need to purchase a SOAPEngine license from the Priore Group (see URI, above).

 This relies on a delegate pattern, as opposed to the closure pattern that Rémy Virin's library used.

 HOW THE FRAMEWORK OPERATES
 
 The RVS_ONVIF Framework is a "hub and spokes" framework, in a similar pattern to the ONVIF specification.
 
 There is a "core," and a bunch of "profiles," as defined by the ONVIF specification.
 
 The profiles (including the core) are the "spokes" of the framework, and are instantiated as needed to address the needs of the device to which the framework instance is dedicated.
 
 You instantiate one RVS_ONVIF instance to connect to one device. You can have as many instances as you want, for multiple devices, but each instance corresponds to only one device.
 
 This framework does not handle device discovery. You are expected to give it an IP number and TCP port. It will handle both IPv4 and IPv6.
 
 DELEGATION, NOT OBSERVATION
 
 The ONVIF Framework uses a delegation pattern; not an observer pattern.
 
 This is mostly because we're talking about device control here, where chaos reigns supreme. It's not always possible (or advisable) to attach a context to an event/response.
 
 Observers are more complicated than delegates, and there's no real advantage to using them, if you can't attach a context. A delegate gives a simple, straightforward "call me"
 interface, without having to deal with things like messages, payloads, contexts and thread contentions.
 
 Each delegate call is optional. This is done by extending the delegate protocol with "do nothing" methods. They are also all called in the main thread.
 
 Each call also contains the deliverable data in as refined a state as possible; usually in the form of data structures specific to the operation.
 
 If you wish to attach context to commands; you may do so at a level above the delegate, but we can't depend on the transport mechanism to preserve state for us.
 
 View the README file for more comprehensive documentation.
 */
@objc public class RVS_ONVIF: NSObject, SOAPEngineDelegate {
    /* ################################################################################################################################## */
    // MARK: - Internal Constants
    /* ################################################################################################################################## */
    /* ################################################################## */
    /**
     Holds the SOAPEngine license key. You can't use this library in a device without a valid license key.
     */
    internal let _soapEngineLicenseKey: String!

    /* ################################################################################################################################## */
    // MARK: - Internal Instance Properties
    /* ################################################################################################################################## */
    /* ################################################################## */
    /**
     This is the authentication realm and other stuff.
     */
    internal var _authData: [String: String]?
    
    /* ################################################################## */
    /**
     This tracks the number of times a nonce has been created.
     */
    internal var _nonceCount: Int = 0

    /* ################################################################## */
    /**
     These are our various profile handlers. They should be read-only for users of the framework.
     */
    internal var _profiles: [String: ProfileHandlerProtocol] = [:]

    /* ################################################################################################################################## */
    // MARK: - Internal Initializers
    /* ################################################################################################################################## */
    /**
     These need to be declared in the main context, which is why they are not in the internals file.
     */
    /* ################################################################## */
    /**
     Blank initializer (Internal, so only the factory can create it outside the framework).
     */
    internal override init() {
        loginCredentials = nil
        ipAddressAndPort = ""
        _soapEngineLicenseKey = ""
    }
    
    /* ################################################################## */
    /**
     Default initializer (Internal, so only the factory can create it outside the framework).
     
     - parameter ipAddressAndPort: This is a String, containing a standard IPV4 address and port (123.123.123.123:1234)
     - parameter loginCredentials: This is a tuple, containing the login ID and password (Strings) for the camera. It cannot have either field empty (login: String, password: String)
     - parameter soapEngineLicenseKey: This is a String, with the SOAPEngine license key. It is optional (defaults to blank). If not provided, SOAPEngine will only work in the simulator.
     - parameter authMethod: This is an optional parameter, indicating the authorization method. Default is both.
     - parameter delegate: This is an optional (default is nil) parameter that allows you to specify a delegate up front. If it is provided, the instance will be immediately initialized.
     */
    internal init(ipAddressAndPort inIPAddressAndPort: String,
                  loginCredentials inCredentials: LoginCredentialTuple,
                  soapEngineLicenseKey inSoapEngineLicenseKey: String? = nil,
                  authMethod inAuthMethod: SOAPAuthMethod = .both,
                  delegate inDelegate: (RVS_ONVIFDelegate & RVS_ONVIF_CoreDelegate & RVS_ONVIF_Profile_SDelegate)! = nil) {
        ipAddressAndPort = inIPAddressAndPort
        loginCredentials = inCredentials
        _soapEngineLicenseKey = inSoapEngineLicenseKey
        super.init()
        defer { // We do this, to make sure that didSet gets called.
            let core = (RVS_ONVIF_Core(owner: self))
            core.supportedNamespaces = type(of: core).namespaces
            _profiles[String(describing: type(of: core).self)] = core
            authMethod = inAuthMethod
            delegate = inDelegate
        }
    }

    /* ################################################################################################################################## */
    // MARK: - Public Class Methods
    /* ################################################################################################################################## */
    /* ################################################################## */
    /**
     This is a factory method for creating instances of the camera handler. It will not create an instance if there is a problem with the submitted data.
     
     - parameter ipAddressAndPort: This is a String, containing a standard IPV4 address and port (123.123.123.123:1234)
     - parameter loginCredentials: This is a tuple, containing the login ID and password (Strings) for the camera. It cannot have either field empty (login: String, password: String)
     - parameter soapEngineLicenseKey: This is a String, with the SOAPEngine license key. It is optional (defaults to blank). If not provided, SOAPEngine will only work in the simulator.
     - parameter authMethod: This is an optional parameter, indicating the authorization method. Default is both.
     - parameter delegate: This is an optional (default is nil) parameter that allows you to specify a delegate up front. If specified, the instance will immediately attempt a connection.

     - returns: A new instance of this class. Nil, if the provided parameters are not correct.
     */
    public class func makeONVIFInstance(ipAddressAndPort inIPAddressAndPort: String,
                                        loginCredentials inCredentials: LoginCredentialTuple,
                                        soapEngineLicenseKey inSoapEngineLicenseKey: String? = nil,
                                        authMethod inAuthMethod: SOAPAuthMethod = .both,
                                        delegate: (RVS_ONVIFDelegate & RVS_ONVIF_CoreDelegate & RVS_ONVIF_Profile_SDelegate)? = nil) -> RVS_ONVIF? {
        var onvifObject: RVS_ONVIF!
        
        if _isValidIPAddressAndPort(inIPAddressAndPort) && !inCredentials.login.isEmpty && !inCredentials.password.isEmpty {
            onvifObject = RVS_ONVIF(ipAddressAndPort: inIPAddressAndPort, loginCredentials: inCredentials, soapEngineLicenseKey: inSoapEngineLicenseKey, authMethod: inAuthMethod, delegate: delegate)
        }
        
        return onvifObject
    }
    
    /* ################################################################################################################################## */
    // MARK: - Public Typealiases
    /* ################################################################################################################################## */
    /* ################################################################## */
    /**
     This simply contains our login credentials, as Strings.
     */
    public typealias LoginCredentialTuple = (login: String, password: String)

    /* ################################################################################################################################## */
    // MARK: - Public Enums
    /* ################################################################################################################################## */
    /* ################################################################## */
    /**
     This is the authorization method to be used for SOAP connections.
     */
    public enum SOAPAuthMethod {
        /// This forces all connections to be done using Basic auth.
        case basic
        /// This will use either, but always tries Digest first. It is the default.
        case both
        /// This forces Digest.
        case digest
    }
    
    /* ################################################################################################################################## */
    // MARK: - Public Calculated Instance Properties
    /* ################################################################################################################################## */
    /* ################################################################## */
    /**
     These are our profile handlers, returned in an Array. The first element is always the Core handler.
     
     -returns: an Array of profile handler instances. The first element is always the Core handler. This ensures consistent order.
     */
    public var profilesAsArray: [ProfileHandlerProtocol] {
        var ret: [ProfileHandlerProtocol] = []
        
        if 0 < profiles.count, let core = self.core {
            ret.append(core)
            
            let keys = profiles.keys.sorted()
            
            for key in keys where "RVS_ONVIF_Core" != key {
                if let profile = profiles[key] {
                    ret.append(profile)
                }
            }
        }
        return ret
    }

    /* ################################################################################################################################## */
    // MARK: - Public Stored Instance Constants
    /* ################################################################################################################################## */
    /* ################################################################## */
    /**
     This is a String, with our IP address and TCP port.
     */
    public let ipAddressAndPort: String
    
    /* ################################################################## */
    /**
     These are our login credentials.
     */
    public let loginCredentials: LoginCredentialTuple!

    /* ################################################################################################################################## */
    // MARK: - Public Stored Instance Properties
    /* ################################################################################################################################## */
    /* ################################################################## */
    /**
     These are our various profile handlers. They should be read-only for users of the framework.
     */
    public var profiles: [String: ProfileHandlerProtocol] {
        return _profiles
    }
    
    /* ################################################################## */
    /**
     This is our delegate object.
     */
    weak public var delegate: (RVS_ONVIFDelegate & RVS_ONVIF_CoreDelegate & RVS_ONVIF_Profile_SDelegate)! {
        /* ############################################################## */
        /**
         A delegate is required for us to initialize our connection. No delegate, no initialization.
         */
        didSet {
            if nil != delegate, nil == core?.capabilities {    // Only if we haven't done it already.
                _initializeConnection()
            }
        }
    }
    
    /* ################################################################## */
    /**
     This is the SOAP authorization method to use. Default is both, but it can be set to Basic, or Digest; which forces the method.
     */
    public var authMethod: SOAPAuthMethod = .both

    /* ################################################################################################################################## */
    // MARK: - Public Calculated Instance Properties
    /* ################################################################################################################################## */
    /* ################################################################## */
    /**
     Shortcut to access the core profile, as it will always be there.
     
     - returns the core object. nil if there was an error.
     */
    public var core: RVS_ONVIF_Core! {
        return _profiles["RVS_ONVIF_Core"] as? RVS_ONVIF_Core
    }
    
    /* ################################################################## */
    /**
     Shortcut to access the device information.
     
     - returns the device information Dictionary. nil if there was an error.
     */
    public var deviceInformation: [String: Any]! {
        return core?.deviceInformation
    }
    
    /* ################################################################## */
    /**
     Shortcut to access the services.
     
     - returns the services Array. nil if there was an error.
     */
    public var services: [String: RVS_ONVIF_Core.Service]! {
        return core?.services
    }
    
    /* ################################################################## */
    /**
     Shortcut to access the scopes.
     
     - returns the scopes Array. nil if there was an error.
     */
    public var scopes: [RVS_ONVIF_Core.Scope]! {
        return core?.scopes
    }
    
    /* ################################################################## */
    /**
     Shortcut to access the capabilities.
     
     - returns the capability instance. nil if there was an error.
     */
    public var capabilities: RVS_ONVIF_Core.Capabilities! {
        return core?.capabilities
    }
    
    /* ################################################################## */
    /**
     Shortcut to access the default service capabilities.
     
     - returns the service capability instance. nil if there was an error.
     */
    public var serviceCapabilities: RVS_ONVIF_Core.ServiceCapabilities! {
        return core?.serviceCapabilities
    }

    /* ################################################################################################################################## */
    // MARK: - Public Instance Methods
    /* ################################################################################################################################## */
    /* ################################################################## */
    /**
     This is called to initialize the connection.
     */
    public func initializeConnection() {
        _initializeConnection()
    }
    
    /* ################################################################## */
    /**
     This is called to deinitialize the connection. It removes any non-core profile handlers, and clears the caches.
     */
    public func deinitializeConnection() {
        _deinitializeConnection()
    }
    
    /* ################################################################## */
    /**
     This is a generic request mechanism.
     
     The request is sent in as a device request protocol instance, and optional parameters may be supplied.
     
     - parameter inRequest: The request, usually an enum.
     - parameter params: An optional parameter Dictionary. Default is empty.
     - parameter path: An optional (default is empty string) path. If provided, it will trump the one in the request.
     */
    public func performRequest(_ inRequest: RVS_ONVIF_DeviceRequestProtocol, params inParams: [String: Any] = [:], path inPath: String = "") {
        _performSOAPRequest(request: inRequest, params: inParams, path: inPath)
    }

    /* ###################################################################################################################################### */
    // MARK: - Public Structs and Classes
    /* ###################################################################################################################################### */
    /**
     This is a struct that describes an error/issue.
     
     The enclosed enums are the standard ONVIF error codes and subcodes. They use ONVIF TitleCase, as opposed to the standard camelCase, in order to help correlate.
     */
    public struct RVS_Fault: Error {
        /* ############################################################################################################################## */
        // MARK: - Private Stored (READ-ONLY) Properties
        /* ############################################################################################################################## */
        /// It is possible to initialize the struct with a fault code.
        private let _faultCode: RVS_Fault.FaultCode!
        
        /* ############################################################################################################################## */
        // MARK: - Public Embedded Enums
        /* ############################################################################################################################## */
        /* ############################################################## */
        /**
         The main fault codes (env namespace)
         */
        public enum FaultCode: Error {
            /// Nothing to see here, folks. Move along.
            case NoFault
            /// This means that we had an HTTP error, and you should look at the embedded HTTP code.
            case HTTPError(httpError: Int)
            /// Unable to get a SOAP authentication realm.
            case NilRealm
            /// The device found an invalid element information item instead of the expected Envelope element information item.
            case VersionMismatch
            /// One or more mandatory SOAP header blocks were not understood.
            case MustUnderstand
            /// SOAP header block or SOAP body child element information item is scoped with data encoding that is not supported by the device.
            case DataEncodingUnknown
            /// See below. The subcode is embedded. The extra subcode is optional.
            case Sender(subcode: Subcode, extraSubcode: Subcode!)
            /// See below. The subcode is embedded. The extra subcode is optional.
            case Receiver(subcode: Subcode, extraSubcode: Subcode!)
            /// Whiskey Tango Foxtrot (SOAPEngine). Add any error (can be nil).
            case UnknownSOAPError(error: Error!)
            /// Whiskey Tango Foxtrot (ONVIF). Add any error (can be nil).
            case UnknownONVIFError(error: Error!)
            
            /* ########################################################## */
            /**
             This returns a somewhat interpreted description of the fault.
             This will return the code, plus anything more.
             If this is an HTTP error, the HTTP response code is appened by a "-".
             If the fault has subcodes, they are returned, attached to the code by "-".
             */
            public var localizedFullDescription: String {
                var ret = localizedDescription
                switch self {
                case .HTTPError(let httpError):
                    ret += "-\(httpError)"
                    
                case .Sender(let subcode, let extraSubcode):
                    ret += "-\(subcode.localizedDescription)"
                    if let extraSubcode = extraSubcode {
                        ret += "-" + extraSubcode.localizedDescription
                    }
                    
                case .Receiver(let subcode, let extraSubcode):
                    ret += "-\(subcode.localizedDescription)"
                    if let extraSubcode = extraSubcode {
                        ret += "-" + extraSubcode.localizedDescription
                    }
                    
                case .UnknownSOAPError(let error):
                    if let error = error {
                        ret += "-" + error.localizedDescription
                    }
                    
                case .UnknownONVIFError(let error):
                    if let error = error {
                        ret += "-" + error.localizedDescription
                    }
                    
                default:
                    break
                }
                
                return ret
            }
            
            /* ########################################################## */
            /**
             This returns just the code.
             */
            public var localizedDescription: String {
                var ret = ""
                switch self {
                case .NoFault:
                    ret = "NoFault"
                    
                case .NilRealm:
                    ret = "NilRealm"
                    
                case .UnknownSOAPError:
                    ret = "UnknownSOAPError"
                    
                case .UnknownONVIFError:
                    ret = "UnknownONVIFError"
                    
                case .HTTPError:
                    ret = "HTTPError"
                    
                case .VersionMismatch:
                    ret = "VersionMismatch"
                    
                case .MustUnderstand:
                    ret = "MustUnderstand"
                    
                case .DataEncodingUnknown:
                    ret = "DataEncodingUnknown"
                    
                case .Sender:
                    ret = "Sender"
                    
                case .Receiver:
                    ret = "Receiver"
                }
                
                return ret
            }
        }
        
        /* ############################################################## */
        /**
         Sender and Receiver subcodes (ter namespace)
         */
        public enum Subcode: String, Error {
            
            /************* SENDER ENUMS *************/
            
            /// XML Well-formed violation occurred.
            case WellFormed
            /// There was a tag name or namespace mismatch.
            case TagMismatch
            /// XML element tag was missing.
            case Tag
            /// SOAP Namespace error occurred.
            case Namespace
            /// There was a missing required attribute.
            case MissingAttr
            /// A prohibited attribute was present.
            case ProhibAttr
            /**
             An error due to any of the following:
             • missing argument
             • too many arguments
             • arguments are of the wrong data type.
             */
            case InvalidArgs
            /// The argument value is invalid.
            case InvalidArgVal
            /// An unknown action is specified.
            case UnknownAction
            /// The requested operation is not permitted by the device.
            case OperationProhibited
            /// The action requested requires authorization and the sender is not authorized.
            case NotAuthorized
            
            /************* RECEIVER ENUMS *************/
            
            /// The requested action is optional and is not implemented by the device.
            case ActionNotSupported
            /// The requested SOAP action failed.
            case Action
            /// The device does not have sufficient memory to complete the action.
            case OutOfMemory
            /// The device has encountered an error condition which it cannot recover by itself and needs reset or power cycle.
            case CriticalError
            
            /* ########################################################## */
            /**
             This returns the subcode (the namespace is stripped off the front).
             */
            public var localizedDescription: String {
                return self.rawValue
            }
        }
        
        /* ############################################################################################################################## */
        // MARK: - Public Constant Properties
        /* ############################################################################################################################## */
        /// This is any HTTP code that may have accompanied the error. Default is 0.
        public let httpCode: Int
        /// This is a partially-parsed ONVIF response. If this is specified, the the fault code will be dynamically determined.
        public let responseDictionary: [String: Any]!

        /* ############################################################################################################################## */
        // MARK: - Public Calculated Properties
        /* ############################################################################################################################## */
        /* ############################################################## */
        /**
         This is any ONVIF fault. The dictionary is parsed. READ-ONLY.
         */
        public var fault: FaultCode {
            guard nil == _faultCode else { return _faultCode }  // A preset fault code trumps all.
            
            // First things first. An HTTP error goes right to the front of the line.
            guard 300 >= httpCode else { return .HTTPError(httpError: httpCode) }
            
            // In order to proceed, we need to have all of this.
            guard let basilFawlty = responseDictionary, let code = basilFawlty["Code"] as? [String: Any] else { return .NoFault }
            
            var sc1: Subcode!
            var sc2: Subcode!
            
            // Look for a "top-level" subcode, first. The reason for the goddamn double-check, is because these camera manufacturers have the values in different places. #doublefacepalm
            if let subcode1 = code["Subcode"] as? [String: Any] {
                if let valueContainer = subcode1["Value"] as? [String: Any], var value = valueContainer["value"] as? String {
                    if let colonPos = value.firstIndex(of: ":") {   // We strip out the namespace.
                        value = String(value[value.index(after: colonPos)...])
                    }
                    sc1 = Subcode(rawValue: value)
                } else if var value = subcode1["Value"] as? String {
                    if let colonPos = value.firstIndex(of: ":") {
                        value = String(value[value.index(after: colonPos)...])
                    }
                    sc1 = Subcode(rawValue: value)
                }
                
                // See if we have a "second-level" code.
                if let subcode2 = subcode1["Subcode"] as? [String: Any] {
                    if let valueContainer = subcode2["Value"] as? [String: Any], var value = valueContainer["value"] as? String {
                        if let colonPos = value.firstIndex(of: ":") {
                            value = String(value[value.index(after: colonPos)...])
                        }
                        sc2 = Subcode(rawValue: value)
                    } else if var value = subcode2["Value"] as? String {
                        if let colonPos = value.firstIndex(of: ":") {
                            value = String(value[value.index(after: colonPos)...])
                        }
                        sc2 = Subcode(rawValue: value)
                    }
                }
            }
            
            // Now we need to get the code, itself.
            var value: String = ""
            
            // #doublefacepalm
            if let valueContainer = code["Value"] as? [String: Any] {
                if let value1 = valueContainer["value"] as? String {
                    value = value1
                }
            } else if let value1 = code["Value"] as? String {
                value = value1
            }
            
            if !value.isEmpty {
                if let colonPos = value.firstIndex(of: ":") {
                    value = String(value[value.index(after: colonPos)...])
                }
                
                switch value {
                case "VersionMismatch":
                    return .VersionMismatch
                    
                case "MustUnderstand":
                    return .MustUnderstand
                    
                case "DataEncodingUnknown":
                    return .DataEncodingUnknown
                    
                case "Sender":
                    guard nil != sc1 else { return .UnknownONVIFError(error: nil) } // Uh-oh.
                    return .Sender(subcode: sc1, extraSubcode: sc2)
                    
                case "Receiver":
                    guard nil != sc1 else { return .UnknownONVIFError(error: nil) } // Uh-oh.
                    return .Receiver(subcode: sc1, extraSubcode: sc2)
                    
                default:
                    return .UnknownONVIFError(error: nil)
                }
            }
            
            return .NoFault // Shouldn't get here, but we won't throw a nutty if we do.
        }
        
        /* ############################################################## */
        /**
         This returns any reason or details text (may be empty).
         */
        public var reason: String {
            var ret = ""
            
            if let basilFawlty = responseDictionary, let reason = (basilFawlty["Reason"] ?? basilFawlty["Detail"]) as? [String: Any] {
                if let reasonText = reason["Text"] as? [String: String], let reasonString = reasonText["value"] {
                    ret = reasonString
                } else if let reasonString = reason["Text"] as? String {
                    ret = reasonString
                }
            }
            
            return ret
        }
        
        /* ############################################################## */
        /**
         This returns the main fault localized description.
         */
        public var localizedDescription: String {
            return fault.localizedDescription
        }
        
        /* ############################################################################################################################## */
        // MARK: - Public Initializer
        /* ############################################################################################################################## */
        /* ############################################################## */
        /**
         This initializer will fail if there is no actual fault in the data.
         
         Both parameters are optional.
         
         - parameter faultCode: This is a prearranged fault. If this is provided, then the next two are ignored.
         - parameter faultDictionary: This is the Dictionary that has been partially parsed, but is "top-level" (above "Body"). Default is nil.
         - parameter httpCode: This is any HTTP code that accompanies the fault. Default is 0 (undefined).
         
         - returns: nil, if there is no fault.
         */
        public init?(faultCode inFaultCode: FaultCode! = nil, faultDictionary inFaultDictionary: [String: Any]! = nil, httpCode inHTTPCode: Int = 0) {
            _faultCode = inFaultCode
            
            if nil == _faultCode {
                httpCode = inHTTPCode
                // We parse the input dictionary for the Fault records.
                if let dictionary = inFaultDictionary, let body = dictionary["Body"] as? [String: Any], let fault = body["Fault"] as? [String: Any] {
                    responseDictionary = fault
                } else {
                    responseDictionary = nil
                }
            } else {
                httpCode = 0
                responseDictionary = nil
            }
            
            if nil == _faultCode, 300 > httpCode, nil == responseDictionary {
                return nil
            }
        }
    }
}
