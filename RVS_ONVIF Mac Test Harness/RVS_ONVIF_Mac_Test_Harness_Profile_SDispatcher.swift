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
class RVS_ONVIF_Mac_Test_Harness_Profile_SDispatcher: RVS_ONVIF_Profile_SDispatcher {
    /* ################################################################## */
    /**
     This is the RVS_ONVIF instance that the dispatcher references. It is required to be implemented (and populated) by the final dispatcher instance.
     */
    var owner: RVS_ONVIF!
    
    /* ################################################################## */
    /**
     Initializer.
     
     - parameter owner: The RVS_ONVIF instance that is referenced by this dispatcher.
     */
    init(owner inOwner: RVS_ONVIF) {
        owner = inOwner
    }

    /* ################################################################## */
    /**
     This method is implemented by the final dispatcher, and is used to fetch the parameters for the given command. This implementation returns an empty command.
     
     - parameter inCommand: The command being sent.
     - returns: an empty Dictionary<String, Any>.
     */
    public func getGetParametersForCommand(_ inCommand: RVS_ONVIF_DeviceRequestProtocol) -> [String: Any] {
        return [:]
    }

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
