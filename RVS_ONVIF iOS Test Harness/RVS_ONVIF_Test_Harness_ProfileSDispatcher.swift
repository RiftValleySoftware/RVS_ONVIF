/**
 © Copyright 2019, The Great Rift Valley Software Company. All rights reserved.
 
 This code is proprietary and confidential code,
 It is NOT to be reused or combined into any application,
 unless done so, specifically under written license from The Great Rift Valley Software Company.
 
 The Great Rift Valley Software Company: https://riftvalleysoftware.com
 */

import UIKit
import RVS_ONVIF_iOS

/* ################################################################################################################################## */
// MARK: - Dispatch Profile S Functions
/* ################################################################################################################################## */
class RVS_ONVIF_Test_Harness_ProfileSDispatcher: RVS_ONVIF_Test_Harness_Dispatcher, RVS_ONVIF_Profile_SDispatcher {
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
     This method is implemented by the final dispatcher, and is used to fetch the parameters for the given command. This implementation returns an empty command.
     
     - parameter inCommand: The command being sent.
     - returns: an empty Dictionary<String, Any>.
     */
    public func getParametersForCommand(_ inCommand: RVS_ONVIF_DeviceRequestProtocol) -> [String: Any]! {
        if "GetStreamUri" == inCommand.rawValue {
        }
        
        return [:]
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
            print("RVS_ONVIF_Test_Harness_Profile_SDispatcher::deliverResponse:\(String(describing: inCommand)), params: \(String(describing: inParams))")
        #endif
        
        if "GetProfiles" == inCommand.rawValue, let profileArray = inParams as? [RVS_ONVIF_Profile_S.Profile] {
            #if DEBUG
                print("RVS_ONVIF_Test_Harness_Profile_SDispatcher::deliverResponse Profile Array: \(String(reflecting: profileArray))")
            #endif
            RVS_ONVIF_Test_Harness_AppDelegate.appDelegateObject.openNamespaceHandlerScreen.performSegue(withIdentifier: type(of: self).profileDisplaySegueID, sender: profileArray)
            return true
        } else if "GetStreamUri" == inCommand.rawValue, let streamingURI = inParams as? RVS_ONVIF_Profile_S.Stream_URI {
            #if DEBUG
                print("RVS_ONVIF_Test_Harness_Profile_SDispatcher::deliverResponse Stream URI: \(String(reflecting: streamingURI))")
            #endif
            return true
        } else {
            let header = "\(inCommand.rawValue)Response:"
            var body = ""
            if let params = inParams {
                body = String(reflecting: params)
            }
            RVS_ONVIF_Test_Harness_AppDelegate.appDelegateObject.openNamespaceHandlerScreen.displayResult(header: header, data: body)
            return true
        }
    }
}
