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
     - parameter presentedBy: An optional UIViewController object that is acting as the presenter context for the alert. If nil, we use the top controller of the Navigation stack.
     */
    class func displayAlert(_ inTitle: String, message inMessage: String, presentedBy inPresentingViewController: UIViewController! = nil ) {
        #if DEBUG
            print("*** \(inTitle)\n\t\(inMessage)")
        #endif
        DispatchQueue.main.async {
            if nil != inPresentingViewController {
                let alertController = UIAlertController(title: inTitle, message: inMessage, preferredStyle: .alert)
                
                let okAction = UIAlertAction(title: "OK", style: UIAlertAction.Style.cancel, handler: nil)
                
                alertController.addAction(okAction)
                
                inPresentingViewController?.present(alertController, animated: true, completion: nil)
            }
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
    var openNamespaceHandlerScreen: RVS_ONVIF_tvOS_Test_Harness_Namespaces_ViewController!
    
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
