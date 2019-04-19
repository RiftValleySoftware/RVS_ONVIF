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
// MARK: - Main Logged-In Capabilities Screen View Controller
/* ################################################################################################################################## */
class RVS_ONVIF_Mac_Test_Harness_Capabilities_ViewController: RVS_ONVIF_Mac_Test_Harness_Base_ViewController, NSTableViewDataSource, NSTableViewDelegate {
    @IBOutlet weak var displayTableView: NSTableView!
    
    typealias RVS_ONVIF_Mac_Test_Harness_GroupedTableData = (key: String, value: String)
    
    var tableRowData: [RVS_ONVIF_Mac_Test_Harness_GroupedTableData] = []
    
    override var loginViewController: RVS_ONVIF_Mac_Test_Harness_LoginScreen_ViewController! {
        get {
            return super.loginViewController
        }
        
        set {
            super.loginViewController = newValue
            
            if let capabilities = RVS_ONVIF_Mac_Test_Harness_AppDelegate.appDelegateObject.onvifInstance?.capabilities {
                if let analyticsCapabilities = capabilities.analyticsCapabilities {
                    tableRowData.append(RVS_ONVIF_Mac_Test_Harness_GroupedTableData(key: "ANALYTICS", value: ""))
                    if let xAddr = analyticsCapabilities.xAddr {
                        tableRowData.append(RVS_ONVIF_Mac_Test_Harness_GroupedTableData(key: "xAddr", value: xAddr.absoluteString))
                    }
                }
                
                if let analyticsDeviceCapabilities = capabilities.analyticsDeviceCapabilities {
                    tableRowData.append(RVS_ONVIF_Mac_Test_Harness_GroupedTableData(key: "ANALYTICS DEVICE", value: ""))
                    if let xAddr = analyticsDeviceCapabilities.xAddr {
                        tableRowData.append(RVS_ONVIF_Mac_Test_Harness_GroupedTableData(key: "xAddr", value: xAddr.absoluteString))
                    }
                }
                
                if let deviceCapabilities = capabilities.deviceCapabilities {
                    tableRowData.append(RVS_ONVIF_Mac_Test_Harness_GroupedTableData(key: "DEVICE", value: ""))
                    if let xAddr = deviceCapabilities.xAddr {
                        tableRowData.append(RVS_ONVIF_Mac_Test_Harness_GroupedTableData(key: "xAddr", value: xAddr.absoluteString))
                    }
                    
                    if let networkCapabilities = deviceCapabilities.networkCapabilities {
                        tableRowData.append(RVS_ONVIF_Mac_Test_Harness_GroupedTableData(key: "DEVICE: Network", value: ""))
                        tableRowData.append(RVS_ONVIF_Mac_Test_Harness_GroupedTableData(key: "IP Filter", value: networkCapabilities.isIPFilter ? "TRUE" : "FALSE"))
                        tableRowData.append(RVS_ONVIF_Mac_Test_Harness_GroupedTableData(key: "Zero Config", value: networkCapabilities.isZeroConfiguration ? "TRUE" : "FALSE"))
                        tableRowData.append(RVS_ONVIF_Mac_Test_Harness_GroupedTableData(key: "IPv6", value: networkCapabilities.isIPVersion6 ? "TRUE" : "FALSE"))
                        tableRowData.append(RVS_ONVIF_Mac_Test_Harness_GroupedTableData(key: "DynDNS", value: networkCapabilities.isDynDNS ? "TRUE" : "FALSE"))
                        tableRowData.append(RVS_ONVIF_Mac_Test_Harness_GroupedTableData(key: "Dot11Config", value: networkCapabilities.isDot11Configuration ? "TRUE" : "FALSE"))
                        if let dot1XConfiguration = networkCapabilities.dot1XConfiguration {
                            tableRowData.append(RVS_ONVIF_Mac_Test_Harness_GroupedTableData(key: "Dot1XConfig", value: String(dot1XConfiguration)))
                        }
                        tableRowData.append(RVS_ONVIF_Mac_Test_Harness_GroupedTableData(key: "Hostname From DHCP", value: networkCapabilities.isHostnameFromDHCP ? "TRUE" : "FALSE"))
                        tableRowData.append(RVS_ONVIF_Mac_Test_Harness_GroupedTableData(key: "IPv6 DHCP", value: networkCapabilities.isDHCPv6 ? "TRUE" : "FALSE"))
                        if let ntp = networkCapabilities.ntp {
                            tableRowData.append(RVS_ONVIF_Mac_Test_Harness_GroupedTableData(key: "NTP Servers", value: String(ntp)))
                        }
                    }
                    
                    if let systemCapabilities = deviceCapabilities.systemCapabilities {
                        tableRowData.append(RVS_ONVIF_Mac_Test_Harness_GroupedTableData(key: "DEVICE: System", value: ""))
                        tableRowData.append(RVS_ONVIF_Mac_Test_Harness_GroupedTableData(key: "Discovery Resolve", value: systemCapabilities.isDiscoveryResolve ? "TRUE" : "FALSE"))
                        tableRowData.append(RVS_ONVIF_Mac_Test_Harness_GroupedTableData(key: "Discovery Bye", value: systemCapabilities.isDiscoveryBye ? "TRUE" : "FALSE"))
                        tableRowData.append(RVS_ONVIF_Mac_Test_Harness_GroupedTableData(key: "Remote Discovery", value: systemCapabilities.isRemoteDiscovery ? "TRUE" : "FALSE"))
                        tableRowData.append(RVS_ONVIF_Mac_Test_Harness_GroupedTableData(key: "System Backup", value: systemCapabilities.isSystemBackup ? "TRUE" : "FALSE"))
                        tableRowData.append(RVS_ONVIF_Mac_Test_Harness_GroupedTableData(key: "System Logging", value: systemCapabilities.isSystemLogging ? "TRUE" : "FALSE"))
                        tableRowData.append(RVS_ONVIF_Mac_Test_Harness_GroupedTableData(key: "Firmware Upgrade", value: systemCapabilities.isFirmwareUpgrade ? "TRUE" : "FALSE"))
                        tableRowData.append(RVS_ONVIF_Mac_Test_Harness_GroupedTableData(key: "HTTP Firmware Upgrade", value: systemCapabilities.isHttpFirmwareUpgrade ? "TRUE" : "FALSE"))
                        tableRowData.append(RVS_ONVIF_Mac_Test_Harness_GroupedTableData(key: "HTTP System Backup", value: systemCapabilities.isHttpSystemBackup ? "TRUE" : "FALSE"))
                        tableRowData.append(RVS_ONVIF_Mac_Test_Harness_GroupedTableData(key: "HTTP System Logging", value: systemCapabilities.isHttpSystemLogging ? "TRUE" : "FALSE"))
                        tableRowData.append(RVS_ONVIF_Mac_Test_Harness_GroupedTableData(key: "HTTP Support Information", value: systemCapabilities.isHttpSupportInformation ? "TRUE" : "FALSE"))
                        tableRowData.append(RVS_ONVIF_Mac_Test_Harness_GroupedTableData(key: "Storage Configuration", value: systemCapabilities.isStorageConfiguration ? "TRUE" : "FALSE"))
                        if let maxStorageConfigurations = systemCapabilities.maxStorageConfigurations {
                            tableRowData.append(RVS_ONVIF_Mac_Test_Harness_GroupedTableData(key: "Max Storage Config", value: String(maxStorageConfigurations)))
                        }
                        if let geoLocationEntries = systemCapabilities.geoLocationEntries {
                            tableRowData.append(RVS_ONVIF_Mac_Test_Harness_GroupedTableData(key: "Geolocation Entries", value: String(geoLocationEntries)))
                        }
                        if let autoGeo = systemCapabilities.autoGeo {
                            autoGeo.forEach {
                                tableRowData.append(RVS_ONVIF_Mac_Test_Harness_GroupedTableData(key: "Auto Geo Mode", value: String($0)))
                            }
                        }
                        if let storageTypesSupported = systemCapabilities.storageTypesSupported {
                            storageTypesSupported.forEach {
                                tableRowData.append(RVS_ONVIF_Mac_Test_Harness_GroupedTableData(key: "Supported Storage Type", value: String($0)))
                            }
                        }
                    }
                    
                    if let ioCapabilities = deviceCapabilities.ioCapabilities {
                        tableRowData.append(RVS_ONVIF_Mac_Test_Harness_GroupedTableData(key: "DEVICE: Device I/O", value: ""))
                        if let inputConnectors = ioCapabilities.inputConnectors {
                            tableRowData.append(RVS_ONVIF_Mac_Test_Harness_GroupedTableData(key: "Input Connectors", value: String(inputConnectors)))
                        }
                        if let relayOutputs = ioCapabilities.relayOutputs {
                            tableRowData.append(RVS_ONVIF_Mac_Test_Harness_GroupedTableData(key: "Relay Outputs", value: String(relayOutputs)))
                        }
                        if let auxiliary = ioCapabilities.auxiliary {
                            tableRowData.append(RVS_ONVIF_Mac_Test_Harness_GroupedTableData(key: "Auxiliary", value: auxiliary))
                        }
                    }
                    
                    if let securityCapabilities = deviceCapabilities.securityCapabilities {
                        tableRowData.append(RVS_ONVIF_Mac_Test_Harness_GroupedTableData(key: "DEVICE: Security", value: ""))
                        tableRowData.append(RVS_ONVIF_Mac_Test_Harness_GroupedTableData(key: "TLS 1.0", value: securityCapabilities.isTLS10 ? "TRUE" : "FALSE"))
                        tableRowData.append(RVS_ONVIF_Mac_Test_Harness_GroupedTableData(key: "TLS 1.1", value: securityCapabilities.isTLS11 ? "TRUE" : "FALSE"))
                        tableRowData.append(RVS_ONVIF_Mac_Test_Harness_GroupedTableData(key: "TLS 1.2", value: securityCapabilities.isTLS12 ? "TRUE" : "FALSE"))
                        tableRowData.append(RVS_ONVIF_Mac_Test_Harness_GroupedTableData(key: "Onboard Keygen", value: securityCapabilities.isOnboardKeyGeneration ? "TRUE" : "FALSE"))
                        tableRowData.append(RVS_ONVIF_Mac_Test_Harness_GroupedTableData(key: "Access Policy Config", value: securityCapabilities.isAccessPolicyConfig ? "TRUE" : "FALSE"))
                        tableRowData.append(RVS_ONVIF_Mac_Test_Harness_GroupedTableData(key: "Default Access Policy", value: securityCapabilities.isDefaultAccessPolicy ? "TRUE" : "FALSE"))
                        tableRowData.append(RVS_ONVIF_Mac_Test_Harness_GroupedTableData(key: "Dot 1X", value: securityCapabilities.isDot1X ? "TRUE" : "FALSE"))
                        tableRowData.append(RVS_ONVIF_Mac_Test_Harness_GroupedTableData(key: "Remote User Handling", value: securityCapabilities.isRemoteUserHandling ? "TRUE" : "FALSE"))
                        tableRowData.append(RVS_ONVIF_Mac_Test_Harness_GroupedTableData(key: "X509 Token", value: securityCapabilities.isX509Token ? "TRUE" : "FALSE"))
                        tableRowData.append(RVS_ONVIF_Mac_Test_Harness_GroupedTableData(key: "SAML Token", value: securityCapabilities.isSAMLToken ? "TRUE" : "FALSE"))
                        tableRowData.append(RVS_ONVIF_Mac_Test_Harness_GroupedTableData(key: "Kerberos Token", value: securityCapabilities.isKerberosToken ? "TRUE" : "FALSE"))
                        tableRowData.append(RVS_ONVIF_Mac_Test_Harness_GroupedTableData(key: "Username Token", value: securityCapabilities.isUsernameToken ? "TRUE" : "FALSE"))
                        tableRowData.append(RVS_ONVIF_Mac_Test_Harness_GroupedTableData(key: "HTTP Digest", value: securityCapabilities.isHttpDigest ? "TRUE" : "FALSE"))
                        tableRowData.append(RVS_ONVIF_Mac_Test_Harness_GroupedTableData(key: "REL Token", value: securityCapabilities.isRELToken ? "TRUE" : "FALSE"))
                        if let supportedEAPMethods = securityCapabilities.supportedEAPMethods {
                            supportedEAPMethods.forEach {
                                tableRowData.append(RVS_ONVIF_Mac_Test_Harness_GroupedTableData(key: "Supported EAP Method", value: String($0)))
                            }
                        }
                        if let maxUsers = securityCapabilities.maxUsers {
                            tableRowData.append(RVS_ONVIF_Mac_Test_Harness_GroupedTableData(key: "Max Users", value: String(maxUsers)))
                        }
                        if let maxUserNameLength = securityCapabilities.maxUserNameLength {
                            tableRowData.append(RVS_ONVIF_Mac_Test_Harness_GroupedTableData(key: "Max Username Length", value: String(maxUserNameLength)))
                        }
                        if let maxPasswordLength = securityCapabilities.maxPasswordLength {
                            tableRowData.append(RVS_ONVIF_Mac_Test_Harness_GroupedTableData(key: "Max Password Length", value: String(maxPasswordLength)))
                        }
                   }
               }

                if let ioCapabilities = capabilities.deviceIOCapabilities {
                    tableRowData.append(RVS_ONVIF_Mac_Test_Harness_GroupedTableData(key: "DEVICE INPUT/OUTPUT", value: ""))
                    if let xAddr = ioCapabilities.xAddr {
                        tableRowData.append(RVS_ONVIF_Mac_Test_Harness_GroupedTableData(key: "xAddr", value: xAddr.absoluteString))
                    }
                    if let videoSources = ioCapabilities.videoSources {
                        tableRowData.append(RVS_ONVIF_Mac_Test_Harness_GroupedTableData(key: "Video Sources", value: String(videoSources)))
                    }
                    if let videoOutputs = ioCapabilities.videoOutputs {
                        tableRowData.append(RVS_ONVIF_Mac_Test_Harness_GroupedTableData(key: "Video Outputs", value: String(videoOutputs)))
                    }
                    if let audioSources = ioCapabilities.audioSources {
                        tableRowData.append(RVS_ONVIF_Mac_Test_Harness_GroupedTableData(key: "Audio Sources", value: String(audioSources)))
                    }
                    if let audioOutputs = ioCapabilities.audioOutputs {
                        tableRowData.append(RVS_ONVIF_Mac_Test_Harness_GroupedTableData(key: "Audio Outputs", value: String(audioOutputs)))
                    }
                    if let relayOutputs = ioCapabilities.relayOutputs {
                        tableRowData.append(RVS_ONVIF_Mac_Test_Harness_GroupedTableData(key: "Relay Outputs", value: String(relayOutputs)))
                    }
                }

                if let displayCapabilities = capabilities.displayCapabilities {
                    tableRowData.append(RVS_ONVIF_Mac_Test_Harness_GroupedTableData(key: "DISPLAY", value: ""))
                    if let xAddr = displayCapabilities.xAddr {
                        tableRowData.append(RVS_ONVIF_Mac_Test_Harness_GroupedTableData(key: "xAddr", value: xAddr.absoluteString))
                    }
                    tableRowData.append(RVS_ONVIF_Mac_Test_Harness_GroupedTableData(key: "Fixed Layout", value: displayCapabilities.isFixedLayout ? "TRUE" : "FALSE"))
                }

                if let eventsCapabilities = capabilities.eventsCapabilities {
                    tableRowData.append(RVS_ONVIF_Mac_Test_Harness_GroupedTableData(key: "EVENTS", value: ""))
                    if let xAddr = eventsCapabilities.xAddr {
                        tableRowData.append(RVS_ONVIF_Mac_Test_Harness_GroupedTableData(key: "xAddr", value: xAddr.absoluteString))
                    }
                    tableRowData.append(RVS_ONVIF_Mac_Test_Harness_GroupedTableData(key: "Subscription Policy Support", value: eventsCapabilities.isWSSubscriptionPolicySupport ? "TRUE" : "FALSE"))
                    tableRowData.append(RVS_ONVIF_Mac_Test_Harness_GroupedTableData(key: "WS Pull Point Support", value: eventsCapabilities.isWSPullPointSupport ? "TRUE" : "FALSE"))
                    tableRowData.append(RVS_ONVIF_Mac_Test_Harness_GroupedTableData(key: "Pausable Subscription Support", value: eventsCapabilities.isWSPausableSubscriptionManagerInterfaceSupport ? "TRUE" : "FALSE"))
                }

                if let imagingCapabilities = capabilities.imagingCapabilities {
                    tableRowData.append(RVS_ONVIF_Mac_Test_Harness_GroupedTableData(key: "IMAGING", value: ""))
                    if let xAddr = imagingCapabilities.xAddr {
                        tableRowData.append(RVS_ONVIF_Mac_Test_Harness_GroupedTableData(key: "xAddr", value: xAddr.absoluteString))
                    }
                }

                if let mediaCapabilities = capabilities.mediaCapabilities {
                    tableRowData.append(RVS_ONVIF_Mac_Test_Harness_GroupedTableData(key: "MEDIA", value: ""))
                    if let xAddr = mediaCapabilities.xAddr {
                        tableRowData.append(RVS_ONVIF_Mac_Test_Harness_GroupedTableData(key: "xAddr", value: xAddr.absoluteString))
                    }
                    tableRowData.append(RVS_ONVIF_Mac_Test_Harness_GroupedTableData(key: "RTP Multicast", value: mediaCapabilities.isRTPMulticast ? "TRUE" : "FALSE"))
                    tableRowData.append(RVS_ONVIF_Mac_Test_Harness_GroupedTableData(key: "RTP TCP", value: mediaCapabilities.isRTP_TCP ? "TRUE" : "FALSE"))
                    tableRowData.append(RVS_ONVIF_Mac_Test_Harness_GroupedTableData(key: "RTSP TCP", value: mediaCapabilities.isRTP_RTSP_TCP ? "TRUE" : "FALSE"))
                    if let maximumNumberOfProfiles = mediaCapabilities.maximumNumberOfProfiles {
                        tableRowData.append(RVS_ONVIF_Mac_Test_Harness_GroupedTableData(key: "Max Profiles", value: String(maximumNumberOfProfiles)))
                    }
                }

                if let ptzCapabilities = capabilities.ptzCapabilities {
                    tableRowData.append(RVS_ONVIF_Mac_Test_Harness_GroupedTableData(key: "PTZ", value: ""))
                    if let xAddr = ptzCapabilities.xAddr {
                        tableRowData.append(RVS_ONVIF_Mac_Test_Harness_GroupedTableData(key: "xAddr", value: xAddr.absoluteString))
                    }
                }

                if let receiverCapabilities = capabilities.receiverCapabilities {
                    tableRowData.append(RVS_ONVIF_Mac_Test_Harness_GroupedTableData(key: "RECEIVER", value: ""))
                    if let xAddr = receiverCapabilities.xAddr {
                        tableRowData.append(RVS_ONVIF_Mac_Test_Harness_GroupedTableData(key: "xAddr", value: xAddr.absoluteString))
                    }
                    tableRowData.append(RVS_ONVIF_Mac_Test_Harness_GroupedTableData(key: "RTP Multicast", value: receiverCapabilities.isRTP_Multicast ? "TRUE" : "FALSE"))
                    tableRowData.append(RVS_ONVIF_Mac_Test_Harness_GroupedTableData(key: "RTP TCP", value: receiverCapabilities.isRTP_TCP ? "TRUE" : "FALSE"))
                    tableRowData.append(RVS_ONVIF_Mac_Test_Harness_GroupedTableData(key: "RTSP TCP", value: receiverCapabilities.isRTP_RTSP_TCP ? "TRUE" : "FALSE"))
                    if let supportedReceivers = receiverCapabilities.supportedReceivers {
                        tableRowData.append(RVS_ONVIF_Mac_Test_Harness_GroupedTableData(key: "Supported Receivers", value: String(supportedReceivers)))
                    }
                    if let maximumRTSPURILength = receiverCapabilities.maximumRTSPURILength {
                        tableRowData.append(RVS_ONVIF_Mac_Test_Harness_GroupedTableData(key: "Max URI Length", value: String(maximumRTSPURILength)))
                    }
                }

                if let recordingCapabilities = capabilities.recordingCapabilities {
                    tableRowData.append(RVS_ONVIF_Mac_Test_Harness_GroupedTableData(key: "RECORDING", value: ""))
                    if let xAddr = recordingCapabilities.xAddr {
                        tableRowData.append(RVS_ONVIF_Mac_Test_Harness_GroupedTableData(key: "xAddr", value: xAddr.absoluteString))
                    }
                    tableRowData.append(RVS_ONVIF_Mac_Test_Harness_GroupedTableData(key: "Dynamic Recordings", value: recordingCapabilities.isDynamicRecordings ? "TRUE" : "FALSE"))
                    tableRowData.append(RVS_ONVIF_Mac_Test_Harness_GroupedTableData(key: "Dynamic Tracks", value: recordingCapabilities.isDynamicTracks ? "TRUE" : "FALSE"))
                    tableRowData.append(RVS_ONVIF_Mac_Test_Harness_GroupedTableData(key: "Delete Data", value: recordingCapabilities.isDeleteData ? "TRUE" : "FALSE"))
                }

                if let replayCapabilities = capabilities.replayCapabilities {
                    tableRowData.append(RVS_ONVIF_Mac_Test_Harness_GroupedTableData(key: "REPLAY", value: ""))
                    if let xAddr = replayCapabilities.xAddr {
                        tableRowData.append(RVS_ONVIF_Mac_Test_Harness_GroupedTableData(key: "xAddr", value: xAddr.absoluteString))
                    }
                }

                if let searchCapabilities = capabilities.searchCapabilities {
                    tableRowData.append(RVS_ONVIF_Mac_Test_Harness_GroupedTableData(key: "SEARCH", value: ""))
                    if let xAddr = searchCapabilities.xAddr {
                        tableRowData.append(RVS_ONVIF_Mac_Test_Harness_GroupedTableData(key: "xAddr", value: xAddr.absoluteString))
                    }
                    tableRowData.append(RVS_ONVIF_Mac_Test_Harness_GroupedTableData(key: "Metadata Search", value: searchCapabilities.isMetadataSearch ? "TRUE" : "FALSE"))
                }
            }
            displayTableView?.reloadData()
        }
    }

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
        if let column = inTableColumn, let cell = inTableView.makeView(withIdentifier: column.identifier, owner: nil) as? NSTableCellView {
            cell.textField?.stringValue = "NAME" == inTableColumn?.title ? tableRowData[inRow].key + ":" : tableRowData[inRow].value
            return cell
        } else if nil == inTableColumn {
            let groupHeader = NSTextView()
            groupHeader.isEditable = false
            groupHeader.font = NSFont.boldSystemFont(ofSize: 20)
            groupHeader.alignment = .center
            groupHeader.drawsBackground = false
            groupHeader.string = tableRowData[inRow].key
            return groupHeader
        }
        
        return nil
    }
}
