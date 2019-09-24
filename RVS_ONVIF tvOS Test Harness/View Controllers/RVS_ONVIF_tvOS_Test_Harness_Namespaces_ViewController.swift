/** 
 © Copyright 2019, The Great Rift Valley Software Company

LICENSE:

MIT License

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation
files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy,
modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the
Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF
CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

The Great Rift Valley Software Company: https://riftvalleysoftware.com
*/

import UIKit
import RVS_ONVIF_tvOS

typealias RVS_ONVIF_tvOS_Test_Harness_Namespaces_ViewController_CacheElement = (label: String, values: [UITableViewCell])

/* ################################################################################################################################## */
// MARK: - Class for A Specialized TableView Cell That Carries An Associated Command Enum.
/* ################################################################################################################################## */
/**
 */
class RVS_ONVIF_tvOS_Test_Harness_Namespaces_ViewController_AssociatedCommand_TableViewCell: UITableViewCell {
    var associatedCommand: RVS_ONVIF_DeviceRequestProtocol!
}

/* ################################################################################################################################## */
// MARK: - Class for A Specialized TableView Cell That Is Used to Fetch A Streaming URI
/* ################################################################################################################################## */
/**
 */
class RVS_ONVIF_tvOS_Test_Harness_Namespaces_ViewController_StreamingURI_TableViewCell: UITableViewCell {
    var associatedCommand: RVS_ONVIF_DeviceRequestProtocol!
}

/* ################################################################################################################################## */
// MARK: - Main Class for the Namespaces ViewController
/* ################################################################################################################################## */
class RVS_ONVIF_tvOS_Test_Harness_Namespaces_ViewController: RVS_ONVIF_tvOS_Test_Harness_Base_Modal_TableViewController {
    var sectionCache: [RVS_ONVIF_tvOS_Test_Harness_Namespaces_ViewController_CacheElement] = []
    
    /* ################################################################## */
    /**
     */
    func displayResult(header inHeader: String, data inData: String) {
    }

    /* ############################################################################################################################## */
    // MARK: - Internal Base Class Override Methods
    /* ############################################################################################################################## */
    /* ################################################################## */
    /**
     */
    override func buildCache() {
        sectionCache = []
        if nil != tableView {
            onvifInstance?.profilesAsArray.forEach {
                var cells: [UITableViewCell] = []
                let nameSpaces = type(of: $0).namespaces
                let supportedNamespaces = $0.supportedNamespaces
                
                for namespace in nameSpaces {
                    if supportedNamespaces.contains(namespace) {
                        let cell = UITableViewCell()
                        addLabel(toContainer: cell, withText: "Namespace: \(namespace)")
                        cells.append(cell)
                    }
                    
                }

                let sectionLabel = $0.profileName
                let sectionCommands = $0.availableCommands
                for i in sectionCommands.enumerated() {
                    let cell = RVS_ONVIF_tvOS_Test_Harness_Namespaces_ViewController_AssociatedCommand_TableViewCell()
                    cell.associatedCommand = $0.availableCommands[i.offset]
                    addLabel(toContainer: cell, withText: i.element.rawValue)
                    cells.append(cell)
                }
                
                sectionCache.append(RVS_ONVIF_tvOS_Test_Harness_Namespaces_ViewController_CacheElement(label: sectionLabel, values: cells))
            }
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
    
    /* ################################################################## */
    /**
     */
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        RVS_ONVIF_tvOS_Test_Harness_AppDelegate.delegateObject.openNamespaceHandlerScreen = self
    }
    
    /* ################################################################## */
    /**
     */
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        RVS_ONVIF_tvOS_Test_Harness_AppDelegate.delegateObject.openNamespaceHandlerScreen = nil
    }

    /* ############################################################################################################################## */
    // MARK: - UITableViewDataSource Methods
    /* ############################################################################################################################## */
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
        return section.values.count
    }
    
    /* ################################################################## */
    /**
     */
    override func tableView(_ inTableView: UITableView, cellForRowAt inIndexPath: IndexPath) -> UITableViewCell {
        let section = sectionCache[inIndexPath.section]
        if inIndexPath.row < section.values.count {
            return section.values[inIndexPath.row]
        }
        
        return UITableViewCell()
    }
    
    /* ############################################################################################################################## */
    // MARK: - UITableViewDelegate Methods
    /* ############################################################################################################################## */
    /* ################################################################## */
    /**
     */
    override func tableView(_ inTableView: UITableView, willSelectRowAt inIndexPath: IndexPath) -> IndexPath? {
        let section = sectionCache[inIndexPath.section]
        if  inIndexPath.row < section.values.count,
            let cellItem = section.values[inIndexPath.row].subviews[0] as? UILabel,
            let text = cellItem.text,
            nil == text.index(of: "Namespace:") {
            return inIndexPath
        }
        
        return nil
    }
    
    /* ################################################################## */
    /**
     */
    override func tableView(_ inTableView: UITableView, didSelectRowAt inIndexPath: IndexPath) {
        let section = sectionCache[inIndexPath.section]
        if  inIndexPath.row < section.values.count,
            let cell = section.values[inIndexPath.row] as? RVS_ONVIF_tvOS_Test_Harness_Namespaces_ViewController_AssociatedCommand_TableViewCell,
            let cellItem = cell.subviews[0] as? UILabel,
            let text = cellItem.text,
            nil == text.index(of: "Namespace:") {
            for dispatcher in onvifInstance.dispatchers {
                if let disp = dispatcher as? RVS_ONVIF_tvOS_Test_Harness_Dispatcher {
                    disp.setupCommandParameters(cell.associatedCommand)
                }
            }
        }
    }
    
    /* ################################################################## */
    /**
     */
    func tableView(_ inTableView: UITableView, canFocusRowAt inIndexPath: IndexPath) -> Bool {
        let section = sectionCache[inIndexPath.section]
        if  inIndexPath.row < section.values.count,
            (section.values[inIndexPath.row] is RVS_ONVIF_tvOS_Test_Harness_Namespaces_ViewController_AssociatedCommand_TableViewCell
                || section.values[inIndexPath.row] is RVS_ONVIF_tvOS_Test_Harness_Namespaces_ViewController_StreamingURI_TableViewCell) {
            return true
        }
        
        return false
    }
}
