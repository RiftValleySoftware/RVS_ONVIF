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
    var networkInterfaceObject: RVS_ONVIF_Core.NetworkInterface!
    
    /* ################################################################## */
    /**
     */
    var dispatcher: RVS_ONVIF_tvOS_Test_Harness_Dispatcher!
    
    /* ################################################################## */
    /**
     */
    var command: RVS_ONVIF_DeviceRequestProtocol!

    /* ############################################################################################################################## */
    // MARK: - Instance Calculated Properties
    /* ############################################################################################################################## */
    /* ################################################################## */
    /**
     */
    var sendParameters: [String: Any] {
        if var networkInterfaceObject = networkInterfaceObject {
            networkInterfaceObject.isEnabled = 0 == enabledSegmentedSwitch.selectedSegmentIndex
            
            if nil != networkInterfaceObject.info {
                networkInterfaceObject.info.name = nameTextField.text ?? ""
                networkInterfaceObject.info.mtu = Int(mtuTextField.text ?? "") ?? 0
            }
            
            if nil != networkInterfaceObject.link {
                networkInterfaceObject.link.adminSettings.autoNegotiation = 0 == adminAutoNegSegmentedSwitch.selectedSegmentIndex
                networkInterfaceObject.link.adminSettings.duplex = 0 == adminDuplexSegmentedSwitch.selectedSegmentIndex ? .Full : .Half
                networkInterfaceObject.link.adminSettings.speed = Int(adminSpeedTextField.text ?? "") ?? 0

                networkInterfaceObject.link.operSettings.autoNegotiation = 0 == operAutoNegSegmentedSwitch.selectedSegmentIndex
                networkInterfaceObject.link.operSettings.duplex = 0 == operDuplexSegmentedSwitch.selectedSegmentIndex ? .Full : .Half
                networkInterfaceObject.link.operSettings.speed = Int(operSpeedTextField.text ?? "") ?? 0
            }
            
            if  nil != networkInterfaceObject.ipV4,
                let address = ipv4ManualAddressEntryTextField?.text?.ipAddress,
                let prefix = Int(ipv4ManualPrefixLengthTextField.text ?? ""),
                0 < prefix {
                networkInterfaceObject.ipV4?.configuration.dhcp = 0 == ipv4DHCPSegmentedSwitch.selectedSegmentIndex ? .On : .Off
                let manVal = RVS_ONVIF_Core.IPAddressEntry(address: address, prefixLength: prefix)
                networkInterfaceObject.ipV4?.configuration.manual.append(manVal)
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
    @IBOutlet weak var ipv6ManualPrefixLengthTextField: UITextField!
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
        dispatcher?.sendParameters = sendParameters
        dispatcher?.sendRequest(command)
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
                ipv4DHCPSegmentedSwitch.selectedSegmentIndex = ipv4.configuration.isDHCP ? 0 : 1
                
                if  let manual = ipv4.configuration.manual,
                    !manual.isEmpty,
                    nil != manual[0].address {
                    ipv4ManualAddressStackView.isHidden = false
                    ipv4ManualAddressEntryTextField.text = manual[0].address.address
                    ipv4ManualPrefixLengthTextField.text = String(manual[0].prefixLength)
                }
                
                if  let linkLocal = ipv4.configuration.linkLocal,
                    !linkLocal.isEmpty,
                    nil != linkLocal[0].address {
                    ipv4LinkLocalAddressLabel.isHidden = false
                    let addresses: String = linkLocal.reduce("") { (current, next) -> String in
                        var ret = current
                        
                        if !ret.isEmpty {
                            ret += ","
                        }
                        
                        ret += next.address.address
                        ret += "/" + String(next.prefixLength)
                        
                        return ret
                    }
                    ipv4LinkLocalAddressLabel.text = "Link Local: \(addresses)"
                }
                
                if  let fromDHCP = ipv4.configuration.fromDHCP,
                    !fromDHCP.isEmpty,
                    nil != fromDHCP[0].address {
                    ipv4FromDHCPAddressLabel.isHidden = false
                    let addresses: String = fromDHCP.reduce("") { (current, next) -> String in
                        var ret = current
                        
                        if !ret.isEmpty {
                            ret += ","
                        }
                        
                        ret += next.address.address
                        ret += "/" + String(next.prefixLength)
                        
                        return ret
                    }
                    ipv4FromDHCPAddressLabel.text = "From DHCP: \(addresses)"
                }
            }
            
            if let ipv6 = networkInterfaceObject.ipV6 {
                ipv4StackView.isHidden = false
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
                if  let manual = ipv6.configuration.manual,
                    !manual.isEmpty,
                    nil != manual[0].address {
                    ipv6ManualAddressStackView.isHidden = false
                    ipv6ManualAddressEntryTextField.text = manual[0].address.address
                    ipv6ManualPrefixLengthTextField.text = String(manual[0].prefixLength)
                }
                
                if  let linkLocal = ipv6.configuration.linkLocal,
                    !linkLocal.isEmpty,
                    nil != linkLocal[0].address {
                    ipv6LinkLocalAddressLabel.isHidden = false
                    let addresses: String = linkLocal.reduce("") { (current, next) -> String in
                        var ret = current
                        
                        if !ret.isEmpty {
                            ret += ","
                        }
                        
                        ret += next.address.address
                        ret += "/" + String(next.prefixLength)
                        
                        return ret
                    }
                    ipv6LinkLocalAddressLabel.text = "Link Local: \(addresses)"
                }
                
                if  let fromDHCP = ipv6.configuration.fromDHCP,
                    !fromDHCP.isEmpty,
                    nil != fromDHCP[0].address {
                    ipv6FromDHCPAddressLabel.isHidden = false
                    let addresses: String = fromDHCP.reduce("") { (current, next) -> String in
                        var ret = current
                        
                        if !ret.isEmpty {
                            ret += ","
                        }
                        
                        ret += next.address.address
                        ret += "/" + String(next.prefixLength)
                        
                        return ret
                    }
                    ipv6FromDHCPAddressLabel.text = "From DHCP: \(addresses)"
                }
                
                if  let fromRA = ipv6.configuration.fromRA,
                    !fromRA.isEmpty,
                    nil != fromRA[0].address {
                    ipv6FromRAAddressLabel.isHidden = false
                    let addresses: String = fromRA.reduce("") { (current, next) -> String in
                        var ret = current
                        
                        if !ret.isEmpty {
                            ret += ","
                        }
                        
                        ret += next.address.address
                        ret += "/" + String(next.prefixLength)
                        
                        return ret
                    }
                    ipv6FromRAAddressLabel.text = "From RA: \(addresses)"
                }
            }
            
            extensionButton.isHidden = nil == networkInterfaceObject.networkInterfaceExtension
        }
    }
}
