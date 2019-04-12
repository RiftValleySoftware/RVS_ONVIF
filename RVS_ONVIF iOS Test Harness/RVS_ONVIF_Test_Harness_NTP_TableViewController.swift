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
// MARK: - Main TableView Controller Class for the NTP Inspector Screen
/* ################################################################################################################################## */
class RVS_ONVIF_Test_Harness_NTP_TableViewController: RVS_ONVIF_Test_Harness_ONVIF_TableViewController {
    /* ################################################################## */
    /**
     */
    var ntpEntry: RVS_ONVIF_Core.NTPRecord!
    
    /* ############################################################################################################################## */
    // MARK: - Internal Instance Override UITableViewDataSource Methods
    /* ############################################################################################################################## */
    /* ################################################################## */
    /**
     */
    override func numberOfSections(in tableView: UITableView) -> Int {
        return ntpEntry.names.isEmpty ? (ntpEntry.addresses.isEmpty ? 1 : 2) : (ntpEntry.addresses.isEmpty ? 2 : 3)
    }
    
    /* ################################################################## */
    /**
     */
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 1:
            return ntpEntry.addresses.isEmpty ? ntpEntry.names.count : ntpEntry.addresses.count
        case 2:
            return ntpEntry.names.count
        default:
            return 1
        }
    }
    
    /* ################################################################## */
    /**
     */
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        var ret: String = ""
        
        switch section {
        case 0:
            ret = "From DHCP"
        case 1:
            if ntpEntry.addresses.isEmpty {
                fallthrough
            }
            ret = "NTP Server Addresses"
        case 2:
            ret = "NTP Server DNS Names"
        default:
            break
        }
        return ret
    }

    /* ################################################################## */
    /**
     */
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "basic-cell", for: indexPath)
        
        switch indexPath.section {
        case 0:
            cell.textLabel?.text = ntpEntry.isFromDHCP ? "YES" : "NO"
        case 1:
            if ntpEntry.addresses.isEmpty {
                fallthrough
            }
            if var addressStr = ntpEntry.addresses[indexPath.row] as? RVS_IPAddressV6 {
                addressStr.isPadded = false
                cell.textLabel?.text = addressStr.address
            } else {
                cell.textLabel?.text = ntpEntry.addresses[indexPath.row].address
            }
        case 2:
            cell.textLabel?.text = ntpEntry.names[indexPath.row]
            
        default:
            break
        }

        return cell
    }
}
