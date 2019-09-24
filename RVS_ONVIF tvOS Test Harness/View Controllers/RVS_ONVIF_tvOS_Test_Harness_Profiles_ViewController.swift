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

/* ################################################################################################################################## */
// MARK: - Main Class for the Namespaces ViewController
/* ################################################################################################################################## */
class RVS_ONVIF_tvOS_Test_Harness_Profiles_ViewController: RVS_ONVIF_tvOS_Test_Harness_Base_Modal_TableViewController {
    /* ############################################################################################################################## */
    // MARK: - Class Calculated Properties
    /* ############################################################################################################################## */
    /* ################################################################## */
    /**
     */
    class var storyboardID: String {
        return "displayResponseProfileListScreen"
    }
    
    /* ############################################################################################################################## */
    // MARK: - Instance Properties
    /* ############################################################################################################################## */
    /* ################################################################## */
    /**
     */
    var profileObjects: [RVS_ONVIF_Profile_S.Profile] = []

    /* ############################################################################################################################## */
    // MARK: - Internal Base Class Override Methods
    /* ############################################################################################################################## */
    /* ################################################################## */
    /**
     */
    override func buildCache() {
        if nil != tableView, 0 < profileObjects.count {
            profileObjects.forEach {
                let tableCellContainer = UITableViewCell()
                tableCellContainer.frame = CGRect(x: 0, y: 0, width: tableView.bounds.size.width, height: 0)
                addLabel(toContainer: tableCellContainer, withText: $0.name, offsetBy: 0)
                cachedCells.append(tableCellContainer)
            }
        }
    }
    
    /* ################################################################## */
    /**
     */
    override func backToHomeBase() {
        dismiss(animated: true, completion: nil)
    }

    /* ############################################################################################################################## */
    // MARK: - UITableViewDelegate Methods
    /* ############################################################################################################################## */
    /* ################################################################## */
    /**
     */
    override func tableView(_ inTableView: UITableView, willSelectRowAt inIndexPath: IndexPath) -> IndexPath? {
        return inIndexPath
    }

    /* ################################################################## */
    /**
     */
    override func tableView(_ inTableView: UITableView, didSelectRowAt inIndexPath: IndexPath) {
        if inIndexPath.row < profileObjects.count {
            if let profileScreen = storyboard?.instantiateViewController(withIdentifier: RVS_ONVIF_tvOS_Test_Harness_DisplayResponse_Profile_ViewController.storyboardID) as? RVS_ONVIF_tvOS_Test_Harness_DisplayResponse_Profile_ViewController {
                profileScreen.profileObject = profileObjects[inIndexPath.row]
                present(profileScreen, animated: true, completion: nil)
            }
        } else {
            super.tableView(inTableView, didSelectRowAt: inIndexPath)
        }
    }
}
