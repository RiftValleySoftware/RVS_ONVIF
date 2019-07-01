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
        
        let profile = inProfiles[0]
        XCTAssertEqual(profile.owner, testTarget)
        XCTAssertEqual("profile_1_h264", profile.token)
        
        XCTAssertEqual(profile.videoSourceConfiguration.owner, testTarget)
        XCTAssertEqual("0", profile.videoSourceConfiguration.token)
        XCTAssertEqual("0", profile.videoSourceConfiguration.sourceToken)
        XCTAssertEqual("user0", profile.videoSourceConfiguration.name)
        XCTAssertEqual(2, profile.videoSourceConfiguration.useCount)
        XCTAssertEqual(CGRect(x: 0, y: 0, width: 1920, height: 1080), profile.videoSourceConfiguration.bounds)

        XCTAssertEqual(profile.videoEncoderConfiguration.owner, testTarget)
        XCTAssertEqual("default_1 h264", profile.videoEncoderConfiguration.name)
        XCTAssertEqual("default_1_h264", profile.videoSourceConfiguration.token)
        XCTAssertEqual(1, profile.videoEncoderConfiguration.useCount)
        XCTAssertEqual(.h264, profile.videoEncoderConfiguration.encoding)
        XCTAssertEqual(CGSize(width: 1920, height: 1080), profile.videoEncoderConfiguration.resolution)
        XCTAssertEqual(70, profile.videoEncoderConfiguration.quality)
        XCTAssertEqual(60, profile.videoEncoderConfiguration.timeoutInSeconds)

        XCTAssertEqual(profile.videoEncoderConfiguration.rateControl.owner, testTarget)
        XCTAssertEqual(30, profile.videoEncoderConfiguration.rateControl.frameRateLimit)
        XCTAssertEqual(1, profile.videoEncoderConfiguration.rateControl.encodingInterval)
        XCTAssertEqual(2147483647, profile.videoEncoderConfiguration.rateControl.bitRateLimit)

        if 1 < inProfiles.count {
            let profile = inProfiles[1]
            XCTAssertEqual(profile.owner, testTarget)
            XCTAssertEqual("profile_1_jpeg", profile.token)
        }
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
