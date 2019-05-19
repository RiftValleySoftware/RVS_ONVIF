/**
 © Copyright 2019, The Great Rift Valley Software Company. All rights reserved.
 
 This code is proprietary and confidential code,
 It is NOT to be reused or combined into any application,
 unless done so, specifically under written license from The Great Rift Valley Software Company.
 
 The Great Rift Valley Software Company: https://riftvalleysoftware.com
 */

import Cocoa
import RVS_ONVIF_MacOS

/* ################################################################################################################################## */
// MARK: - Holds a Profile Instance
/* ################################################################################################################################## */
class RVS_ONVIF_Mac_Test_Harness_ProfileButton: NSButton {
    var associatedProfile: RVS_ONVIF_Profile_S.Profile!
}

/* ################################################################################################################################## */
// MARK: - Used to Display the Commands
/* ################################################################################################################################## */
class RVS_ONVIF_Mac_Test_Harness_ProfileDisplayViewController: NSViewController, NSTableViewDelegate, NSTableViewDataSource {
    /* ################################################################## */
    /**
     */
    typealias RVS_ONVIF_Mac_Test_Harness_Profile_S_GroupedTableData = (key: String, value: String, associatedProfile: RVS_ONVIF_Profile_S.Profile?)
    
    /* ################################################################## */
    /**
     */
    var tableRowData: [RVS_ONVIF_Mac_Test_Harness_Profile_S_GroupedTableData] = []
    
