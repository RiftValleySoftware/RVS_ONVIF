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

    /* ################################################################## */
    /**
     Displays the given error in an alert with an "OK" button.
     
     - parameter inTitle: a string to be displayed as the title of the alert. It is localized by this method.
     - parameter message: a string to be displayed as the message of the alert. It is localized by this method.
     */
    class func displayAlert(_ inTitle: String, message inMessage: String) {
        #if DEBUG
            print("*** \(inTitle)\n\t\(inMessage)")
        #endif
        DispatchQueue.main.async {
            self.delegateObject.mainTabController?.selectedIndex = 0
            let presentingController = self.delegateObject.window?.rootViewController
            let alertController = UIAlertController(title: inTitle, message: inMessage, preferredStyle: .alert)
            
            let okAction = UIAlertAction(title: "OK", style: UIAlertAction.Style.cancel, handler: nil)
            
            alertController.addAction(okAction)
            
            presentingController?.present(alertController, animated: true, completion: nil)
        }
    }

    /* ############################################################################################################################## */
    // MARK: - Internal Instance Properties
    /* ############################################################################################################################## */
    /* ################################################################## */
    /**
     */
    var window: UIWindow?
    
    /* ################################################################## */
    /**
     */
    var prefs: RVS_PersistentPrefs!
    
    /* ################################################################## */
    /**
     */
    var mainTabController: RVS_ONVIF_tvOS_Test_Harness_UITabBarController!
    
    /* ################################################################## */
    /**
     */
    var openNamespaceHandlerScreen: RVS_ONVIF_tvOS_Test_Harness_Namespaces_ViewController!

    /* ################################################################## */
    /**
     */
    var openProfileScreen: RVS_ONVIF_tvOS_Test_Harness_DisplayResponse_Profile_ViewController!
    
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
