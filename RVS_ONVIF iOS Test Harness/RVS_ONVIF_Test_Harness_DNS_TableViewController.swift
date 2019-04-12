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
// MARK: - Main TableView Controller Class for the DNS Inspector Screen
/* ################################################################################################################################## */
class RVS_ONVIF_Test_Harness_DNS_TableViewController: RVS_ONVIF_Test_Harness_ONVIF_TableViewController {
    /* ################################################################## */
    /**
     */
    var dnsEntry: RVS_ONVIF_Core.DNSRecord!
    
    /* ############################################################################################################################## */
    // MARK: - Internal Instance Override UITableViewDataSource Methods
    /* ############################################################################################################################## */
    /* ################################################################## */
    /**
     */
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }
    
    /* ################################################################## */
    /**
     */
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 2:
            return dnsEntry.addresses.count
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
            ret = "Search Domain"
        case 2:
            ret = "DNS Server Addresses"
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
            cell.textLabel?.text = dnsEntry.isFromDHCP ? "YES" : "NO"
        case 1:
            cell.textLabel?.text = dnsEntry.searchDomain.joined(separator: ",")
        case 2:
            if var addressStr = dnsEntry.addresses[indexPath.row] as? RVS_IPAddressV6 {
                addressStr.isPadded = false
                cell.textLabel?.text = addressStr.address.lowercased()
            } else {
                cell.textLabel?.text = dnsEntry.addresses[indexPath.row].address
            }
            
        default:
            break
        }

        return cell
    }
}
