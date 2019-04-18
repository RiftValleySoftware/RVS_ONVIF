/**
 © Copyright 2019, The Great Rift Valley Software Company. All rights reserved.
 
 This code is proprietary and confidential code,
 It is NOT to be reused or combined into any application,
 unless done so, specifically under written license from The Great Rift Valley Software Company.
 
 The Great Rift Valley Software Company: https://riftvalleysoftware.com
 */

import Cocoa
import RVS_ONVIF_MacOS

/* ################################################################################################################################## */
// MARK: - Main Logged-In Capabilities Screen View Controller
/* ################################################################################################################################## */
class RVS_ONVIF_Mac_Test_Harness_Capabilities_ViewController: RVS_ONVIF_Mac_Test_Harness_Base_ViewController, NSTableViewDataSource, NSTableViewDelegate {
    @IBOutlet weak var displayTableView: NSTableView!
    
    var sectionLabels: [String] = []
    
    override var loginViewController: RVS_ONVIF_Mac_Test_Harness_LoginScreen_ViewController! {
        get {
            return super.loginViewController
        }
        
        set {
            super.loginViewController = newValue

            if let capabilities = RVS_ONVIF_Mac_Test_Harness_AppDelegate.appDelegateObject.onvifInstance?.capabilities {
                if nil != capabilities.analyticsCapabilities {
                    sectionLabels.append("Analytics")
                }
                
                if nil != capabilities.analyticsDeviceCapabilities {
                    sectionLabels.append("Analytics Device")
                }
                
                if nil != capabilities.deviceCapabilities {
                    sectionLabels.append("Device")
                }
                
                if nil != capabilities.deviceIOCapabilities {
                    sectionLabels.append("Device I/O")
                }
                
                if nil != capabilities.displayCapabilities {
                    sectionLabels.append("Display")
                }
                
                if nil != capabilities.eventsCapabilities {
                    sectionLabels.append("Events")
                }
                
                if nil != capabilities.imagingCapabilities {
                    sectionLabels.append("Imaging")
                }
                
                if nil != capabilities.mediaCapabilities {
                    sectionLabels.append("Media")
                }
                
                if nil != capabilities.ptzCapabilities {
                    sectionLabels.append("PTZ")
                }
                
                if nil != capabilities.receiverCapabilities {
                    sectionLabels.append("Receiver")
                }
                
                if nil != capabilities.recordingCapabilities {
                    sectionLabels.append("Recording")
                }
                
                if nil != capabilities.replayCapabilities {
                    sectionLabels.append("Replay")
                }
                
                if nil != capabilities.searchCapabilities {
                    sectionLabels.append("Search")
                }
            }
            displayTableView?.reloadData()
        }
    }

    /* ################################################################## */
    /**
     */
    func numberOfRows(in inTableView: NSTableView) -> Int {
        return sectionLabels.count
    }
    
    /* ################################################################## */
    /**
     */
    func tableView(_ tableView: NSTableView, isGroupRow row: Int) -> Bool {
        return true
    }
    
    /* ################################################################## */
    /**
     */
    func tableView(_ inTableView: NSTableView, viewFor inTableColumn: NSTableColumn?, row inRow: Int) -> NSView? {
        let identifier: NSUserInterfaceItemIdentifier = nil != inTableColumn ? inTableColumn?.identifier ?? NSUserInterfaceItemIdentifier(rawValue: sectionLabels[inRow]) : NSUserInterfaceItemIdentifier(rawValue: sectionLabels[inRow])
        if let cell = inTableView.makeView(withIdentifier: identifier, owner: nil) as? NSTableCellView {
            if let column = inTableColumn, let cell = inTableView.makeView(withIdentifier: column.identifier, owner: nil) as? NSTableCellView {
                cell.textField?.stringValue = sectionLabels[inRow]
                return cell
            }
            return cell
        }
        return nil
    }
}
