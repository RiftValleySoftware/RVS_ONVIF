/** 
 © Copyright 2019, The Great Rift Valley Software Company

LICENSE:

MIT License

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation
files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy,
modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the
Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF
CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

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
