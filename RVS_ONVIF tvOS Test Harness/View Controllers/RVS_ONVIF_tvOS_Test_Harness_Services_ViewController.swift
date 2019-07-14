/**
 © Copyright 2019, The Great Rift Valley Software Company. All rights reserved.
 
 This code is proprietary and confidential code,
 It is NOT to be reused or combined into any application,
 unless done so, specifically under written license from The Great Rift Valley Software Company.
 
 The Great Rift Valley Software Company: https://riftvalleysoftware.com
 */

import UIKit

/* ################################################################################################################################## */
// MARK: - Main Class for the Info Screen
/* ################################################################################################################################## */
class RVS_ONVIF_tvOS_Test_Harness_Services_ViewController: RVS_ONVIF_tvOS_Test_Harness_Base_TableViewController {
    let heightOfOneLabel: CGFloat = 40.0

    var cachedCells: [UITableViewCell] = []
    
    /* ############################################################################################################################## */
    // MARK: - Internal Instance Properties
    /* ############################################################################################################################## */
    /* ################################################################## */
    /**
     */
    func addLabel(toContainer inContainer: UITableViewCell, withText inText: String, offsetBy inOffset: CGFloat = 40) {
        var frame = inContainer.frame
        var labelBounds = inContainer.bounds
        labelBounds.size.height = heightOfOneLabel
        labelBounds.size.width -= inOffset
        labelBounds.origin.x = inOffset
        frame.size.height += heightOfOneLabel
        labelBounds.origin.y = frame.size.height - labelBounds.size.height
        let label = UILabel(frame: labelBounds)
        label.text = inText
        inContainer.addSubview(label)
        inContainer.frame = frame
    }
    
    /* ################################################################## */
    /**
     */
    func buildCache() {
        cachedCells = []
        
        if let tableView = tableView {
            onvifInstance?.core?.services.forEach {
                let tableCellContainer = UITableViewCell()
                tableCellContainer.frame = CGRect(x: 0, y: 0, width: tableView.bounds.size.width, height: 0)
                addLabel(toContainer: tableCellContainer, withText: $0.value.namespace, offsetBy: 0)
                addLabel(toContainer: tableCellContainer, withText: "Path: \($0.value.xAddr.path)")
                if let version = $0.value.version {
                    addLabel(toContainer: tableCellContainer, withText: "Version: \(version)")
                }
                cachedCells.append(tableCellContainer)
            }
        }
    }
    
    /* ############################################################################################################################## */
    // MARK: - Internal Base Class Override Methods
    /* ############################################################################################################################## */
    /* ################################################################## */
    /**
     */
    override func updateUI() {
        buildCache()
        super.updateUI()
    }
    
    /* ############################################################################################################################## */
    // MARK: - UITableViewDelegate Methods
    /* ############################################################################################################################## */
    /* ################################################################## */
    /**
     */
    func tableView(_ inTableView: UITableView, heightForRowAt inIndexPath: IndexPath) -> CGFloat {
        return cachedCells[inIndexPath.row].frame.size.height
    }
    
    func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        return nil
    }
    
    /* ################################################################## */
    /**
     */
    override func didUpdateFocus(in context: UIFocusUpdateContext, with coordinator: UIFocusAnimationCoordinator) {
        super.didUpdateFocus(in: context, with: coordinator)
        if let nextFocus = context.nextFocusedView {
            nextFocus.backgroundColor = UIColor.black
            for cell in cachedCells where cell == nextFocus {
                cell.subviews.forEach {
                    if let label = $0 as? UILabel {
                        label.textColor = UIColor.white
                    }
                }
            }
        }
        
        if let prevFocus = context.previouslyFocusedView {
            for cell in cachedCells where cell == prevFocus {
                prevFocus.backgroundColor = UIColor.clear
                cell.subviews.forEach {
                    if let label = $0 as? UILabel {
                        label.textColor = UIColor.black
                    }
                }
            }
        }
    }

    /* ############################################################################################################################## */
    // MARK: - UITableViewDataSource Methods
    /* ############################################################################################################################## */
    /* ################################################################## */
    /**
     */
    override func tableView(_ inTableView: UITableView, numberOfRowsInSection inSection: Int) -> Int {
        return cachedCells.count
    }
    
    /* ################################################################## */
    /**
     */
    override func tableView(_ inTableView: UITableView, cellForRowAt inIndexPath: IndexPath) -> UITableViewCell {
        return cachedCells[inIndexPath.row]
    }
}
