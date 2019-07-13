/**
 © Copyright 2019, The Great Rift Valley Software Company. All rights reserved.
 
 This code is proprietary and confidential code,
 It is NOT to be reused or combined into any application,
 unless done so, specifically under written license from The Great Rift Valley Software Company.
 
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
