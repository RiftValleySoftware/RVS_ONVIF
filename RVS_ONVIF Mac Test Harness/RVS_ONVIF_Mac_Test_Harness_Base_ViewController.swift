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
// MARK: - Abstract Base for All Extra Windows
/* ################################################################################################################################## */
class RVS_ONVIF_Mac_Test_Harness_Base_ViewController: NSViewController {
    var loginViewController: RVS_ONVIF_Mac_Test_Harness_LoginScreen_ViewController!
    
    /* ################################################################## */
    /**
     */
    override func viewDidAppear() {
        super.viewDidAppear()
        loginViewController?.myViews[className] = self
        loginViewController?.view.window?.makeKeyAndOrderFront(nil)
    }
    
    /* ################################################################## */
    /**
     */
    override func viewWillDisappear() {
        super.viewWillDisappear()
        loginViewController?.myViews.removeValue(forKey: className)
    }
}
