/**
 © Copyright 2019, The Great Rift Valley Software Company. All rights reserved.
 
 This code is proprietary and confidential code,
 It is NOT to be reused or combined into any application,
 unless done so, specifically under written license from The Great Rift Valley Software Company.
 
 The Great Rift Valley Software Company: https://riftvalleysoftware.com
 */

import UIKit

/* ################################################################################################################################## */
// MARK: - Main Class for the Service Capabilities Screen
/* ################################################################################################################################## */
class RVS_ONVIF_tvOS_Test_Harness_ServiceCapabilities_ViewController: RVS_ONVIF_tvOS_Test_Harness_Base_Cached_TableViewController {
    /* ################################################################## */
    /**
     */
    override func buildCache() {
        if nil != tableView {
            if let allCapabilities = onvifInstance?.core?.serviceCapabilities {
                if let capabilities = allCapabilities.networkCapabilities {
                    let tableCellContainer = UITableViewCell()
                    tableCellContainer.frame = CGRect(x: 0, y: 0, width: tableView.bounds.size.width, height: 0)
                    addLabel(toContainer: tableCellContainer, withText: "Network", offsetBy: 0)
                    addHierarchyTo(tableCellContainer, from: capabilities, withIndent: heightOfOneLabel)
                    cachedCells.append(tableCellContainer)
                }
                if let capabilities = allCapabilities.securityCapabilities {
                    let tableCellContainer = UITableViewCell()
                    tableCellContainer.frame = CGRect(x: 0, y: 0, width: tableView.bounds.size.width, height: 0)
                    addLabel(toContainer: tableCellContainer, withText: "Security", offsetBy: 0)
                    addHierarchyTo(tableCellContainer, from: capabilities, withIndent: heightOfOneLabel)
                    cachedCells.append(tableCellContainer)
                }
                if let capabilities = allCapabilities.systemCapabilities {
                    let tableCellContainer = UITableViewCell()
                    tableCellContainer.frame = CGRect(x: 0, y: 0, width: tableView.bounds.size.width, height: 0)
                    addLabel(toContainer: tableCellContainer, withText: "System", offsetBy: 0)
                    addHierarchyTo(tableCellContainer, from: capabilities, withIndent: heightOfOneLabel)
                    cachedCells.append(tableCellContainer)
                }
                if let capabilities = allCapabilities.auxiliaryCommands {
                    let tableCellContainer = UITableViewCell()
                    tableCellContainer.frame = CGRect(x: 0, y: 0, width: tableView.bounds.size.width, height: 0)
                    addLabel(toContainer: tableCellContainer, withText: "Auxiliary", offsetBy: 0)
                    addHierarchyTo(tableCellContainer, from: capabilities, withIndent: heightOfOneLabel)
                    cachedCells.append(tableCellContainer)
                }
            }
        }
    }
}
