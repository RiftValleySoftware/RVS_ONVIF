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
class RVS_ONVIF_Mac_Test_Harness_CoreDispatcher: RVS_ONVIF_CoreDispatcher {
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
     */
    func hostNameCallback(_ inControl: NSView?) {
        print("HOSTNAME CALLBACK!")
    }
    
    /* ################################################################## */
    /**
     This method is implemented by the final dispatcher, and is used to fetch the parameters for the given command. This implementation returns an empty command.
     
     - parameter inCommand: The command being sent.
     - returns: an empty Dictionary<String, Any>.
     */
    public func getGetParametersForCommand(_ inCommand: RVS_ONVIF_DeviceRequestProtocol) -> [String: Any] {
        var dataEntryDialog: RVS_ONVIF_Mac_Test_Harness_FunctionData_ViewController!
        
        switch inCommand.rawValue {
        case "SetHostname":
            dataEntryDialog = RVS_ONVIF_Mac_Test_Harness_FunctionData_ViewController.dialogFactory(["Host Name": .textEntry(defaultValue: "", callback: hostNameCallback)], title: inCommand.rawValue)
            
        case "SetHostnameFromDHCP":
            ()
            
        case "SetNTP":
            ()
            
        case "SetDNS":
            ()
            
        case "SetDynamicDNS":
            ()

        default:
            ()
        }
        
        if let windowViewController = RVS_ONVIF_Mac_Test_Harness_AppDelegate.appDelegateObject.functionHandlerScreen {
            dataEntryDialog.view.frame = windowViewController.view.bounds
            windowViewController.presentAsModalWindow(dataEntryDialog)
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
            print("RVS_ONVIF_Mac_Test_Harness_CoreDispatcher::deliverResponse:\(String(describing: inCommand)), params: \(String(describing: inParams))")
        #endif
        
        return isAbleToHandleThisCommand(inCommand)
    }
}
