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

import UIKit

/* ################################################################################################################################## */
// MARK: - Main Class for the Capabilities Screen
/* ################################################################################################################################## */
class RVS_ONVIF_tvOS_Test_Harness_Capabilities_ViewController: RVS_ONVIF_tvOS_Test_Harness_Base_Modal_TableViewController {
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
