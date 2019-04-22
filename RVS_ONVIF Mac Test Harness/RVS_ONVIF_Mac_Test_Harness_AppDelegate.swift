/**
 © Copyright 2019, The Great Rift Valley Software Company. All rights reserved.
 
 This code is proprietary and confidential code,
 It is NOT to be reused or combined into any application,
 unless done so, specifically under written license from The Great Rift Valley Software Company.
 
 The Great Rift Valley Software Company: https://riftvalleysoftware.com
 */

import Cocoa
import RVS_ONVIF_MacOS

// Frome here: https://stackoverflow.com/a/52523517/879365
extension NSView {
    var isDarkMode: Bool {
        if #available(OSX 10.14, *) {
            return effectiveAppearance.name == .darkAqua
        }
        return false
    }
}

protocol RVS_ONVIF_Mac_Test_Harness_Dispatcher: RVS_ONVIF_CoreDelegate, RVS_ONVIF_Profile_SDelegate { }

extension RVS_ONVIF_Mac_Test_Harness_Dispatcher {
    /* ################################################################## */
    /**
     */
    func onvifInstance(_ inONVIFInstance: RVS_ONVIF, getWSDLURI: String!) { }
    
    /* ################################################################## */
    /**
     */
    func onvifInstance(_ inONVIFInstance: RVS_ONVIF, getHostname: RVS_ONVIF_Core.HostnameResponse!) { }
    
    /* ################################################################## */
    /**
     */
    func onvifInstance(_ inONVIFInstance: RVS_ONVIF, getDNS: RVS_ONVIF_Core.DNSRecord!) { }
    
    /* ################################################################## */
    /**
     */
    func onvifInstance(_ inONVIFInstance: RVS_ONVIF, getDynamicDNS: RVS_ONVIF_Core.DynamicDNSRecord!) { }
    
    /* ################################################################## */
    /**
     */
    func onvifInstance(_ inONVIFInstance: RVS_ONVIF, getNTP: RVS_ONVIF_Core.NTPRecord!) { }

    /* ################################################################## */
    /**
     */
    func onvifInstance(_ inONVIFInstance: RVS_ONVIF, getProfiles: [RVS_ONVIF_Profile_S.Profile]) { }
    
    /* ################################################################## */
    /**
     */
    func onvifInstance(_ inONVIFInstance: RVS_ONVIF, getStreamURI: RVS_ONVIF_Profile_S.Stream_URI) { }
    
    /* ################################################################## */
    /**
     */
    func onvifInstance(_ inONVIFInstance: RVS_ONVIF, getVideoSourceConfigurations: [RVS_ONVIF_Profile_S.VideoSourceConfiguration]) { }
}

