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
class RVS_ONVIF_Mac_Test_Harness_Handlers_ViewController: RVS_ONVIF_Mac_Test_Harness_Base_ViewController, NSTableViewDataSource, NSTableViewDelegate {
    @IBOutlet weak var displayTableView: NSTableView!
    
    typealias RVS_ONVIF_Mac_Test_Harness_GroupedTableData = (key: String, value: String)
    
    var tableRowData: [RVS_ONVIF_Mac_Test_Harness_GroupedTableData] = []
    
    override var loginViewController: RVS_ONVIF_Mac_Test_Harness_LoginScreen_ViewController! {
        get {
            return super.loginViewController
        }
        
        set {
            super.loginViewController = newValue
            
            if let profileHandlers = RVS_ONVIF_Mac_Test_Harness_AppDelegate.appDelegateObject.onvifInstance?.profilesAsArray {
                profileHandlers.forEach {
                    tableRowData.append(RVS_ONVIF_Mac_Test_Harness_GroupedTableData(key: $0.profileName, value: ""))
                    let nameSpaces = type(of: $0).namespaces
                    let supportedNamespaces = $0.supportedNamespaces
                    
                    for var namespace in nameSpaces {
                        if supportedNamespaces.contains(namespace) {
                            namespace = " √ " + namespace
                        } else {
                            namespace = " X " + namespace
                        }
                        tableRowData.append(RVS_ONVIF_Mac_Test_Harness_GroupedTableData(key: namespace, value: ""))
                    }
                    
                    let commands = $0.availableCommandsAsStrings
                    commands.forEach {
                        tableRowData.append(RVS_ONVIF_Mac_Test_Harness_GroupedTableData(key: "", value: "        " + $0))
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
        return !tableRowData[inRow].key.starts(with: " ")
    }
    
    /* ################################################################## */
    /**
     */
    func tableView(_ inTableView: NSTableView, viewFor inTableColumn: NSTableColumn?, row inRow: Int) -> NSView? {
        let cell = NSTextView()
        cell.isEditable = false
        cell.drawsBackground = false
        cell.string = tableRowData[inRow].key
        if tableRowData[inRow].key.starts(with: " ") {
            cell.textColor = tableRowData[inRow].key.starts(with: " √") ? NSColor.green : NSColor.red
            cell.font = NSFont.monospacedDigitSystemFont(ofSize: 17, weight: .light)
        } else if tableRowData[inRow].key.isEmpty {
            cell.font = NSFont.boldSystemFont(ofSize: 17)
            cell.textColor = view.isDarkMode ? NSColor.lightGray : NSColor.darkGray
            cell.string = tableRowData[inRow].value
        } else if tableView(inTableView, isGroupRow: inRow) {
            cell.font = NSFont.boldSystemFont(ofSize: 20)
            cell.alignment = .center
        }
        
        return cell
    }
}
