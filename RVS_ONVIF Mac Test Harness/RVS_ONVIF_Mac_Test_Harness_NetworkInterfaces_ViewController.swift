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

import Cocoa
import RVS_ONVIF_MacOS

/* ################################################################################################################################## */
// MARK: - Main Logged-In Network Interfaces Screen View Controller
/* ################################################################################################################################## */
class RVS_ONVIF_Mac_Test_Harness_NetworkInterfaces_ViewController: RVS_ONVIF_Mac_Test_Harness_Base_ViewController, NSTableViewDataSource, NSTableViewDelegate {
    @IBOutlet weak var displayTableView: NSTableView!
    
    typealias RVS_ONVIF_Mac_Test_Harness_GroupedTableData = (key: String, value: String)
    
    var tableRowData: [RVS_ONVIF_Mac_Test_Harness_GroupedTableData] = []
    
    override var loginViewController: RVS_ONVIF_Mac_Test_Harness_LoginScreen_ViewController! {
        get {
            return super.loginViewController
        }
        
        set {
            super.loginViewController = newValue
            tableRowData = []
            if let networkInterfacesArray = RVS_ONVIF_Mac_Test_Harness_AppDelegate.appDelegateObject.onvifInstance?.networkInterfaces {
                for i in networkInterfacesArray.enumerated() {
                    if let info = i.element.info {
                        tableRowData.append(RVS_ONVIF_Mac_Test_Harness_GroupedTableData(key: "NETWORK INTERFACE \(info.name)", value: ""))
                        tableRowData.append(RVS_ONVIF_Mac_Test_Harness_GroupedTableData(key: "Info", value: ""))
                        tableRowData.append(RVS_ONVIF_Mac_Test_Harness_GroupedTableData(key: "Name", value: info.name))
                        tableRowData.append(RVS_ONVIF_Mac_Test_Harness_GroupedTableData(key: "HWAddress", value: info.hwAddress))
                        tableRowData.append(RVS_ONVIF_Mac_Test_Harness_GroupedTableData(key: "MTU", value: String(info.mtu)))
                    }
                    
                    if let link = i.element.link {
                        tableRowData.append(RVS_ONVIF_Mac_Test_Harness_GroupedTableData(key: "Link", value: ""))
                        tableRowData.append(RVS_ONVIF_Mac_Test_Harness_GroupedTableData(key: "InterfaceType", value: String(link.interfaceType.rawValue)))
                        tableRowData.append(RVS_ONVIF_Mac_Test_Harness_GroupedTableData(key: "ADMIN: AutoNegotiation", value: link.adminSettings.autoNegotiation ? "ON" : "OFF"))
                        tableRowData.append(RVS_ONVIF_Mac_Test_Harness_GroupedTableData(key: "ADMIN: Speed", value: String(link.adminSettings.speed)))
                        tableRowData.append(RVS_ONVIF_Mac_Test_Harness_GroupedTableData(key: "ADMIN: Duplex", value: link.adminSettings.duplex.rawValue))
                        tableRowData.append(RVS_ONVIF_Mac_Test_Harness_GroupedTableData(key: "OPERATOR: AutoNegotiation", value: link.operSettings.autoNegotiation ? "ON" : "OFF"))
                        tableRowData.append(RVS_ONVIF_Mac_Test_Harness_GroupedTableData(key: "OPERATOR: Speed", value: String(link.operSettings.speed)))
                        tableRowData.append(RVS_ONVIF_Mac_Test_Harness_GroupedTableData(key: "OPERATOR: Duplex", value: link.operSettings.duplex.rawValue))
                    }
                    
                    if let ipv4 = i.element.ipV4 {
                        tableRowData.append(RVS_ONVIF_Mac_Test_Harness_GroupedTableData(key: "IPv4", value: ""))
                        tableRowData.append(RVS_ONVIF_Mac_Test_Harness_GroupedTableData(key: "Enabled", value: ipv4.isEnabled ? "YES" : "NO"))
                        tableRowData.append(RVS_ONVIF_Mac_Test_Harness_GroupedTableData(key: "DHCP", value: ipv4.configuration.isDHCP ? "YES" : "NO"))
                        if let list = ipv4.configuration.manual {
                            for i in list.enumerated() {
                                if let addr = i.element.address {
                                    tableRowData.append(RVS_ONVIF_Mac_Test_Harness_GroupedTableData(key: "DHCP-Manual-Address[\(i.offset)]", value: addr.address))
                                }
                                tableRowData.append(RVS_ONVIF_Mac_Test_Harness_GroupedTableData(key: "DHCP-Manual-Prefix[\(i.offset)]", value: String(i.element.prefixLength)))
                            }
                        }
                        
                        if let list = ipv4.configuration.linkLocal {
                            for i in list.enumerated() {
                                if let addr = i.element.address {
                                    tableRowData.append(RVS_ONVIF_Mac_Test_Harness_GroupedTableData(key: "DHCP-LinkLocal-Address[\(i.offset)]", value: addr.address))
                                }
                                tableRowData.append(RVS_ONVIF_Mac_Test_Harness_GroupedTableData(key: "DHCP-LinkLocal-Prefix[\(i.offset)]", value: String(i.element.prefixLength)))
                            }
                        }
                        
                        if let list = ipv4.configuration.fromDHCP {
                            for i in list.enumerated() {
                                if let addr = i.element.address {
                                    tableRowData.append(RVS_ONVIF_Mac_Test_Harness_GroupedTableData(key: "DHCP-FromDHCP-Address[\(i.offset)]", value: addr.address))
                                }
                                tableRowData.append(RVS_ONVIF_Mac_Test_Harness_GroupedTableData(key: "DHCP-FromDHCP-Prefix[\(i.offset)]", value: String(i.element.prefixLength)))
                            }
                        }
                    }
                    
                    if let ipv6 = i.element.ipV6 {
                        let isAbletoRA: Bool = ipv6.configuration.isAbleToAcceptRouterAdvert ?? false
                        tableRowData.append(RVS_ONVIF_Mac_Test_Harness_GroupedTableData(key: "IPv6", value: ""))
                        tableRowData.append(RVS_ONVIF_Mac_Test_Harness_GroupedTableData(key: "Enabled", value: ipv6.isEnabled ? "YES" : "NO"))
                        tableRowData.append(RVS_ONVIF_Mac_Test_Harness_GroupedTableData(key: "DHCP", value: ipv6.configuration.dhcp.rawValue))
                        tableRowData.append(RVS_ONVIF_Mac_Test_Harness_GroupedTableData(key: "Can Accept Router Advert", value: isAbletoRA ? "YES" : "NO"))
                        if let list = ipv6.configuration.manual {
                            for i in list.enumerated() {
                                if let addr = i.element.address {
                                    tableRowData.append(RVS_ONVIF_Mac_Test_Harness_GroupedTableData(key: "DHCP-Manual-Address[\(i.offset)]", value: addr.address))
                                }
                                tableRowData.append(RVS_ONVIF_Mac_Test_Harness_GroupedTableData(key: "DHCP-Manual-Prefix[\(i.offset)]", value: String(i.element.prefixLength)))
                            }
                        }
                        
                        if let list = ipv6.configuration.linkLocal {
                            for i in list.enumerated() {
                                if let addr = i.element.address {
                                    tableRowData.append(RVS_ONVIF_Mac_Test_Harness_GroupedTableData(key: "DHCP-LinkLocal-Address[\(i.offset)]", value: addr.address))
                                }
                                tableRowData.append(RVS_ONVIF_Mac_Test_Harness_GroupedTableData(key: "DHCP-LinkLocal-Prefix[\(i.offset)]", value: String(i.element.prefixLength)))
                            }
                        }
                        
                        if let list = ipv6.configuration.fromDHCP {
                            for i in list.enumerated() {
                                if let addr = i.element.address {
                                    tableRowData.append(RVS_ONVIF_Mac_Test_Harness_GroupedTableData(key: "DHCP-FromDHCP-Address[\(i.offset)]", value: addr.address))
                                }
                                tableRowData.append(RVS_ONVIF_Mac_Test_Harness_GroupedTableData(key: "DHCP-FromDHCP-Prefix[\(i.offset)]", value: String(i.element.prefixLength)))
                            }
                        }
                        
                        if let list = ipv6.configuration.fromRA {
                            for i in list.enumerated() {
                                if let addr = i.element.address {
                                    tableRowData.append(RVS_ONVIF_Mac_Test_Harness_GroupedTableData(key: "DHCP-FromRA-Address[\(i.offset)]", value: addr.address))
                                }
                                tableRowData.append(RVS_ONVIF_Mac_Test_Harness_GroupedTableData(key: "DHCP-FromRA-Prefix[\(i.offset)]", value: String(i.element.prefixLength)))
                            }
                        }
                        
                        if let ext = ipv6.configuration.ipv6ConfigurationExtension {
                            tableRowData.append(RVS_ONVIF_Mac_Test_Harness_GroupedTableData(key: "Extension", value: String(describing: ext)))
                        }
                    }
                    
                    if let sect = i.element.networkInterfaceExtension {
                        tableRowData.append(RVS_ONVIF_Mac_Test_Harness_GroupedTableData(key: "Extension", value: ""))
                        tableRowData.append(RVS_ONVIF_Mac_Test_Harness_GroupedTableData(key: "InterfaceType", value: String(sect.interfaceType.rawValue)))
                        
                        if let ext = sect.dot3Configuration {
                            tableRowData.append(RVS_ONVIF_Mac_Test_Harness_GroupedTableData(key: "Dot3", value: String(describing: ext)))
                        }
                        
                        if let dot11 = sect.dot11 {
                            tableRowData.append(RVS_ONVIF_Mac_Test_Harness_GroupedTableData(key: "Dot11-SSID", value: dot11.ssid))
                            tableRowData.append(RVS_ONVIF_Mac_Test_Harness_GroupedTableData(key: "Dot11-Alias", value: dot11.alias))
                            tableRowData.append(RVS_ONVIF_Mac_Test_Harness_GroupedTableData(key: "Dot11-StationMode", value: dot11.mode.rawValue))
                            tableRowData.append(RVS_ONVIF_Mac_Test_Harness_GroupedTableData(key: "Dot11-SecurityMode", value: dot11.security.mode.rawValue))
                            
                            if let priority = dot11.priority {
                                tableRowData.append(RVS_ONVIF_Mac_Test_Harness_GroupedTableData(key: "Dot11-Priority", value: String(describing: priority)))
                            }
                            
                            if let algorithm = dot11.security.algorithm {
                                tableRowData.append(RVS_ONVIF_Mac_Test_Harness_GroupedTableData(key: "Dot11-Security-Algorithm", value: algorithm.rawValue))
                            }
                            
                            if let pskRec = dot11.security.psk {
                                if let ext = pskRec.dot11PSKSetExtension {
                                    tableRowData.append(RVS_ONVIF_Mac_Test_Harness_GroupedTableData(key: "Dot11-Security-PSK-Key", value: pskRec.key))
                                    tableRowData.append(RVS_ONVIF_Mac_Test_Harness_GroupedTableData(key: "Dot11-Security-PSK-Passphrase", value: pskRec.passphrase))
                                    tableRowData.append(RVS_ONVIF_Mac_Test_Harness_GroupedTableData(key: "Dot11-Security-PSK-Extension", value: String(describing: ext)))
                                }
                            }
                            
                            if let token = dot11.security.dot1XToken {
                                tableRowData.append(RVS_ONVIF_Mac_Test_Harness_GroupedTableData(key: "Dot11-Security-Token", value: token))
                            }
                            
                            if let ext = dot11.security.dot11SecurityConfigurationExtension {
                                tableRowData.append(RVS_ONVIF_Mac_Test_Harness_GroupedTableData(key: "Dot11-Security-Extension", value: String(describing: ext)))
                            }
                        }
                    }
                }
            }
            
            displayTableView?.reloadData()
        }
    }