    /* ################################################################## */
    /**
     */
    var profiles: [RVS_ONVIF_Profile_S.Profile] = [] {
        didSet {
            profiles.forEach {
                let headerName = $0.name
                let token = $0.token
                tableRowData.append(RVS_ONVIF_Mac_Test_Harness_Profile_S_GroupedTableData(key: headerName, value: "", associatedProfile: $0))
                tableRowData.append(RVS_ONVIF_Mac_Test_Harness_Profile_S_GroupedTableData(key: "Token", value: token, associatedProfile: $0))
                if let ptzConfiguration = $0.ptzConfiguration {
                    tableRowData.append(RVS_ONVIF_Mac_Test_Harness_Profile_S_GroupedTableData(key: "PTZ Configuration Name", value: ptzConfiguration.name, associatedProfile: $0))
                    tableRowData.append(RVS_ONVIF_Mac_Test_Harness_Profile_S_GroupedTableData(key: "PTZ Configuration Token", value: ptzConfiguration.token, associatedProfile: $0))
                    
                    if let panTiltLimits = ptzConfiguration.panTiltLimits {
                        let xRangeString = "X: " + String(describing: panTiltLimits.xRange)
                        let yRangeString = "Y: " + String(describing: panTiltLimits.yRange)
                        tableRowData.append(RVS_ONVIF_Mac_Test_Harness_Profile_S_GroupedTableData(key: "PTZ Configuration Pan Tilt Limits", value: xRangeString + ", " + yRangeString, associatedProfile: $0))
                    }
                    
                    if let zoomLimits = ptzConfiguration.zoomLimits {
                        let xRangeString = String(describing: zoomLimits.xRange)
                        tableRowData.append(RVS_ONVIF_Mac_Test_Harness_Profile_S_GroupedTableData(key: "PTZ Configuration Zoom Limits", value: xRangeString, associatedProfile: $0))
                    }
                }
                
                if let videoEncoderConfiguration = $0.videoEncoderConfiguration {
                    tableRowData.append(RVS_ONVIF_Mac_Test_Harness_Profile_S_GroupedTableData(key: "Video Encoder Configuration Name", value: videoEncoderConfiguration.name, associatedProfile: $0))
                    tableRowData.append(RVS_ONVIF_Mac_Test_Harness_Profile_S_GroupedTableData(key: "Video Encoder Configuration Token", value: videoEncoderConfiguration.token, associatedProfile: $0))
                    tableRowData.append(RVS_ONVIF_Mac_Test_Harness_Profile_S_GroupedTableData(key: "Video Encoder Configuration Encoding", value: videoEncoderConfiguration.encoding.rawValue, associatedProfile: $0))
                    tableRowData.append(RVS_ONVIF_Mac_Test_Harness_Profile_S_GroupedTableData(key: "Video Encoder Configuration Timeout", value: String(videoEncoderConfiguration.timeoutInSeconds) + " Seconds", associatedProfile: $0))
                    if let rateControl = videoEncoderConfiguration.rateControl {
                        if let frameRateLimit = rateControl.frameRateLimit {
                            tableRowData.append(RVS_ONVIF_Mac_Test_Harness_Profile_S_GroupedTableData(key: "Video Encoder Configuration Frame Rate Limit", value: String(frameRateLimit), associatedProfile: $0))
                        }
                        if let encodingInterval = rateControl.encodingInterval {
                            tableRowData.append(RVS_ONVIF_Mac_Test_Harness_Profile_S_GroupedTableData(key: "Video Encoder Configuration Frame Encoding Interval", value: String(encodingInterval), associatedProfile: $0))
                        }
                        if let bitRateLimit = rateControl.bitRateLimit {
                            tableRowData.append(RVS_ONVIF_Mac_Test_Harness_Profile_S_GroupedTableData(key: "Video Encoder Configuration Frame Bit Rate Limit", value: String(bitRateLimit), associatedProfile: $0))
                        }
                    }
                    
                    if let multicast = videoEncoderConfiguration.multicast {
                        if let ipAddress = multicast.ipAddress {
                            tableRowData.append(RVS_ONVIF_Mac_Test_Harness_Profile_S_GroupedTableData(key: "Video Encoder Configuration Multicast IP Address", value: ipAddress.address, associatedProfile: $0))
                        }
                        tableRowData.append(RVS_ONVIF_Mac_Test_Harness_Profile_S_GroupedTableData(key: "Video Encoder Configuration Multicast Autostart", value: multicast.autoStart ? "true" : "false", associatedProfile: $0))
                        tableRowData.append(RVS_ONVIF_Mac_Test_Harness_Profile_S_GroupedTableData(key: "Video Encoder Configuration Multicast TCP Port", value: String(multicast.port), associatedProfile: $0))
                        tableRowData.append(RVS_ONVIF_Mac_Test_Harness_Profile_S_GroupedTableData(key: "Video Encoder Configuration Multicast TTL", value: String( multicast.ttl.second ?? 0) + " Seconds", associatedProfile: $0))
                    }
                    
                    if let quality = videoEncoderConfiguration.quality {
                        tableRowData.append(RVS_ONVIF_Mac_Test_Harness_Profile_S_GroupedTableData(key: "Video Encoder Configuration Quality", value: String(quality), associatedProfile: $0))
                    }
                    
                    if let resolution = videoEncoderConfiguration.resolution {
                        tableRowData.append(RVS_ONVIF_Mac_Test_Harness_Profile_S_GroupedTableData(key: "Video Encoder Configuration Resolution", value: String(Int(resolution.width)) + " X " + String(Int(resolution.height)), associatedProfile: $0))
                    }
                    
                    if let encodingParameters = videoEncoderConfiguration.encodingParameters, !encodingParameters.isEmpty {
                        tableRowData.append(RVS_ONVIF_Mac_Test_Harness_Profile_S_GroupedTableData(key: "Video Encoder Configuration Encoding Parameters", value: String(describing: encodingParameters), associatedProfile: $0))
                    }
                }
                
                tableRowData.append(RVS_ONVIF_Mac_Test_Harness_Profile_S_GroupedTableData(key: "Fetch Video URI", value: "FETCH", associatedProfile: $0))
            }
        }
    }

    /* ################################################################## */
    /**
     */
    @IBOutlet weak var profileTable: NSTableView!
    
    /* ############################################################################################################################## */
    // MARK: - Control Callbacks -
    /* ############################################################################################################################## */
    /* ################################################################## */
    /**
     */
    @objc func handleUDPButtonPress(_ inButton: RVS_ONVIF_Mac_Test_Harness_ProfileButton) {
        inButton.associatedProfile.fetchURI(streamType: "RTP-Unicast", andProtocol: "UDP")
    }
    
