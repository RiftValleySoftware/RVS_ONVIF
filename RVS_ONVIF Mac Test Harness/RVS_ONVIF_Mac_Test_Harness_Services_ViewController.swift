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
                            capabilities.forEach {
                                if let value = $0.value as? String {
                                    tableRowData.append(RVS_ONVIF_Mac_Test_Harness_GroupedTableData(key: $0.key, value: value))
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
