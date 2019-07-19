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
// MARK: - Main TableView Controller Class for the Device Capabilities List Screen
/* ################################################################################################################################## */
class RVS_ONVIF_iOS_Test_Harness_DeviceCapabilities_TableViewController: RVS_ONVIF_iOS_Test_Harness_ONVIF_TableViewController {
    /* ############################################################################################################################## */
    // MARK: - Internal Instance Properties
    /* ############################################################################################################################## */
    /* ################################################################## */
    /**
     */
    var capabilityKeyArray: [String] = ["Analytics", "AnalyticsDevice", "Device", "DeviceIO", "Display", "Events", "Imaging", "Media", "PTZ", "Receiver", "Recording", "Replay", "Search"]

    /* ############################################################################################################################## */
    // MARK: - Private Instance Properties
    /* ############################################################################################################################## */
    /* ################################################################## */
    /**
     */
    private var _capabilitiesDictionary: [String: [(key: String, value: Any?)]] = [:]

    /* ############################################################################################################################## */
    // MARK: - Internal Instance Superclass Override Methods
    /* ############################################################################################################################## */
    /* ################################################################## */
    /**
     */
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpArray()
        tableView.reloadData()
    }

    /* ################################################################## */
    /**
     */
    internal func setUpAnalyticsArray() {
        guard nil != onvifInstance?.capabilities.analyticsCapabilities else { return }
        _capabilitiesDictionary["Analytics"] = []
        _capabilitiesDictionary["Analytics"]?.append((key: "XAddr", value: onvifInstance?.capabilities.analyticsCapabilities.xAddr))
        _capabilitiesDictionary["Analytics"]?.append((key: "RuleSupport", value: onvifInstance?.capabilities.analyticsCapabilities.isRuleSupport))
        _capabilitiesDictionary["Analytics"]?.append((key: "AnalyticsModuleSupport", value: onvifInstance?.capabilities.analyticsCapabilities.isAnalyticsModuleSupport))
    }
    
    /* ################################################################## */
    /**
     */
    internal func setUpAnalyticsDeviceArray() {
        guard nil != onvifInstance?.capabilities.analyticsDeviceCapabilities else { return }
        _capabilitiesDictionary["AnalyticsDevice"] = []
        _capabilitiesDictionary["AnalyticsDevice"]?.append((key: "XAddr", value: onvifInstance?.capabilities.analyticsDeviceCapabilities.xAddr))
    }
    
    /* ################################################################## */
    /**
     */
    internal func setUpDeviceArray() {
        guard nil != onvifInstance?.capabilities.deviceCapabilities else { return }
        _capabilitiesDictionary["Device"] = []
        _capabilitiesDictionary["Device"]?.append((key: "XAddr", value: onvifInstance?.capabilities.deviceCapabilities.xAddr))
        
        var networkArray: [(key: String, value: Any?)] = []
        
        networkArray.append((key: "IPFilter", value: onvifInstance?.capabilities.deviceCapabilities.networkCapabilities.isIPFilter))
        networkArray.append((key: "ZeroConfiguration", value: onvifInstance?.capabilities.deviceCapabilities.networkCapabilities.isZeroConfiguration))
        networkArray.append((key: "IPVersion6", value: onvifInstance?.capabilities.deviceCapabilities.networkCapabilities.isIPVersion6))
        networkArray.append((key: "DynDNS", value: onvifInstance?.capabilities.deviceCapabilities.networkCapabilities.isDynDNS))
        networkArray.append((key: "Dot11Configuration", value: onvifInstance?.capabilities.deviceCapabilities.networkCapabilities.isDot11Configuration))
        
        _capabilitiesDictionary["Device"]?.append((key: "Network", value: networkArray))
        
        var systemArray: [(key: String, value: Any?)] = []
        
        systemArray.append((key: "DiscoveryResolve", value: onvifInstance?.capabilities.deviceCapabilities.systemCapabilities.isDiscoveryResolve))
        systemArray.append((key: "DiscoveryBye", value: onvifInstance?.capabilities.deviceCapabilities.systemCapabilities.isDiscoveryBye))
        systemArray.append((key: "RemoteDiscovery", value: onvifInstance?.capabilities.deviceCapabilities.systemCapabilities.isRemoteDiscovery))
        systemArray.append((key: "SystemBackup", value: onvifInstance?.capabilities.deviceCapabilities.systemCapabilities.isSystemBackup))
        systemArray.append((key: "SystemLogging", value: onvifInstance?.capabilities.deviceCapabilities.systemCapabilities.isSystemLogging))
        systemArray.append((key: "FirmwareUpgrade", value: onvifInstance?.capabilities.deviceCapabilities.systemCapabilities.isFirmwareUpgrade))
        systemArray.append((key: "HttpFirmwareUpgrade", value: onvifInstance?.capabilities.deviceCapabilities.systemCapabilities.isHttpFirmwareUpgrade))
        systemArray.append((key: "HttpSystemBackup", value: onvifInstance?.capabilities.deviceCapabilities.systemCapabilities.isHttpSystemBackup))
        systemArray.append((key: "HttpSystemLogging", value: onvifInstance?.capabilities.deviceCapabilities.systemCapabilities.isHttpSystemLogging))
        systemArray.append((key: "HttpSupportInformation", value: onvifInstance?.capabilities.deviceCapabilities.systemCapabilities.isHttpSupportInformation))
        
        _capabilitiesDictionary["Device"]?.append((key: "System", value: systemArray))
        
        var securityArray: [(key: String, value: Any?)] = []
        
        securityArray.append((key: "TLS1.0", value: onvifInstance?.capabilities.deviceCapabilities.securityCapabilities.isTLS10))
        securityArray.append((key: "TLS1.1", value: onvifInstance?.capabilities.deviceCapabilities.securityCapabilities.isTLS11))
        securityArray.append((key: "TLS1.2", value: onvifInstance?.capabilities.deviceCapabilities.securityCapabilities.isTLS12))
        securityArray.append((key: "OnboardKeyGeneration", value: onvifInstance?.capabilities.deviceCapabilities.securityCapabilities.isOnboardKeyGeneration))
        securityArray.append((key: "AccessPolicyConfig", value: onvifInstance?.capabilities.deviceCapabilities.securityCapabilities.isAccessPolicyConfig))
        securityArray.append((key: "DefaultAccessPolicy", value: onvifInstance?.capabilities.deviceCapabilities.securityCapabilities.isDefaultAccessPolicy))
        securityArray.append((key: "Dot1X", value: onvifInstance?.capabilities.deviceCapabilities.securityCapabilities.isDot1X))
        securityArray.append((key: "RemoteUserHandling", value: onvifInstance?.capabilities.deviceCapabilities.securityCapabilities.isRemoteUserHandling))

        _capabilitiesDictionary["Device"]?.append((key: "Security", value: securityArray))
        
        var ioArray: [(key: String, value: Any?)] = []
        
        ioArray.append((key: "InputConnectors", value: onvifInstance?.capabilities.deviceCapabilities.ioCapabilities.inputConnectors))
        ioArray.append((key: "RelayOutputs", value: onvifInstance?.capabilities.deviceCapabilities.ioCapabilities.relayOutputs))
        ioArray.append((key: "Auxiliary", value: onvifInstance?.capabilities.deviceCapabilities.ioCapabilities.auxiliary))

        _capabilitiesDictionary["Device"]?.append((key: "I/O", value: ioArray))
    }
    
    /* ################################################################## */
    /**
     */
    internal func setUpDeviceIOArray() {
        guard nil != onvifInstance?.capabilities.deviceIOCapabilities else { return }
        _capabilitiesDictionary["DeviceIO"] = []
        _capabilitiesDictionary["DeviceIO"]?.append((key: "XAddr", value: onvifInstance?.capabilities.deviceIOCapabilities.xAddr))
        _capabilitiesDictionary["DeviceIO"]?.append((key: "VideoSources", value: onvifInstance?.capabilities.deviceIOCapabilities.videoSources))
        _capabilitiesDictionary["DeviceIO"]?.append((key: "VideoOutputs", value: onvifInstance?.capabilities.deviceIOCapabilities.videoOutputs))
        _capabilitiesDictionary["DeviceIO"]?.append((key: "AudioSources", value: onvifInstance?.capabilities.deviceIOCapabilities.audioSources))
        _capabilitiesDictionary["DeviceIO"]?.append((key: "AudioOutputs", value: onvifInstance?.capabilities.deviceIOCapabilities.audioOutputs))
        _capabilitiesDictionary["DeviceIO"]?.append((key: "RelayOutputs", value: onvifInstance?.capabilities.deviceIOCapabilities.relayOutputs))
    }
    
    /* ################################################################## */
    /**
     */
    internal func setUpDisplayArray() {
        guard nil != onvifInstance?.capabilities.displayCapabilities else { return }
        _capabilitiesDictionary["Display"] = []
        _capabilitiesDictionary["Display"]?.append((key: "XAddr", value: onvifInstance?.capabilities.displayCapabilities.xAddr))
        _capabilitiesDictionary["Display"]?.append((key: "FixedLayout", value: onvifInstance?.capabilities.displayCapabilities.isFixedLayout))
    }
    
    /* ################################################################## */
    /**
     */
    internal func setUpEventsArray() {
        guard nil != onvifInstance?.capabilities.eventsCapabilities else { return }
        _capabilitiesDictionary["Events"] = []
        _capabilitiesDictionary["Events"]?.append((key: "XAddr", value: onvifInstance?.capabilities.eventsCapabilities.xAddr))
        _capabilitiesDictionary["Events"]?.append((key: "WSSubscriptionPolicySupport", value: onvifInstance?.capabilities.eventsCapabilities.isWSSubscriptionPolicySupport))
        _capabilitiesDictionary["Events"]?.append((key: "WSPullPointSupport", value: onvifInstance?.capabilities.eventsCapabilities.isWSPullPointSupport))
        _capabilitiesDictionary["Events"]?.append((key: "WSPausableSubscriptionManagerInterfaceSupport", value: onvifInstance?.capabilities.eventsCapabilities.isWSPausableSubscriptionManagerInterfaceSupport))
    }
    
    /* ################################################################## */
    /**
     */
    internal func setUpImagingArray() {
        guard nil != onvifInstance?.capabilities.imagingCapabilities else { return }
        _capabilitiesDictionary["Imaging"] = []
        _capabilitiesDictionary["Imaging"]?.append((key: "XAddr", value: onvifInstance?.capabilities.imagingCapabilities.xAddr))
    }
    
    /* ################################################################## */
    /**
     */
    internal func setUpMediaArray() {
        guard nil != onvifInstance?.capabilities.mediaCapabilities else { return }
        _capabilitiesDictionary["Media"] = []
        _capabilitiesDictionary["Media"]?.append((key: "XAddr", value: onvifInstance?.capabilities.mediaCapabilities.xAddr))
        _capabilitiesDictionary["Media"]?.append((key: "RTPMulticast", value: onvifInstance?.capabilities.mediaCapabilities.isRTPMulticast))
        _capabilitiesDictionary["Media"]?.append((key: "RTP_TCP", value: onvifInstance?.capabilities.mediaCapabilities.isRTP_TCP))
        _capabilitiesDictionary["Media"]?.append((key: "RTP_RTSP_TCP", value: onvifInstance?.capabilities.mediaCapabilities.isRTP_RTSP_TCP))
        _capabilitiesDictionary["Media"]?.append((key: "MaximumNumberOfProfiles", value: onvifInstance?.capabilities.mediaCapabilities.maximumNumberOfProfiles))
    }
    
    /* ################################################################## */
    /**
     */
    internal func setUpPTZArray() {
        guard nil != onvifInstance?.capabilities.ptzCapabilities else { return }
        _capabilitiesDictionary["PTZ"] = []
        _capabilitiesDictionary["PTZ"]?.append((key: "XAddr", value: onvifInstance?.capabilities.ptzCapabilities.xAddr))
    }
    
    /* ################################################################## */
    /**
     */
    internal func setUpReceiverArray() {
        guard nil != onvifInstance?.capabilities.receiverCapabilities else { return }
        _capabilitiesDictionary["Receiver"] = []
        _capabilitiesDictionary["Receiver"]?.append((key: "XAddr", value: onvifInstance?.capabilities.receiverCapabilities.xAddr))
        _capabilitiesDictionary["Receiver"]?.append((key: "RTP_Multicast", value: onvifInstance?.capabilities.receiverCapabilities.isRTP_Multicast))
        _capabilitiesDictionary["Receiver"]?.append((key: "RTP_TCP", value: onvifInstance?.capabilities.receiverCapabilities.isRTP_TCP))
        _capabilitiesDictionary["Receiver"]?.append((key: "RTP_RTSP_TCP", value: onvifInstance?.capabilities.receiverCapabilities.isRTP_RTSP_TCP))
        _capabilitiesDictionary["Receiver"]?.append((key: "SupportedReceivers", value: onvifInstance?.capabilities.receiverCapabilities.supportedReceivers))
        _capabilitiesDictionary["Receiver"]?.append((key: "MaximumRTSPURILength", value: onvifInstance?.capabilities.receiverCapabilities.maximumRTSPURILength))
    }
    
    /* ################################################################## */
    /**
     */
    internal func setUpRecordingArray() {
        guard nil != onvifInstance?.capabilities.recordingCapabilities else { return }
        _capabilitiesDictionary["Recording"] = []
        _capabilitiesDictionary["Recording"]?.append((key: "XAddr", value: onvifInstance?.capabilities.recordingCapabilities.xAddr))
        _capabilitiesDictionary["Recording"]?.append((key: "DynamicRecordings", value: onvifInstance?.capabilities.recordingCapabilities.isDynamicRecordings))
        _capabilitiesDictionary["Recording"]?.append((key: "DynamicTracks", value: onvifInstance?.capabilities.recordingCapabilities.isDynamicTracks))
        _capabilitiesDictionary["Recording"]?.append((key: "DeleteData", value: onvifInstance?.capabilities.recordingCapabilities.isDeleteData))
    }
    
    /* ################################################################## */
    /**
     */
    internal func setUpReplayArray() {
        guard nil != onvifInstance?.capabilities.replayCapabilities else { return }
        _capabilitiesDictionary["Replay"] = []
        _capabilitiesDictionary["Replay"]?.append((key: "XAddr", value: onvifInstance?.capabilities.replayCapabilities.xAddr))
    }
    
    /* ################################################################## */
    /**
     */
    internal func setUpSearchArray() {
        guard nil != onvifInstance?.capabilities.searchCapabilities else { return }
        _capabilitiesDictionary["Search"] = []
        _capabilitiesDictionary["Search"]?.append((key: "XAddr", value: onvifInstance?.capabilities.searchCapabilities.xAddr))
        _capabilitiesDictionary["Search"]?.append((key: "MetadataSearch", value: onvifInstance?.capabilities.searchCapabilities.isMetadataSearch))
    }

    /* ################################################################## */
    /**
     */
    internal func setUpArray() {
        setUpAnalyticsArray()
        setUpAnalyticsDeviceArray()
        setUpDeviceArray()
        setUpDeviceIOArray()
        setUpDisplayArray()
        setUpEventsArray()
        setUpImagingArray()
        setUpMediaArray()
        setUpPTZArray()
        setUpReceiverArray()
        setUpRecordingArray()
        setUpReplayArray()
        setUpSearchArray()
    }
    
    /* ############################################################################################################################## */
    // MARK: - Internal Instance Override UITableViewDataSource Methods
    /* ############################################################################################################################## */
    /* ################################################################## */
    /**
     */
    override func numberOfSections(in tableView: UITableView) -> Int {
        return capabilityKeyArray.count
    }
    
    /* ################################################################## */
    /**
     */
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return capabilityKeyArray[section] + ((0 == self.tableView(tableView, numberOfRowsInSection: section)) ? " (Not Supported)" : "")
    }
    
    /* ################################################################## */
    /**
     */
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return _capabilitiesDictionary[capabilityKeyArray[section]]?.count ?? 0
    }
    
    /* ################################################################## */
    /**
     */
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "service-capability-cell", for: indexPath)
        if let item = _capabilitiesDictionary[capabilityKeyArray[indexPath.section]] {
            var text = item[indexPath.row].key + ":"
            cell.textLabel?.numberOfLines = 1
            if let value = item[indexPath.row].value {
                if let booleanValue = value as? Bool {
                    text += booleanValue ? " true" : " false"
                } else if let intValue = value as? Int {
                    text += " " + String(intValue)
                } else if let stringValue = value as? String {
                    cell.textLabel?.numberOfLines = 2
                    text += "\n\t" + stringValue
                } else if let urlValue = value as? URL {
                    cell.textLabel?.numberOfLines = 2
                    text += "\n\t" + urlValue.absoluteString
                } else if let internalDictionary = value as? [(key: String, value: Any?)] {
                    cell.textLabel?.numberOfLines = (cell.textLabel?.numberOfLines ?? 1) + internalDictionary.count

                    for item2 in internalDictionary {
                        text += "\n\t" + item2.key + ":"
                        if let booleanValue = item2.value as? Bool {
                            text += booleanValue ? " true" : " false"
                        } else if let intValue = item2.value as? Int {
                            text += " " + String(intValue)
                        } else if let stringValue = item2.value as? String {
                            cell.textLabel?.numberOfLines = (cell.textLabel?.numberOfLines ?? 1) + 1
                            text += "\n\t\t" + stringValue
                        } else if let urlValue = item2.value as? URL {
                            cell.textLabel?.numberOfLines = (cell.textLabel?.numberOfLines ?? 1) + 1
                            text += "\n\t\t" + urlValue.absoluteString
                        } else if nil == item2.value {
                            text += " NOT INDICATED"
                        } else {
                            text += " UNKNOWN"
                        }
                    }
                } else {
                    text += " UNKNOWN"
                }
            } else {
                text += " NOT INDICATED"
            }
            cell.textLabel?.adjustsFontSizeToFitWidth = true
            cell.textLabel?.minimumScaleFactor = 0.1
            cell.textLabel?.text = text
        }
        return cell
    }
}
