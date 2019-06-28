/**
 © Copyright 2019, The Great Rift Valley Software Company. All rights reserved.
 
 This code is proprietary and confidential code,
 It is NOT to be reused or combined into any application,
 unless done so, specifically under written license from The Great Rift Valley Software Company.
 
 The Great Rift Valley Software Company: https://riftvalleysoftware.com
 */

import XCTest

/* ###################################################################################################################################### */
/**
 This is a base class, used for specific tests. It implements a RVS_ONVIF-derived test class instance, and logs in with a fictitous ID and IP Address/port.
 This conforms to the RVS_ONVIFDelegate protocol, and registers as the instance delegate, so derived classes can use that.
 It will not work on-device, as this has a nil SOAPEngine key.
 You can change the IP Address/Port and login ID prior to calling this class instance's setup() method.
 */
class RVS_ONVIF_Generic_TestBaseClass: XCTestCase, RVS_ONVIFDelegate {
    /// This will be used to count expectations.
    var expectation: XCTestExpectation! = nil
    /// Holds the mock device being tested.
    var mockDevice: RVS_ONVIF_TestTarget_MockDevice! = nil
    /// Holds the target being tested.
    var testTarget: RVS_ONVIF_TestTarget! = nil

    /* ############################################################################################################################## */
    // MARK: - RVS_ONVIFDelegate Methods
    /* ############################################################################################################################## */
    /* ################################################################## */
    /**
     This is a "general purpose" callback that is made immediately before any other callback. It allows the client to interrupt the parsing process.
     It contains the information that would be sent to the following specialized callback, but as the initial partially-parsed dictionary from SOAPEngine.
     This is not called for errors.
     
     - parameter inONVIFInstance: The RVS_ONVIF instance that is calling the delegate.
     - parameter rawDataPreview: The partially-parsed data to be sent for specific parsing in the next callback (can be nil).
     - parameter deviceRequest: The request object (can be nil).
     - returns: false, if the following specialized callback should be made. If true, then the following callback will not be made.
     */
    func onvifInstance(_ inONVIFInstance: RVS_ONVIF, rawDataPreview inRawDataPreview: [String: Any]!, deviceRequest inDeviceRequest: RVS_ONVIF_DeviceRequestProtocol!) -> Bool {
        return false
    }
    
    /* ################################################################## */
    /**
     This is called whenever an error is encountered by the RVS_ONVIF framework.
     
     This is not required, but you'd be well-advised to implement it.
     
     - parameter inONVIFInstance: The RVS_ONVIF instance that is calling the delegate.
     - parameter failureWithReason: An enumeration, with associated values that refine the issue.
     */
    func onvifInstance(_ inONVIFInstance: RVS_ONVIF, failureWithReason inFailureReason: RVS_ONVIF.RVS_Fault!) {
        XCTFail("Failure Callback: \(String(describing: inFailureReason))")
        expectation.fulfill()
    }
    
    /* ################################################################## */
    /**
     This is called when a response is a simple empty packet. It is a simple "ack."
     
     This is not required, but it's a good idea to implement it, as many responses use it.
     
     - parameter inONVIFInstance: The RVS_ONVIF instance that is calling the delegate.
     - parameter simpleResponseToRequest: An enumeration, with the request that is being satisfied by this response.
     */
    func onvifInstance(_ inONVIFInstance: RVS_ONVIF, simpleResponseToRequest inSimpleResponseToRequest: RVS_ONVIF_DeviceRequestProtocol!) {
    }
    
    /* ################################################################## */
    /**
     This is called if the instance is completely initialized. It is optional.
     
     - parameter inONVIFInstance: The RVS_ONVIF instance that is calling the delegate.
     */
    func onvifInstanceInitialized(_ inONVIFInstance: RVS_ONVIF) {
    }
    
    /* ################################################################## */
    /**
     This is called if the instance is "deinitialized." It is optional.
     
     - parameter inONVIFInstance: The RVS_ONVIF instance that is calling the delegate.
     */
    func onvifInstanceDeinitialized(_ inONVIFInstance: RVS_ONVIF) {
    }
}
