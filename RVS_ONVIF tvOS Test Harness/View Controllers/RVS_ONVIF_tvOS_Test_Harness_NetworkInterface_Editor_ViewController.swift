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
    @IBOutlet weak var ipv4EnabledSegmentedSwitch: UISegmentedControl!
    @IBOutlet weak var ipv4DHCPSegmentedSwitch: UISegmentedControl!
    @IBOutlet weak var ipv4ManualAddressStackView: UIStackView!
    @IBOutlet weak var ipv4ManualAddressEntryTextField: UITextField!
    @IBOutlet weak var ipv4ManualPrefixLengthTextField: UITextField!
    @IBOutlet weak var ipv4LinkLocalAddressLabel: UILabel!
    @IBOutlet weak var ipv4FromDHCPAddressLabel: UILabel!
    
    @IBOutlet weak var ipv6StackView: UIStackView!
    @IBOutlet weak var ipv6EnabledSegmentedSwitch: UISegmentedControl!
    @IBOutlet weak var ipv6AcceptRALabel: UILabel!
    @IBOutlet weak var ipv6AcceptRouterAdvertSegmentedSwitch: UISegmentedControl!
    @IBOutlet weak var ipv6DHCPSegmentedSwitch: UISegmentedControl!
    @IBOutlet weak var ipv6ManualAddressStackView: UIStackView!
    @IBOutlet weak var ipv6ManualAddressEntryTextField: UITextField!
    @IBOutlet weak var ipv5ManualPrefixLengthTextField: UITextField!
    @IBOutlet weak var ipv6LinkLocalAddressLabel: UILabel!
    @IBOutlet weak var ipv6FromDHCPAddressLabel: UILabel!
    @IBOutlet weak var ipv6FromRAAddressLabel: UILabel!

    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var extensionButton: UIButton!
    @IBOutlet weak var sendButton: UIButton!
    
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
    
    /* ################################################################## */
    /**
     */
    @IBAction func extensionButtonHit(_ sender: Any) {
    }

    /* ############################################################################################################################## */
    // MARK: - Base Class Override Methods
    /* ############################################################################################################################## */
    /* ################################################################## */
    /**
     */
    override func viewDidLoad() {
        super.viewDidLoad()
        
        infoStackView.isHidden = true
        
        linkStackView.isHidden = true
        
        ipv4StackView.isHidden = true
        ipv4ManualAddressStackView.isHidden = true
        ipv4LinkLocalAddressLabel.isHidden = true
        ipv4FromDHCPAddressLabel.isHidden = true
        
        ipv6StackView.isHidden = true
        ipv6AcceptRALabel.isHidden = true
        ipv6AcceptRouterAdvertSegmentedSwitch.isHidden = true
        ipv6ManualAddressStackView.isHidden = true
        ipv6LinkLocalAddressLabel.isHidden = true
        ipv6FromDHCPAddressLabel.isHidden = true
        ipv6FromRAAddressLabel.isHidden = true
        
        extensionButton.isHidden = true

        if let networkInterfaceObject = networkInterfaceObject {
            enabledSegmentedSwitch.selectedSegmentIndex = networkInterfaceObject.isEnabled ? 0 : 1
            var tokenText = networkInterfaceObject.token.isEmpty ? "NO TOKEN" : networkInterfaceObject.token
            if let info = networkInterfaceObject.info {
                tokenText += " (Hardware Address: \(info.hwAddress))"
            }
            tokenHeadlineLabel.text = tokenText

            if let info = networkInterfaceObject.info {
                infoStackView.isHidden = false
                nameTextField.text = info.name
                mtuTextField.text = String(info.mtu)
            }
            
            if let link = networkInterfaceObject.link {
                linkStackView.isHidden = false
                interfaceTypeLabel.text = "Interface Type: " + String(describing: link.interfaceType)
                adminAutoNegSegmentedSwitch.selectedSegmentIndex = link.adminSettings.autoNegotiation ? 0 : 1
                adminDuplexSegmentedSwitch.selectedSegmentIndex = .Full == link.adminSettings.duplex ? 0 : 1
                adminSpeedTextField.text = String(link.adminSettings.speed)
                operAutoNegSegmentedSwitch.selectedSegmentIndex = link.operSettings.autoNegotiation ? 0 : 1
                operDuplexSegmentedSwitch.selectedSegmentIndex = .Full == link.operSettings.duplex ? 0 : 1
                operSpeedTextField.text = String(link.operSettings.speed)
            }
            
            if let ipv4 = networkInterfaceObject.ipV4 {
                ipv4StackView.isHidden = false
                if let manual = ipv4.configuration.manual {
                    ipv4ManualAddressStackView.isHidden = false
                    ipv4ManualAddressEntryTextField.text = manual[0].address.address
                    ipv4ManualPrefixLengthTextField.text = String(manual[0].prefixLength)
                }
                
                if nil != ipv4.configuration.linkLocal {
                    ipv4LinkLocalAddressLabel.isHidden = false
                }
                
                if nil != ipv4.configuration.fromDHCP {
                    ipv4FromDHCPAddressLabel.isHidden = false
                }
            }
            
            if let ipv6 = networkInterfaceObject.ipV6 {
                ipv4StackView.isHidden = false
                if let manual = ipv6.configuration.manual {
                    ipv6ManualAddressStackView.isHidden = false
                    ipv6ManualAddressEntryTextField.text = manual[0].address.address
                    ipv5ManualPrefixLengthTextField.text = String(manual[0].prefixLength)
                }
                
                if nil != ipv6.configuration.linkLocal {
                    ipv6LinkLocalAddressLabel.isHidden = false
                }
                
                if nil != ipv6.configuration.fromDHCP {
                    ipv6FromDHCPAddressLabel.isHidden = false
                }
                
                if nil != ipv6.configuration.fromRA {
                    ipv6FromRAAddressLabel.isHidden = false
                }
            }
            
            extensionButton.isHidden = nil == networkInterfaceObject.networkInterfaceExtension
        }
    }
}
