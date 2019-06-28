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
 This tests the basic startup/initialization.
 */
class RVS_ONVIF_Initialization_Tests: RVS_ONVIF_Generic_TestBaseClass {
    /* ############################################################################################################################## */
    // MARK: - Internal Instance RVS_ONVIFDelegate Methods
    /* ############################################################################################################################## */
    /* ################################################################## */
    /**
     We override the initialization complete callback in order to fulfill our expectation.
     */
    override func onvifInstanceInitialized(_ inONVIFInstance: RVS_ONVIF) {
        expectation.fulfill()
    }
    
    /* ############################################################################################################################## */
    // MARK: - Test Methods
    /* ############################################################################################################################## */
    /* ################################################################## */
    /**
     Tests simple initialization (actually, not so simple).
     */
    func testInitializers() {
        mockDevice = AxisM5525ECameraMock()
        expectation = XCTestExpectation()
        testTarget = RVS_ONVIF_TestTarget(mock: mockDevice, delegate: self)
        wait(for: [expectation], timeout: 10)
        expectation = nil
    }
}
