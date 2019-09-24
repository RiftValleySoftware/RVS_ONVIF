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

import Cocoa
import RVS_ONVIF_MacOS

/* ################################################################################################################################## */
// MARK: - Main Logged-In Capabilities Screen View Controller
/* ################################################################################################################################## */
class RVS_ONVIF_Mac_Test_Harness_ServiceCapabilities_ViewController: RVS_ONVIF_Mac_Test_Harness_Base_ViewController, NSTableViewDataSource, NSTableViewDelegate {
    @IBOutlet weak var displayTableView: NSTableView!
    
    typealias RVS_ONVIF_Mac_Test_Harness_GroupedTableData = (key: String, value: String)
    
    var tableRowData: [RVS_ONVIF_Mac_Test_Harness_GroupedTableData] = []
    
    override var loginViewController: RVS_ONVIF_Mac_Test_Harness_LoginScreen_ViewController! {
        get {
            return super.loginViewController
        }
        
        set {
            super.loginViewController = newValue
            
            if let capabilities = RVS_ONVIF_Mac_Test_Harness_AppDelegate.appDelegateObject.onvifInstance?.serviceCapabilities {
                tableRowData.append(RVS_ONVIF_Mac_Test_Harness_GroupedTableData(key: "NETWORK", value: ""))
                if let networkCapabilities = capabilities.networkCapabilities {
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

                if let securityCapabilities = capabilities.securityCapabilities {
                    tableRowData.append(RVS_ONVIF_Mac_Test_Harness_GroupedTableData(key: "SECURITY", value: ""))
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
                
                if let systemCapabilities = capabilities.systemCapabilities {
                    tableRowData.append(RVS_ONVIF_Mac_Test_Harness_GroupedTableData(key: "SYSTEM", value: ""))
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
                
                if let auxiliaryCommands = capabilities.auxiliaryCommands {
                    tableRowData.append(RVS_ONVIF_Mac_Test_Harness_GroupedTableData(key: "AUXILIARY", value: ""))
                    auxiliaryCommands.forEach {
                        tableRowData.append(RVS_ONVIF_Mac_Test_Harness_GroupedTableData(key: "Auxiliary Command", value: String($0)))
                    }
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
