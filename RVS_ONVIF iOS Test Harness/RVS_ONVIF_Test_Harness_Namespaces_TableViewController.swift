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
public protocol RVS_ONVIF_iOS_Test_Harness_Dispatcher {
    var sendParameters: [String: Any]! { get set }
    func setupCommandParameters(_ inCommand: RVS_ONVIF_DeviceRequestProtocol)
    func sendSpecificCommand(_ inCommand: RVS_ONVIF_DeviceRequestProtocol)
    // We repeat this, because we will be calling it, based on this protocol, not the RVS_ONVIF-defined one, which includes this.
    @discardableResult func sendRequest(_ inCommand: RVS_ONVIF_DeviceRequestProtocol) -> Bool
}

/* ################################################################################################################################## */
// MARK: - Used to Display the Commands
/* ################################################################################################################################## */
class RVS_ONVIF_Mac_Test_Harness_CommandButton: UIButton {
    var associatedCommand: RVS_ONVIF_DeviceRequestProtocol!
}

/* ################################################################################################################################## */
// MARK: - Main Table View Controller Class for inspecting our profile handlers.
/* ################################################################################################################################## */
class RVS_ONVIF_Test_Harness_Namespaces_TableViewController: RVS_ONVIF_Test_Harness_ONVIF_TableViewController {
    /* ################################################################## */
    /**
     */
    @objc func handleButtonPress(_ inButton: RVS_ONVIF_Mac_Test_Harness_CommandButton) {
        for dispatcher in onvifInstance.dispatchers {
            if let disp = dispatcher as? RVS_ONVIF_iOS_Test_Harness_Dispatcher {
                disp.setupCommandParameters(inButton.associatedCommand)
            }
        }
    }

    // MARK: - Table view data source

    /* ################################################################## */
    /**
     */
    override func numberOfSections(in tableView: UITableView) -> Int {
        return onvifInstance.profilesAsArray.count
    }

    /* ################################################################## */
    /**
     */
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let profileHandler = onvifInstance.profilesAsArray[section]
        return profileHandler.availableCommands.count + 1
    }

    /* ################################################################## */
    /**
     */
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return onvifInstance.profilesAsArray[section].profileName
    }
    
    /* ################################################################## */
    /**
     */
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "show_profile_data_cell", for: indexPath)
        let profileHandler = onvifInstance.profilesAsArray[indexPath.section]
        var numberOfLines = 1
        var text: String = ""
        
        if 0 == indexPath.row {
            text = "Namespaces:"
            
            let nameSpaces = type(of: profileHandler).namespaces
            let supportedNamespaces = profileHandler.supportedNamespaces
            
            for namespace in nameSpaces {
                numberOfLines += 1
                var text2 = "\(namespace)"
                
                if supportedNamespaces.contains(namespace) {
                    text2 = "√ " + text2
                } else {
                    text2 = "X " + text2
                }
                
                text += "\n\t" + text2
            }
            cell.textLabel?.font = UIFont.monospacedDigitSystemFont(ofSize: 17, weight: .light)
        } else {
            cell.textLabel?.font = UIFont.italicSystemFont(ofSize: 17)
            text = profileHandler.availableCommandsAsStrings[indexPath.row - 1]
        }
        
        cell.textLabel?.adjustsFontSizeToFitWidth = true
        cell.textLabel?.numberOfLines = numberOfLines
        cell.textLabel?.text = text
        return cell
    }
}
