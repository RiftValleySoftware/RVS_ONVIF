/**
 © Copyright 2019, The Great Rift Valley Software Company. All rights reserved.
 
 This code is proprietary and confidential code,
 It is NOT to be reused or combined into any application,
 unless done so, specifically under written license from The Great Rift Valley Software Company.
 
 The Great Rift Valley Software Company: https://riftvalleysoftware.com
 */

import Cocoa
import RVS_ONVIF_MacOS

// From here: https://stackoverflow.com/a/52523517/879365
extension NSView {
    var isDarkMode: Bool {
        if #available(OSX 10.14, *) {
            return effectiveAppearance.name == .darkAqua
        }
        return false
    }
}

/* ################################################################################################################################## */
// MARK: - Main Application Delegate
/* ################################################################################################################################## */
@NSApplicationMain
class RVS_ONVIF_Mac_Test_Harness_AppDelegate: NSObject, NSApplicationDelegate, RVS_ONVIFDelegate {
    /* ############################################################################################################################## */
    // MARK: - Internal Static Properties
    /* ############################################################################################################################## */
    /* ################################################################## */
    /**
     */
    static let prefsKeys = ["ip_address_and_port", "login_id", "password", "soap_key", "auth_method"]

    /* ############################################################################################################################## */
    // MARK: - Internal Class Calculated Properties
    /* ############################################################################################################################## */
    /* ################################################################## */
    /**
     This is a quick way to get this object instance (it's a SINGLETON), cast as the correct class.
     */
    class var appDelegateObject: RVS_ONVIF_Mac_Test_Harness_AppDelegate {
        return (NSApplication.shared.delegate as? RVS_ONVIF_Mac_Test_Harness_AppDelegate)!
    }

    /* ############################################################################################################################## */
    // MARK: - Internal Class Functions
    /* ############################################################################################################################## */
    /* ################################################################## */
    /**
     */
    class func displayAlert(header inHeader: String, message inMessage: String = "") {
        let alert = NSAlert()
        alert.messageText = inHeader
        alert.informativeText = inMessage
        alert.addButton(withTitle: "OK")
        alert.runModal()
    }

    /* ############################################################################################################################## */
    // MARK: - Internal Stored Properties
    /* ############################################################################################################################## */
    var onvifInstance: RVS_ONVIF!
    var connectionScreen: RVS_ONVIF_Mac_Test_Harness_LoginScreen_ViewController!
    var functionHandlerScreen: RVS_ONVIF_Mac_Test_Harness_Handlers_ViewController!
    var displayProfilesScreen: RVS_ONVIF_Mac_Test_Harness_ProfileDisplayViewController!
    var displayVideoScreen: RVS_ONVIF_Mac_Test_Harness_VideoDisplayViewController!

    var prefs: RVS_PersistentPrefs!
    
    /* ############################################################################################################################## */
    // MARK: - Internal Calculated Properties
    /* ############################################################################################################################## */
    /* ################################################################## */
    /**
     */
    var currentPrefs: [String: String] {
        get {
            if nil == prefs {
                var val: [String: String] = [:]
                
                type(of: self).prefsKeys.forEach {
                    switch $0 {
                    case "ip_address_and_port":
                        val["ip_address_and_port"] = "0.0.0.0:80"
                    case "auth_method":
                        val["auth_method"] = "1"
                    default:
                        val[$0] = ""
                    }
                }
                
                prefs = RVS_PersistentPrefs(tag: "RVS_ONVIF_Test", values: val)
            }
            
            return prefs?.values as? [String: String] ?? [:]
        }
        
        set {
            prefs?.values = newValue
        }
    }
    
    /* ############################################################################################################################## */
    // MARK: - RVS_ONVIFDelegate Methods
    /* ############################################################################################################################## */
    /* ################################################################## */
    /**
     This is called whenever an error is encountered by the RVS_ONVIF framework.
     
     This is not required, but you'd be well-advised to implement it.
     
     - parameter instance: The RVS_ONVIF instance that is calling the delegate.
     - parameter failureWithReason: An enumeration, with associated values that refine the issue.
     */
    func onvifInstance(_ inONVIFInstance: RVS_ONVIF, failureWithReason inReason: RVS_ONVIF.RVS_Fault!) {
        onvifInstance = nil
        connectionScreen?.scramTheReactor()
        connectionScreen?.updateUI(true)
        type(of: self).displayAlert(header: "ERROR!", message: inReason.debugDescription)
    }

    /* ################################################################## */
    /**
     This is called if the instance is completely initialized. It is optional.
     
     - parameter instance: The RVS_ONVIF instance that is calling the delegate.
     */
    func onvifInstanceInitialized(_ inONVIFInstance: RVS_ONVIF) {
        onvifInstance = inONVIFInstance
        connectionScreen?.view.window?.title = "CONNECTED"
        inONVIFInstance.profiles.forEach {
            switch $0.key {
            case "RVS_ONVIF_Core":
                let dispatcher = RVS_ONVIF_Mac_Test_Harness_CoreDispatcher(owner: onvifInstance)
                inONVIFInstance.dispatchers.append(dispatcher)
            case "RVS_ONVIF_Profile_S":
                inONVIFInstance.dispatchers.append(RVS_ONVIF_Mac_Test_Harness_Profile_SDispatcher(owner: onvifInstance))
            default:
                break
            }
        }
        
        connectionScreen?.openInfoScreen()
        connectionScreen?.openHandlersScreen()
        connectionScreen?.openServicesScreen()
        connectionScreen?.openScopesScreen()
        connectionScreen?.openCapabilitiesScreen()
        connectionScreen?.openServiceCapabilitiesScreen()
        connectionScreen?.openNetworkInterfacesScreen()
        connectionScreen?.updateUI(true)
    }
    
    /* ################################################################## */
    /**
     This is called if the instance is "deinitialized." It is optional.
     
     - parameter instance: The RVS_ONVIF instance that is calling the delegate.
     */
    func onvifInstanceDeinitialized(_ inONVIFInstance: RVS_ONVIF) {
        onvifInstance = nil
        connectionScreen?.scramTheReactor()
    }
}
