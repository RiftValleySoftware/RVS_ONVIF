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
// MARK: - Main TableView Controller Class for the Profile List Screen
/* ################################################################################################################################## */
class RVS_ONVIF_Test_Harness_Profiles_TableViewController: RVS_ONVIF_Test_Harness_ONVIF_TableViewController {
    /* ############################################################################################################################## */
    // MARK: - Internal Instance Properties
    /* ############################################################################################################################## */
    /* ################################################################## */
    /**
     */
    var profileArray: [RVS_ONVIF_Profile_S.Profile] = []
    
    /* ############################################################################################################################## */
    // MARK: - Internal @IB Instance Properties
    /* ############################################################################################################################## */
    /* ################################################################## */
    /**
     */

    /* ############################################################################################################################## */
    // MARK: - Internal Instance Superclass Override Methods
    /* ############################################################################################################################## */
    /* ################################################################## */
    /**
     */
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.reloadData()
    }
    
    /* ################################################################## */
    /**
     */
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let profile = sender as? RVS_ONVIF_Profile_S.Profile, let destination = segue.destination as? RVS_ONVIF_Test_Harness_Profile_TableViewController {
            destination.onvifInstance = onvifInstance
            destination.profile = profile
        }
        super.prepare(for: segue, sender: sender)
    }

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
        return profileArray.count
    }

    /* ################################################################## */
    /**
     */
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "onvif-profile-overview", for: indexPath)
        
        cell.textLabel?.text = profileArray[indexPath.row].name
        
        return cell
    }

    /* ############################################################################################################################## */
    // MARK: - Internal Instance Override UITableViewDelegate Methods
    /* ############################################################################################################################## */
    /* ################################################################## */
    /**
     */
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let profile = profileArray[indexPath.row]
        #if DEBUG
            print(profile)
        #endif
        
        tableView.deselectRow(at: indexPath, animated: true)
        
        performSegue(withIdentifier: "show-profile-detail", sender: profile)
    }
}
