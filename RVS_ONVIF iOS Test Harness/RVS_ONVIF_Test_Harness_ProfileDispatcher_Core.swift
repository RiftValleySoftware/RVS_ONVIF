//
//  RVS_ONVIF_Test_Harness_ProfileDispatcher_Core.swift
//  RVS_ONVIF Test Harness
//
//  Created by Chris Marshall on 3/6/19.
//  Copyright © 2019 The Great Rift Valley Software Company. All rights reserved.
//

import UIKit
import RVS_ONVIF_iOS

class RVS_ONVIF_Test_Harness_ProfileDispatcher_Core: RVS_ONVIF_Test_Harness_ProfileDispatcherProtocol {
    /* ################################################################## */
    /**
     */
    var profileObject: ProfileHandlerProtocol!

    /* ################################################################## */
    /**
     */
    var owner: RVS_ONVIF_Test_Harness_Functions_TableViewController!
    
    /* ################################################################## */
    /**
     */
    var wsdlUriString: String = ""
    
    /* ################################################################## */
    /**
     */
    var dynamicDNSResult: RVS_ONVIF_Core.DynamicDNSRecord!
    
    /* ################################################################## */
    /**
     */
    var hostnameString: String = ""
    
    /* ################################################################## */
    /**
     */
    var hostnameFromDHCP: Bool = false

    /* ################################################################## */
    /**
     */
    var getHostnameButton: UIButton!
    
    /* ################################################################## */
    /**
     */
    var getHostnameTextField: UITextField!
    
    /* ################################################################## */
    /**
     */
    var setHostnameTextField: UITextField!

    /* ################################################################## */
    /**
     */
    func updateUI() {
        owner?.tableView?.reloadData()
    }
    
    /* ################################################################## */
    /**
     */
    init(profile inProfile: ProfileHandlerProtocol, owner inOwner: RVS_ONVIF_Test_Harness_Functions_TableViewController) {
        profileObject = inProfile
        owner = inOwner
    }

    /* ################################################################## */
    /**
     */
    @objc func simpleCallFromButton(_ inButton: UIButton) {
        if var deviceRequestName = inButton.title(for: .normal) {
            if let arrowIndex = deviceRequestName.index(of: " 〉") {
                deviceRequestName = String(deviceRequestName[deviceRequestName.startIndex..<arrowIndex])
            }
            let commands = profileObject?.availableCommands.filter {    // This turns our string into the actual enum provided by the driver.
                $0.rawValue == deviceRequestName
            }
            
            if 1 == commands?.count, let command = commands?[0] {
                owner.simpleCall(command)
            }
        }
    }

    /* ################################################################## */
    /**
     */
    @objc func setHostnameButtonHit(_ inButton: UIButton) {
        let deviceRequestName = inButton.title(for: .normal)
        let commands = profileObject?.availableCommands.filter {    // This turns our string into the actual enum provided by the driver.
            $0.rawValue == deviceRequestName
        }
        
        if 1 == commands?.count, let command = commands?[0] {
            if let textVal = setHostnameTextField?.text {
                hostnameString = textVal
                getHostnameTextField?.text = hostnameString + (hostnameFromDHCP ? " (From DHCP)" : "")
                owner.paramCall(command, params: ["Name": textVal])
            }
        }
    }

    /* ################################################################## */
    /**
     */
    @objc func setDNSButtonHit(_ inButton: DNSEditorButton) {
        if let ownerInstance = owner?.onvifInstance {
            let isDHCP = inButton.isDHCPSwitch.isOn
            let searchDomains: [String] = inButton.searchDomainsTextField?.text?.components(separatedBy: ",") ?? []
            var ipAddresses: [RVS_IPAddress] = []
            if let ipAddressArray = inButton.dnsServerIPsTextField?.text?.components(separatedBy: ","), !ipAddressArray.isEmpty {
                for ip in ipAddressArray {
                    if let asIPAddress = ip.ipAddress, asIPAddress.isValidAddress {
                        ipAddresses.append(asIPAddress)
                    }
                }
            }
            let dns: RVS_ONVIF_Core.DNSRecord = RVS_ONVIF_Core.DNSRecord(owner: ownerInstance, searchDomain: searchDomains, isFromDHCP: isDHCP, addresses: ipAddresses)
            
            ownerInstance.core.setDNS(dns)
        }
    }

