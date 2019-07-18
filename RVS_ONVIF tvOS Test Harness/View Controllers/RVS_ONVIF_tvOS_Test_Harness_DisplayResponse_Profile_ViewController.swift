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
