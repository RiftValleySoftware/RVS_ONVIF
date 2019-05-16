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
// MARK: - Main View Controller Class
/* ################################################################################################################################## */
class RVS_ONVIF_Test_Harness_ProfileSProfiles_TableViewController: UITableViewController {
    static let standardTextReuseID = "standard-text"
    static let calloutButtonsReuseID = "callout-buttons"
    
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
        return data.count
    }
    
    /* ################################################################## */
    /**
     */
    override func tableView(_ inTableView: UITableView, cellForRowAt inIndexPath: IndexPath) -> UITableViewCell {
        let profile = profiles[inIndexPath.section]
        let data = getDataDisplayForProfile(profile)[inIndexPath.row]
        
        let ret = UITableViewCell()
        
        let keyLabel = UILabel()
        keyLabel.text = data.key
        
        ret.addSubview(keyLabel)
        
        keyLabel.translatesAutoresizingMaskIntoConstraints = false
        keyLabel.topAnchor.constraint(equalTo: ret.topAnchor, constant: 0).isActive = true
        keyLabel.leadingAnchor.constraint(equalTo: ret.leadingAnchor, constant: 0).isActive = true
        keyLabel.trailingAnchor.constraint(equalTo: ret.trailingAnchor, constant: 0).isActive = true
        
        let valueLabel = UILabel()
        valueLabel.text = data.value
        
        ret.addSubview(valueLabel)
        
        valueLabel.translatesAutoresizingMaskIntoConstraints = false
        keyLabel.bottomAnchor.constraint(equalTo: valueLabel.topAnchor, constant: 0).isActive = true
        valueLabel.topAnchor.constraint(equalTo: keyLabel.bottomAnchor, constant: 0).isActive = true
        valueLabel.trailingAnchor.constraint(equalTo: ret.trailingAnchor, constant: 0).isActive = true
        valueLabel.leadingAnchor.constraint(equalTo: keyLabel.leadingAnchor, constant: 0).isActive = true
        valueLabel.bottomAnchor.constraint(equalTo: ret.bottomAnchor, constant: 0).isActive = true

        return ret
    }
}
