/**
 © Copyright 2019, The Great Rift Valley Software Company. All rights reserved.
 
 This code is proprietary and confidential code,
 It is NOT to be reused or combined into any application,
 unless done so, specifically under written license from The Great Rift Valley Software Company.
 
 The Great Rift Valley Software Company: https://riftvalleysoftware.com
 */

import UIKit
import RVS_ONVIF_tvOS

/* ################################################################################################################################## */
// MARK: - Main Class for the Namespaces ViewController
/* ################################################################################################################################## */
class RVS_ONVIF_tvOS_Test_Harness_Profiles_ViewController: RVS_ONVIF_tvOS_Test_Harness_Base_Modal_TableViewController {
    /* ############################################################################################################################## */
    // MARK: - Class Calculated Properties
    /* ############################################################################################################################## */
    /* ################################################################## */
    /**
     */
    class var storyboardID: String {
        return "displayResponseProfileListScreen"
    }
    
    /* ############################################################################################################################## */
    // MARK: - Instance Properties
    /* ############################################################################################################################## */
    /* ################################################################## */
    /**
     */
    var profileObjects: [RVS_ONVIF_Profile_S.Profile] = []

    /* ############################################################################################################################## */
    // MARK: - Internal Base Class Override Methods
    /* ############################################################################################################################## */
    /* ################################################################## */
    /**
     */
    override func buildCache() {
        if nil != tableView, 0 < profileObjects.count {
            profileObjects.forEach {
                let tableCellContainer = UITableViewCell()
                tableCellContainer.frame = CGRect(x: 0, y: 0, width: tableView.bounds.size.width, height: 0)
                addLabel(toContainer: tableCellContainer, withText: $0.name, offsetBy: 0)
                cachedCells.append(tableCellContainer)
            }
        }
    }
    
    /* ################################################################## */
    /**
     */
    override func backToHomeBase() {
        dismiss(animated: true, completion: nil)
    }

    /* ############################################################################################################################## */
    // MARK: - UITableViewDelegate Methods
    /* ############################################################################################################################## */
    /* ################################################################## */
    /**
     */
    override func tableView(_ inTableView: UITableView, willSelectRowAt inIndexPath: IndexPath) -> IndexPath? {
        return inIndexPath
    }

    /* ################################################################## */
    /**
     */
    override func tableView(_ inTableView: UITableView, didSelectRowAt inIndexPath: IndexPath) {
        if inIndexPath.row < profileObjects.count {
            if let profileScreen = storyboard?.instantiateViewController(withIdentifier: RVS_ONVIF_tvOS_Test_Harness_DisplayResponse_Profile_ViewController.storyboardID) as? RVS_ONVIF_tvOS_Test_Harness_DisplayResponse_Profile_ViewController {
                profileScreen.profileObject = profileObjects[inIndexPath.row]
                present(profileScreen, animated: true, completion: nil)
            }
        } else {
            super.tableView(inTableView, didSelectRowAt: inIndexPath)
        }
    }
}
