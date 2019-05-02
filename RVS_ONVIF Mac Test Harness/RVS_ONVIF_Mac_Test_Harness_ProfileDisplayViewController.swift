/**
 © Copyright 2019, The Great Rift Valley Software Company. All rights reserved.
 
 This code is proprietary and confidential code,
 It is NOT to be reused or combined into any application,
 unless done so, specifically under written license from The Great Rift Valley Software Company.
 
 The Great Rift Valley Software Company: https://riftvalleysoftware.com
 */

import Cocoa
import RVS_ONVIF_MacOS

class RVS_ONVIF_Mac_Test_Harness_ProfileDisplayViewController: NSViewController, NSTableViewDelegate, NSTableViewDataSource {
    /* ################################################################## */
    /**
     */
    typealias RVS_ONVIF_Mac_Test_Harness_Profile_S_GroupedTableData = (key: String, value: String, associatedProfile: RVS_ONVIF_Profile_S.Profile?)
    
    /* ################################################################## */
    /**
     */
    var tableRowData: [RVS_ONVIF_Mac_Test_Harness_Profile_S_GroupedTableData] = []
    
    /* ################################################################## */
    /**
     */
    var profiles: [RVS_ONVIF_Profile_S.Profile] = [] {
        didSet {
            profiles.forEach {
                tableRowData.append(RVS_ONVIF_Mac_Test_Harness_Profile_S_GroupedTableData(key: $0.name, value: "", associatedProfile: nil))
            }
        }
    }

    /* ################################################################## */
    /**
     */
    @IBOutlet weak var profileTable: NSTableView!
    
    /* ################################################################## */
    /**
     */
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
    }
    
    /* ############################################################################################################################## */
    // MARK: - NSTableViewDelegate/DataSource Methods -
    /* ############################################################################################################################## */
    /* ################################################################## */
    /**
     */
    func numberOfRows(in inTableView: NSTableView) -> Int {
        return tableRowData.count
    }
    
    /* ################################################################## */
    /**
     */
    func tableView(_ inTableView: NSTableView, isGroupRow inRow: Int) -> Bool {
        return !tableRowData[inRow].key.starts(with: " ")
    }
    
    /* ################################################################## */
    /**
     */
    func tableView(_ inTableView: NSTableView, viewFor inTableColumn: NSTableColumn?, row inRow: Int) -> NSView? {
        let cell = NSTextView()
        cell.isEditable = false
        cell.drawsBackground = false
        cell.string = tableRowData[inRow].key
        if tableView(inTableView, isGroupRow: inRow) {
            cell.font = NSFont.boldSystemFont(ofSize: 20)
            cell.alignment = .center
        }
        
        return cell
    }
}
