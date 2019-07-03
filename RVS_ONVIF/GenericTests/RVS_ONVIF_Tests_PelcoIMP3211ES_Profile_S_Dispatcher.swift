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
 Runs tests on a mock Pelco camera.
 */
class RVS_ONVIF_Tests_PelcoIMP3211ES_Profile_S_Dispatcher: RVS_ONVIF_Generic_TestBaseClass, RVS_ONVIF_Profile_SDispatcher {
    var owner: RVS_ONVIF!
    var profileTag: String = "stream1"

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
        XCTAssertEqual("Profile 0", profile.name)
        XCTAssertEqual("0", profile.token)
        XCTAssertNil(profile.ptzConfiguration)

        XCTAssertEqual(profile.videoSourceConfiguration.owner, testTarget)
        XCTAssertEqual("VideoSource 1", profile.videoSourceConfiguration.name)
        XCTAssertEqual("1", profile.videoSourceConfiguration.token)
        XCTAssertEqual("1", profile.videoSourceConfiguration.sourceToken)
        XCTAssertEqual(2, profile.videoSourceConfiguration.useCount)
        XCTAssertEqual(CGRect(x: 0, y: 0, width: 4000, height: 3000), profile.videoSourceConfiguration.bounds)

        XCTAssertEqual(profile.videoEncoderConfiguration.owner, testTarget)
        XCTAssertEqual("VideoEncoder 1", profile.videoEncoderConfiguration.name)
        XCTAssertEqual("1", profile.videoEncoderConfiguration.token)
        XCTAssertEqual(1, profile.videoEncoderConfiguration.useCount)
        XCTAssertEqual(.h264, profile.videoEncoderConfiguration.encoding)
        XCTAssertEqual(CGSize(width: 2048, height: 1536), profile.videoEncoderConfiguration.resolution)
        XCTAssertEqual(60, profile.videoEncoderConfiguration.timeoutInSeconds)
        XCTAssertEqual(57, profile.videoEncoderConfiguration.quality)

        if let multicast = profile.videoEncoderConfiguration.multicast {
            XCTAssertEqual(multicast.owner, testTarget)
            XCTAssertEqual("239.168.4.18", multicast.ipAddress.address)
            XCTAssertFalse(multicast.autoStart)
            XCTAssertEqual(3586, multicast.port)
            XCTAssertNotNil(multicast.ttl)
            XCTAssertEqual(10, multicast.ttl.second)
            XCTAssertNil(multicast.ttl.minute)
            XCTAssertNil(multicast.ttl.hour)
        } else {
            XCTFail("NoMulticast")
        }

        XCTAssertEqual(profile.videoEncoderConfiguration.rateControl.owner, testTarget)
        XCTAssertEqual(10, profile.videoEncoderConfiguration.rateControl.frameRateLimit)
        XCTAssertEqual(1, profile.videoEncoderConfiguration.rateControl.encodingInterval)
        XCTAssertEqual(7000, profile.videoEncoderConfiguration.rateControl.bitRateLimit)
        
        if let encodingParameters = profile.videoEncoderConfiguration.encodingParameters as? [String:String] {
            XCTAssertEqual(2, encodingParameters.count)
            XCTAssertEqual("High", encodingParameters["H264Profile"])
            XCTAssertEqual("10", encodingParameters["GovLength"])
        } else {
            XCTFail("No Encoding Parameters")
        }

        profile.fetchURI()

