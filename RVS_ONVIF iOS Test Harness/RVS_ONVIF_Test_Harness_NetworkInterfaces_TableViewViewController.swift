/**
 © Copyright 2019, The Great Rift Valley Software Company. All rights reserved.
 
 This code is proprietary and confidential code,
 It is NOT to be reused or combined into any application,
 unless done so, specifically under written license from The Great Rift Valley Software Company.
 
 The Great Rift Valley Software Company: https://riftvalleysoftware.com
 */

import UIKit
import RVS_ONVIF_iOS
fileprivate extension UIView {
    /* ################################################################## */
    /**
     */
    func addContainedViewSpecial(_ inSubView: UIView, below inUpperView: UIView! = nil) {
        addSubview(inSubView)
        inSubView.translatesAutoresizingMaskIntoConstraints = false
        if let bottomAnchor = inUpperView?.bottomAnchor {
            inSubView.topAnchor.constraint(equalTo: bottomAnchor, constant: 0).isActive = true
        } else {
            inSubView.topAnchor.constraint(equalTo: self.topAnchor, constant: 0).isActive = true
        }
        inSubView.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: 0).isActive = true
        inSubView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 0).isActive = true
        inSubView.heightAnchor.constraint(equalToConstant: RVS_ONVIF_Test_Harness_NetworkInterfaces_TableViewViewController.rowHeight).isActive = true
    }
}

/* ################################################################################################################################## */
// MARK: - 
/* ################################################################################################################################## */
class RVS_ONVIF_Test_Harness_NetworkInterfaces_TableViewViewController: RVS_ONVIF_Test_Harness_ONVIF_TableViewController {
    static let rowHeight: CGFloat = 30
    let basicCellID = "basic-cell"
    var keyArray: [String] = ["Info", "Link", "IPv4", "IPv6", "Extension"]

    /* ############################################################################################################################## */
    // MARK: - Private Instance Properties
    /* ############################################################################################################################## */
    /* ################################################################## */
    /**
     */
    private var _networkInterfaceDictionaryArray: [[String: [String: String]?]] = []

    /* ################################################################## */
    /**
     */
    internal func setUpArray() {
        _networkInterfaceDictionaryArray = []
        for i in onvifInstance.core.networkInterfaces.enumerated() {
            _networkInterfaceDictionaryArray.append([:])
            setUpInterfaceInfoSection(for: i.element, atIndex: i.offset)
            setUpInterfaceLinkSection(for: i.element, atIndex: i.offset)
            setUpIPv4Section(for: i.element, atIndex: i.offset)
            setUpIPv6Section(for: i.element, atIndex: i.offset)
            setUpInterfaceExtensionSection(for: i.element, atIndex: i.offset)
        }
    }
    
    /* ################################################################## */
    /**
     */
    internal func setUpInterfaceInfoSection(for inInterface: RVS_ONVIF_Core.NetworkInterface?, atIndex inAtIndex: Int) {
        guard let info = inInterface?.info else { return }
        
        var section: [String: String] = [:]
        section["Name"] = info.name
        section["HWAddress"] = info.hwAddress
        section["MTU"] = String(info.mtu)
        _networkInterfaceDictionaryArray[inAtIndex]["Info"] = section
    }

    /* ################################################################## */
    /**
     */
    internal func setUpInterfaceLinkSection(for inInterface: RVS_ONVIF_Core.NetworkInterface?, atIndex inAtIndex: Int) {
        guard let link = inInterface?.link else { return }
        
        var section: [String: String] = [:]
        section["InterfaceType"] = String(link.interfaceType.rawValue)
        
        section["ADMIN: AutoNegotiation"] = link.adminSettings.autoNegotiation ? "ON" : "OFF"
        section["ADMIN: Speed"] = String(link.adminSettings.speed)
        section["ADMIN: Duplex"] = link.adminSettings.duplex.rawValue
        
        section["OPERATOR: AutoNegotiation"] = link.operSettings.autoNegotiation ? "ON" : "OFF"
        section["OPERATOR: Speed"] = String(link.operSettings.speed)
        section["OPERATOR: Duplex"] = link.operSettings.duplex.rawValue
        
        _networkInterfaceDictionaryArray[inAtIndex]["Link"] = section
    }