    /* ################################################################## */
    /**
     */
    @objc func setDynDNSButtonHit(_ inButton: DynDNSEditorButton) {
        if let ownerInstance = owner?.onvifInstance {
            var type: RVS_ONVIF_Core.DynamicDNSRecord.DynDNSType!
            
            switch inButton.typeSegmentedSwitch.selectedSegmentIndex {
            case 1:
                type = .ServerUpdates(ttl: inButton.ttlTextField.text?.asXMLDuration)
            case 2:
                type = .ClientUpdates(name: inButton.nameTextField.text ?? "", ttl: inButton.ttlTextField.text?.asXMLDuration)
            default:
                type = .NoUpdate
            }
            
            ownerInstance.core.setDynamicDNS(RVS_ONVIF_Core.DynamicDNSRecord(owner: ownerInstance, type: type))
        }
    }

    /* ################################################################## */
    /**
     */
    @objc func setNTPButtonHit(_ inButton: NTPEditorButton) {
        if let ownerInstance = owner?.onvifInstance {
            let isDHCP = inButton.isDHCPSwitch.isOn
            var ipAddresses: [RVS_IPAddress] = []
            var names: [String] = []
            if let ipAddressArray = inButton.ntpServerAddressTextField?.text?.components(separatedBy: ","), !ipAddressArray.isEmpty {
                for ip in ipAddressArray {
                    if let asIPAddress = ip.ipAddress, asIPAddress.isValidAddress {
                        ipAddresses.append(asIPAddress)
                    } else {
                        names.append(ip)
                    }
                }
            }
            
            let ntp: RVS_ONVIF_Core.NTPRecord = RVS_ONVIF_Core.NTPRecord(owner: ownerInstance, isFromDHCP: isDHCP, addresses: ipAddresses, names: names)
            
            ownerInstance.core.setNTP(ntp)
        }
    }

    /* ################################################################## */
    /**
     */
    func tableView(_ inTableView: UITableView, heightForRowAt inIndexPath: IndexPath) -> CGFloat {
        let command = profileObject.availableCommandsAsStrings[inIndexPath.row]
        
        switch command {
        case "GetWsdlUrl":
            if !wsdlUriString.isEmpty {
                return 80
            }
        case "GetDynamicDNS":
            if let dynamicDNSResult = dynamicDNSResult {
                switch dynamicDNSResult.type {
                case .ClientUpdates(let name, let ttl):
                    if !name.isEmpty && nil != ttl {
                        return 116
                    }
                    
                    fallthrough
                    
                default:
                    return 80
                }
            }
        case "GetHostname", "SetHostname":
            return 80
        case "SetDNS":
            return 166
        case "SetNTP", "SetDynamicDNS":
            return 136
        default:
            break
        }
        
        return 30
    }

