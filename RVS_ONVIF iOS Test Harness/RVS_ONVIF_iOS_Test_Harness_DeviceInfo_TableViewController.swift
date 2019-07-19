/**
 © Copyright 2019, The Great Rift Valley Software Company. All rights reserved.
 
 This code is proprietary and confidential code,
 It is NOT to be reused or combined into any application,
 unless done so, specifically under written license from The Great Rift Valley Software Company.
 
 The Great Rift Valley Software Company: https://riftvalleysoftware.com
 */

import UIKit
import RVS_ONVIF_iOS

/* ################################################################################################################################## */
// MARK: - Main TableView Controller Class for the Device Information Inspector Screen
/* ################################################################################################################################## */
class RVS_ONVIF_iOS_Test_Harness_DeviceInfo_TableViewController: RVS_ONVIF_iOS_Test_Harness_ONVIF_TableViewController {
    /* ############################################################################################################################## */
    // MARK: - Internal Instance Override UITableViewDataSource Methods
    /* ############################################################################################################################## */
    /* ################################################################## */
    /**
     */
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    /* ################################################################## */
    /**
     */
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return onvifInstance?.deviceInformation.count ?? 0
    }

    /* ################################################################## */
    /**
     */
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "basic-cell", for: indexPath)
        if let keys = onvifInstance?.deviceInformation.keys {
            let key = Array(keys)[indexPath.row]
            if let infoItem = onvifInstance?.deviceInformation[key] as? String {
                cell.textLabel?.adjustsFontSizeToFitWidth = true
                cell.textLabel?.text = key + ": " + infoItem
            }
        }
        
        return cell
    }
}
