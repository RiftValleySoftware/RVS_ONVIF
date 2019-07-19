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

 DELEGATE
 
 Each delegate call is optional. This is done by extending the delegate protocol with "do nothing" methods. They are also all called in the main thread. There are only a couple of calls
 that come if for errors, successful connection, and successful disconnection.

 DISPATCHER
 
 We use "smart dispatchers" to manage the conversation with the driver. The client instantiates profile dispatchers, and registers them with the driver.
 
 The driver then uses these to deliver responses, and the client uses them to send requests.
 
 View the README file for more comprehensive documentation.
 */
@objc open class RVS_ONVIF: NSObject, SOAPEngineDelegate {
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
     This is a flag that is set by classes that override this in order to afford testing. If true, then we don't actually send data out.
     */
    internal var _testingSetup: Bool = false
    
    /* ################################################################## */
    /**
     This flag will indicate if a given IP address/port combo is bad. If true, it short-circuits everything.
     */
    internal var _badIPAddress: Bool = false

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
    public override init() {
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
                  delegate inDelegate: RVS_ONVIFDelegate! = nil) {
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
    // MARK: - Internal Class Methods
    /* ################################################################################################################################## */
    /* ################################################################## */
    /**
     We define this here, so that we can override it in our tester methods.
     
     - parameter inSoapEngine: An optional parameter, with the SOAPEngine instance, primed, and ready to go.
     - parameter uri: A String, with the URI to call.
     - parameter action: A String, with the action to call.
     */
    internal class func _callSOAPEngine(_ inSoapEngine: SOAPEngine!, uri inURI: String, action inAction: String) {
        #if DEBUG
            print("Calling SOAPEngine: URI: \(inURI), Action: \(inAction)")
        #endif
        inSoapEngine?.requestURL(inURI, soapAction: inAction)
    }
    
    /* ################################################################################################################################## */
    // MARK: - Internal Instance Methods
    /* ################################################################################################################################## */
    /* ################################################################## */
    /**
     This is inspired by the ONVIFCamera library, by Rémy Virin, but I'm a jerk, and couldn't leave well enough alone.
     We define this here, so that we can override it in our tester methods.

     Perform a SOAP request
     Responses happen through the error and success instance callbacks.
     
     - parameter request: The Device Request instance.
     - parameter params: An optional (default is nil) parameter that contains parameters to be added to the SOAP request.
     - parameter asSSL: An optional Bool (default is false), that requires the request to be made as SSL (HTTPS).
     - parameter path: An optional (default is empty string) path. If provided, it will trump the one in the request.
     */
    internal func _performSOAPRequest(request inRequest: RVS_ONVIF_DeviceRequestProtocol, params inParams: [String: Any]! = nil, asSSL inAsSSL: Bool = false, path inPath: String = "") {
        let soap = SOAPEngine() // We initialize a new SOAPEngine for each call.
        soap.authorizationMethod = .AUTH_CUSTOM

        let path = inPath.isEmpty ? inRequest.pathFor(self) : inPath
        
        // See if we need to make this HTTPS.
        let reqURLString = "http" + (inAsSSL ? "s" : "") + "://" + self.ipAddressAndPort + path
        
        #if DEBUG
            print("SOAP Request URL: \(reqURLString)")
        #endif
        
        // Unless we are forcing basic, we always try to use Digest first, as it is (theoretically) *slightly* more secure than Basic.
        // If we are marked stale, we go in again, as well.
        if !_testingSetup && .basic != authMethod && (nil == _authData || (.digest == authMethod && ("true" == _authData?["stale"] ?? ""))) {
            #if DEBUG
                if let stale = _authData?["stale"], "true" == stale {
                    print("Digest Stale. Into the breach once more.")
                }
                print("Requesting SOAP Authorization Realm for Digest")
            #endif
            
            // Get the result of a Digest challenge.
            _badIPAddress = false   // HACK ALERT! This is a semaphore to detect whether or not a given IP address failed the sniff test immediately.
            _authData = _AuthorizationSetup().authCreds(for: reqURLString, onvifInstance: self)
            
            // If the IP address was bad, we immediatey report an error, and exit.
            if _badIPAddress {
                _badIPAddress = false
                DispatchQueue.main.async {  // All callbacks happen in the main queue.
                    self._errorCallback(RVS_Fault(faultCode: .NoDeviceAtIPAddress(address: reqURLString)))
                }
                return
            } else {
                _authData?["username"] = self.loginCredentials?.login ?? ""     // Add the username, so we have it all in one place.
                _authData?["password"] = self.loginCredentials?.password ?? ""  // Add the password, so we have it all in one place.
                
                #if DEBUG   // These are printouts for debug mode.
                    if _authData?.isEmpty ?? false {
                        if .both == authMethod {
                            print("No SOAP Authorization Realm (Digest), but Trying Basic Authentication")
                        } else {
                            print("No SOAP Authorization Realm (Digest), and We Will Not Allow Basic Authorization.")
                        }
                    } else {
                        print("Received SOAP Authorization Realm for Digest: \(String(describing: _authData))")
                    }
                #endif
                
                // If they didn't play nice, we switch to basic to avoid checking for a realm every call.
                if nil == _authData && .digest != authMethod {
                    authMethod = .basic
                    soap.authorizationMethod = .AUTH_BASIC
                    #if DEBUG
                        print("Switching to Basic SOAP Authorization.")
                    #endif
                }
            }
        }
        
        // If we don't have a realm, and we have force digest selected, then we fail. Otherwise, we just blunder on, and hope the device likes us.
        if .digest != authMethod || nil != _authData {
            soap.retrievesAttributes = inRequest.isRetrieveAttributes
            soap.delegate = self    // We allow interception of delegate calls.
            soap.licenseKey = self._soapEngineLicenseKey    // So we can work on devices.
            soap.version = .VERSION_1_2
            soap.envelope = inRequest.headerNamespaceFor(self)
            soap.username = self.loginCredentials?.login ?? ""
            soap.password = self.loginCredentials?.password ?? ""
            soap.responseHeader = true  // If this is not set, you will get an empty dictionary.
            
            soap.realm = _authData?["realm"]
            
            // Set up the parameters for the SOAP call.
            if let params = inParams {
                #if DEBUG
                    print("SOAP Request Parameters: \(params)")
                #endif
                var modifiedParams: [String: Any] = [:]
                
                params.forEach {
                    var namespace = ""
                    if nil == $0.key.firstIndex(of: ":") {
                        namespace = inRequest.soapSpace + ":"
                    }
                    modifiedParams["\(namespace)\($0.key)"] = $0.value
                }
                
                soap.defaultTagName = nil
                
                modifiedParams.forEach {
                    let param = $0
                    if let array = param.value as? [Any] {
                        array.forEach {
                            soap.setValue($0, forKey: param.key)
                        }
                    } else {
                        soap.setValue(param.value, forKey: param.key)
                    }
                }
            }
            
            // This is the actual SOAPEngine request. We ask for a parsed Dictionary in response.
            type(of: self)._callSOAPEngine(soap, uri: reqURLString, action: inRequest.soapAction)
        } else {
            DispatchQueue.main.async {  // All callbacks happen in the main queue.
                self._errorCallback(RVS_Fault(faultCode: .NilRealm))
            }
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
                                        delegate: RVS_ONVIFDelegate? = nil) -> RVS_ONVIF? {
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
    // MARK: - Public Stored Instance Properties
    /* ################################################################################################################################## */
    /* ################################################################## */
    /**
     This is a String, with our IP address and TCP port.
     */
    public var ipAddressAndPort: String
    
    /* ################################################################## */
    /**
     These are our login credentials.
     */
    public var loginCredentials: LoginCredentialTuple!
    
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
    weak public var delegate: RVS_ONVIFDelegate! {
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
    
    /* ################################################################## */
    /**
     This contains our dispatchers. These are strong references.
     
     Dispatchers are how we communicate with the ONVIF devices.
     */
    public var dispatchers: [RVS_ONVIF_Dispatcher] = [] {
        didSet {
            for var dispatcher in dispatchers {
                dispatcher.owner = self
            }
        }
    }

    /* ################################################################################################################################## */
    // MARK: - Public Calculated Instance Properties
    /* ################################################################################################################################## */
    /* ################################################################## */
    /**
     Shortcut to access the core profile, as it will always be there.
     
     - returns: the core object. nil if there was an error.
     */
    public var core: RVS_ONVIF_Core! {
        return _profiles["RVS_ONVIF_Core"] as? RVS_ONVIF_Core
    }
    
    /* ################################################################## */
    /**
     Shortcut to access the device information.
     
     - returns: the device information Dictionary. nil if there was an error.
     */
    public var deviceInformation: [String: Any]! {
        return core?.deviceInformation
    }
    
    /* ################################################################## */
    /**
     Shortcut to access the services.
     
     - returns: the services Array. nil if there was an error.
     */
    public var services: [String: RVS_ONVIF_Core.Service]! {
        return core?.services
    }
    
    /* ################################################################## */
    /**
     Shortcut to access the scopes.
     
     - returns: the scopes Array. nil if there was an error.
     */
    public var scopes: [RVS_ONVIF_Core.Scope]! {
        return core?.scopes
    }
    
    /* ################################################################## */
    /**
     Shortcut to access the capabilities.
     
     - returns: the capability instance. nil if there was an error.
     */
    public var capabilities: RVS_ONVIF_Core.Capabilities! {
        return core?.capabilities
    }
    
    /* ################################################################## */
    /**
     Shortcut to access the default service capabilities.
     
     - returns: the service capability instance. nil if there was an error.
     */
    public var serviceCapabilities: RVS_ONVIF_Core.ServiceCapabilities! {
        return core?.serviceCapabilities
    }
    
    /* ################################################################## */
    /**
     Shortcut to access the device network interface information.
     
     - returns: The cached device network interface Array.
     */
    public var networkInterfaces: [RVS_ONVIF_Core.NetworkInterface]! {
        return core?.networkInterfaces
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
            /// There was no response at the given IP address.
            case NoDeviceAtIPAddress(address: String)
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
                    
                case .NoDeviceAtIPAddress:
                    ret = "NoDeviceAtIPAddress"
                    
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
         Sender and Receiver subcodes (per namespace)
         */
        public enum Subcode: String, Error {
            
            /* ############# SENDER ENUMS ############# */
            
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
            
            /* ############# RECEIVER ENUMS ############# */
            
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
