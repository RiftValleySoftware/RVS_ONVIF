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
// MARK: - Main Logged-In Info Screen View Controller
/* ################################################################################################################################## */
class RVS_ONVIF_Mac_Test_Harness_Info_ViewController: RVS_ONVIF_Mac_Test_Harness_Base_ViewController, NSTableViewDataSource, NSTableViewDelegate {    
    /* ################################################################## */
    /**
     */
    func numberOfRows(in inTableView: NSTableView) -> Int {
        return RVS_ONVIF_Mac_Test_Harness_AppDelegate.appDelegateObject.onvifInstance?.deviceInformation.count ?? 0
    }
    
    /* ################################################################## */
    /**
     */
    func tableView(_ inTableView: NSTableView, viewFor inTableColumn: NSTableColumn?, row inRow: Int) -> NSView? {
        if let keys = RVS_ONVIF_Mac_Test_Harness_AppDelegate.appDelegateObject.onvifInstance?.deviceInformation.keys {
            let key = Array(keys).sorted()[inRow]
            if let value = RVS_ONVIF_Mac_Test_Harness_AppDelegate.appDelegateObject.onvifInstance?.deviceInformation[key] as? String {
                if let column = inTableColumn, let cell = inTableView.makeView(withIdentifier: column.identifier, owner: nil) as? NSTableCellView {
                    cell.textField?.stringValue = "NAME" == inTableColumn?.title ? key + ":" : value
                    return cell
                }
            }
        }
        return nil
    }
}
