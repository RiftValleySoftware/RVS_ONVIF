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
// MARK: - Main View Controller Class
/* ################################################################################################################################## */
class RVS_ONVIF_tvOS_Test_Harness_DisplayResponse_Profile_ViewController: RVS_ONVIF_tvOS_Test_Harness_DisplayResponse_ViewController {
    /* ############################################################################################################################## */
    // MARK: - Class Calculated Properties
    /* ############################################################################################################################## */
    /* ################################################################## */
    /**
     */
    override class var storyboardID: String {
      return "displayResponseProfileScreen"
    }
    
    /* ############################################################################################################################## */
    // MARK: - Instance Properties
    /* ############################################################################################################################## */
    /* ################################################################## */
    /**
     */
    var profileObject: RVS_ONVIF_Profile_S!
    
    /* ############################################################################################################################## */
    // MARK: - Instance IB Properties
    /* ############################################################################################################################## */
    /* ################################################################## */
    /**
     */
    @IBOutlet weak var tcpStreamButton: UIButton!
    
    /* ################################################################## */
    /**
     */
    @IBOutlet weak var udpStreamButton: UIButton!
    
    /* ############################################################################################################################## */
    // MARK: - Instance IB Actions
    /* ############################################################################################################################## */
    /* ################################################################## */
    /**
     */
    @IBAction func streamButtonHit(_ inButton: UIButton) {
        
    }
    
    /* ############################################################################################################################## */
    // MARK: - Base Class Override Methods
    /* ############################################################################################################################## */
    /* ################################################################## */
    /**
     */
    override func viewDidLoad() {
        super.viewDidLoad()
    }
}
