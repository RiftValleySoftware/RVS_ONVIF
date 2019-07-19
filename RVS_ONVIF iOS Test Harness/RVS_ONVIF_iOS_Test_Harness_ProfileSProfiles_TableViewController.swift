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
// MARK: - Holds a Profile Instance
/* ################################################################################################################################## */
class RVS_ONVIF_iOS_Test_Harness_ProfileButton: UIButton {
    var associatedProfile: RVS_ONVIF_Profile_S.Profile!
}

/* ################################################################################################################################## */
// MARK: - Standard Data Cell View
/* ################################################################################################################################## */
class RVS_ONVIF_iOS_Test_Harness_StandardCell: UITableViewCell {
    @IBOutlet var labelView: UILabel!
    @IBOutlet var dataView: UILabel!
}

/* ################################################################################################################################## */
// MARK: - Callout Button Cell View
/* ################################################################################################################################## */
class RVS_ONVIF_iOS_Test_Harness_ButtonCell: UITableViewCell {
    @IBOutlet var udpButton: RVS_ONVIF_iOS_Test_Harness_ProfileButton!
    @IBOutlet var tcpButton: RVS_ONVIF_iOS_Test_Harness_ProfileButton!
}

/* ################################################################################################################################## */
// MARK: - Main View Controller Class
/* ################################################################################################################################## */
class RVS_ONVIF_iOS_Test_Harness_ProfileSProfiles_TableViewController: UITableViewController {
    static let standardTextReuseID = "standard-text"
    static let calloutButtonsReuseID = "callout-buttons"
    static let displayVideoSegueID = "display-video"

    typealias RVS_ONVIF_iOS_Test_Harness_ProfileSVideoCall = (uri: URL, onvifInstance: RVS_ONVIF)
    
    /* ################################################################## */
    /**
     */
    var profiles: [RVS_ONVIF_Profile_S.Profile] = []
    
    /* ################################################################## */
    /**
     */
    func getDataDisplayForProfile(_ inProfile: RVS_ONVIF_Profile_S.Profile) -> [(key: String, value: String)] {
        var ret: [(key: String, value: String)] = [
            (key: "Name:", value: inProfile.name),
            (key: "Token:", value: inProfile.token)
        ]
        
        if let ptzConfig = inProfile.ptzConfiguration {
            ret.append((key: "PTZ Config Name:", value: ptzConfig.name))
            ret.append((key: "PTZ Config Token:", value: ptzConfig.token))

            if let panTiltLimits = ptzConfig.panTiltLimits {
                ret.append((key: "PTZ Config PanTiltLimits X Range:", value: "\(panTiltLimits.xRange.lowerBound)...\(panTiltLimits.xRange.upperBound)"))
                ret.append((key: "PTZ Config PanTiltLimits Y Range:", value: "\(panTiltLimits.yRange.lowerBound)...\(panTiltLimits.yRange.upperBound)"))
                ret.append((key: "PTZ Config PanTiltLimits URI:", value: panTiltLimits.uri.absoluteString))
            }
            
            if let zoomLimits = ptzConfig.zoomLimits {
                ret.append((key: "PTZ Config ZoomLimits X Range:", value: "\(zoomLimits.xRange.lowerBound)...\(zoomLimits.xRange.upperBound)"))
                ret.append((key: "PTZ Config ZoomLimits URI:", value: zoomLimits.uri.absoluteString))
            }
        }
        
        if let encoderConfig = inProfile.videoEncoderConfiguration {
            ret.append((key: "Encoder Config Name:", value: encoderConfig.name))
            ret.append((key: "Encoder Config Use Count:", value: String(encoderConfig.useCount)))
            ret.append((key: "Encoder Config Token:", value: encoderConfig.token))
            ret.append((key: "Encoder Config EncodingTypes:", value: String(encoderConfig.encoding.rawValue)))
            ret.append((key: "Encoder Config Timeout:", value: String(encoderConfig.timeoutInSeconds) + " Seconds"))

            if let rateControl = encoderConfig.rateControl {
                if let frameRateLimit = rateControl.frameRateLimit {
                    ret.append((key: "Encoder Config Rate Control Frame Rate Limit:", value: String(frameRateLimit)))
                }
                
                if let encodingInterval = rateControl.encodingInterval {
                    ret.append((key: "Encoder Config Rate Control Encoding Interval:", value: String(encodingInterval)))
                }
                
                if let bitRateLimit = rateControl.bitRateLimit {
                    ret.append((key: "Encoder Config Rate Control Bit Rate Limit:", value: String(bitRateLimit)))
                }
            }
        
            if let multicast = encoderConfig.multicast {
                if let ipAddress = multicast.ipAddress {
                    ret.append((key: "Encoder Config Multicast IP Address:", value: ipAddress.address))
                }
                
                ret.append((key: "Encoder Config Multicast AutoStart:", value: multicast.autoStart ? "TRUE" : "FALSE"))
                
                ret.append((key: "Encoder Config Multicast TCP Port:", value: String(multicast.port)))
                
                ret.append((key: "Encoder Config Multicast TTL:", value: String(reflecting: multicast.ttl)))
            }
            
            if let quality = encoderConfig.quality {
                ret.append((key: "Encoder Config Quality:", value: String(quality)))
            }
            
            if let resolution = encoderConfig.resolution {
                ret.append((key: "Encoder Config Resolution:", value: String(reflecting: resolution)))
            }
            
            if let encodingParameters = encoderConfig.encodingParameters {
                ret.append((key: "Encoder Config Encoding Parameters:", value: String(reflecting: encodingParameters)))
            }
        }
        
        return ret
    }

