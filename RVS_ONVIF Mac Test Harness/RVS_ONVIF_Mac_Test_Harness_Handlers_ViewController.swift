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

import Cocoa
import RVS_ONVIF_MacOS

/* ################################################################################################################################## */
// MARK: - Used to Display the Commands
/* ################################################################################################################################## */
class RVS_ONVIF_Mac_Test_Harness_CommandButton: NSButton {
    var associatedCommand: RVS_ONVIF_DeviceRequestProtocol!
}

/* ################################################################################################################################## */
// MARK: - Main Logged-In Capabilities Screen View Controller
/* ################################################################################################################################## */
class RVS_ONVIF_Mac_Test_Harness_Handlers_ViewController: RVS_ONVIF_Mac_Test_Harness_Base_ViewController, NSTableViewDataSource, NSTableViewDelegate {
    @IBOutlet weak var displayTableView: NSTableView!
    
    typealias RVS_ONVIF_Mac_Test_Harness_GroupedTableData = (key: String, value: String, associatedCommand: RVS_ONVIF_DeviceRequestProtocol?)
    
    var tableRowData: [RVS_ONVIF_Mac_Test_Harness_GroupedTableData] = []
    
    /* ############################################################################################################################## */
    // MARK: - Instance Calulated Properties -
    /* ############################################################################################################################## */
    /* ################################################################## */
    /**
     */
    override var loginViewController: RVS_ONVIF_Mac_Test_Harness_LoginScreen_ViewController! {
        /* ############################################################## */
        /**
         */
        get {
            return super.loginViewController
        }
        
        /* ############################################################## */
        /**
         */
        set {
            super.loginViewController = newValue
            
            if let profileHandlers = RVS_ONVIF_Mac_Test_Harness_AppDelegate.appDelegateObject.onvifInstance?.profilesAsArray {
                profileHandlers.forEach {
                    tableRowData.append(RVS_ONVIF_Mac_Test_Harness_GroupedTableData(key: $0.profileName, value: "", associatedCommand: nil))
                    let nameSpaces = type(of: $0).namespaces
                    let supportedNamespaces = $0.supportedNamespaces
                    
                    for var namespace in nameSpaces {
                        if supportedNamespaces.contains(namespace) {
                            namespace = " √ " + namespace
                        } else {
                            namespace = " X " + namespace
                        }
                        tableRowData.append(RVS_ONVIF_Mac_Test_Harness_GroupedTableData(key: namespace, value: "", associatedCommand: nil))
                    }
                    
                    let commands = $0.availableCommands
                    commands.forEach {
                        tableRowData.append(RVS_ONVIF_Mac_Test_Harness_GroupedTableData(key: "", value: "        " + $0.rawValue, associatedCommand: $0))
                    }
                }
            }
            
            displayTableView?.reloadData()
        }
    }

    /* ############################################################################################################################## */
    // MARK: - Superclass Overrides -
    /* ############################################################################################################################## */
    /* ################################################################## */
    /**
     */
    override func viewWillAppear() {
        RVS_ONVIF_Mac_Test_Harness_AppDelegate.appDelegateObject.functionHandlerScreen = self
        super.viewWillAppear()
    }

    /* ################################################################## */
    /**
     */
    override func viewWillDisappear() {
        RVS_ONVIF_Mac_Test_Harness_AppDelegate.appDelegateObject.functionHandlerScreen = nil
        super.viewWillDisappear()
    }

    /* ############################################################################################################################## */
    // MARK: - Control Callbacks -
    /* ############################################################################################################################## */
    /* ################################################################## */
    /**
     */
    @objc func handleButtonPress(_ inButton: RVS_ONVIF_Mac_Test_Harness_CommandButton) {
        for dispatcher in RVS_ONVIF_Mac_Test_Harness_AppDelegate.appDelegateObject.onvifInstance.dispatchers {
            if let disp = dispatcher as? RVS_ONVIF_Mac_Test_Harness_Dispatcher {
                disp.setupCommandParameters(inButton.associatedCommand)
            }
        }
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
        if tableRowData[inRow].key.starts(with: " ") {
            cell.textColor = tableRowData[inRow].key.starts(with: " √") ? NSColor.green : NSColor.red
            cell.font = NSFont.monospacedDigitSystemFont(ofSize: 17, weight: .light)
        } else if tableRowData[inRow].key.isEmpty {
            let returnedButton = RVS_ONVIF_Mac_Test_Harness_CommandButton()
            returnedButton.setButtonType(.momentaryPushIn)
            returnedButton.title = tableRowData[inRow].associatedCommand?.rawValue ?? "ERROR"
            returnedButton.target = self
            returnedButton.action = #selector(handleButtonPress)
            returnedButton.associatedCommand = tableRowData[inRow].associatedCommand
            return returnedButton
        } else if tableView(inTableView, isGroupRow: inRow) {
            cell.font = NSFont.boldSystemFont(ofSize: 20)
            cell.alignment = .center
        }
        
        return cell
    }
}
