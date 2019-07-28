/**
 © Copyright 2019, The Great Rift Valley Software Company. All rights reserved.
 
 This code is proprietary and confidential code,
 It is NOT to be reused or combined into any application,
 unless done so, specifically under written license from The Great Rift Valley Software Company.
 
 The Great Rift Valley Software Company: https://riftvalleysoftware.com
 */

import UIKit

/* ################################################################################################################################## */
// MARK: - Main Class for the Services Screen
/* ################################################################################################################################## */
class RVS_ONVIF_tvOS_Test_Harness_Protocols_ViewController: RVS_ONVIF_tvOS_Test_Harness_Base_Modal_TableViewController {
    /* ################################################################## */
    /**
     */
    override func buildCache() {
        if let tableView = tableView {
            onvifInstance?.core?.networkProtocols.forEach {
                let tableCellContainer = UITableViewCell()
                tableCellContainer.frame = CGRect(x: 0, y: 0, width: tableView.bounds.size.width, height: 0)
                addLabel(toContainer: tableCellContainer, withText: String(describing: $0), offsetBy: 0)
                cachedCells.append(tableCellContainer)
            }
        }
    }
}
