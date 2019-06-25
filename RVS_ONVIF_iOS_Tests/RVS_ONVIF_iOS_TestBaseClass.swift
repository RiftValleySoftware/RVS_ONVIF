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
    var expectation: XCTestExpectation!
    
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
        _testingSetup = true    // By setting this to true, we intercept communications to a device, allowing us to inject our own data.
        defer { // We do this, to make sure that didSet gets called.
            let core = (RVS_ONVIF_Core(owner: self))
            core.supportedNamespaces = type(of: core).namespaces
            _profiles[String(describing: type(of: core).self)] = core
            authMethod = inAuthMethod
            delegate = inDelegate
        }
    }
    
    /* ################################################################## */
    /**
     This may be called in non-main threads.
     
     This is a special base method that is designed to be overridden. If the module is set to be tested, then this is called, instead of the regular method.
     
     - parameter inSOAPEngine: The SOAPEngine instance calling this method. It may be nil.
     - parameter didBeforeSendingURLRequest: This is a URL Request that will be sent. You can modify this.
     - returns nil.
     */
    override internal func _soapEngine(_ soapEngine: SOAPEngine!, didBeforeSendingURLRequest inRequest: NSMutableURLRequest!) -> NSMutableURLRequest! {
        print("didBeforeSendingURLRequest: \(String(describing: inRequest))")
        expectation.fulfill()
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
        let string = String(data: inData, encoding: .utf8)
        print("didBeforeParsingResponseData: \(String(reflecting: string))")
        expectation.fulfill()
        return inData
    }
    
    public func soapEngine(_ inSOAPEngine: SOAPEngine!, didReceiveDataSize inCurrent: NSNumber!, total inTotal: NSNumber!) {
        print("didReceiveDataSize: \(String(describing: inCurrent)), total: \(String(describing: inTotal))")
    }
    
    public func soapEngine(_ inSOAPEngine: SOAPEngine!, didSendDataSize inCurrent: NSNumber!, total inTotal: NSNumber!) {
        print("didReceiveDataSize: \(String(describing: inCurrent)), total: \(String(describing: inTotal))")
    }
    
    public func soapEngine(_ inSOAPEngine: SOAPEngine!, didReceiveResponseCode inStatusCode: NSNumber!) -> Bool {
        print("didReceiveResponseCode: \(String(describing: inStatusCode))")

        return false
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
    var authCredentials: RVS_ONVIF.LoginCredentialTuple = RVS_ONVIF.LoginCredentialTuple(login: "root", password: "$4cx4QjmgufQmq6b")
    var authMehod: RVS_ONVIF.SOAPAuthMethod = .both
//    var ipAndPort: String = "192.168.4.12:80"
    var ipAndPort: String = "127.0.0.1:80"

    /* ################################################################## */
    /**
     Set up prior to every test.
     */
    override func setUp() {
    }
    
    func testSimple() {
        let testTarget = RVS_ONVIF_TestTarget(ipAddressAndPort: ipAndPort, loginCredentials: authCredentials, authMethod: authMehod, delegate: self)
        
        testTarget.expectation = XCTestExpectation()
        testTarget.expectation.expectedFulfillmentCount = 2
        
        print(String(reflecting: testTarget))
        
        // Wait until the expectation is fulfilled, with a timeout of half a second.
        wait(for: [testTarget.expectation], timeout: 10)

        print(String(reflecting: testTarget))
    }
}
