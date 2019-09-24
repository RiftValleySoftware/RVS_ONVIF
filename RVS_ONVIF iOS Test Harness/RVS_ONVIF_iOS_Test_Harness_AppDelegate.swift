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

@UIApplicationMain
class RVS_ONVIF_iOS_Test_Harness_AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?
    var openNamespaceHandlerScreen: RVS_ONVIF_iOS_Test_Harness_Namespaces_TableViewController!
    var openProfileSProfilesScreen: RVS_ONVIF_iOS_Test_Harness_ProfileSProfiles_TableViewController!
    
    /* ################################################################## */
    /**
     This is a quick way to get this object instance (it's a SINGLETON), cast as the correct class.
     */
    static var appDelegateObject: RVS_ONVIF_iOS_Test_Harness_AppDelegate {
        return (UIApplication.shared.delegate as? RVS_ONVIF_iOS_Test_Harness_AppDelegate)!
    }

    /* ################################################################## */
    /**
     Displays the given error in an alert with an "OK" button.
     
     - parameter inTitle: a string to be displayed as the title of the alert. It is localized by this method.
     - parameter inMessage: a string to be displayed as the message of the alert. It is localized by this method.
     - parameter presentedBy: An optional UIViewController object that is acting as the presenter context for the alert. If nil, we use the top controller of the Navigation stack.
     */
    class func displayAlert(_ inTitle: String, inMessage: String, presentedBy inPresentingViewController: UIViewController! = nil ) {
        #if DEBUG
            print("*** \(inTitle)\n\t\(inMessage)")
        #endif
        DispatchQueue.main.async {
            var presentedBy = inPresentingViewController
            
            if nil == presentedBy {
                if let navController = self.appDelegateObject.window?.rootViewController as? UINavigationController {
                    presentedBy = navController.topViewController
                } else {
                    if let tabController = self.appDelegateObject.window?.rootViewController as? UITabBarController {
                        if let navController = tabController.selectedViewController as? UINavigationController {
                            presentedBy = navController.topViewController
                        } else {
                            presentedBy = tabController.selectedViewController
                        }
                    }
                }
            }
            
            if nil != presentedBy {
                let alertController = UIAlertController(title: inTitle, message: inMessage, preferredStyle: .actionSheet)
                
                let okAction = UIAlertAction(title: "OK", style: UIAlertAction.Style.cancel, handler: nil)
                
                alertController.addAction(okAction)
                
                presentedBy?.present(alertController, animated: true, completion: nil)
            }
        }
    }
}