        if 1 < inProfiles.count {
            let profile = inProfiles[1]
            XCTAssertEqual(profile.owner, testTarget)
            XCTAssertEqual("Profile 1", profile.name)
            XCTAssertEqual("1", profile.token)
            XCTAssertNil(profile.ptzConfiguration)
            
            XCTAssertEqual(profile.videoSourceConfiguration.owner, testTarget)
            XCTAssertEqual("VideoSource 1", profile.videoSourceConfiguration.name)
            XCTAssertEqual("1", profile.videoSourceConfiguration.token)
            XCTAssertEqual("1", profile.videoSourceConfiguration.sourceToken)
            XCTAssertEqual(2, profile.videoSourceConfiguration.useCount)
            XCTAssertEqual(CGRect(x: 0, y: 0, width: 4000, height: 3000), profile.videoSourceConfiguration.bounds)
            
            XCTAssertEqual(profile.videoEncoderConfiguration.owner, testTarget)
            XCTAssertEqual("VideoEncoder 2", profile.videoEncoderConfiguration.name)
            XCTAssertEqual("2", profile.videoEncoderConfiguration.token)
            XCTAssertEqual(1, profile.videoEncoderConfiguration.useCount)
            XCTAssertEqual(.h264, profile.videoEncoderConfiguration.encoding)
            XCTAssertEqual(CGSize(width: 800, height: 600), profile.videoEncoderConfiguration.resolution)
            XCTAssertEqual(60, profile.videoEncoderConfiguration.timeoutInSeconds)
            XCTAssertEqual(24, profile.videoEncoderConfiguration.quality)
            
            if let multicast = profile.videoEncoderConfiguration.multicast {
                XCTAssertEqual(multicast.owner, testTarget)
                XCTAssertEqual("239.168.4.18", multicast.ipAddress.address)
                XCTAssertFalse(multicast.autoStart)
                XCTAssertEqual(2538, multicast.port)
                XCTAssertNotNil(multicast.ttl)
                XCTAssertEqual(10, multicast.ttl.second)
                XCTAssertNil(multicast.ttl.minute)
                XCTAssertNil(multicast.ttl.hour)
            } else {
                XCTFail("NoMulticast")
            }
            
            XCTAssertEqual(profile.videoEncoderConfiguration.rateControl.owner, testTarget)
            XCTAssertEqual(20, profile.videoEncoderConfiguration.rateControl.frameRateLimit)
            XCTAssertEqual(1, profile.videoEncoderConfiguration.rateControl.encodingInterval)
            XCTAssertEqual(3000, profile.videoEncoderConfiguration.rateControl.bitRateLimit)
            
            if let encodingParameters = profile.videoEncoderConfiguration.encodingParameters as? [String:String] {
                XCTAssertEqual(2, encodingParameters.count)
                XCTAssertEqual("High", encodingParameters["H264Profile"])
                XCTAssertEqual("20", encodingParameters["GovLength"])
            } else {
                XCTFail("No Encoding Parameters")
            }

            profile.fetchURI()
        }
    }
    
    /* ################################################################## */
    /**
     */
    func evaluateStreamURI(_ inStreamURI: RVS_ONVIF_Profile_S.Stream_URI) {
        XCTAssertEqual(inStreamURI.owner, testTarget)
        XCTAssertEqual(inStreamURI.uri, URL(string: "rtsp://192.168.4.18:554/\(profileTag)"))
        profileTag = "stream2" // The reason I do this here, is because the callback can happen before the call to the second URI has been processed. This makes sure it happens afterwards.
        XCTAssertFalse(inStreamURI.invalidAfterConnect)
        XCTAssertFalse(inStreamURI.invalidAfterReboot)
        XCTAssertEqual(inStreamURI.timeoutInSeconds, 0)
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
        if "trt:GetStreamUri" == inCommand.soapAction {
            if let params = params as? RVS_ONVIF_Profile_S.Stream_URI {
                evaluateStreamURI(params)
            }
            return true
        } else if "trt:GetProfiles" == inCommand.soapAction {
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
        mockDevice = PelcoIMP3211ESCameraMock()
        expectation = XCTestExpectation()
        expectation.expectedFulfillmentCount = 2
    }
    
    /* ################################################################## */
    /**
     Tests Getting the profiles.
     */
    func testGetProfiles() {
        testTarget = RVS_ONVIF_TestTarget(mock: mockDevice, delegate: self, dispatchers: [self])
        wait(for: [expectation], timeout: 10)
        expectation = nil
    }
}
