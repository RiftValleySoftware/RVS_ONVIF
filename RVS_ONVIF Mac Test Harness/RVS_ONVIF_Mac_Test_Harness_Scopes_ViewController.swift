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
// MARK: - Main Logged-In Scopes Screen View Controller
/* ################################################################################################################################## */
class RVS_ONVIF_Mac_Test_Harness_Scopes_ViewController: RVS_ONVIF_Mac_Test_Harness_Base_ViewController, NSTableViewDataSource, NSTableViewDelegate {
    /* ################################################################## */
    /**
     */
    func numberOfRows(in inTableView: NSTableView) -> Int {
        return RVS_ONVIF_Mac_Test_Harness_AppDelegate.appDelegateObject.onvifInstance?.scopes.count ?? 0
    }
    
    /* ################################################################## */
    /**
     */
    func tableView(_ inTableView: NSTableView, viewFor inTableColumn: NSTableColumn?, row inRow: Int) -> NSView? {
        if let scopes = RVS_ONVIF_Mac_Test_Harness_AppDelegate.appDelegateObject.onvifInstance?.scopes {
            let scope = scopes[inRow]
            var key = "ERROR"
            var value = "ERROR"
            switch scope.category {
            case .Name(let nameVal):
                key = "Name"
                value = nameVal

            case .Hardware(let hardwareVal):
                key = "Hardware"
                value = hardwareVal
                
            case .Location(let locationVal):
                key = "Location"
                value = locationVal
                
            case .Profile(let profileVal):
                key = "Profile"
                value = String(describing: profileVal)

            case .Custom(let customName, let customVal):
                key = "\(customName)"
                value = customVal
            }
                
            if let cell = inTableView.makeView(withIdentifier: inTableColumn?.identifier ?? NSTableColumn().identifier, owner: nil) as? NSTableCellView {
                if let column = inTableColumn, let cell = inTableView.makeView(withIdentifier: column.identifier, owner: nil) as? NSTableCellView {
                    cell.textField?.stringValue = "NAME" == inTableColumn?.title ? key + ":" : value
                    return cell
                }
                return cell
            }
        }
        return nil
    }
}