    /* ################################################################## */
    /**
     */
    @objc func handleTCPButtonPress(_ inButton: RVS_ONVIF_Mac_Test_Harness_ProfileButton) {
        inButton.associatedProfile.fetchURI(streamType: "RTP-Unicast", andProtocol: "TCP")
    }
    
    /* ################################################################## */
    /**
     */
    override func viewWillAppear() {
        super.viewWillAppear()
        RVS_ONVIF_Mac_Test_Harness_AppDelegate.appDelegateObject.displayProfilesScreen = self
    }
    
    /* ################################################################## */
    /**
     */
    override func viewWillDisappear() {
        super.viewWillDisappear()
        RVS_ONVIF_Mac_Test_Harness_AppDelegate.appDelegateObject.displayProfilesScreen = nil
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
        return tableRowData[inRow].value.isEmpty
    }
    
    /* ################################################################## */
    /**
     */
    func tableView(_ inTableView: NSTableView, viewFor inTableColumn: NSTableColumn?, row inRow: Int) -> NSView? {
        let cell = NSTextView()
        cell.isEditable = false
        cell.drawsBackground = false
        cell.string = tableRowData[inRow].key
        if tableView(inTableView, isGroupRow: inRow) {
            cell.font = NSFont.boldSystemFont(ofSize: 20)
            cell.alignment = .center
        } else {
            if "VALUE" == inTableColumn?.title {
                if "Fetch Video URI" == tableRowData[inRow].key {
                    var ret: NSView!
                    let udpButton = RVS_ONVIF_Mac_Test_Harness_ProfileButton()
                    udpButton.associatedProfile = tableRowData[inRow].associatedProfile
                    udpButton.setButtonType(.momentaryPushIn)
                    udpButton.title = "FETCH URI (RTP UDP Unicast)"
                    udpButton.target = self
                    udpButton.action = #selector(handleUDPButtonPress)
                    if RVS_ONVIF_Mac_Test_Harness_AppDelegate.appDelegateObject.onvifInstance.capabilities.mediaCapabilities.isRTP_TCP {
                        ret = NSView()
                        let tcpButton = RVS_ONVIF_Mac_Test_Harness_ProfileButton()
                        tcpButton.associatedProfile = tableRowData[inRow].associatedProfile
                        tcpButton.setButtonType(.momentaryPushIn)
                        tcpButton.target = self
                        tcpButton.title = "FETCH URI (RTP TCP Unicast)"
                        tcpButton.action = #selector(handleTCPButtonPress)
                        ret.addSubview(udpButton)
                        ret.addSubview(tcpButton)
                        
                        udpButton.translatesAutoresizingMaskIntoConstraints = false
                        udpButton.topAnchor.constraint(equalTo: ret.topAnchor, constant: 0).isActive = true
                        udpButton.bottomAnchor.constraint(equalTo: ret.bottomAnchor, constant: 0).isActive = true
                        udpButton.leadingAnchor.constraint(equalTo: ret.leadingAnchor, constant: 0).isActive = true
                        udpButton.trailingAnchor.constraint(equalTo: tcpButton.leadingAnchor, constant: 0).isActive = true
                        udpButton.widthAnchor.constraint(equalTo: tcpButton.widthAnchor, constant: 0).isActive = true

                        tcpButton.translatesAutoresizingMaskIntoConstraints = false
                        tcpButton.topAnchor.constraint(equalTo: ret.topAnchor, constant: 0).isActive = true
                        tcpButton.bottomAnchor.constraint(equalTo: ret.bottomAnchor, constant: 0).isActive = true
                        tcpButton.trailingAnchor.constraint(equalTo: ret.trailingAnchor, constant: 0).isActive = true
                        tcpButton.widthAnchor.constraint(equalTo: udpButton.widthAnchor, constant: 0.5).isActive = true
                    } else {
                        ret = udpButton
                    }
                    
                    return ret
                } else {
                    cell.string = tableRowData[inRow].value
                }
            }
        }
        
        return cell
    }
}