    /* ################################################################## */
    /**
     */
    internal func setUpIPv4Section(for inInterface: RVS_ONVIF_Core.NetworkInterface?, atIndex inAtIndex: Int) {
        guard let ipv4 = inInterface?.ipV4 else { return }
        
        var section: [String: String] = [:]
        section["Enabled"] = ipv4.isEnabled ? "YES" : "NO"
        section["DHCP"] = ipv4.configuration.isDHCP ? "YES" : "NO"
        if let list = ipv4.configuration.manual {
            for i in list.enumerated() {
                if let addr = i.element.address {
                    section["DHCP-Manual-Address[\(i.offset)]"] = addr.address
                }
                section["DHCP-Manual-Prefix[\(i.offset)]"] = String(i.element.prefixLength)
            }
        }
        
        if let list = ipv4.configuration.linkLocal {
            for i in list.enumerated() {
                if let addr = i.element.address {
                    section["DHCP-LinkLocal-Address[\(i.offset)]"] = addr.address
                }
                section["DHCP-LinkLocal-Prefix[\(i.offset)]"] = String(i.element.prefixLength)
            }
        }
        
        if let list = ipv4.configuration.fromDHCP {
            for i in list.enumerated() {
                if let addr = i.element.address {
                    section["DHCP-FromDHCP-Address[\(i.offset)]"] = addr.address
                }
                section["DHCP-FromDHCP-Prefix[\(i.offset)]"] = String(i.element.prefixLength)
            }
        }

        _networkInterfaceDictionaryArray[inAtIndex]["IPv4"] = section
    }

    /* ################################################################## */
    /**
     */
    internal func setUpIPv6Section(for inInterface: RVS_ONVIF_Core.NetworkInterface?, atIndex inAtIndex: Int) {
        guard let ipv6 = inInterface?.ipV6 else { return }
        
        var section: [String: String] = [:]
        section["Enabled"] = ipv6.isEnabled ? "YES" : "NO"
        section["DHCP"] = ipv6.configuration.isDHCP ? "YES" : "NO"
        section["Can Accept Router Advert"] = (ipv6.configuration.isAbleToAcceptRouterAdvert ?? false) ? "YES" : "NO"
        if let list = ipv6.configuration.manual {
            for i in list.enumerated() {
                if let addr = i.element.address {
                    section["DHCP-Manual-Address[\(i.offset)]"] = addr.address
                }
                section["DHCP-Manual-Prefix[\(i.offset)]"] = String(i.element.prefixLength)
            }
        }
        
        if let list = ipv6.configuration.linkLocal {
            for i in list.enumerated() {
                if let addr = i.element.address {
                    section["DHCP-LinkLocal-Address[\(i.offset)]"] = addr.address
                }
                section["DHCP-LinkLocal-Prefix[\(i.offset)]"] = String(i.element.prefixLength)
            }
        }
        
        if let list = ipv6.configuration.fromDHCP {
            for i in list.enumerated() {
                if let addr = i.element.address {
                    section["DHCP-FromDHCP-Address[\(i.offset)]"] = addr.address
                }
                section["DHCP-FromDHCP-Prefix[\(i.offset)]"] = String(i.element.prefixLength)
            }
        }
        
        if let list = ipv6.configuration.fromRA {
            for i in list.enumerated() {
                if let addr = i.element.address {
                    section["DHCP-FromRA-Address[\(i.offset)]"] = addr.address
                }
                section["DHCP-FromRA-Prefix[\(i.offset)]"] = String(i.element.prefixLength)
            }
        }
        
        if let ext = ipv6.configuration.ipv6ConfigurationExtension {
            section["Extension"] = String(describing: ext)
        }
        
        _networkInterfaceDictionaryArray[inAtIndex]["IPv6"] = section
    }

