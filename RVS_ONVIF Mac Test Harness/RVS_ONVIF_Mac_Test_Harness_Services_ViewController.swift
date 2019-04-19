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
// MARK: - Main Logged-In Capabilities Screen View Controller
/* ################################################################################################################################## */
class RVS_ONVIF_Mac_Test_Harness_Services_ViewController: RVS_ONVIF_Mac_Test_Harness_Base_ViewController, NSTableViewDataSource, NSTableViewDelegate {
    @IBOutlet weak var displayTableView: NSTableView!
    
    typealias RVS_ONVIF_Mac_Test_Harness_GroupedTableData = (key: String, value: String)
    
    var tableRowData: [RVS_ONVIF_Mac_Test_Harness_GroupedTableData] = []
    
    override var loginViewController: RVS_ONVIF_Mac_Test_Harness_LoginScreen_ViewController! {
        get {
            return super.loginViewController
        }
        
        set {
            super.loginViewController = newValue
            
            if let services = RVS_ONVIF_Mac_Test_Harness_AppDelegate.appDelegateObject.onvifInstance?.services {
                services.forEach {
                    if let namespace = $0.value.namespace {
                        tableRowData.append(RVS_ONVIF_Mac_Test_Harness_GroupedTableData(key: namespace, value: ""))
                        if let version = $0.value.version {
                            tableRowData.append(RVS_ONVIF_Mac_Test_Harness_GroupedTableData(key: "Version", value: String(version)))
                        }
                        if let xAddr = $0.value.xAddr {
                            tableRowData.append(RVS_ONVIF_Mac_Test_Harness_GroupedTableData(key: "Local Path", value: String(xAddr.relativePath)))
                        }
                        if let capabilities = $0.value.capabilities {
                            if nil != capabilities.networkCapabilities {
                                tableRowData.append(RVS_ONVIF_Mac_Test_Harness_GroupedTableData(key: "Network Capabilities", value: "√"))
                            }
                            if nil != capabilities.securityCapabilities {
                                tableRowData.append(RVS_ONVIF_Mac_Test_Harness_GroupedTableData(key: "Security Capabilities", value: "√"))
                            }
                            if nil != capabilities.systemCapabilities {
                                tableRowData.append(RVS_ONVIF_Mac_Test_Harness_GroupedTableData(key: "System Capabilities", value: "√"))
                           }
                            if let auxiliaryCommands = capabilities.auxiliaryCommands {
                                auxiliaryCommands.forEach {
                                    tableRowData.append(RVS_ONVIF_Mac_Test_Harness_GroupedTableData(key: "Auxiliary Command", value: String($0)))
                                }
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
            groupHeader.font = NSFont.boldSystemFont(ofSize: 20)
            groupHeader.alignment = .center
            groupHeader.drawsBackground = false
            groupHeader.string = tableRowData[inRow].key
            return groupHeader
        }
        
        return nil
    }
}
