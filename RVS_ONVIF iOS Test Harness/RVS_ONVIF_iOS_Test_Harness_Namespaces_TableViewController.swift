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
import RVS_ONVIF_iOS

/* ################################################################################################################################## */
// MARK: - Used to Display the Commands
/* ################################################################################################################################## */
class RVS_ONVIF_iOS_Test_Harness_CommandButton: UIButton {
    var associatedCommand: RVS_ONVIF_DeviceRequestProtocol!
}

/* ################################################################################################################################## */
// MARK: - Used to Display the Commands as Tappable Buttons
/* ################################################################################################################################## */
class RVS_ONVIF_iOS_Test_Harness_Namespaces_Command_TableViewCell: UITableViewCell {
    @IBOutlet var commandButton: RVS_ONVIF_iOS_Test_Harness_CommandButton!
}

/* ################################################################################################################################## */
// MARK: - Main Table View Controller Class for inspecting our profile handlers.
/* ################################################################################################################################## */
class RVS_ONVIF_iOS_Test_Harness_Namespaces_TableViewController: RVS_ONVIF_iOS_Test_Harness_ONVIF_TableViewController {
    let displayDataSegueID = "show-response"
    typealias ResponseData = (header: String, data: String)
    
    /* ################################################################## */
    /**
     */
    func displayResult(header inHeader: String, data inData: String) {
        performSegue(withIdentifier: displayDataSegueID, sender: (header: inHeader, data: inData))
    }
    
    /* ################################################################## */
    /**
     */
    @objc func handleButtonPress(_ inButton: RVS_ONVIF_iOS_Test_Harness_CommandButton) {
        for dispatcher in onvifInstance.dispatchers {
            if let disp = dispatcher as? RVS_ONVIF_iOS_Test_Harness_Dispatcher {
                disp.setupCommandParameters(inButton.associatedCommand)
            }
        }
    }
    
    /* ################################################################## */
    /**
     */
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        RVS_ONVIF_iOS_Test_Harness_AppDelegate.appDelegateObject.openNamespaceHandlerScreen = self
    }
    
    /* ################################################################## */
    /**
     */
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        RVS_ONVIF_iOS_Test_Harness_AppDelegate.appDelegateObject.openNamespaceHandlerScreen = nil
    }
    
    /* ################################################################## */
    /**
     */
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destination = segue.destination as? RVS_ONVIF_iOS_Test_Harness_DisplayResponse_ViewController, let sender = sender as? ResponseData {
            destination.responseName = sender.header
            destination.responseData = sender.data
        } else if let destination = segue.destination as? RVS_ONVIF_iOS_Test_Harness_ProfileSProfiles_TableViewController, let sender = sender as? [RVS_ONVIF_Profile_S.Profile] {
            destination.profiles = sender
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
        var cell = tableView.dequeueReusableCell(withIdentifier: "show_profile_data_cell", for: indexPath)
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
            cell = tableView.dequeueReusableCell(withIdentifier: "RVS_ONVIF_Test_Harness_Namespaces_Command_TableViewCell", for: indexPath)
            
            if let myCell = cell as? RVS_ONVIF_iOS_Test_Harness_Namespaces_Command_TableViewCell {
                myCell.commandButton.setTitle(profileHandler.availableCommandsAsStrings[indexPath.row - 1], for: .normal)
                myCell.commandButton.addTarget(self, action: #selector(handleButtonPress), for: .touchUpInside)
                myCell.commandButton.associatedCommand = profileHandler.availableCommands[indexPath.row - 1]
            }
        }
        
        cell.textLabel?.adjustsFontSizeToFitWidth = true
        cell.textLabel?.numberOfLines = numberOfLines
        cell.textLabel?.text = text
        return cell
    }
}
