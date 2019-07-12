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
// MARK: - Main Class for the Namespaces NavigationController
/* ################################################################################################################################## */
class RVS_ONVIF_tvOS_Test_Harness_Namespaces_NavigationController: UINavigationController {
    /* ############################################################################################################################## */
    // MARK: - Internal Instance Properties
    /* ############################################################################################################################## */
    /* ################################################################## */
    /**
     */
    /* ############################################################################################################################## */
    // MARK: - Internal Calculated Properties
    /* ############################################################################################################################## */
    /* ################################################################## */
    /**
     */
    var onvifInstance: RVS_ONVIF! {
        get {
            if let tabBarController = tabBarController as? RVS_ONVIF_tvOS_Test_Harness_UITabBarController {
                return tabBarController.onvifInstance
            }
            
            return nil
        }
        
        set {
            if let tabBarController = tabBarController as? RVS_ONVIF_tvOS_Test_Harness_UITabBarController {
                tabBarController.onvifInstance = newValue
            }
        }
    }
    
    /* ################################################################## */
    /**
     */
    var isConnected: Bool {
        get {
            if let tabBarController = tabBarController as? RVS_ONVIF_tvOS_Test_Harness_UITabBarController {
                return tabBarController.isConnected
            }
            return false
        }
        
        set {
            if let tabBarController = tabBarController as? RVS_ONVIF_tvOS_Test_Harness_UITabBarController {
                return tabBarController.isConnected = newValue
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
        viewControllers.forEach {
            if let vc = $0 as? RVS_ONVIF_tvOS_Test_Harness_ViewProtocol {
                vc.updateUI()
            }
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
    }
}
