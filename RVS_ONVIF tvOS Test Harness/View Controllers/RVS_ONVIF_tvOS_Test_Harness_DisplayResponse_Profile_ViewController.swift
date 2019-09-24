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
// MARK: - Main View Controller Class
/* ################################################################################################################################## */
class RVS_ONVIF_tvOS_Test_Harness_DisplayResponse_Profile_ViewController: RVS_ONVIF_tvOS_Test_Harness_DisplayResponse_ViewController {
    /* ############################################################################################################################## */
    // MARK: - Class Calculated Properties
    /* ############################################################################################################################## */
    /* ################################################################## */
    /**
     */
    override class var storyboardID: String {
      return "displayResponseProfileScreen"
    }
    
    /* ############################################################################################################################## */
    // MARK: - Overridden Superclass Calculated Properties
    /* ############################################################################################################################## */
    /* ################################################################## */
    /**
     */
    override var preferredFocusEnvironments: [UIFocusEnvironment] {
        return [udpStreamButton, tcpStreamButton]
    }

    /* ############################################################################################################################## */
    // MARK: - Instance Properties
    /* ############################################################################################################################## */
    /* ################################################################## */
    /**
     */
    var profileObject: RVS_ONVIF_Profile_S.Profile!
    
    /* ############################################################################################################################## */
    // MARK: - Instance IB Properties
    /* ############################################################################################################################## */
    /* ################################################################## */
    /**
     */
    @IBOutlet weak var tcpStreamButton: UIButton!
    
    /* ################################################################## */
    /**
     */
    @IBOutlet weak var udpStreamButton: UIButton!
    
    /* ############################################################################################################################## */
    // MARK: - Instance IB Actions
    /* ############################################################################################################################## */
    /* ################################################################## */
    /**
     */
    @IBAction func streamButtonHit(_ inButton: UIButton) {
        if inButton == udpStreamButton {
            profileObject.fetchURI(streamType: "RTP-Unicast", andProtocol: "UDP")
        } else {
            profileObject.fetchURI(streamType: "RTP-Unicast", andProtocol: "TCP")
        }
    }
    
    /* ############################################################################################################################## */
    // MARK: - Internal Instance Methods
    /* ############################################################################################################################## */
    /* ################################################################## */
    /**
     */
    func getHierarchyAsString(_ inInitialString: String = "", from inObject: Any! = nil, withIndent inIndent: Int = 0) -> String {
        #if DEBUG
            print("RVS_ONVIF_tvOS_Test_Harness_DisplayResponse_Profile_ViewController::getHierarchyAsString:\(String(describing: inInitialString)), from: \(String(describing: inObject)), withIndent: \(inIndent)")
        #endif
        
        var ret = inInitialString
        
        if let objectToTest = inObject {
            let mirrored_object = Mirror(reflecting: objectToTest)
            if 0 < mirrored_object.children.count {
                mirrored_object.children.forEach {
                    let value = $0.value
                    var propertyName = $0.label ?? ""
                    if "owner" != propertyName, case Optional<Any>.some = value {
                        if !ret.isEmpty {
                            ret += "\n\n"
                        }
                        
                        if "some" == propertyName {
                            propertyName = ""
                        } else if !propertyName.isEmpty {
                            propertyName += ": "
                        }
                        
                        ret += propertyName + String(reflecting: $0.value)
                    }
                }
            } else if let object = inObject {
                ret += String(reflecting: object)
            }
        }
        
        return ret
    }

    /* ############################################################################################################################## */
    // MARK: - Base Class Override Methods
    /* ############################################################################################################################## */
    /* ################################################################## */
    /**
     */
    override func viewDidLoad() {
        if let profileObject = profileObject {
            titleText = profileObject.name
            contentText = getHierarchyAsString(from: profileObject)
            if (profileObject.owner?.capabilities?.mediaCapabilities?.isRTP_TCP ?? false) || (profileObject.owner?.capabilities?.mediaCapabilities?.isRTP_RTSP_TCP ?? false) {
                tcpStreamButton.isHidden = false
            }
        }
        super.viewDidLoad()
    }
    
    /* ################################################################## */
    /**
     */
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        RVS_ONVIF_tvOS_Test_Harness_AppDelegate.delegateObject.openProfileScreen = self
    }
    
    /* ################################################################## */
    /**
     */
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        RVS_ONVIF_tvOS_Test_Harness_AppDelegate.delegateObject.openProfileScreen = nil
    }
}
