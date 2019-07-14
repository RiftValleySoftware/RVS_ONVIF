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
// MARK: - Main Base Class for Test Harness View Controllers
/* ################################################################################################################################## */
class RVS_ONVIF_tvOS_Test_Harness_Base_ViewController: UIViewController, RVS_ONVIF_tvOS_Test_Harness_ViewProtocol {    
    /* ############################################################################################################################## */
    // MARK: - Internal Calculated Properties
    /* ############################################################################################################################## */
    /* ################################################################## */
    /**
     */
    var persistentPrefs: RVS_PersistentPrefs! {
        get {
            if let tabBarController = tabBarController as? RVS_ONVIF_tvOS_Test_Harness_UITabBarController {
                return tabBarController.persistentPrefs
            }
            
            return nil
        }
        
        set {
            if let tabBarController = tabBarController as? RVS_ONVIF_tvOS_Test_Harness_UITabBarController {
                tabBarController.persistentPrefs = newValue
            }
        }
    }
    
    /* ################################################################## */
    /**
     */
    var onvifInstance: RVS_ONVIF! {
        get {
            if let tabBarController = tabBarController as? RVS_ONVIF_tvOS_Test_Harness_UITabBarController {
                return tabBarController.onvifInstance
            }
            
            return nil
        }
        
        set {
            if let tabBarController = tabBarController as? RVS_ONVIF_tvOS_Test_Harness_UITabBarController {
                tabBarController.onvifInstance = newValue
            }
        }
    }
    
    /* ################################################################## */
    /**
     */
    var isConnected: Bool {
        get {
            if let tabBarController = tabBarController as? RVS_ONVIF_tvOS_Test_Harness_UITabBarController {
                return tabBarController.isConnected
            }
            return false
        }
        
        set {
            if let tabBarController = tabBarController as? RVS_ONVIF_tvOS_Test_Harness_UITabBarController {
                return tabBarController.isConnected = newValue
            }
        }
    }
    
    /* ############################################################################################################################## */
    // MARK: - Internal Base Class Override Methods
    /* ############################################################################################################################## */
    /* ################################################################## */
    /**
     */
    override func viewDidLoad() {
        super.viewDidLoad()
        updateUI()
    }

    /* ############################################################################################################################## */
    // MARK: - Internal Instance Properties
    /* ############################################################################################################################## */
    /* ################################################################## */
    /**
     */
    func updateUI() {}
}

/* ################################################################################################################################## */
// MARK: - Main Base Class for Test Harness View Controllers that Have a Table
/* ################################################################################################################################## */
class RVS_ONVIF_tvOS_Test_Harness_Base_TableViewController: RVS_ONVIF_tvOS_Test_Harness_Base_ViewController, UITableViewDataSource, UITableViewDelegate {
    /* ############################################################################################################################## */
    // MARK: - IBOutlet Properties
    /* ############################################################################################################################## */
    @IBOutlet var tableView: UITableView!

    /* ############################################################################################################################## */
    // MARK: - Base Class Override Methods
    /* ############################################################################################################################## */
    /* ################################################################## */
    /**
     */
    override func updateUI() {
        tableView?.reloadData()
    }
    
    /* ############################################################################################################################## */
    // MARK: - UITableViewDataSource Methods
    /* ############################################################################################################################## */
    /* ################################################################## */
    /**
     */
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 0
    }
    
    /* ################################################################## */
    /**
     */
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return UITableViewCell()
    }
}
