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
    
    /* ############################################################################################################################## */
    // MARK: - Instance Properties
    /* ############################################################################################################################## */
    /* ################################################################## */
    /**
     */
    var networkInterfaceObjects: [RVS_ONVIF_Core.NetworkInterface]!
    
    /* ################################################################## */
    /**
     */
    var dispatcher: RVS_ONVIF_tvOS_Test_Harness_Dispatcher!
    
    /* ################################################################## */
    /**
     */
    var command: RVS_ONVIF_DeviceRequestProtocol!
    
    /* ################################################################## */
    /**
     */
    var selectedInterfaceObjectIndex: Int = 0

    /* ############################################################################################################################## */
    // MARK: - Instance Calculated Properties
    /* ############################################################################################################################## */
    /* ################################################################## */
    /**
     */
    var sendParameters: [String: Any] {
        if var networkInterfaceObject = networkInterfaceObjects?[selectedInterfaceObjectIndex] {
            networkInterfaceObject.isEnabled = 0 == enabledSegmentedSwitch.selectedSegmentIndex
            
            if  nil != networkInterfaceObject.ipV4,
                let address = ipv4ManualAddressEntryTextField?.text?.ipAddress,
                let prefix = Int(ipv4ManualPrefixLengthTextField.text ?? ""),
                0 < prefix {
                networkInterfaceObject.ipV4?.configuration.dhcp = 0 == ipv4DHCPSegmentedSwitch.selectedSegmentIndex ? .On : .Off
                let manVal = RVS_ONVIF_Core.IPAddressEntry(address: address, prefixLength: prefix)
                networkInterfaceObject.ipV4?.configuration.manual = [manVal]
            }
            
            if  nil != networkInterfaceObject.ipV6,
                let address = ipv6ManualAddressEntryTextField?.text?.ipAddress,
                let prefix = Int(ipv6ManualPrefixLengthTextField.text ?? ""),
                0 < prefix {
                    switch ipv4DHCPSegmentedSwitch.selectedSegmentIndex {
                    case 0:
                        networkInterfaceObject.ipV6.configuration.dhcp = .Auto
                        
                    case 1:
                        networkInterfaceObject.ipV6.configuration.dhcp = .Stateful

                    case 2:
                        networkInterfaceObject.ipV6.configuration.dhcp = .Stateless

                    default:
                        networkInterfaceObject.ipV6.configuration.dhcp = .Off
                    }
                let manVal = RVS_ONVIF_Core.IPAddressEntry(address: address, prefixLength: prefix)
                networkInterfaceObject.ipV6?.configuration.manual.append(manVal)
            }
            
            if nil != networkInterfaceObject.networkInterfaceExtension {
            }

            if let asParameters = networkInterfaceObject.asParameters {
                networkInterfaceObjects[selectedInterfaceObjectIndex] = networkInterfaceObject
                print(String(reflecting: asParameters))
                return asParameters
            }
        }

        return [:]
    }

    /* ############################################################################################################################## */
    // MARK: - IB Properties
    /* ############################################################################################################################## */
    /* ################################################################## */
    /**
     */
    @IBOutlet weak var enabledSegmentedSwitch: UISegmentedControl!
    @IBOutlet weak var tokenHeadlineLabel: UILabel!
    @IBOutlet weak var networkInterfaceSelectorSegmentedSwitch: UISegmentedControl!
    
    @IBOutlet weak var infoStackView: UIStackView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var mtuLabel: UILabel!
    
    @IBOutlet weak var ipv4StackView: UIStackView!
    @IBOutlet weak var ipv4EnabledSegmentedSwitch: UISegmentedControl!
    @IBOutlet weak var ipv4DHCPSegmentedSwitch: UISegmentedControl!
    @IBOutlet weak var ipv4ManualAddressStackView: UIStackView!
    @IBOutlet weak var ipv4ManualAddressEntryTextField: UITextField!
    @IBOutlet weak var ipv4ManualPrefixLengthTextField: UITextField!
    
    @IBOutlet weak var ipv6StackView: UIStackView!
    @IBOutlet weak var ipv6EnabledSegmentedSwitch: UISegmentedControl!
    @IBOutlet weak var ipv6AcceptRALabel: UILabel!
    @IBOutlet weak var ipv6AcceptRouterAdvertSegmentedSwitch: UISegmentedControl!
    @IBOutlet weak var ipv6DHCPSegmentedSwitch: UISegmentedControl!
    @IBOutlet weak var ipv6ManualAddressStackView: UIStackView!
    @IBOutlet weak var ipv6ManualAddressEntryTextField: UITextField!
    @IBOutlet weak var ipv6ManualPrefixLengthTextField: UITextField!

    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var extensionButton: UIButton!
    @IBOutlet weak var sendButton: UIButton!
    
    /* ############################################################################################################################## */
    // MARK: - IBAction Methods
    /* ############################################################################################################################## */
    /* ################################################################## */
    /**
     */
    @IBAction func interfaceSwitchHit(_ inSwitch: UISegmentedControl) {
        selectedInterfaceObjectIndex = inSwitch.selectedSegmentIndex
        loadInterfaceObject()
    }
    
    /* ################################################################## */
    /**
     */
    @IBAction func cancelButtonHit(_ inButton: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    /* ################################################################## */
    /**
     */
    @IBAction func sendButtonHit(_ inButton: Any) {
        dispatcher?.sendParameters = sendParameters
        dispatcher?.sendRequest(command)
        dismiss(animated: true, completion: nil)
    }
    
    /* ################################################################## */
    /**
     */
    @IBAction func extensionButtonHit(_ inButton: Any) {
    }
    
    /* ################################################################## */
    /**
     */
    func loadInterfaceObject() {
        infoStackView.isHidden = true
        
        ipv4StackView.isHidden = true
        ipv4ManualAddressStackView.isHidden = true
        
        ipv6StackView.isHidden = true
        ipv6AcceptRALabel.isHidden = true
        ipv6AcceptRouterAdvertSegmentedSwitch.isHidden = true
        ipv6ManualAddressStackView.isHidden = true
        
        extensionButton.isHidden = true

        if let networkInterfaceObject = networkInterfaceObjects?[selectedInterfaceObjectIndex] {
            enabledSegmentedSwitch.selectedSegmentIndex = networkInterfaceObject.isEnabled ? 0 : 1
            var tokenText = networkInterfaceObject.token.isEmpty ? "" : networkInterfaceObject.token
            if let info = networkInterfaceObject.info {
                if tokenText.isEmpty {
                    tokenText = "Hardware Address: \(info.hwAddress)"
                } else {
                    tokenText += " (Hardware Address: \(info.hwAddress))"
                }
            }
            
            tokenHeadlineLabel.text = tokenText
            
            if let info = networkInterfaceObject.info {
                infoStackView.isHidden = false
                nameLabel.text = info.name
                mtuLabel.text = "MTU: " + String(info.mtu)
            }
            
            if let ipv4 = networkInterfaceObject.ipV4 {
                ipv4StackView.isHidden = false
                ipv4DHCPSegmentedSwitch.selectedSegmentIndex = ipv4.configuration.isDHCP ? 0 : 1
                
                if  let manual = ipv4.configuration.manual,
                    !manual.isEmpty,
                    nil != manual[0].address {
                    ipv4ManualAddressStackView.isHidden = false
                    ipv4ManualAddressEntryTextField.text = manual[0].address.address
                    ipv4ManualPrefixLengthTextField.text = String(manual[0].prefixLength)
                }
            }
            
            if let ipv6 = networkInterfaceObject.ipV6 {
                ipv6StackView.isHidden = false
                switch ipv6.configuration.dhcp {
                case .Auto:
                    ipv6DHCPSegmentedSwitch.selectedSegmentIndex = 0
                    
                case .Stateful:
                    ipv6DHCPSegmentedSwitch.selectedSegmentIndex = 1
                    
                case .Stateless:
                    ipv6DHCPSegmentedSwitch.selectedSegmentIndex = 2
                    
                default:
                    ipv6DHCPSegmentedSwitch.selectedSegmentIndex = 3
                }
                
                ipv6ManualAddressStackView.isHidden = false
                
                if  let manual = ipv6.configuration.manual,
                    !manual.isEmpty {
                    ipv6ManualPrefixLengthTextField.text = String(manual[0].prefixLength)
                    if let addr = manual[0].address?.address {
                        ipv6ManualAddressEntryTextField.text = addr
                    }
                }
            }
            
            extensionButton.isHidden = nil == networkInterfaceObject.networkInterfaceExtension
        }
    }
    
    /* ############################################################################################################################## */
    // MARK: - Base Class Override Methods
    /* ############################################################################################################################## */
    /* ################################################################## */
    /**
     */
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let networkInterfaceObjects = networkInterfaceObjects {
            networkInterfaceSelectorSegmentedSwitch.isHidden = 2 > networkInterfaceObjects.count
            
            for networkInterfaceTuple in networkInterfaceObjects.enumerated() {
                let token = networkInterfaceTuple.element.token
                if networkInterfaceSelectorSegmentedSwitch.numberOfSegments < networkInterfaceTuple.offset {
                    networkInterfaceSelectorSegmentedSwitch.insertSegment(withTitle: token, at: networkInterfaceSelectorSegmentedSwitch.numberOfSegments, animated: false)
                } else {
                    networkInterfaceSelectorSegmentedSwitch.setTitle(token, forSegmentAt: networkInterfaceTuple.offset)
                }
            }
        }
        
        loadInterfaceObject()
    }
}
