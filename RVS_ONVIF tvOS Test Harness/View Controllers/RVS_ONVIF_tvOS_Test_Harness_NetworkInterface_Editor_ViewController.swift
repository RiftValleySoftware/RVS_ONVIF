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
// MARK: - Main View Controller Class
/* ################################################################################################################################## */
class RVS_ONVIF_tvOS_Test_Harness_NetworkInterface_Editor_ViewController: UIViewController {
    /* ############################################################################################################################## */
    // MARK: - Class Calculated Properties
    /* ############################################################################################################################## */
    /* ################################################################## */
    /**
     */
    class var storyboardID: String {
        return "networkInterfaceInput"
    }
    
    var networkInterfaceObject: RVS_ONVIF_Core.NetworkInterface!
    
    /* ############################################################################################################################## */
    // MARK: - IB Properties
    /* ############################################################################################################################## */
    /* ################################################################## */
    /**
     */
    @IBOutlet weak var enabledSegmentedSwitch: UISegmentedControl!
    @IBOutlet weak var tokenHeadlineLabel: UILabel!
    
    @IBOutlet weak var infoStackView: UIStackView!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var mtuTextField: UITextField!
    
    @IBOutlet weak var linkStackView: UIStackView!
    @IBOutlet weak var interfaceTypeLabel: UILabel!
    @IBOutlet weak var adminAutoNegSegmentedSwitch: UISegmentedControl!
    @IBOutlet weak var adminDuplexSegmentedSwitch: UISegmentedControl!
    @IBOutlet weak var adminSpeedTextField: UITextField!
    @IBOutlet weak var operAutoNegSegmentedSwitch: UISegmentedControl!
    @IBOutlet weak var operDuplexSegmentedSwitch: UISegmentedControl!
    @IBOutlet weak var operSpeedTextField: UITextField!
    
    @IBOutlet weak var ipv4StackView: UIStackView!
    
    @IBOutlet weak var sendButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!
    
    /* ############################################################################################################################## */
    // MARK: - IBAction Methods
    /* ############################################################################################################################## */
    /* ################################################################## */
    /**
     */
    @IBAction func cancelButtonHit(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    /* ################################################################## */
    /**
     */
    @IBAction func sendButtonHit(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    /* ############################################################################################################################## */
    // MARK: - Base Class Override Methods
    /* ############################################################################################################################## */
    /* ################################################################## */
    /**
     */
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let networkInterfaceObject = networkInterfaceObject {
            enabledSegmentedSwitch.selectedSegmentIndex = networkInterfaceObject.isEnabled ? 0 : 1
            var tokenText = networkInterfaceObject.token.isEmpty ? "NO TOKEN" : networkInterfaceObject.token
            if let info = networkInterfaceObject.info {
                tokenText += " (Hardware Address: \(info.hwAddress))"
            }
            tokenHeadlineLabel.text = tokenText
            if let info = networkInterfaceObject.info {
                nameTextField.text = info.name
                mtuTextField.text = String(info.mtu)
            }
            
            if let link = networkInterfaceObject.link {
                interfaceTypeLabel.text = "Interface Type: " + String(describing: link.interfaceType)
            }
        }
    }
}
