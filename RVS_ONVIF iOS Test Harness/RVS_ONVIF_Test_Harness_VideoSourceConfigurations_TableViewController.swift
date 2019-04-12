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
// MARK: - Main TableView Controller Class for the Profile Inspector Screen
/* ################################################################################################################################## */
class RVS_ONVIF_Test_Harness_VideoSourceConfigurations_TableViewController: UITableViewController {
    /* ############################################################################################################################## */
    // MARK: - Internal Instance Properties
    /* ############################################################################################################################## */
    /* ################################################################## */
    /**
     */
    var configurationRows: [RVS_ONVIF_Profile_S.VideoSourceConfiguration] = []
    /* ################################################################## */
    /**
     */
    var onvifInstance: RVS_ONVIF!
    
    /* ################################################################## */
    /**
     */
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return configurationRows.count
    }
    
    /* ################################################################## */
    /**
     */
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "video-configuration-cell", for: indexPath)
        
        var numberOfLines = 1
        var text = configurationRows[indexPath.row].name
        
        if !configurationRows[indexPath.row].token.isEmpty && "0" != configurationRows[indexPath.row].token {
            numberOfLines += 1
            text += "\nToken: \(configurationRows[indexPath.row].token)"
        }
        
        if 0 < configurationRows[indexPath.row].useCount {
            numberOfLines += 1
            text += "\nUseCount: \(configurationRows[indexPath.row].useCount)"
        }

        if !configurationRows[indexPath.row].bounds.isEmpty {
            numberOfLines += 5
            text += "\nBounds:\n\tleft: \(configurationRows[indexPath.row].bounds.origin.x)\n\ttop: \(configurationRows[indexPath.row].bounds.origin.y)\n\twidth: \(configurationRows[indexPath.row].bounds.size.width)\n\theight: \(configurationRows[indexPath.row].bounds.size.height)"
        }
        
        cell.textLabel?.numberOfLines = numberOfLines
        cell.textLabel?.text = text
        
        return cell
    }
}
