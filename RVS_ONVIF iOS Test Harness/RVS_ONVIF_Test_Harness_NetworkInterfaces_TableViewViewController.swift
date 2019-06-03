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
// MARK: - 
/* ################################################################################################################################## */
class RVS_ONVIF_Test_Harness_NetworkInterfaces_TableViewViewController: RVS_ONVIF_Test_Harness_ONVIF_TableViewController {
    let basicCellID = "basic-cell"
    
    /* ############################################################################################################################## */
    // MARK: - Internal Instance Override UITableViewDataSource Methods
    /* ############################################################################################################################## */
    /* ################################################################## */
    /**
     */
    override func numberOfSections(in tableView: UITableView) -> Int {
        return onvifInstance.core.networkInterfaces.count
    }
    
    /* ################################################################## */
    /**
     */
    override func tableView(_ tableView: UITableView, titleForHeaderInSection inSection: Int) -> String? {
        let networkConfig = onvifInstance.core.networkInterfaces[inSection]
        var name = "Default"
        
        if !networkConfig.info.name.isEmpty {
            name = networkConfig.info.name
        } else if !networkConfig.token.isEmpty {
            name = networkConfig.token
        }
        
        return name
    }
    
    /* ################################################################## */
    /**
     */
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 0
    }
}
