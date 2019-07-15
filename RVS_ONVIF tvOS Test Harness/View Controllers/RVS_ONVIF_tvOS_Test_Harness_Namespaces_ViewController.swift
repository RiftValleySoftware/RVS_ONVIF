/**
 © Copyright 2019, The Great Rift Valley Software Company. All rights reserved.
 
 This code is proprietary and confidential code,
 It is NOT to be reused or combined into any application,
 unless done so, specifically under written license from The Great Rift Valley Software Company.
 
 The Great Rift Valley Software Company: https://riftvalleysoftware.com
 */

import UIKit

typealias RVS_ONVIF_tvOS_Test_Harness_Namespaces_ViewController_CacheElement = (label: String, values: [UITableViewCell])
/* ################################################################################################################################## */
// MARK: - Main Class for the Namespaces NavigationController
/* ################################################################################################################################## */
class RVS_ONVIF_tvOS_Test_Harness_Namespaces_ViewController: RVS_ONVIF_tvOS_Test_Harness_Base_Modal_TableViewController {
    var sectionCache: [RVS_ONVIF_tvOS_Test_Harness_Namespaces_ViewController_CacheElement] = []
    
    /* ############################################################################################################################## */
    // MARK: - Internal Base Class Override Methods
    /* ############################################################################################################################## */
    /* ################################################################## */
    /**
     */
    override func buildCache() {
        if nil != tableView {
            onvifInstance?.profilesAsArray.forEach {
                let sectionLabel = $0.profileName
                let sectionCommands = $0.availableCommandsAsStrings
                var cells: [UITableViewCell] = []
                sectionCommands.forEach { commandString in
                    let cell = UITableViewCell()
                    addLabel(toContainer: cell, withText: commandString)
                    cells.append(cell)
                }
                let section = RVS_ONVIF_tvOS_Test_Harness_Namespaces_ViewController_CacheElement(label: sectionLabel, values: cells)
                sectionCache.append(section)
            }
        }
    }
    
    /* ################################################################## */
    /**
     */
    func numberOfSections(in inTableView: UITableView) -> Int {
        return sectionCache.count
    }

    /* ################################################################## */
    /**
     */
    func tableView(_ inTableView: UITableView, titleForHeaderInSection inSection: Int) -> String? {
        return sectionCache[inSection].label
    }

    /* ################################################################## */
    /**
     */
    override func tableView(_ inTableView: UITableView, numberOfRowsInSection inSection: Int) -> Int {
        let section = sectionCache[inSection]
        return section.values.count + 1
    }
    
    /* ################################################################## */
    /**
     */
    override func tableView(_ inTableView: UITableView, cellForRowAt inIndexPath: IndexPath) -> UITableViewCell {
        let section = sectionCache[inIndexPath.section]
        if inIndexPath.row < section.values.count {
            return section.values[inIndexPath.row]
        } else {
            return UITableViewCell()
        }
    }
    
    /* ################################################################## */
    /**
     */
    override func addLabel(toContainer inContainer: UITableViewCell, withText inText: String, offsetBy inOffset: CGFloat! = nil) {
        var offset: CGFloat = inOffset ?? 0
        
        if nil == inOffset {
            offset = heightOfOneLabel
        }
        
        var frame = inContainer.frame
        var labelBounds = inContainer.bounds
        labelBounds.size.height = heightOfOneLabel
        labelBounds.size.width -= offset
        labelBounds.origin.x = offset
        frame.size.height += heightOfOneLabel
        labelBounds.origin.y = frame.size.height - labelBounds.size.height
        let label = UILabel(frame: labelBounds)
        label.text = inText
        
        if 0 == offset {
            label.font = UIFont.boldSystemFont(ofSize: heightOfOneLabel - 4)
        } else {
            label.font = UIFont.italicSystemFont(ofSize: heightOfOneLabel - 10)
        }
        
        inContainer.addContainedView(label)
        inContainer.frame = frame
    }
}
