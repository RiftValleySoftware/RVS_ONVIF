/**
 © Copyright 2019, The Great Rift Valley Software Company. All rights reserved.
 
 This code is proprietary and confidential code,
 It is NOT to be reused or combined into any application,
 unless done so, specifically under written license from The Great Rift Valley Software Company.
 
 The Great Rift Valley Software Company: https://riftvalleysoftware.com
 */

import Cocoa
import RVS_ONVIF_MacOS

/* ################################################################################################################################## */
// MARK: - Dispatch Core Functions
/* ################################################################################################################################## */
class RVS_ONVIF_Mac_Test_Harness_Profile_SDispatcher: RVS_ONVIF_Mac_Test_Harness_Dispatcher, RVS_ONVIF_Profile_SDelegate {
    /* ################################################################## */
    /**
     This is called to deliver the device ONVIF profiles.
     
     - parameter instance: The RVS_ONVIF instance that is calling the delegate.
     - parameter getProfiles: An Array of Profile objects.
     */
    func onvifInstance(_ instance: RVS_ONVIF, getProfiles: [RVS_ONVIF_Profile_S.Profile]) {
        #if DEBUG
            print("Delegate onvifInstance:simpleResponseToRequest(\(String(describing: getProfiles))")
        #endif
    }
    
    /* ################################################################## */
    /**
     This is called to deliver the device stream URI.
     
     - parameter instance: The RVS_ONVIF instance that is calling the delegate.
     - parameter getStreamURI: The Stream_URI instance that contains the ONVIF response.
     */
    func onvifInstance(_ instance: RVS_ONVIF, getStreamURI: RVS_ONVIF_Profile_S.Stream_URI) {
        #if DEBUG
            print("Delegate onvifInstance:simpleResponseToRequest(\(String(describing: getStreamURI))")
        #endif
    }
    
    /* ################################################################## */
    /**
     This is called to deliver the device stream URI.
     
     - parameter instance: The RVS_ONVIF instance that is calling the delegate.
     - parameter getVideoSourceConfigurations: An Array of video source configuration structs.
     */
    func onvifInstance(_ instance: RVS_ONVIF, getVideoSourceConfigurations: [RVS_ONVIF_Profile_S.VideoSourceConfiguration]) {
        #if DEBUG
            print("Delegate onvifInstance:simpleResponseToRequest(\(String(describing: getVideoSourceConfigurations))")
        #endif
    }
}