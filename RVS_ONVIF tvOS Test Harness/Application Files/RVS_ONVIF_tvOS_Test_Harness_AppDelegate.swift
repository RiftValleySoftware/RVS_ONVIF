/**
 © Copyright 2019, The Great Rift Valley Software Company. All rights reserved.
 
 This code is proprietary and confidential code,
 It is NOT to be reused or combined into any application,
 unless done so, specifically under written license from The Great Rift Valley Software Company.
 
 The Great Rift Valley Software Company: https://riftvalleysoftware.com
 */

import UIKit

/* ################################################################################################################################## */
// MARK: - Main Application Delegate
/* ################################################################################################################################## */
@UIApplicationMain
class RVS_ONVIF_tvOS_Test_Harness_AppDelegate: UIResponder, UIApplicationDelegate {
    static var delegateObject: RVS_ONVIF_tvOS_Test_Harness_AppDelegate! {
        return UIApplication.shared.delegate as? RVS_ONVIF_tvOS_Test_Harness_AppDelegate
    }
    
    /* ############################################################################################################################## */
    // MARK: - Internal Instance Properties
    /* ############################################################################################################################## */
    /* ################################################################## */
    /**
     */
    var window: UIWindow?
    
    /* ############################################################################################################################## */
    // MARK: - Internal Instance UIApplicationDelegate Methods
    /* ############################################################################################################################## */
    /* ################################################################## */
    /**
     */
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        return true
    }
}
