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
