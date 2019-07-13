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
class RVS_ONVIF_tvOS_Test_Harness_Scopes_ViewController_ValueTableCellView: UITableViewCell {
    @IBOutlet var rowLabel: UILabel!
    @IBOutlet var valueLabel: UILabel!
}

/* ################################################################################################################################## */
// MARK: - Main Class for the Info Screen
/* ################################################################################################################################## */
class RVS_ONVIF_tvOS_Test_Harness_Scopes_ViewController: RVS_ONVIF_tvOS_Test_Harness_Base_ViewController, UITableViewDelegate, UITableViewDataSource {
    /* ############################################################################################################################## */
    // MARK: - Internal Instance Properties
    /* ############################################################################################################################## */
    /* ################################################################## */
    /**
     */
    
    /* ############################################################################################################################## */
    // MARK: - Internal Base Class Override Methods
    /* ############################################################################################################################## */
    /* ################################################################## */
    /**
     */
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    /* ############################################################################################################################## */
    // MARK: - UITableViewDataSource Methods
    /* ############################################################################################################################## */
    /* ################################################################## */
    /**
     */
    func tableView(_ inTableView: UITableView, numberOfRowsInSection inSection: Int) -> Int {
        return onvifInstance?.core?.scopes.count ?? 0
    }
    
    /* ################################################################## */
    /**
     */
    func tableView(_ inTableView: UITableView, heightForRowAt inIndexPath: IndexPath) -> CGFloat {
        if let scope = onvifInstance?.core?.scopes[inIndexPath.row] {
            var labelString = ""
            var valueString = ""
            switch scope.category {
            case .Name(let nameVal):
                labelString = "Name"
                valueString = nameVal
                
            case .Hardware(let hardwareVal):
                labelString = "Hardware"
                valueString = hardwareVal
                
            case .Location(let locationVal):
                labelString = "Location"
                valueString = locationVal
                
            case .Profile(let profileVal):
                labelString = "Profile"
                valueString = String(describing: profileVal)
                
            case .Custom(let customName, let customVal):
                labelString = "\(customName)"
                valueString = customVal
            }
            
            if !labelString.isEmpty, !valueString.isEmpty {
                return inTableView.rowHeight
            }
        }

        return 0
    }

    /* ################################################################## */
    /**
     */
    func tableView(_ inTableView: UITableView, cellForRowAt inIndexPath: IndexPath) -> UITableViewCell {
        if let scope = onvifInstance?.core?.scopes[inIndexPath.row] {
            var labelString = "ERROR"
            var valueString = "ERROR"
            switch scope.category {
            case .Name(let nameVal):
                labelString = "Name"
                valueString = nameVal
                
            case .Hardware(let hardwareVal):
                labelString = "Hardware"
                valueString = hardwareVal
                
            case .Location(let locationVal):
                labelString = "Location"
                valueString = locationVal
                
            case .Profile(let profileVal):
                labelString = "Profile"
                valueString = String(describing: profileVal)
                
            case .Custom(let customName, let customVal):
                labelString = "\(customName)"
                valueString = customVal
            }

            if !valueString.isEmpty, let ret = inTableView.dequeueReusableCell(withIdentifier: "InfoValueCell") as? RVS_ONVIF_tvOS_Test_Harness_Scopes_ViewController_ValueTableCellView {
                ret.rowLabel?.text = labelString + ":"
                ret.valueLabel?.text = valueString

                return ret
            }
        }
        
        return UITableViewCell()
    }
}
