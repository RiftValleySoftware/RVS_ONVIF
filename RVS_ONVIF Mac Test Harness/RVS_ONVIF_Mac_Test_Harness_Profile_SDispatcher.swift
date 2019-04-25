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
class RVS_ONVIF_Mac_Test_Harness_Profile_SDispatcher: RVS_ONVIF_Dispatcher {
    var scope: ProfileHandlerProtocol
    
    /* ################################################################## */
    /**
     */
    required init(scope inScope: ProfileHandlerProtocol) {
        scope = inScope
    }
    
    
    /* ################################################################## */
    /**
     */
    func isAbleToHandleThisCommand(_ inCommand: RVS_ONVIF_DeviceRequestProtocol) -> Bool {
        if let profileHandler = RVS_ONVIF_Mac_Test_Harness_AppDelegate.appDelegateObject.onvifInstance.profiles["RVS_ONVIF_ProfileS"] {
            if profileHandler.availableCommandsAsStrings.contains(inCommand.rawValue) {
                return true
            }
        }
        
        return false
    }

    /* ################################################################## */
    /**
     */
    func handleCommand(_ inONVIFInstance: RVS_ONVIF, command inCommand: RVS_ONVIF_DeviceRequestProtocol) -> Bool {
        if isAbleToHandleThisCommand(inCommand) {
            return true
        }
        return false
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