/* ################################################################################################################################## */
// MARK: - Main Application Delegate
/* ################################################################################################################################## */
@NSApplicationMain
class RVS_ONVIF_Mac_Test_Harness_AppDelegate: NSObject, NSApplicationDelegate, RVS_ONVIFDelegate, RVS_ONVIF_CoreDelegate, RVS_ONVIF_Profile_SDelegate {
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
    var prefs: RVS_PersistentPrefs!
    var dispatchers: [RVS_ONVIF_Mac_Test_Harness_Dispatcher] = []
    
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
    // MARK: - Instance Methods
    /* ############################################################################################################################## */
    
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
        connectionScreen?.openInfoScreen()
        connectionScreen?.openHandlersScreen()
        connectionScreen?.openServicesScreen()
        connectionScreen?.openScopesScreen()
        connectionScreen?.openCapabilitiesScreen()
        connectionScreen?.openServiceCapabilitiesScreen()
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
        connectionScreen?.updateUI(true)
    }
    
    /* ############################################################################################################################## */
    // MARK: - RVS_ONVIF_CoreDelegate Methods
    /* ############################################################################################################################## */
    /**
     These methods are either ignored, or sent directly to a dispatcher that can handle them.
     */
    /* ################################################################## */
    /**
     This is called to deliver the WSDL URI.
     
     - parameter instance: The RVS_ONVIF instance that is calling the delegate.
     - parameter getWSDLURI: The WSDL URI instance. Nil, if there is none available.
     */
    func onvifInstance(_ inONVIFInstance: RVS_ONVIF, getWSDLURI inGetWSDLURI: String!) {
        dispatchers.forEach {
            $0.onvifInstance(inONVIFInstance, getWSDLURI: inGetWSDLURI)
        }
    }
    
    /* ################################################################## */
    /**
     This is called to deliver the Hostname.
     
     - parameter instance: The RVS_ONVIF instance that is calling the delegate.
     - parameter getHostname: The returned hostname tuple. Nil, if there is none available.
     */
    func onvifInstance(_ inONVIFInstance: RVS_ONVIF, getHostname inGetHostname: RVS_ONVIF_Core.HostnameResponse!) {
        dispatchers.forEach {
            $0.onvifInstance(inONVIFInstance, getHostname: inGetHostname)
        }
    }
    
    /* ################################################################## */
    /**
     This is called to deliver the DNS.
     
     - parameter instance: The RVS_ONVIF instance that is calling the delegate.
     - parameter getDNS: The DNS Response. Nil, if there is none available.
     */
    func onvifInstance(_ inONVIFInstance: RVS_ONVIF, getDNS inGetDNS: RVS_ONVIF_Core.DNSRecord!) {
        dispatchers.forEach {
            $0.onvifInstance(inONVIFInstance, getDNS: inGetDNS)
        }
    }
    
    /* ################################################################## */
    /**
     This is called to deliver the Dynamic DNS.
     
     - parameter instance: The RVS_ONVIF instance that is calling the delegate.
     - parameter getDynamicDNS: The Dynamic DNS Response. Nil, if there is none available.
     */
    func onvifInstance(_ inONVIFInstance: RVS_ONVIF, getDynamicDNS inGetDynamicDNS: RVS_ONVIF_Core.DynamicDNSRecord!) {
        dispatchers.forEach {
            $0.onvifInstance(inONVIFInstance, getDynamicDNS: inGetDynamicDNS)
        }
    }
    
    /* ################################################################## */
    /**
     This is called to deliver the NTP Record.
     
     - parameter instance: The RVS_ONVIF instance that is calling the delegate.
     - parameter getNTP: The NTP Response. Nil, if there is none available.
     */
    func onvifInstance(_ inONVIFInstance: RVS_ONVIF, getNTP inGetNTP: RVS_ONVIF_Core.NTPRecord!) {
        dispatchers.forEach {
            $0.onvifInstance(inONVIFInstance, getNTP: inGetNTP)
        }
    }

    /* ############################################################################################################################## */
    // MARK: - RVS_ONVIF_Profile_SDelegate Methods
    /* ############################################################################################################################## */
    /**
     These methods are either ignored, or sent directly to a dispatcher that can handle them.
     */
    /* ################################################################## */
    /**
     This is called to deliver the device ONVIF profiles.
     
     - parameter instance: The RVS_ONVIF instance that is calling the delegate.
     - parameter getProfiles: An Array of Profile objects.
     */
    func onvifInstance(_ inONVIFInstance: RVS_ONVIF, getProfiles inGetProfiles: [RVS_ONVIF_Profile_S.Profile]) {
        dispatchers.forEach {
            $0.onvifInstance(inONVIFInstance, getProfiles: inGetProfiles)
        }
    }
    
    /* ################################################################## */
    /**
     This is called to deliver the device stream URI.
     
     - parameter instance: The RVS_ONVIF instance that is calling the delegate.
     - parameter getStreamURI: The Stream_URI instance that contains the ONVIF response.
     */
    func onvifInstance(_ inONVIFInstance: RVS_ONVIF, getStreamURI inGetStreamURI: RVS_ONVIF_Profile_S.Stream_URI) {
        dispatchers.forEach {
            $0.onvifInstance(inONVIFInstance, getStreamURI: inGetStreamURI)
        }
    }
    
    /* ################################################################## */
    /**
     This is called to deliver the device stream URI.
     
     - parameter instance: The RVS_ONVIF instance that is calling the delegate.
     - parameter getVideoSourceConfigurations: An Array of video source configuration structs.
     */
    func onvifInstance(_ inONVIFInstance: RVS_ONVIF, getVideoSourceConfigurations inGetVideoSourceConfigurations: [RVS_ONVIF_Profile_S.VideoSourceConfiguration]) {
        dispatchers.forEach {
            $0.onvifInstance(inONVIFInstance, getVideoSourceConfigurations: inGetVideoSourceConfigurations)
        }
    }
}
