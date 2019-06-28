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
    /* ################################################################## */
    /**
     Set up prior to every test.
     */
    override func setUp() {
    }
    
    func testSimple() {
        let testTarget = RVS_ONVIF_TestTarget(mock: AxisM5525ECameraMock(), delegate: self)
        let expectation = XCTestExpectation()
        
        print(String(reflecting: testTarget))
        
        // Wait until the expectation is fulfilled, with a timeout of half a second.
        wait(for: [expectation], timeout: 10)
        
        print(String(reflecting: testTarget))
    }
}