    /* ################################################################## */
    /**
     */
    func numberOfRows(in inTableView: NSTableView) -> Int {
        return tableRowData.count
    }
    
    /* ################################################################## */
    /**
     */
    func tableView(_ inTableView: NSTableView, isGroupRow inRow: Int) -> Bool {
        return tableRowData[inRow].value.isEmpty
    }
    
    /* ################################################################## */
    /**
     */
    func tableView(_ inTableView: NSTableView, viewFor inTableColumn: NSTableColumn?, row inRow: Int) -> NSView? {
        if let column = inTableColumn, let cell = inTableView.makeView(withIdentifier: column.identifier, owner: nil) as? NSTableCellView {
            cell.textField?.stringValue = "NAME" == inTableColumn?.title ? tableRowData[inRow].key + ":" : tableRowData[inRow].value
            return cell
        } else if nil == inTableColumn {
            let groupHeader = NSTextView()
            groupHeader.isEditable = false
            groupHeader.font = NSFont.boldSystemFont(ofSize: 17)
            if tableRowData[inRow].key.starts(with: "NETWORK INTERFACE ") {
                groupHeader.textColor = NSColor.yellow
            }
            
            groupHeader.alignment = .center
            groupHeader.drawsBackground = false
            groupHeader.string = tableRowData[inRow].key
            return groupHeader
        }
        
        return nil
    }
}
