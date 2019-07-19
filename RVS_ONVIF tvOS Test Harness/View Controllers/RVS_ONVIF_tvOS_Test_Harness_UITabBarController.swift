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
// MARK: - Protocol to Access The Basics
/* ################################################################################################################################## */
protocol RVS_ONVIF_tvOS_Test_Harness_ViewProtocol {
    var persistentPrefs: RVS_PersistentPrefs! { get set }
    var onvifInstance: RVS_ONVIF! { get set }
    var isConnected: Bool { get set }
    func updateUI()
}

/* ################################################################################################################################## */
// MARK: - Main Tab Bar Controller Class
/* ################################################################################################################################## */
class RVS_ONVIF_tvOS_Test_Harness_UITabBarController: UITabBarController, RVS_ONVIF_tvOS_Test_Harness_ViewProtocol, RVS_ONVIFDelegate {
    var preferredF: [UIFocusEnvironment] = []
    
    /* ############################################################################################################################## */
    // MARK: - Overridden Superclass Calculated Properties
    /* ############################################################################################################################## */
    /* ################################################################## */
    /**
     */
    override var preferredFocusEnvironments: [UIFocusEnvironment] {
        if !preferredF.isEmpty {
            let ret = preferredF
            preferredF = []
            selectedIndex = 1
            return ret
        }

        return super.preferredFocusEnvironments
    }
    
    /* ############################################################################################################################## */
    // MARK: - Internal Instance Properties
    /* ############################################################################################################################## */
    /* ################################################################## */
    /**
     */
    var persistentPrefs: RVS_PersistentPrefs!

    /* ################################################################## */
    /**
     */
    var onvifInstance: RVS_ONVIF! {
        didSet {
            if !isConnected {
                selectedIndex = 0
            }
            
            setNeedsFocusUpdate()
            updateUI()
        }
    }
    
    /* ################################################################## */
    /**
     */
    var isConnected: Bool {
        get {
            return nil != onvifInstance
        }
        
        set {
            if !newValue, let onvifInstance = onvifInstance {
                onvifInstance.deinitializeConnection()
            }
        }
    }

    /* ############################################################################################################################## */
    // MARK: - Internal Instance Methods
    /* ############################################################################################################################## */
    /* ################################################################## */
    /**
     */
    func updateUI() {
        viewControllers?.forEach {
            if let vc = $0 as? RVS_ONVIF_tvOS_Test_Harness_Base_ViewController {
                vc.updateUI()
                vc.tabBarItem.isEnabled = vc is RVS_ONVIF_tvOS_Test_Harness_Connect_ViewController ? true : isConnected
            } else if let vc = $0 as? RVS_ONVIF_tvOS_Test_Harness_Dispatcher_NavigationController {
                vc.updateUI()
                vc.tabBarItem.isEnabled = isConnected
            } else if let vc = $0 as? RVS_ONVIF_tvOS_Test_Harness_Namespaces_NavigationController {
                vc.updateUI()
                vc.tabBarItem.isEnabled = isConnected
            }
        }
        
        if !isConnected {
            selectedIndex = 0
        }
    }

    /* ############################################################################################################################## */
    // MARK: - Internal Base Class Override Methods
    /* ############################################################################################################################## */
    /* ################################################################## */
    /**
     */
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let defaultPrefs: [String: Any] = ["ip_address": "", "tcp_port": 0, "login_id": "", "password": "", "soap_key": "", "auth_method": 0]

        persistentPrefs = RVS_PersistentPrefs(tag: "TestONVIFSettings", values: defaultPrefs)
        
        RVS_ONVIF_tvOS_Test_Harness_AppDelegate.delegateObject.prefs = persistentPrefs
        RVS_ONVIF_tvOS_Test_Harness_AppDelegate.delegateObject.mainTabController = self
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
        if let connectViewController = viewControllers?[0] as? RVS_ONVIF_tvOS_Test_Harness_Connect_ViewController {
            connectViewController.isConnecting = false  // Make sure we hide the throbber.
        }
        onvifInstance = nil
        RVS_ONVIF_tvOS_Test_Harness_AppDelegate.displayAlert("ERROR!", message: inReason.debugDescription)
    }
    
    /* ################################################################## */
    /**
     This is called if the instance is completely initialized. It is optional.
     
     - parameter instance: The RVS_ONVIF instance that is calling the delegate.
     */
    func onvifInstanceInitialized(_ inONVIFInstance: RVS_ONVIF) {
        preferredF = [tabBar]
        onvifInstance = inONVIFInstance
        inONVIFInstance.profiles.forEach {
            switch $0.key {
            case "RVS_ONVIF_Core":
                inONVIFInstance.dispatchers.append(RVS_ONVIF_tvOS_Test_Harness_CoreDispatcher(owner: inONVIFInstance))
            case "RVS_ONVIF_Profile_S":
                inONVIFInstance.dispatchers.append(RVS_ONVIF_tvOS_Test_Harness_ProfileSDispatcher(owner: inONVIFInstance))
            default:
                break
            }
        }
        onvifInstance = inONVIFInstance
    }
    
    /* ################################################################## */
    /**
     This is called if the instance is "deinitialized." It is optional.
     
     - parameter instance: The RVS_ONVIF instance that is calling the delegate.
     */
    func onvifInstanceDeinitialized(_ inONVIFInstance: RVS_ONVIF) {
        onvifInstance = nil
    }
}
