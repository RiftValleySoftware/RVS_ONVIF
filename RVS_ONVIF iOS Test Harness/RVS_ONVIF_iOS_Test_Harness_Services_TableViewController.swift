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
// MARK: - Special Button Class With Associated ONVIF Service
/* ################################################################################################################################## */
class RVS_ONVIF_iOS_Test_Harness_Services_ServiceCapabilitiesButton: UIButton {
    var service: RVS_ONVIF_Core.Service!
}

/* ################################################################################################################################## */
// MARK: - Special Table Cell View Class with Associated Capabilities
/* ################################################################################################################################## */
class RVS_ONVIF_iOS_Test_Harness_Services_ServiceWithCapabilityTableViewCell: UITableViewCell {
    @IBOutlet var capabilitiesButton: RVS_ONVIF_iOS_Test_Harness_Services_ServiceCapabilitiesButton!
}

/* ################################################################################################################################## */
// MARK: - Main TableView Controller Class for the Profile List Screen
/* ################################################################################################################################## */
class RVS_ONVIF_iOS_Test_Harness_Services_TableViewController: RVS_ONVIF_iOS_Test_Harness_ONVIF_TableViewController {
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
        return onvifInstance?.services.count ?? 0
    }

    /* ################################################################## */
    /**
     */
    override func tableView(_ tableView: UITableView, cellForRowAt inIndexPath: IndexPath) -> UITableViewCell {
        if let keys = onvifInstance?.services.keys {
            let keysArray = Array(keys)
            let row = inIndexPath.row
            let key = keysArray[row]
            if let service = onvifInstance?.services[key] {
                let cell = tableView.dequeueReusableCell(withIdentifier: "basic-cell", for: inIndexPath)
                if let namespace = service.namespace {
                    var text = "Namespace: \(namespace)"
                    var numberOfLines = 1
                    
                    if let version = service.version {
                        numberOfLines += 1
                        text += "\nVersion: \(version)"
                    }
                    
                    if let xAddr = service.xAddr {
                        numberOfLines += 1
                        text += "\nLocal Path: \(xAddr.path)"
                    }
                    
                    if let capabilities = service.capabilities, 0 < capabilities.count {
                        for (key, value) in capabilities {
                            if let value = value as? String {
                                numberOfLines += 1
                                text += "\n\t\(key): \(value)"
                            }
                        }
                    }
                    
                    cell.textLabel?.adjustsFontSizeToFitWidth = true
                    cell.textLabel?.numberOfLines = numberOfLines
                    cell.textLabel?.text = text
                }
                
                return cell
            }
        }
        
        return UITableViewCell()
    }
}
