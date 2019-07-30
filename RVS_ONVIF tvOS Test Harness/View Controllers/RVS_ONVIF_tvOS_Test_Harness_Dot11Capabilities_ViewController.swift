/**
 © Copyright 2019, The Great Rift Valley Software Company. All rights reserved.
 
 This code is proprietary and confidential code,
 It is NOT to be reused or combined into any application,
 unless done so, specifically under written license from The Great Rift Valley Software Company.
 
 The Great Rift Valley Software Company: https://riftvalleysoftware.com
 */

import UIKit

/* ################################################################################################################################## */
// MARK: - Main Class for the Dot 11 Capabilities Screen
/* ################################################################################################################################## */
class RVS_ONVIF_tvOS_Test_Harness_Dot11Capabilities_ViewController: RVS_ONVIF_tvOS_Test_Harness_Base_Modal_TableViewController {
    /* ################################################################## */
    /**
     */
    override func buildCache() {
        if  let tableView = tableView,
            let capabilities = onvifInstance?.core?.dot11Capabilities {
            var tableCellContainer = UITableViewCell()
            tableCellContainer.frame = CGRect(x: 0, y: 0, width: tableView.bounds.size.width, height: 0)
            addLabel(toContainer: tableCellContainer, withText: "WEP: " + String(describing: capabilities.supportsWEP), offsetBy: 0)
            cachedCells.append(tableCellContainer)
            tableCellContainer = UITableViewCell()
            tableCellContainer.frame = CGRect(x: 0, y: 0, width: tableView.bounds.size.width, height: 0)
            addLabel(toContainer: tableCellContainer, withText: "TKIP: " + String(describing: capabilities.supportsTKIP), offsetBy: 0)
            cachedCells.append(tableCellContainer)
            tableCellContainer = UITableViewCell()
            tableCellContainer.frame = CGRect(x: 0, y: 0, width: tableView.bounds.size.width, height: 0)
            addLabel(toContainer: tableCellContainer, withText: "Scan AvailableNetworks: " + String(describing: capabilities.canScanAvailableNetworks), offsetBy: 0)
            cachedCells.append(tableCellContainer)
            tableCellContainer = UITableViewCell()
            tableCellContainer.frame = CGRect(x: 0, y: 0, width: tableView.bounds.size.width, height: 0)
            addLabel(toContainer: tableCellContainer, withText: "Multiple Configurations: " + String(describing: capabilities.supportsMultipleConfigurations), offsetBy: 0)
            cachedCells.append(tableCellContainer)
            tableCellContainer = UITableViewCell()
            tableCellContainer.frame = CGRect(x: 0, y: 0, width: tableView.bounds.size.width, height: 0)
            addLabel(toContainer: tableCellContainer, withText: "Ad Hoc Station Mode: " + String(describing: capabilities.supportsAdHocStationMode), offsetBy: 0)
            cachedCells.append(tableCellContainer)
        }
    }
}
