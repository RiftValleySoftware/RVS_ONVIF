/**
 © Copyright 2019, The Great Rift Valley Software Company. All rights reserved.
 
 This code is proprietary and confidential code,
 It is NOT to be reused or combined into any application,
 unless done so, specifically under written license from The Great Rift Valley Software Company.
 
 The Great Rift Valley Software Company: https://riftvalleysoftware.com
 */

import UIKit
import RVS_ONVIF_tvOS

/* ################################################################################################################################## */
// MARK: - Dispatch Profile S Functions
/* ################################################################################################################################## */
class RVS_ONVIF_tvOS_Test_Harness_ProfileSDispatcher: RVS_ONVIF_tvOS_Test_Harness_Dispatcher, RVS_ONVIF_Profile_SDispatcher {
    static let profileDisplaySegueID = "display-profiles-profiles"
    
    /* ################################################################## */
    /**
     This is the RVS_ONVIF instance that the dispatcher references. It is required to be implemented (and populated) by the final dispatcher instance.
     */
    var owner: RVS_ONVIF!
    var sendParameters: [String: Any]!
    
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
     */
    func sendSpecificCommand(_ inCommand: RVS_ONVIF_DeviceRequestProtocol) {
        switch inCommand.rawValue {
        default:
            ()
        }
    }

    /* ################################################################## */
    /**
     */
    func setupCommandParameters(_ inCommand: RVS_ONVIF_DeviceRequestProtocol) {
        sendRequest(inCommand)
    }
    
    /* ################################################################## */
    /**
     This method is called to deliver the response from the device.
     
     - parameter inCommand: The command to which this is a response.
     - parameter params: The data returned (and parsed) from the device. It can be any one of the various data types.
     - returns: true, if the response was consumed. Can be ignored.
     */
    @discardableResult public func deliverProfileResponseHandler(_ inCommand: RVS_ONVIF_DeviceRequestProtocol, params inParams: Any!) -> Bool {
        #if DEBUG
            print("RVS_ONVIF_tvOS_Test_Harness_Dispatcher::deliverProfileResponseHandler:\(String(describing: inCommand)), params: \(String(describing: inParams))")
        #endif
        
        if let params = inParams as? [RVS_ONVIF_Profile_S.Profile] {
            if  let windowViewController = RVS_ONVIF_tvOS_Test_Harness_AppDelegate.delegateObject.openNamespaceHandlerScreen,
                let dataEntryDialog = windowViewController.storyboard?.instantiateViewController(withIdentifier: RVS_ONVIF_tvOS_Test_Harness_Profiles_ViewController.storyboardID) as? RVS_ONVIF_tvOS_Test_Harness_Profiles_ViewController {
                dataEntryDialog.profileObjects = params
                windowViewController.present(dataEntryDialog, animated: true, completion: nil)
            }
        }
        
        return true
    }
    
    /* ################################################################## */
    /**
     This method is called to deliver the response from the device.
     
     - parameter inCommand: The command to which this is a response.
     - parameter params: The data returned (and parsed) from the device. It can be any one of the various data types.
     - returns: true, if the response was consumed. Can be ignored.
     */
    @discardableResult public func deliverStreamResponseHandler(_ inCommand: RVS_ONVIF_DeviceRequestProtocol, params inParams: Any!) -> Bool {
        #if DEBUG
            print("RVS_ONVIF_tvOS_Test_Harness_Dispatcher::deliverStreamResponseHandler:\(String(describing: inCommand)), params: \(String(describing: inParams))")
        #endif
        
        if let params = inParams as? RVS_ONVIF_Profile_S.Stream_URI {
            if  let windowViewController = RVS_ONVIF_tvOS_Test_Harness_AppDelegate.delegateObject.openProfileScreen,
                let dataEntryDialog = windowViewController.storyboard?.instantiateViewController(withIdentifier: RVS_ONVIF_tvOS_Test_Harness_DisplayStream_ViewController.storyboardID) as? RVS_ONVIF_tvOS_Test_Harness_DisplayStream_ViewController {
                print(params)
                windowViewController.present(dataEntryDialog, animated: true, completion: nil)
            }
        }
        
        return true
    }

    /* ################################################################## */
    /**
     This method is required to be implemented by the final dispatcher. This method is called to deliver the response from the device.
     
     - parameter inCommand: The command to which this is a response.
     - parameter params: The data returned (and parsed) from the device. It can be any one of the various data types.
     - returns: true, if the response was consumed. Can be ignored.
     */
    @discardableResult public func deliverResponse(_ inCommand: RVS_ONVIF_DeviceRequestProtocol, params inParams: Any!) -> Bool {
        #if DEBUG
            print("RVS_ONVIF_tvOS_Test_Harness_ProfileSDispatcher::deliverResponse:\(String(describing: inCommand)), params: \(String(describing: inParams))")
        #endif
        if "GetStreamUri" == inCommand.rawValue {
            return deliverStreamResponseHandler(inCommand, params: inParams)
        } else if "GetProfiles" == inCommand.rawValue {
            return deliverProfileResponseHandler(inCommand, params: inParams)
        } else {
            return deliverResponseHandler(inCommand, params: inParams)
        }
    }
}
