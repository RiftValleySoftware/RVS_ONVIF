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
// MARK: - Main TableView Controller Class for the Profile Inspector Screen
/* ################################################################################################################################## */
class RVS_ONVIF_Test_Harness_Profile_TableViewController: UITableViewController {
    /* ############################################################################################################################## */
    // MARK: - Internal Instance Properties
    /* ############################################################################################################################## */
    /* ################################################################## */
    /**
     */
    let profileRows: [String] = ["name",
                                 "token",
                                 "ptzConfiguration",
                                 "videoEncoderConfiguration"
                                ]
    
    /* ################################################################## */
    /**
     */
    var onvifInstance: RVS_ONVIF!
    
    /* ################################################################## */
    /**
     */
    var profile: RVS_ONVIF_Profile_S.Profile!
    
    /* ################################################################## */
    /**
     */
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destination = segue.destination as? RVS_ONVIF_Test_Harness_Stream_Inspector_ViewController {
            destination.onvifInstance = onvifInstance
            destination.profile = profile
            
            let params: [String: String] = ["token": profile.token, "streamType": "RTP-Unicast", "protocol": "UDP"]
            
            destination.params = params
        }
    }

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
        return profileRows.count + 1
    }
    
    /* ################################################################## */
    /**
     */
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if profileRows.count == indexPath.row {
            return 121
        } else {
            return super.tableView(tableView, heightForRowAt: indexPath)
        }
    }

    /* ################################################################## */
    /**
     */
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = UITableViewCell()
        
        switch indexPath.row {
        case 0:
            cell = tableView.dequeueReusableCell(withIdentifier: "basic-label", for: indexPath)
            cell.textLabel?.text = "Name: " + profile.name
            
        case 1:
            cell = tableView.dequeueReusableCell(withIdentifier: "basic-label", for: indexPath)
            cell.textLabel?.text = "Token: " + profile.token
            
        case 2:
            cell = tableView.dequeueReusableCell(withIdentifier: "basic-label", for: indexPath)
            if let ptz = profile.ptzConfiguration {
                var displayString = "PTZ Configuration:\n\tName: " + ptz.name + "\n\tToken: " + ptz.token + "\n"
                cell.textLabel?.numberOfLines = 10
                if let panTiltLimits = ptz.panTiltLimits {
                    displayString += String(format: "\tPan Range: %0.2f...%0.2f", panTiltLimits.xRange.lowerBound, panTiltLimits.xRange.upperBound) + "\n"
                    displayString += String(format: "\tTilt Range: %0.2f...%0.2f", panTiltLimits.yRange.lowerBound, panTiltLimits.yRange.upperBound) + "\n"
                    
                    let uri = panTiltLimits.uri
                    displayString += "\tPan/Tilt URI: " + uri.lastPathComponent + "\n"
                }
                
                if let zoomLimits = ptz.zoomLimits {
                    displayString += String(format: "\tZoom Range: %0.2f...%0.2f", zoomLimits.xRange.lowerBound, zoomLimits.xRange.upperBound) + "\n"
                    let uri = zoomLimits.uri
                    displayString += "\tZoom URI: " + uri.lastPathComponent
                }
                
                cell.textLabel?.text = displayString
            } else {
                cell.textLabel?.text = "No PTZ"
            }
            
        case 3:
            cell = tableView.dequeueReusableCell(withIdentifier: "basic-label", for: indexPath)
            if let vec = profile.videoEncoderConfiguration {
                cell.textLabel?.numberOfLines = 9
                
                if nil != vec.rateControl {
                    cell.textLabel?.numberOfLines += 4
                }
                
                if nil != vec.multicast {
                    cell.textLabel?.numberOfLines += 5
                }
                
                if let encParam = vec.encodingParameters, 0 < encParam.count {
                    cell.textLabel?.numberOfLines += (encParam.count + 1)
                }
                
                cell.textLabel?.text = buildVideoEncoderDisplayString(vec)
            } else {
                cell.textLabel?.text = "No PTZ"
            }

        case profileRows.count:
            cell = tableView.dequeueReusableCell(withIdentifier: "stream-cell", for: indexPath)

        default:
            cell = tableView.dequeueReusableCell(withIdentifier: "basic-label", for: indexPath)
            cell.textLabel?.text = "Unknown Field"
        }
        return cell
    }
    
    func buildVideoEncoderDisplayString(_ vec: RVS_ONVIF_Profile_S.VideoEncoderConfiguration) -> String {
        var displayString = "Video Encoder Configuration:\n\tName: " + vec.name + "\n\tToken: " + vec.token + "\n\tUseCount: " + String(vec.useCount) + "\n"
        
        displayString += "\tEncoding Type: " + vec.encoding.rawValue.uppercased() + "\n"
        displayString += String(format: "\tTimeout: %d Seconds\n", vec.timeoutInSeconds)
        
        displayString += String(format: "\tQuality: %d\n", vec.quality)
        displayString += String(format: "\tResolution: %0.f X %0.f\n", vec.resolution.width, vec.resolution.height)
        
        if let rateControl = vec.rateControl {
            displayString += "\tRate Control:\n"
            displayString += String(format: "\t\tFrame Rate Limit: %0.2f\n", rateControl.frameRateLimit)
            displayString += String(format: "\t\tEncoding Interval: %0.2f\n", rateControl.encodingInterval)
            displayString += String(format: "\t\tBit Rate Limit: %d\n", rateControl.bitRateLimit)
        }
        
        if let multicast = vec.multicast {
            displayString += "\tMulticast:\n"
            displayString += "\t\tIP Address: " + multicast.ipAddress.address + "\n"
            displayString += String(format: "\t\tPort: %d\n", multicast.port)
            displayString += "\t\tAutostart " + (multicast.autoStart ? "ON" : "OFF") + "\n"
            displayString += "\t\tTTL: " + String(describing: multicast.ttl)
        }
        
        if let encParam = vec.encodingParameters, 0 < encParam.count {
            displayString += "\n\tEncoding Parameters:"
            for param in encParam {
                displayString += String(format: "\n\t\t%@: %@", param.key, String(describing: param.value))
            }
        }

        return displayString
    }
}