    /* ################################################################## */
    /**
     */
    func tableView(_ inTableView: UITableView, cellForRowAt inIndexPath: IndexPath) -> UITableViewCell {
        let commandAsString = profileObject.availableCommandsAsStrings[inIndexPath.row]
        
        switch commandAsString {
        case "GetWsdlUrl":
            if !wsdlUriString.isEmpty {
                if let ret = inTableView.dequeueReusableCell(withIdentifier: RVS_ONVIF_Test_Harness_Functions_TableViewController.buttonEditCellID) as? RVS_ONVIF_Test_Harness_Functions_ButtonEdit_TableViewCell {
                    ret.button?.setTitle(commandAsString, for: .normal)
                    ret.textField?.text = wsdlUriString
                    ret.textField?.isEnabled = false
                    ret.button?.addTarget(self, action: #selector(simpleCallFromButton), for: .touchUpInside)
                    return ret
                }
            } else {
                fallthrough
            }
            
        case "GetHostname":
            if let ret = inTableView.dequeueReusableCell(withIdentifier: RVS_ONVIF_Test_Harness_Functions_TableViewController.buttonEditCellID) as? RVS_ONVIF_Test_Harness_Functions_ButtonEdit_TableViewCell {
                let buttonTitle = commandAsString
                getHostnameButton = ret.button
                getHostnameTextField = ret.textField
                getHostnameButton?.setTitle(buttonTitle, for: .normal)
                getHostnameTextField?.text = hostnameString + (hostnameFromDHCP ? " (From DHCP)" : "")
                getHostnameTextField?.isEnabled = false
                getHostnameButton?.addTarget(self, action: #selector(simpleCallFromButton), for: .touchUpInside)
                return ret
            }
            
        case "GetDynamicDNS":
            if let dynDNSRecord = dynamicDNSResult {
                let editTextContents = dynDNSRecord.type.description
                var ret: RVS_ONVIF_Test_Harness_Functions_ButtonEdit_TableViewCell!
                
                switch dynamicDNSResult.type {
                case .ClientUpdates(let name, let ttl):
                    if !name.isEmpty, nil != ttl, let retTemp = inTableView.dequeueReusableCell(withIdentifier: RVS_ONVIF_Test_Harness_Functions_TableViewController.button2LineEditCellID) as? RVS_ONVIF_Test_Harness_Functions_ButtonEdit_TableViewCell {
                        ret = retTemp
                    } else {
                        fallthrough
                    }
                    
                default:
                    if let retTemp = inTableView.dequeueReusableCell(withIdentifier: RVS_ONVIF_Test_Harness_Functions_TableViewController.buttonEditCellID) as? RVS_ONVIF_Test_Harness_Functions_ButtonEdit_TableViewCell {
                        ret = retTemp
                    }
                }
                
                if nil != ret {
                    ret.button?.setTitle(commandAsString + " 〉", for: .normal)
                    ret.textField?.text = editTextContents
                    ret.textField?.isEnabled = false
                    ret.button?.addTarget(self, action: #selector(simpleCallFromButton), for: .touchUpInside)
                    return ret
                }
            } else {
                fallthrough
            }

        default:
            return tableViewPartOnePointFive(inTableView, cellForRowAt: inIndexPath)
        }
        
        return UITableViewCell()
    }

    /* ################################################################## */
    /**
     */
    func tableViewPartOnePointFive(_ inTableView: UITableView, cellForRowAt inIndexPath: IndexPath) -> UITableViewCell {
        let commandAsString = profileObject.availableCommandsAsStrings[inIndexPath.row]
        
        switch commandAsString {
        case "SetHostname":
            if let ret = inTableView.dequeueReusableCell(withIdentifier: RVS_ONVIF_Test_Harness_Functions_TableViewController.buttonEditCellID) as? RVS_ONVIF_Test_Harness_Functions_ButtonEdit_TableViewCell {
                let buttonTitle = commandAsString
                ret.button?.setTitle(buttonTitle, for: .normal)
                setHostnameTextField = ret.textField
                setHostnameTextField.text = hostnameString
                ret.button?.addTarget(self, action: #selector(setHostnameButtonHit), for: .touchUpInside)
                return ret
            }
            
        case "SetHostnameFromDHCP":
            if let ret = inTableView.dequeueReusableCell(withIdentifier: RVS_ONVIF_Test_Harness_Functions_TableViewController.buttonOnlyCellID) as? RVS_ONVIF_Test_Harness_Functions_ButtonOnly_TableViewCell {
                ret.button?.setTitle(commandAsString, for: .normal)
                ret.button?.addTarget(self, action: #selector(simpleCallFromButton), for: .touchUpInside)
                return ret
            }

        case "SetNTP":
            if  let ret = inTableView.dequeueReusableCell(withIdentifier: RVS_ONVIF_Test_Harness_Functions_TableViewController.ntpCellID) as? RVS_ONVIF_Test_Harness_Functions_NTP_TableViewCell {
                ret.button?.setTitle(commandAsString, for: .normal)
                ret.button?.addTarget(self, action: #selector(setNTPButtonHit), for: .touchUpInside)
                ret.button?.command = profileObject.availableCommands[inIndexPath.row]
                return ret
            }

        default:
            return tableViewPartDeux(inTableView, cellForRowAt: inIndexPath)
        }
        return UITableViewCell()
    }
    
    /* ################################################################## */
    /**
     */
    func tableViewPartDeux(_ inTableView: UITableView, cellForRowAt inIndexPath: IndexPath) -> UITableViewCell {
        let commandAsString = profileObject.availableCommandsAsStrings[inIndexPath.row]
        
        switch commandAsString {
        case "SetDNS":
            if  let ret = inTableView.dequeueReusableCell(withIdentifier: RVS_ONVIF_Test_Harness_Functions_TableViewController.dnsCellID) as? RVS_ONVIF_Test_Harness_Functions_DNS_TableViewCell {
                ret.button?.setTitle(commandAsString, for: .normal)
                ret.button?.addTarget(self, action: #selector(setDNSButtonHit), for: .touchUpInside)
                ret.button?.command = profileObject.availableCommands[inIndexPath.row]
                return ret
            }
            
        case "SetDynamicDNS":
            if  let ret = inTableView.dequeueReusableCell(withIdentifier: RVS_ONVIF_Test_Harness_Functions_TableViewController.dynDnsCellID) as? RVS_ONVIF_Test_Harness_Functions_DynDNS_TableViewCell {
                ret.button?.setTitle(commandAsString, for: .normal)
                if let dynamicDNSResult = dynamicDNSResult {
                    switch dynamicDNSResult.type {
                    case .NoUpdate:
                        ret.button?.typeSegmentedSwitch.selectedSegmentIndex = 0
                    case .ServerUpdates(let ttl):
                        ret.button?.typeSegmentedSwitch.selectedSegmentIndex = 1
                        ret.button?.ttlTextField?.text = ttl?.asXMLDuration
                    case .ClientUpdates(let name, let ttl):
                        ret.button?.typeSegmentedSwitch.selectedSegmentIndex = 2
                        ret.button?.nameTextField?.text = name
                        ret.button?.ttlTextField?.text = ttl?.asXMLDuration
                    }
                }
                ret.button?.addTarget(self, action: #selector(setDynDNSButtonHit), for: .touchUpInside)
                ret.button?.command = profileObject.availableCommands[inIndexPath.row]
                return ret
            }

        default:
            if profileObject.availableCommands[inIndexPath.row].requiresParameters {
                if let ret = inTableView.dequeueReusableCell(withIdentifier: RVS_ONVIF_Test_Harness_Functions_TableViewController.textOnlyCellID) {
                    ret.textLabel?.text = commandAsString
                    return ret
                }
            } else if let ret = inTableView.dequeueReusableCell(withIdentifier: RVS_ONVIF_Test_Harness_Functions_TableViewController.buttonOnlyCellID) as? RVS_ONVIF_Test_Harness_Functions_ButtonOnly_TableViewCell {
                ret.button?.setTitle(commandAsString + " 〉", for: .normal)
                ret.button?.addTarget(self, action: #selector(simpleCallFromButton), for: .touchUpInside)
                return ret
            }
        }
        
        return UITableViewCell()
    }
    
    /* ############################################################################################################################## */
    // MARK: - Internal Instance RVS_ONVIFDelegate Methods
    /* ############################################################################################################################## */
    /* ################################################################## */
    /**
     */
    func onvifInstance(_ inONVIFInstance: RVS_ONVIF, simpleResponseToRequest inSimpleResponseToRequest: RVS_ONVIF_DeviceRequestProtocol!) {
        #if DEBUG
            print("Bill the Cat Says \"ACK\"")
        #endif
    }
    
    /* ################################################################## */
    /**
     */
    func onvifInstance(_ inONVIFInstance: RVS_ONVIF, getWSDLURI inWSDLURI: String!) {
        #if DEBUG
            print("URI: \(String(describing: inWSDLURI))")
        #endif
        wsdlUriString = inWSDLURI
        owner?.tableView?.reloadData()
    }
    
    /* ################################################################## */
    /**
     */
    func onvifInstance(_ inONVIFInstance: RVS_ONVIF, getHostname inHostname: RVS_ONVIF_Core.HostnameResponse!) {
        #if DEBUG
            print("Hostname: \(String(describing: inHostname))")
        #endif
        hostnameString = inHostname.name
        hostnameFromDHCP = inHostname.fromDHCP
        owner?.tableView?.reloadData()
    }
    
    /* ################################################################## */
    /**
     */
    func onvifInstance(_ inONVIFInstance: RVS_ONVIF, getDNS inGetDNS: RVS_ONVIF_Core.DNSRecord!) {
        if let getDNS = inGetDNS, let destination = owner?.storyboard?.instantiateViewController(withIdentifier: "GetDNS") as? RVS_ONVIF_Test_Harness_DNS_TableViewController {
            destination.onvifInstance = owner?.onvifInstance
            destination.dnsEntry = getDNS
            owner?.navigationController?.show(destination, sender: nil)
        }
    }
    
    /* ################################################################## */
    /**
     */
    func onvifInstance(_ inONVIFInstance: RVS_ONVIF, getDynamicDNS inGetDynamicDNS: RVS_ONVIF_Core.DynamicDNSRecord!) {
        dynamicDNSResult = inGetDynamicDNS
        owner?.tableView?.reloadData()
    }

    /* ################################################################## */
    /**
     */
    func onvifInstance(_ inONVIFInstance: RVS_ONVIF, getNTP inGetNTP: RVS_ONVIF_Core.NTPRecord!) {
        if let getNTP = inGetNTP, let destination = owner?.storyboard?.instantiateViewController(withIdentifier: "GetNTP") as? RVS_ONVIF_Test_Harness_NTP_TableViewController {
            destination.onvifInstance = owner?.onvifInstance
            destination.ntpEntry = getNTP
            owner?.navigationController?.show(destination, sender: nil)
        }
    }
}
