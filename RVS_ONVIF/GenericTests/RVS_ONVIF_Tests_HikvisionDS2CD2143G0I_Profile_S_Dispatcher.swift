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
 Runs tests on a mock Hikvision camera.
 */
class RVS_ONVIF_Tests_HikvisionDS2CD2143G0I_Profile_S_Dispatcher: RVS_ONVIF_Generic_TestBaseClass, RVS_ONVIF_Profile_SDispatcher {
    var owner: RVS_ONVIF!
    
    /* ############################################################################################################################## */
    // MARK: - Evaluation Methods
    /* ############################################################################################################################## */
    /* ################################################################## */
    /**
     */
    func evaluateProfiles(_ inProfiles: [RVS_ONVIF_Profile_S.Profile]) {
        XCTAssertEqual(inProfiles.count, 3)
        
        let profile = inProfiles[0]
        XCTAssertEqual(profile.owner, testTarget)
        XCTAssertEqual("mainStream", profile.name)
        XCTAssertEqual("Profile_1", profile.token)
        XCTAssertNil(profile.ptzConfiguration)

        XCTAssertEqual(profile.videoSourceConfiguration.owner, testTarget)
        XCTAssertEqual("VideoSourceConfig", profile.videoSourceConfiguration.name)
        XCTAssertEqual("VideoSourceToken", profile.videoSourceConfiguration.token)
        XCTAssertEqual("VideoSource_1", profile.videoSourceConfiguration.sourceToken)
        XCTAssertEqual(3, profile.videoSourceConfiguration.useCount)
        XCTAssertEqual(CGRect(x: 0, y: 0, width: 2688, height: 1520), profile.videoSourceConfiguration.bounds)

        XCTAssertEqual(profile.videoEncoderConfiguration.owner, testTarget)
        XCTAssertEqual("VideoEncoder_1", profile.videoEncoderConfiguration.name)
        XCTAssertEqual("VideoEncoderToken_1", profile.videoEncoderConfiguration.token)
        XCTAssertEqual(1, profile.videoEncoderConfiguration.useCount)
        XCTAssertEqual(.h264, profile.videoEncoderConfiguration.encoding)
        XCTAssertEqual(CGSize(width: 1920, height: 1080), profile.videoEncoderConfiguration.resolution)
        XCTAssertEqual(5, profile.videoEncoderConfiguration.timeoutInSeconds)
        XCTAssertEqual(5, profile.videoEncoderConfiguration.quality)

        if let multicast = profile.videoEncoderConfiguration.multicast {
            XCTAssertEqual(multicast.owner, testTarget)
            XCTAssertEqual("0.0.0.0", multicast.ipAddress.address)
            XCTAssertFalse(multicast.autoStart)
            XCTAssertEqual(8860, multicast.port)
            XCTAssertNotNil(multicast.ttl)
            print(String(reflecting: multicast.ttl))
            XCTAssertEqual(128, multicast.ttl.second)
            XCTAssertNil(multicast.ttl.minute)
            XCTAssertNil(multicast.ttl.hour)
        } else {
            XCTFail("NoMulticast")
        }

        XCTAssertEqual(profile.videoEncoderConfiguration.rateControl.owner, testTarget)
        XCTAssertEqual(4, profile.videoEncoderConfiguration.rateControl.frameRateLimit)
        XCTAssertEqual(1, profile.videoEncoderConfiguration.rateControl.encodingInterval)
        XCTAssertEqual(12288, profile.videoEncoderConfiguration.rateControl.bitRateLimit)
        
        if let encodingParameters = profile.videoEncoderConfiguration.encodingParameters as? [String:String] {
            XCTAssertEqual(2, encodingParameters.count)
            XCTAssertEqual("Main", encodingParameters["H264Profile"])
            XCTAssertEqual("4", encodingParameters["GovLength"])
        } else {
            XCTFail("No Encoding Parameters")
        }

        if 1 < inProfiles.count {
            let profile = inProfiles[1]
            XCTAssertEqual(profile.owner, testTarget)
            XCTAssertEqual("subStream", profile.name)
            XCTAssertEqual("Profile_2", profile.token)
            XCTAssertNil(profile.ptzConfiguration)

            XCTAssertEqual(profile.videoSourceConfiguration.owner, testTarget)
            XCTAssertEqual("VideoSourceConfig", profile.videoSourceConfiguration.name)
            XCTAssertEqual("VideoSourceToken", profile.videoSourceConfiguration.token)
            XCTAssertEqual("VideoSource_1", profile.videoSourceConfiguration.sourceToken)
            XCTAssertEqual(3, profile.videoSourceConfiguration.useCount)
            XCTAssertEqual(CGRect(x: 0, y: 0, width: 2688, height: 1520), profile.videoSourceConfiguration.bounds)
            
            XCTAssertEqual(profile.videoEncoderConfiguration.owner, testTarget)
            XCTAssertEqual("VideoEncoder_2", profile.videoEncoderConfiguration.name)
            XCTAssertEqual("VideoEncoderToken_2", profile.videoEncoderConfiguration.token)
            XCTAssertEqual(1, profile.videoEncoderConfiguration.useCount)
            XCTAssertEqual(.jpeg, profile.videoEncoderConfiguration.encoding)
            XCTAssertEqual(CGSize(width: 640, height: 480), profile.videoEncoderConfiguration.resolution)
            XCTAssertEqual(5, profile.videoEncoderConfiguration.timeoutInSeconds)
            XCTAssertEqual(5, profile.videoEncoderConfiguration.quality)

            if let multicast = profile.videoEncoderConfiguration.multicast {
                XCTAssertEqual(multicast.owner, testTarget)
                XCTAssertEqual("0.0.0.0", multicast.ipAddress.address)
                XCTAssertFalse(multicast.autoStart)
                XCTAssertEqual(8866, multicast.port)
                XCTAssertNotNil(multicast.ttl)
                print(String(reflecting: multicast.ttl))
                XCTAssertEqual(128, multicast.ttl.second)
                XCTAssertNil(multicast.ttl.minute)
                XCTAssertNil(multicast.ttl.hour)
            } else {
                XCTFail("NoMulticast")
            }
            
            XCTAssertEqual(profile.videoEncoderConfiguration.rateControl.owner, testTarget)
            XCTAssertEqual(10, profile.videoEncoderConfiguration.rateControl.frameRateLimit)
            XCTAssertEqual(1, profile.videoEncoderConfiguration.rateControl.encodingInterval)
            XCTAssertEqual(768, profile.videoEncoderConfiguration.rateControl.bitRateLimit)
        }

        if 2 < inProfiles.count {
            let profile = inProfiles[2]
            XCTAssertEqual(profile.owner, testTarget)
            XCTAssertEqual("thirdStream", profile.name)
            XCTAssertEqual("Profile_3", profile.token)
            XCTAssertNil(profile.ptzConfiguration)
            
            XCTAssertEqual(profile.videoSourceConfiguration.owner, testTarget)
            XCTAssertEqual("VideoSourceConfig", profile.videoSourceConfiguration.name)
            XCTAssertEqual("VideoSourceToken", profile.videoSourceConfiguration.token)
            XCTAssertEqual("VideoSource_1", profile.videoSourceConfiguration.sourceToken)
            XCTAssertEqual(3, profile.videoSourceConfiguration.useCount)
            XCTAssertEqual(CGRect(x: 0, y: 0, width: 2688, height: 1520), profile.videoSourceConfiguration.bounds)
            
            XCTAssertEqual(profile.videoEncoderConfiguration.owner, testTarget)
            XCTAssertEqual("VideoEncoder_3", profile.videoEncoderConfiguration.name)
            XCTAssertEqual("VideoEncoderToken_3", profile.videoEncoderConfiguration.token)
            XCTAssertEqual(1, profile.videoEncoderConfiguration.useCount)
            XCTAssertEqual(.h264, profile.videoEncoderConfiguration.encoding)
            XCTAssertEqual(CGSize(width: 1280, height: 720), profile.videoEncoderConfiguration.resolution)
            XCTAssertEqual(5, profile.videoEncoderConfiguration.timeoutInSeconds)
            XCTAssertEqual(3, profile.videoEncoderConfiguration.quality)
            
            if let multicast = profile.videoEncoderConfiguration.multicast {
                XCTAssertEqual(multicast.owner, testTarget)
                XCTAssertEqual("0.0.0.0", multicast.ipAddress.address)
                XCTAssertFalse(multicast.autoStart)
                XCTAssertEqual(8872, multicast.port)
                XCTAssertNotNil(multicast.ttl)
                print(String(reflecting: multicast.ttl))
                XCTAssertEqual(128, multicast.ttl.second)
                XCTAssertNil(multicast.ttl.minute)
                XCTAssertNil(multicast.ttl.hour)
            } else {
                XCTFail("NoMulticast")
            }
            
            XCTAssertEqual(profile.videoEncoderConfiguration.rateControl.owner, testTarget)
            XCTAssertEqual(10, profile.videoEncoderConfiguration.rateControl.frameRateLimit)
            XCTAssertEqual(1, profile.videoEncoderConfiguration.rateControl.encodingInterval)
            XCTAssertEqual(768, profile.videoEncoderConfiguration.rateControl.bitRateLimit)
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
        mockDevice = HikvisionDS2CD2143G0IMock()
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
