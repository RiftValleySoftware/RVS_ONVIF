/**
 © Copyright 2019, The Great Rift Valley Software Company. All rights reserved.
 
 This code is proprietary and confidential code,
 It is NOT to be reused or combined into any application,
 unless done so, specifically under written license from The Great Rift Valley Software Company.
 
 The Great Rift Valley Software Company: https://riftvalleysoftware.com
 */

import UIKit
import RVS_ONVIF_tvOS

/* ################################################################################################################################## */
// MARK: - Main Base Class for Test Harness View Controllers
/* ################################################################################################################################## */
class RVS_ONVIF_tvOS_Test_Harness_Base_ViewController: UIViewController, RVS_ONVIF_tvOS_Test_Harness_ViewProtocol {    
    /* ############################################################################################################################## */
    // MARK: - Internal Calculated Properties
    /* ############################################################################################################################## */
    /* ################################################################## */
    /**
     */
    var persistentPrefs: RVS_PersistentPrefs! {
        get {
            if let tabBarController = tabBarController as? RVS_ONVIF_tvOS_Test_Harness_UITabBarController {
                return tabBarController.persistentPrefs
            }
            
            return nil
        }
        
        set {
            if let tabBarController = tabBarController as? RVS_ONVIF_tvOS_Test_Harness_UITabBarController {
                tabBarController.persistentPrefs = newValue
            }
        }
    }
    
    /* ################################################################## */
    /**
     */
    var onvifInstance: RVS_ONVIF! {
        get {
            if let tabBarController = tabBarController as? RVS_ONVIF_tvOS_Test_Harness_UITabBarController {
                return tabBarController.onvifInstance
            }
            
            return nil
        }
        
        set {
            if let tabBarController = tabBarController as? RVS_ONVIF_tvOS_Test_Harness_UITabBarController {
                tabBarController.onvifInstance = newValue
            }
        }
    }
    
    /* ################################################################## */
    /**
     */
    var isConnected: Bool {
        get {
            if let tabBarController = tabBarController as? RVS_ONVIF_tvOS_Test_Harness_UITabBarController {
                return tabBarController.isConnected
            }
            return false
        }
        
        set {
            if let tabBarController = tabBarController as? RVS_ONVIF_tvOS_Test_Harness_UITabBarController {
                return tabBarController.isConnected = newValue
            }
        }
    }
    
    /* ############################################################################################################################## */
    // MARK: - Internal Base Class Override Methods
    /* ############################################################################################################################## */
    /* ################################################################## */
    /**
     */
    override func viewDidLoad() {
        super.viewDidLoad()
        updateUI()
    }

    /* ############################################################################################################################## */
    // MARK: - Internal Instance Properties
    /* ############################################################################################################################## */
    /* ################################################################## */
    /**
     */
    func updateUI() {}
}

/* ################################################################################################################################## */
// MARK: - Main Base Class for Test Harness View Controllers that Have a Table
/* ################################################################################################################################## */
class RVS_ONVIF_tvOS_Test_Harness_Base_TableViewController: RVS_ONVIF_tvOS_Test_Harness_Base_ViewController, UITableViewDataSource, UITableViewDelegate {
    /* ############################################################################################################################## */
    // MARK: - IBOutlet Properties
    /* ############################################################################################################################## */
    @IBOutlet var tableView: UITableView!

    /* ############################################################################################################################## */
    // MARK: - Base Class Override Methods
    /* ############################################################################################################################## */
    /* ################################################################## */
    /**
     */
    override func updateUI() {
        tableView?.reloadData()
    }
    
    /* ############################################################################################################################## */
    // MARK: - UITableViewDataSource Methods
    /* ############################################################################################################################## */
    /* ################################################################## */
    /**
     */
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 0
    }
    
    /* ################################################################## */
    /**
     */
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return UITableViewCell()
    }
}

/* ################################################################################################################################## */
// MARK: - Base Class for Screens With Cached Tables
/* ################################################################################################################################## */
class RVS_ONVIF_tvOS_Test_Harness_Base_Cached_TableViewController: RVS_ONVIF_tvOS_Test_Harness_Base_TableViewController {
    let heightOfOneLabel: CGFloat = 40.0
    var cachedCells: [UITableViewCell] = []
    
    /* ############################################################################################################################## */
    // MARK: - Internal Instance Properties
    /* ############################################################################################################################## */
    /* ################################################################## */
    /**
     */
    func addHierarchyTo(_ inContainerObject: UITableViewCell, from inObject: Any, withIndent inIndent: CGFloat) {
        let mirrored_object = Mirror(reflecting: inObject)
        
        mirrored_object.children.forEach {
            if let propertyName = $0.label, "owner" != propertyName, case Optional<Any>.some = $0.value {
                if let urlValue = $0.value as? URL {
                    addLabel(toContainer: inContainerObject, withText: "\(propertyName): \(urlValue.absoluteString)", offsetBy: inIndent)
                } else if let boolVal = $0.value as? Bool {
                    if boolVal {
                        addLabel(toContainer: inContainerObject, withText: "\(propertyName): true", offsetBy: inIndent)
                    }
                } else if let intVal = $0.value as? Int {
                    addLabel(toContainer: inContainerObject, withText: "\(propertyName): \(String(intVal))", offsetBy: inIndent)
                } else if let floatVal = $0.value as? Float {
                    addLabel(toContainer: inContainerObject, withText: "\(propertyName): \(String(floatVal))", offsetBy: inIndent)
                } else if let stringVal = $0.value as? String, "false" != stringVal {
                    addLabel(toContainer: inContainerObject, withText: "\(propertyName): \(stringVal)", offsetBy: inIndent)
                } else if !Mirror(reflecting: $0.value).children.isEmpty {
                    var indent = inIndent
                    if "some" != propertyName {
                        addLabel(toContainer: inContainerObject, withText: "\(propertyName):", offsetBy: inIndent)
                        indent += heightOfOneLabel
                    }
                    addHierarchyTo(inContainerObject, from: $0.value, withIndent: indent)
                } else {
                    addLabel(toContainer: inContainerObject, withText: "\(propertyName): \(String(reflecting: $0.value))", offsetBy: inIndent)
                }
            }
        }
    }
    
    /* ################################################################## */
    /**
     */
    func addLabel(toContainer inContainer: UITableViewCell, withText inText: String, offsetBy inOffset: CGFloat! = nil) {
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
        inContainer.addSubview(label)
        inContainer.frame = frame
    }
    
    /* ################################################################## */
    /**
     */
    func buildCache() { }
    
    /* ############################################################################################################################## */
    // MARK: - Internal Base Class Override Methods
    /* ############################################################################################################################## */
    /* ################################################################## */
    /**
     */
    override func updateUI() {
        cachedCells = []
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
