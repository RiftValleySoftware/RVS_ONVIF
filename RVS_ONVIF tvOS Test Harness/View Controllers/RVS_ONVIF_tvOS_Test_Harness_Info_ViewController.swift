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
// MARK: - Class for one cell of table data.
/* ################################################################################################################################## */
class RVS_ONVIF_tvOS_Test_Harness_Info_ViewController_ValueTableCellView: UITableViewCell {
    @IBOutlet var keyLabel: UILabel!
    @IBOutlet var valueLabel: UILabel!
}

/* ################################################################################################################################## */
// MARK: - Main Class for the Info Screen
/* ################################################################################################################################## */
class RVS_ONVIF_tvOS_Test_Harness_Info_ViewController: RVS_ONVIF_tvOS_Test_Harness_Base_TableViewController {
    /* ############################################################################################################################## */
    // MARK: - UITableViewDelegate Methods
    /* ############################################################################################################################## */
    /* ################################################################## */
    /**
     */
    func tableView(_ inTableView: UITableView, heightForRowAt inIndexPath: IndexPath) -> CGFloat {
        if let dictKeys = onvifInstance?.core?.deviceInformation.keys.sorted() {
            let key = dictKeys[inIndexPath.row]
            if let value = onvifInstance?.core?.deviceInformation[key] as? String, !value.isEmpty {
                return inTableView.rowHeight
            }
        }
        
        return 0
    }

    /* ############################################################################################################################## */
    // MARK: - UITableViewDataSource Methods
    /* ############################################################################################################################## */
    /* ################################################################## */
    /**
     */
    override func tableView(_ inTableView: UITableView, numberOfRowsInSection inSection: Int) -> Int {
        return onvifInstance?.core?.deviceInformation.count ?? 0
    }
    
    /* ################################################################## */
    /**
     */
    override func tableView(_ inTableView: UITableView, cellForRowAt inIndexPath: IndexPath) -> UITableViewCell {
        if let dictKeys = onvifInstance?.core?.deviceInformation.keys.sorted() {
            let key = dictKeys[inIndexPath.row]
            if let value = onvifInstance?.core?.deviceInformation[key] as? String {
                if !value.isEmpty, let ret = inTableView.dequeueReusableCell(withIdentifier: "InfoValueCell") as? RVS_ONVIF_tvOS_Test_Harness_Info_ViewController_ValueTableCellView {
                    ret.keyLabel?.text = key + ":"
                    ret.valueLabel?.text = value
                    
                    return ret
                }
            }
        }
        
        return UITableViewCell()
    }
}