    /* ################################################################## */
    /**
     */
    @objc func streamButtonUDPHit(_ inButton: RVS_ONVIF_iOS_Test_Harness_ProfileButton) {
        #if DEBUG
            print("Stream UDP")
        #endif
        inButton.associatedProfile.fetchURI(streamType: "RTP-Unicast", andProtocol: "UDP")
    }

    /* ################################################################## */
    /**
     */
    @objc func streamButtonTCPHit(_ inButton: RVS_ONVIF_iOS_Test_Harness_ProfileButton) {
        #if DEBUG
            print("Stream TCP")
        #endif
        inButton.associatedProfile.fetchURI(streamType: "RTP-Unicast", andProtocol: "TCP")
    }

    /* ################################################################## */
    /**
     */
    func displayVideoScreen(_ inURI: URL, onvifInstance inONVIFInstance: RVS_ONVIF) {
        #if DEBUG
            print("Displaying RTP URI: \(inURI.absoluteString)")
        #endif
        
        let sender = RVS_ONVIF_iOS_Test_Harness_ProfileSVideoCall(uri: inURI, onvifInstance: inONVIFInstance)
        performSegue(withIdentifier: type(of: self).displayVideoSegueID, sender: sender)
    }
    
    /* ################################################################## */
    /**
     */
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        RVS_ONVIF_iOS_Test_Harness_AppDelegate.appDelegateObject.openProfileSProfilesScreen = self
    }
    
    /* ################################################################## */
    /**
     */
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        RVS_ONVIF_iOS_Test_Harness_AppDelegate.appDelegateObject.openProfileSProfilesScreen = nil
    }

    /* ################################################################## */
    /**
     */
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destination = segue.destination as? RVS_ONVIF_iOS_Test_Harness_ProfileSProfile_Viewer_ViewController, let sender = sender as? RVS_ONVIF_iOS_Test_Harness_ProfileSVideoCall {
            destination.rtpURI = sender.uri
            destination.onvifInstance = sender.onvifInstance
        }
    }
    
    /* ################################################################## */
    /**
     */
    override func numberOfSections(in inTableView: UITableView) -> Int {
        return profiles.count
    }
    
    /* ################################################################## */
    /**
     */
    override func tableView(_ inTableView: UITableView, titleForHeaderInSection inSection: Int) -> String? {
        let profile = profiles[inSection]
        return profile.name
    }
    
    /* ################################################################## */
    /**
     */
    override func tableView(_ inTableView: UITableView, numberOfRowsInSection inSection: Int) -> Int {
        let profile = profiles[inSection]
        let data = getDataDisplayForProfile(profile)
        return data.count + 1
    }
    
    /* ################################################################## */
    /**
     */
    override func tableView(_ inTableView: UITableView, cellForRowAt inIndexPath: IndexPath) -> UITableViewCell {
        let profile = profiles[inIndexPath.section]
        let profileData = getDataDisplayForProfile(profile)
        
        if inIndexPath.row == profileData.count, let ret = inTableView.dequeueReusableCell(withIdentifier: type(of: self).calloutButtonsReuseID, for: inIndexPath) as? RVS_ONVIF_iOS_Test_Harness_ButtonCell {
            
            ret.udpButton?.associatedProfile = profile
            ret.udpButton?.addTarget(self, action: #selector(streamButtonUDPHit), for: .touchUpInside)

            if (profile.owner?.capabilities?.mediaCapabilities?.isRTP_TCP ?? false) || (profile.owner?.capabilities?.mediaCapabilities?.isRTP_RTSP_TCP ?? false) {
                ret.tcpButton?.isHidden = false
                ret.tcpButton?.associatedProfile = profile
                ret.tcpButton?.addTarget(self, action: #selector(streamButtonTCPHit), for: .touchUpInside)
            }
            
            return ret
        } else if let ret = inTableView.dequeueReusableCell(withIdentifier: type(of: self).standardTextReuseID, for: inIndexPath) as? RVS_ONVIF_iOS_Test_Harness_StandardCell {
            let data = profileData[inIndexPath.row]
            ret.labelView.text = data.key
            ret.dataView.text = data.value
            
            return ret
        }
        
        return UITableViewCell()
    }
}
