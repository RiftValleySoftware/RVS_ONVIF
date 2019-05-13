/**
 © Copyright 2019, The Great Rift Valley Software Company. All rights reserved.
 
 This code is proprietary and confidential code,
 It is NOT to be reused or combined into any application,
 unless done so, specifically under written license from The Great Rift Valley Software Company.
 
 The Great Rift Valley Software Company: https://riftvalleysoftware.com
 */

import UIKit
import RVS_ONVIF_iOS

/* ################################################################################################################################## */
// MARK: - Display ONVIF Responses View Controller
/* ################################################################################################################################## */
class RVS_ONVIF_Test_Harness_DisplayResponse_ViewController: UIViewController {
    @IBOutlet var headingLabel: UILabel!
    @IBOutlet var bodyDisplayText: UITextView!
    
    var responseName: String = ""
    var responseData: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        headingLabel.text = responseName
        bodyDisplayText.text = responseData
    }
}
