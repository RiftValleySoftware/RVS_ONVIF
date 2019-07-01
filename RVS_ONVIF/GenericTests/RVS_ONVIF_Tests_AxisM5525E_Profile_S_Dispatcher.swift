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
 Runs tests on a mock AXIS camera.
 */
class RVS_ONVIF_Tests_AxisM5525E_Profile_S_Dispatcher: RVS_ONVIF_Generic_TestBaseClass, RVS_ONVIF_Profile_SDispatcher {
    var owner: RVS_ONVIF!
    
    /* ############################################################################################################################## */
    // MARK: - Evaluation Methods
    /* ############################################################################################################################## */
    /* ################################################################## */
    /**
     */
    func evaluateProfiles(_ inProfiles: [RVS_ONVIF_Profile_S.Profile]) {
        XCTAssertEqual(inProfiles.count, 2)
    }
    
    /* ############################################################################################################################## */
    // MARK: - RVS_ONVIF_Profile_SDispatcher Methods
    /* ############################################################################################################################## */
    /* ################################################################## */
    /**
     This method is required to be implemented by the final dispatcher. This method is called to deliver the response from the device.
     
     - parameter inCommand: The command to which this is a response.
     - parameter params: The data returned (and parsed) from the device. It can be any one of the various data types.
     - returns: true, if the response was consumed. Can be ignored.
     */
    @discardableResult func deliverResponse(_ inCommand: RVS_ONVIF_DeviceRequestProtocol, params: Any!) -> Bool {
        if "trt:GetProfiles" == inCommand.soapAction {
            if let params = params as? [RVS_ONVIF_Profile_S.Profile] {
                evaluateProfiles(params)
            }
            
            expectation.fulfill()
            return true
        } else {
            XCTFail("Unknown Response!")
            expectation.fulfill()
            return false
        }
    }
    
    /* ############################################################################################################################## */
    // MARK: - RVS_ONVIFDelegate Methods
    /* ############################################################################################################################## */
    /* ################################################################## */
    /**
     This is called if the instance is completely initialized. It is optional.
     
     - parameter inONVIFInstance: The RVS_ONVIF instance that is calling the delegate.
     */
    override func onvifInstanceInitialized(_ inONVIFInstance: RVS_ONVIF) {
        let profiles = owner.profiles
        if let profileHandler = profiles["RVS_ONVIF_Profile_S"] as? RVS_ONVIF_Profile_S {
            profileHandler.fetchProfiles()
            expectation.fulfill()
        } else {
            XCTFail("Can't Find Profile S Handler")
        }
    }

    /* ############################################################################################################################## */
    // MARK: - Test Methods
    /* ############################################################################################################################## */
    /* ################################################################## */
    /**
     Just setting up our basic structure.
     */
    override func setUp() {
        mockDevice = AxisM5525ECameraMock()
        expectation = XCTestExpectation()
        expectation.expectedFulfillmentCount = 2
    }
    
    /* ################################################################## */
    /**
     Tests simple initialization (actually, not so simple).
     
     This is a "brute-force" test to make sure that the read-in responses result in an objct that is properly set up.
     */
    func testGetProfiles() {
        testTarget = RVS_ONVIF_TestTarget(mock: mockDevice, delegate: self, dispatchers: [self])
        wait(for: [expectation], timeout: 10)
        expectation = nil
    }
}
