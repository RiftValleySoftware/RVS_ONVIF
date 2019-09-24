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