    /* ################################################################## */
    /**
     */
    internal func setUpInterfaceExtensionSection(for inInterface: RVS_ONVIF_Core.NetworkInterface?, atIndex inAtIndex: Int) {
        guard let sect = inInterface?.networkInterfaceExtension else { return }
        
        var section: [String: String] = [:]
        
        section["InterfaceType"] = String(sect.interfaceType.rawValue)

        if let ext = sect.dot3Configuration {
            section["Dot3"] = String(describing: ext)
        }

        if let dot11 = sect.dot11 {
            section["Dot11-SSID"] = dot11.ssid
            section["Dot11-Alias"] = dot11.alias
            section["Dot11-StationMode"] = dot11.mode.rawValue
            section["Dot11-SecurityMode"] = dot11.security.mode.rawValue
            if let priority = dot11.priority {
                section["Dot11-Priority"] = String(describing: priority)
            }
            
            if let algorithm = dot11.security.algorithm {
                section["Dot11-Security-Algorithm"] = algorithm.rawValue
            }
            
            if let pskRec = dot11.security.psk {
                section["Dot11-Security-PSK-Key"] = pskRec.key
                section["Dot11-Security-PSK-Passphrase"] = pskRec.passphrase
                if let ext = pskRec.dot11PSKSetExtension {
                    section["Dot11-Security-PSK-Extension"] = String(describing: ext)
                }
            }
            
            if let token = dot11.security.dot1XToken {
                section["Dot11-Security-Token"] = token
            }

            if let ext = dot11.security.dot11SecurityConfigurationExtension {
                section["Dot11-Security-Extension"] = String(describing: ext)
            }
        }

        if let ext = sect.networkInterfaceSetConfigurationExtension2 {
            section["Extension"] = String(describing: ext)
        }

        _networkInterfaceDictionaryArray[inAtIndex]["Extension"] = section
    }

    /* ############################################################################################################################## */
    // MARK: - Internal Instance Superclass Override Methods
    /* ############################################################################################################################## */
    /* ################################################################## */
    /**
     */
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpArray()
        tableView.reloadData()
    }

    /* ############################################################################################################################## */
    // MARK: - Internal Instance Override UITableViewDataSource Methods
    /* ############################################################################################################################## */
    /* ################################################################## */
    /**
     */
    override func numberOfSections(in tableView: UITableView) -> Int {
        return _networkInterfaceDictionaryArray.count
    }
    
    /* ################################################################## */
    /**
     */
    override func tableView(_ tableView: UITableView, titleForHeaderInSection inSection: Int) -> String? {
        let networkConfig = onvifInstance.core.networkInterfaces[inSection]
        var name = "Default"
        
        if !networkConfig.info.name.isEmpty {
            name = networkConfig.info.name
        } else if !networkConfig.token.isEmpty {
            name = networkConfig.token
        }
        
        return name
    }
    
    /* ################################################################## */
    /**
     */
    override func tableView(_ tableView: UITableView, numberOfRowsInSection inSection: Int) -> Int {
        return _networkInterfaceDictionaryArray[inSection].count
    }
    
    /* ################################################################## */
    /**
     */
    override func tableView(_ tableView: UITableView, heightForRowAt inIndexPath: IndexPath) -> CGFloat {
        if let section = _networkInterfaceDictionaryArray[inIndexPath.section] as? [String: [String: String]], let subArray = section[keyArray[inIndexPath.row]] {
            let height = CGFloat(subArray.count) * RVS_ONVIF_Test_Harness_NetworkInterfaces_TableViewViewController.rowHeight
            return height
        }
        
        return tableView.rowHeight
    }
    
    /* ################################################################## */
    /**
     */
    override func tableView(_ tableView: UITableView, cellForRowAt inIndexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: basicCellID, for: inIndexPath)
        
        if let section = _networkInterfaceDictionaryArray[inIndexPath.section] as? [String: [String: String]], let subArray = section[keyArray[inIndexPath.row]] {
            let title = keyArray[inIndexPath.row]
            let titleLabel = UILabel()
            titleLabel.text = title
            cell.contentView.addContainedViewSpecial(titleLabel)

            var previousView: UIView = titleLabel

            subArray.forEach { element in
                let elementLabel = UILabel()
                elementLabel.text = "\t\(element.key): \(element.value)"
                cell.contentView.addContainedViewSpecial(elementLabel, below: previousView)
                previousView = elementLabel
            }
        }

        return cell
    }
}
