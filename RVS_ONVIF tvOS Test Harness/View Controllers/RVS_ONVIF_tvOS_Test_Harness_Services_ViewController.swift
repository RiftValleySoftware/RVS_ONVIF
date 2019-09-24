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
// MARK: - Main Class for the Services Screen
/* ################################################################################################################################## */
class RVS_ONVIF_tvOS_Test_Harness_Services_ViewController: RVS_ONVIF_tvOS_Test_Harness_Base_Modal_TableViewController {
    /* ################################################################## */
    /**
     */
    override func buildCache() {
        if let tableView = tableView {
            onvifInstance?.core?.services.forEach {
                let tableCellContainer = UITableViewCell()
                tableCellContainer.frame = CGRect(x: 0, y: 0, width: tableView.bounds.size.width, height: 0)
                addLabel(toContainer: tableCellContainer, withText: $0.value.namespace, offsetBy: 0)
                addLabel(toContainer: tableCellContainer, withText: "Path: \($0.value.xAddr.path)")
                if let version = $0.value.version {
                    addLabel(toContainer: tableCellContainer, withText: "Version: \(version)")
                }
                // Yeah, this is a pathetic lash-up, but this is a simple test harness. No need to get more efficient.
                if let capabilities = $0.value.capabilities, !capabilities.isEmpty {
                    for capability in capabilities {
                        if let value = capability.value as? String {
                            addLabel(toContainer: tableCellContainer, withText: "\(capability.key): \(value)")
                        } else if let values = capability.value as? [String: Any] {
                            addLabel(toContainer: tableCellContainer, withText: "\(capability.key):")
                            for singleInstance in values {
                                if let value = singleInstance.value as? String {
                                    addLabel(toContainer: tableCellContainer, withText: "\(singleInstance.key): \(value)", offsetBy: 80)
                                    // We only go in one level. This all could be done much more slickly.
                                } else if let valuesDeeper = singleInstance.value as? [String: Any] {
                                    for valueDeep in valuesDeeper {
                                        addLabel(toContainer: tableCellContainer, withText: "\(valueDeep.key): \(String(describing: valueDeep.value))", offsetBy: 80)
                                    }
                                } else {
                                    addLabel(toContainer: tableCellContainer, withText: "\(singleInstance.key): \(String(describing: singleInstance.value))", offsetBy: 80)
                                }
                            }
                        } else {
                            addLabel(toContainer: tableCellContainer, withText: "\(capability.key): \(String(describing: capability.value))")
                        }
                    }
                }
                cachedCells.append(tableCellContainer)
            }
        }
    }
}
