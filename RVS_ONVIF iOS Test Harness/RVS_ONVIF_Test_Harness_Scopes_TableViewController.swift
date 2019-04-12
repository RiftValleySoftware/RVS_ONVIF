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
// MARK: - Main TableView Controller Class for the Scopes Inspector Screen
/* ################################################################################################################################## */
class RVS_ONVIF_Test_Harness_Scopes_TableViewController: RVS_ONVIF_Test_Harness_ONVIF_TableViewController {
    /* ############################################################################################################################## */
    // MARK: - Internal Instance Properties
    /* ############################################################################################################################## */
    /* ################################################################## */
    /**
     */
    let scope_id = "scope-cell"

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
        return onvifInstance?.scopes?.count ?? 0
    }
    
    /* ################################################################## */
    /**
     */
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return super.tableView(tableView, heightForRowAt: indexPath)
    }
    
    /* ################################################################## */
    /**
     */
    override func tableView(_ tableView: UITableView, cellForRowAt inIndexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: scope_id, for: inIndexPath)
        let scopeIndex = inIndexPath.row
        if let scope = onvifInstance?.scopes[scopeIndex] {
            var title = "ERROR"
            switch scope.category {
            case .Name(let nameVal):
                title = "Name: \(nameVal)"
                
            case .Hardware(let hardwareVal):
                title = "Hardware: \(hardwareVal)"
                
            case .Location(let locationVal):
                title = "Location: \(locationVal)"
                
            case .Profile(let profileVal):
                title = "Profile: \(profileVal)"
            
            case .Custom(let customName, let customVal):
                title = "\(customName): \(customVal)"
            }
            
            cell.textLabel?.text = title
        }
        return cell
    }
}
