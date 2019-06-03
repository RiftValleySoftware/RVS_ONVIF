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
// MARK: - 
/* ################################################################################################################################## */
class RVS_ONVIF_Test_Harness_NetworkInterfaces_TableViewViewController: RVS_ONVIF_Test_Harness_ONVIF_TableViewController {
    let basicCellID = "basic-cell"

    /* ############################################################################################################################## */
    // MARK: - Private Instance Properties
    /* ############################################################################################################################## */
    /* ################################################################## */
    /**
     */
    private var _networkInterfaceDictionaryArray: [[String: Any?]] = []

    /* ################################################################## */
    /**
     */
    internal func setUpArray() {
        _networkInterfaceDictionaryArray = []
        for i in onvifInstance.core.networkInterfaces.enumerated() {
            _networkInterfaceDictionaryArray.append([:])
            setUpInterfaceInfoSection(for: i.element, atIndex: i.offset)
        }
    }

    /* ################################################################## */
    /**
     */
    internal func setUpInterfaceInfoSection(for inInterface: RVS_ONVIF_Core.NetworkInterface?, atIndex inAtIndex: Int) {
        guard let info = inInterface?.info else { return }
        
        var section: [[String: String]] = []
        section.append(["Name": info.name])
        section.append(["HWAddress": info.hwAddress])
        section.append(["MTU": String(info.mtu)])
        _networkInterfaceDictionaryArray[inAtIndex]["Info"] = section
    }
    /* ############################################################################################################################## */
    // MARK: - Internal Instance Superclass Override Methods
    /* ############################################################################################################################## */
    /* ################################################################## */
    /**
     */
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpArray()
        tableView.reloadData()
    }

    /* ############################################################################################################################## */
    // MARK: - Internal Instance Override UITableViewDataSource Methods
    /* ############################################################################################################################## */
    /* ################################################################## */
    /**
     */
    override func numberOfSections(in tableView: UITableView) -> Int {
        return onvifInstance.core.networkInterfaces.count
    }
    
    /* ################################################################## */
    /**
     */
    override func tableView(_ tableView: UITableView, titleForHeaderInSection inSection: Int) -> String? {
        let networkConfig = onvifInstance.core.networkInterfaces[inSection]
        var name = "Default"
        
        if !networkConfig.info.name.isEmpty {
            name = networkConfig.info.name
        } else if !networkConfig.token.isEmpty {
            name = networkConfig.token
        }
        
        return name
    }
    
    /* ################################################################## */
    /**
     */
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 0
    }
    
    /* ################################################################## */
    /**
     */
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: basicCellID, for: indexPath)
        
        return cell
    }
}
