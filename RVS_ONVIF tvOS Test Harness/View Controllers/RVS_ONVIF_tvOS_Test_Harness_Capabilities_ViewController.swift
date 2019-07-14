/**
 © Copyright 2019, The Great Rift Valley Software Company. All rights reserved.
 
 This code is proprietary and confidential code,
 It is NOT to be reused or combined into any application,
 unless done so, specifically under written license from The Great Rift Valley Software Company.
 
 The Great Rift Valley Software Company: https://riftvalleysoftware.com
 */

import UIKit

/* ################################################################################################################################## */
// MARK: - Main Class for the Capabilities Screen
/* ################################################################################################################################## */
class RVS_ONVIF_tvOS_Test_Harness_Capabilities_ViewController: RVS_ONVIF_tvOS_Test_Harness_Base_Cached_TableViewController {
    /* ################################################################## */
    /**
     */
    override func buildCache() {
        if nil != tableView {
            if let allCapabilities = onvifInstance?.core?.capabilities {
                if let capabilities = allCapabilities.analyticsCapabilities {
                    let tableCellContainer = UITableViewCell()
                    tableCellContainer.frame = CGRect(x: 0, y: 0, width: tableView.bounds.size.width, height: 0)
                    addLabel(toContainer: tableCellContainer, withText: "Analytics", offsetBy: 0)
                    addHierarchyTo(tableCellContainer, from: capabilities, withIndent: heightOfOneLabel)
                    cachedCells.append(tableCellContainer)
                }
                if let capabilities = allCapabilities.analyticsDeviceCapabilities {
                    let tableCellContainer = UITableViewCell()
                    tableCellContainer.frame = CGRect(x: 0, y: 0, width: tableView.bounds.size.width, height: 0)
                    addLabel(toContainer: tableCellContainer, withText: "Analytics Device", offsetBy: 0)
                    addHierarchyTo(tableCellContainer, from: capabilities, withIndent: heightOfOneLabel)
                    cachedCells.append(tableCellContainer)
                }
                if let capabilities = allCapabilities.deviceCapabilities {
                    let tableCellContainer = UITableViewCell()
                    tableCellContainer.frame = CGRect(x: 0, y: 0, width: tableView.bounds.size.width, height: 0)
                    addLabel(toContainer: tableCellContainer, withText: "Device", offsetBy: 0)
                    addHierarchyTo(tableCellContainer, from: capabilities, withIndent: heightOfOneLabel)
                    cachedCells.append(tableCellContainer)
                }
                if let capabilities = allCapabilities.deviceIOCapabilities {
                    let tableCellContainer = UITableViewCell()
                    tableCellContainer.frame = CGRect(x: 0, y: 0, width: tableView.bounds.size.width, height: 0)
                    addLabel(toContainer: tableCellContainer, withText: "Device I/O", offsetBy: 0)
                    addHierarchyTo(tableCellContainer, from: capabilities, withIndent: heightOfOneLabel)
                    cachedCells.append(tableCellContainer)
                }
                if let capabilities = allCapabilities.displayCapabilities {
                    let tableCellContainer = UITableViewCell()
                    tableCellContainer.frame = CGRect(x: 0, y: 0, width: tableView.bounds.size.width, height: 0)
                    addLabel(toContainer: tableCellContainer, withText: "Display", offsetBy: 0)
                    addHierarchyTo(tableCellContainer, from: capabilities, withIndent: heightOfOneLabel)
                    cachedCells.append(tableCellContainer)
                }
                if let capabilities = allCapabilities.eventsCapabilities {
                    let tableCellContainer = UITableViewCell()
                    tableCellContainer.frame = CGRect(x: 0, y: 0, width: tableView.bounds.size.width, height: 0)
                    addLabel(toContainer: tableCellContainer, withText: "Events", offsetBy: 0)
                    addHierarchyTo(tableCellContainer, from: capabilities, withIndent: heightOfOneLabel)
                    cachedCells.append(tableCellContainer)
                }
                if let capabilities = allCapabilities.imagingCapabilities {
                    let tableCellContainer = UITableViewCell()
                    tableCellContainer.frame = CGRect(x: 0, y: 0, width: tableView.bounds.size.width, height: 0)
                    addLabel(toContainer: tableCellContainer, withText: "Imaging", offsetBy: 0)
                    addHierarchyTo(tableCellContainer, from: capabilities, withIndent: heightOfOneLabel)
                    cachedCells.append(tableCellContainer)
                }
                if let capabilities = allCapabilities.mediaCapabilities {
                    let tableCellContainer = UITableViewCell()
                    tableCellContainer.frame = CGRect(x: 0, y: 0, width: tableView.bounds.size.width, height: 0)
                    addLabel(toContainer: tableCellContainer, withText: "Media", offsetBy: 0)
                    addHierarchyTo(tableCellContainer, from: capabilities, withIndent: heightOfOneLabel)
                    cachedCells.append(tableCellContainer)
                }
                if let capabilities = allCapabilities.ptzCapabilities {
                    let tableCellContainer = UITableViewCell()
                    tableCellContainer.frame = CGRect(x: 0, y: 0, width: tableView.bounds.size.width, height: 0)
                    addLabel(toContainer: tableCellContainer, withText: "PTZ", offsetBy: 0)
                    addHierarchyTo(tableCellContainer, from: capabilities, withIndent: heightOfOneLabel)
                    cachedCells.append(tableCellContainer)
                }
                if let capabilities = allCapabilities.receiverCapabilities {
                    let tableCellContainer = UITableViewCell()
                    tableCellContainer.frame = CGRect(x: 0, y: 0, width: tableView.bounds.size.width, height: 0)
                    addLabel(toContainer: tableCellContainer, withText: "Receiver", offsetBy: 0)
                    addHierarchyTo(tableCellContainer, from: capabilities, withIndent: heightOfOneLabel)
                    cachedCells.append(tableCellContainer)
                }
                if let capabilities = allCapabilities.recordingCapabilities {
                    let tableCellContainer = UITableViewCell()
                    tableCellContainer.frame = CGRect(x: 0, y: 0, width: tableView.bounds.size.width, height: 0)
                    addLabel(toContainer: tableCellContainer, withText: "Recording", offsetBy: 0)
                    addHierarchyTo(tableCellContainer, from: capabilities, withIndent: heightOfOneLabel)
                    cachedCells.append(tableCellContainer)
                }
                if let capabilities = allCapabilities.replayCapabilities {
                    let tableCellContainer = UITableViewCell()
                    tableCellContainer.frame = CGRect(x: 0, y: 0, width: tableView.bounds.size.width, height: 0)
                    addLabel(toContainer: tableCellContainer, withText: "Replay", offsetBy: 0)
                    addHierarchyTo(tableCellContainer, from: capabilities, withIndent: heightOfOneLabel)
                    cachedCells.append(tableCellContainer)
                }
                if let capabilities = allCapabilities.searchCapabilities {
                    let tableCellContainer = UITableViewCell()
                    tableCellContainer.frame = CGRect(x: 0, y: 0, width: tableView.bounds.size.width, height: 0)
                    addLabel(toContainer: tableCellContainer, withText: "Search", offsetBy: 0)
                    addHierarchyTo(tableCellContainer, from: capabilities, withIndent: heightOfOneLabel)
                    cachedCells.append(tableCellContainer)
                }
            }
        }
    }
}
