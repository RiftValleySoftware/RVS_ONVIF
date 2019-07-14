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
                // Yeah, this is a pathetic lash-up, but this is a simple test harness. No need to get more efficient.
                if let capabilities = $0.value.capabilities, !capabilities.isEmpty {
                    for capability in capabilities {
                        if let value = capability.value as? String {
                            addLabel(toContainer: tableCellContainer, withText: "\(capability.key): \(value)")
                        } else if let values = capability.value as? [String: Any] {
                            addLabel(toContainer: tableCellContainer, withText: "\(capability.key):")
                            for singleInstance in values {
                                if let value = singleInstance.value as? String {
                                    addLabel(toContainer: tableCellContainer, withText: "\(singleInstance.key): \(value)", offsetBy: 80)
                                    // We only go in one level. This all could be done much more slickly.
                                } else if let valuesDeeper = singleInstance.value as? [String: Any] {
                                    for valueDeep in valuesDeeper {
                                        addLabel(toContainer: tableCellContainer, withText: "\(valueDeep.key): \(String(describing: valueDeep.value))", offsetBy: 80)
                                    }
                                } else {
                                    addLabel(toContainer: tableCellContainer, withText: "\(singleInstance.key): \(String(describing: singleInstance.value))", offsetBy: 80)
                                }
                            }
                        } else {
                            addLabel(toContainer: tableCellContainer, withText: "\(capability.key): \(String(describing: capability.value))")
                        }
                    }
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
    // MARK: - UITableViewDelegate Methods
    /* ############################################################################################################################## */
    /* ################################################################## */
    /**
     */
    func tableView(_ inTableView: UITableView, heightForRowAt inIndexPath: IndexPath) -> CGFloat {
        return inIndexPath.row < cachedCells.count ? cachedCells[inIndexPath.row].frame.size.height : inTableView.rowHeight
    }
    
    /* ################################################################## */
    /**
     */
    func tableView(_ inTableView: UITableView, willSelectRowAt inIndexPath: IndexPath) -> IndexPath? {
        return nil
    }
    
    /* ################################################################## */
    /**
     */
    func tableView(_ inTableView: UITableView, canFocusRowAt inIndexPath: IndexPath) -> Bool {
        return inIndexPath.row < cachedCells.count  // Can't focus that last row, however.
    }

    /* ############################################################################################################################## */
    // MARK: - UITableViewDataSource Methods
    /* ############################################################################################################################## */
    /* ################################################################## */
    /**
     */
    override func tableView(_ inTableView: UITableView, numberOfRowsInSection inSection: Int) -> Int {
        return cachedCells.count + 1    // We add one row at the end, because we want to make sure the table can scroll all the way.
    }
    
    /* ################################################################## */
    /**
     */
    override func tableView(_ inTableView: UITableView, cellForRowAt inIndexPath: IndexPath) -> UITableViewCell {
        return inIndexPath.row < cachedCells.count ? cachedCells[inIndexPath.row] : UITableViewCell()   // Last row is empty.
    }
}
