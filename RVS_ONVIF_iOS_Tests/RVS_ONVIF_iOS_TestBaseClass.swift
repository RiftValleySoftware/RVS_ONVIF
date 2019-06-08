/**
 © Copyright 2019, The Great Rift Valley Software Company. All rights reserved.
 
 This code is proprietary and confidential code,
 It is NOT to be reused or combined into any application,
 unless done so, specifically under written license from The Great Rift Valley Software Company.
 
 The Great Rift Valley Software Company: https://riftvalleysoftware.com
 */

import XCTest
import SOAPEngine64

/* ###################################################################################################################################### */
/**
 This is a special testing subclass of the RVS_ONVIF class. It will implement the ability to insert mock transactions into the SOAPEngine.
 */
class RVS_ONVIF_TestTarget: RVS_ONVIF {
    /* ################################################################## */
    /**
     This is a special intializer for this class. We eschew the main factory method in favor of our own instantiator.
     
     - parameter ipAddressAndPort: This is a String, containing a standard IPV4 address and port (123.123.123.123:1234)
     - parameter loginCredentials: This is a tuple, containing the login ID and password (Strings) for the camera. It cannot have either field empty (login: String, password: String)
     - parameter soapEngineLicenseKey: This is a String, with the SOAPEngine license key. It is optional (defaults to blank). If not provided, SOAPEngine will only work in the simulator.
     - parameter authMethod: This is an optional parameter, indicating the authorization method. Default is both.
     - parameter delegate: This is an optional (default is nil) parameter that allows you to specify a delegate up front. If it is provided, the instance will be immediately initialized.
     */
    internal init(ipAddressAndPort inIPAddressAndPort: String,
                  loginCredentials inCredentials: LoginCredentialTuple,
                  authMethod inAuthMethod: SOAPAuthMethod = .both,
                  delegate inDelegate: RVS_ONVIFDelegate! = nil) {
        super.init()
        ipAddressAndPort = inIPAddressAndPort
        loginCredentials = inCredentials
        defer { // We do this, to make sure that didSet gets called.
            let core = (RVS_ONVIF_Core(owner: self))
            core.supportedNamespaces = type(of: core).namespaces
            _profiles[String(describing: type(of: core).self)] = core
            authMethod = inAuthMethod
            delegate = inDelegate
        }
    }
    
    /* ################################################################################################################################## */
    // MARK: - Public SOAPEngineDelegate Instance Methods
    /* ################################################################################################################################## */
    /* ################################################################## */
    /**
     This may be called in non-main threads.
     
     This is called before sending out a request. It has the request formed by SOAPEngine.
     We use this method to form our own Digest Auth.
    
     We override, because we are actually replacing a base class implementation.

     - parameter inSOAPEngine: The SOAPEngine instance calling this method. It may be nil.
     - parameter didBeforeSending: This is a URL Request that will be sent. You can modify this.
     - returns nil.
     */
    override public func soapEngine(_ soapEngine: SOAPEngine!, didBeforeSending inRequest: NSMutableURLRequest!) -> NSMutableURLRequest! {
        print("didBeforeSending: \(String(describing: inRequest))")
        
        return nil
    }
    
    /* ################################################################## */
    /**
     This may be called in non-main threads.
     
     This is called before the data is sent into the parser.
     
     - parameter inSOAPEngine: The SOAPEngine instance calling this method. It may be nil.
     - parameter didBeforeParsingResponseData: The data that will be parsed. You can modify this.
     - returns a Data object. It should be the inData parameter, unchanged.
     */
    public func soapEngine(_ inSOAPEngine: SOAPEngine!, didBeforeParsingResponseData inData: Data!) -> Data! {
        print("beforeParsingData: \(String(describing: inData))")
        
        return inData
    }
}

/* ###################################################################################################################################### */
/**
 This is a base class, used for specific tests. It implements a RVS_ONVIF-derived test class instance, and logs in with a fictitous ID and IP Address/port.
 This conforms to the RVS_ONVIFDelegate protocol, and registers as the instance delegate, so derived classes can use that.
 It will not work on-device, as this has a nil SOAPEngine key.
 You can change the IP Address/Port and login ID prior to calling this class instance's setup() method.
 */
class RVS_ONVIF_iOS_TestBaseClass: XCTestCase, RVS_ONVIFDelegate {
    var testTarget: RVS_ONVIF_TestTarget!
    var authCredentials: RVS_ONVIF.LoginCredentialTuple = RVS_ONVIF.LoginCredentialTuple(login: "test", password: "test")
    var authMehod: RVS_ONVIF.SOAPAuthMethod = .both
    
    /* ################################################################## */
    /**
     Set up prior to every test.
     */
    override func setUp() {
        testTarget = RVS_ONVIF_TestTarget(ipAddressAndPort: "123.123.123.123:1234", loginCredentials: authCredentials, authMethod: authMehod, delegate: self)
    }
}
