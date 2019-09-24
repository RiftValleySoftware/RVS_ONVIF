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
// MARK: - Main TableView Controller Class for the Scopes Inspector Screen
/* ################################################################################################################################## */
class RVS_ONVIF_iOS_Test_Harness_Scopes_TableViewController: RVS_ONVIF_iOS_Test_Harness_ONVIF_TableViewController {
    /* ############################################################################################################################## */
    // MARK: - Internal Instance Properties
    /* ############################################################################################################################## */
    /* ################################################################## */
    /**
     */
    let scope_id = "scope-cell"

    /* ############################################################################################################################## */
    // MARK: - Internal Instance Override UITableViewDataSource Methods
    /* ############################################################################################################################## */
    /* ################################################################## */
    /**
     */
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    /* ################################################################## */
    /**
     */
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return onvifInstance?.scopes?.count ?? 0
    }
    
    /* ################################################################## */
    /**
     */
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return super.tableView(tableView, heightForRowAt: indexPath)
    }
    
    /* ################################################################## */
    /**
     */
    override func tableView(_ tableView: UITableView, cellForRowAt inIndexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: scope_id, for: inIndexPath)
        let scopeIndex = inIndexPath.row
        if let scope = onvifInstance?.scopes[scopeIndex] {
            var title = "ERROR"
            switch scope.category {
            case .Name(let nameVal):
                title = "Name: \(nameVal)"
                
            case .Hardware(let hardwareVal):
                title = "Hardware: \(hardwareVal)"
                
            case .Location(let locationVal):
                title = "Location: \(locationVal)"
                
            case .Profile(let profileVal):
                title = "Profile: \(profileVal)"
            
            case .Custom(let customName, let customVal):
                title = "\(customName): \(customVal)"
            }
            
            cell.textLabel?.text = title
        }
        return cell
    }
}
