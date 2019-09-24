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
import RVS_ONVIF_iOS

/* ################################################################################################################################## */
// MARK: - Main TableView Controller Class for the Service Capabilities List Screen
/* ################################################################################################################################## */
class RVS_ONVIF_iOS_Test_Harness_ServiceCapabilities_TableViewController: RVS_ONVIF_iOS_Test_Harness_ONVIF_TableViewController {
    /* ############################################################################################################################## */
    // MARK: - Internal Instance Properties
    /* ############################################################################################################################## */
    /* ################################################################## */
    /**
     */
    private var _serviceCapabilitiesDictionary: [String: Any?] = [:]
    private let _serviceCapabilityKeysArray = ["isIPFilter",
                                               "isZeroConfiguration",
                                               "isIPVersion6",
                                               "isDynDNS",
                                               "isDot11Configuration",
                                               "dot1XConfiguration",
                                               "isHostnameFromDHCP",
                                               "ntp",
                                               "isDHCPv6",
                                               "isTLS11",
                                               "isTLS12",
                                               "isOnboardKeyGeneration",
                                               "isAccessPolicyConfig",
                                               "isDefaultAccessPolicy",
                                               "isDot1X",
                                               "isRemoteUserHandling",
                                               "isX509Token",
                                               "isSAMLToken",
                                               "isKerberosToken",
                                               "isUsernameToken",
                                               "isHttpDigest",
                                               "isRELToken",
                                               "supportedEAPMethods",
                                               "maxUsers",
                                               "maxUserNameLength",
                                               "maxPasswordLength",
                                               "isDiscoveryResolve",
                                               "isDiscoveryBye",
                                               "isRemoteDiscovery",
                                               "isSystemBackup",
                                               "isSystemLogging",
                                               "isFirmwareUpgrade",
                                               "isHttpFirmwareUpgrade",
                                               "isHttpSystemBackup",
                                               "isHttpSystemLogging",
                                               "isHttpSupportInformation",
                                               "isStorageConfiguration",
                                               "maxStorageConfigurations",
                                               "geoLocationEntries",
                                               "autoGeo",
                                               "storageTypesSupported",
                                               "auxiliaryCommands"
]
    
    /* ############################################################################################################################## */
    // MARK: - Private Instance Properties
    /* ############################################################################################################################## */
    /* ################################################################## */
    /**
     */

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
    internal func setUpArray() {
        let serviceCapabilitiesInitializer: [String: Any?] = [   "isIPFilter": onvifInstance?.serviceCapabilities.networkCapabilities.isIPFilter,
                                                                 "isZeroConfiguration": onvifInstance?.serviceCapabilities.networkCapabilities.isZeroConfiguration,
                                                                 "isIPVersion6": onvifInstance?.serviceCapabilities.networkCapabilities.isIPVersion6,
                                                                 "isDynDNS": onvifInstance?.serviceCapabilities.networkCapabilities.isDynDNS,
                                                                 "isDot11Configuration": onvifInstance?.serviceCapabilities.networkCapabilities.isDot11Configuration,
                                                                 "dot1XConfiguration": onvifInstance?.serviceCapabilities.networkCapabilities.dot1XConfiguration,
                                                                 "isHostnameFromDHCP": onvifInstance?.serviceCapabilities.networkCapabilities.isHostnameFromDHCP,
                                                                 "ntp": onvifInstance?.serviceCapabilities.networkCapabilities.ntp,
                                                                 "isDHCPv6": onvifInstance?.serviceCapabilities.networkCapabilities.isDHCPv6,
                                                                 "isTLS11": onvifInstance?.serviceCapabilities.securityCapabilities.isTLS11,
                                                                 "isTLS12": onvifInstance?.serviceCapabilities.securityCapabilities.isTLS12,
                                                                 "isOnboardKeyGeneration": onvifInstance?.serviceCapabilities.securityCapabilities.isOnboardKeyGeneration,
                                                                 "isAccessPolicyConfig": onvifInstance?.serviceCapabilities.securityCapabilities.isAccessPolicyConfig,
                                                                 "isDefaultAccessPolicy": onvifInstance?.serviceCapabilities.securityCapabilities.isDefaultAccessPolicy,
                                                                 "isDot1X": onvifInstance?.serviceCapabilities.securityCapabilities.isDot1X,
                                                                 "isRemoteUserHandling": onvifInstance?.serviceCapabilities.securityCapabilities.isRemoteUserHandling,
                                                                 "isX509Token": onvifInstance?.serviceCapabilities.securityCapabilities.isX509Token,
                                                                 "isSAMLToken": onvifInstance?.serviceCapabilities.securityCapabilities.isSAMLToken,
                                                                 "isKerberosToken": onvifInstance?.serviceCapabilities.securityCapabilities.isKerberosToken,
                                                                 "isUsernameToken": onvifInstance?.serviceCapabilities.securityCapabilities.isUsernameToken,
                                                                 "isHttpDigest": onvifInstance?.serviceCapabilities.securityCapabilities.isHttpDigest,
                                                                 "isRELToken": onvifInstance?.serviceCapabilities.securityCapabilities.isRELToken,
                                                                 "supportedEAPMethods": onvifInstance?.serviceCapabilities.securityCapabilities.supportedEAPMethods,
                                                                 "maxUsers": onvifInstance?.serviceCapabilities.securityCapabilities.maxUsers,
                                                                 "maxUserNameLength": onvifInstance?.serviceCapabilities.securityCapabilities.maxUserNameLength,
                                                                 "maxPasswordLength": onvifInstance?.serviceCapabilities.securityCapabilities.maxPasswordLength,
                                                                 "isDiscoveryResolve": onvifInstance?.serviceCapabilities.systemCapabilities.isDiscoveryResolve,
                                                                 "isDiscoveryBye": onvifInstance?.serviceCapabilities.systemCapabilities.isDiscoveryBye,
                                                                 "isRemoteDiscovery": onvifInstance?.serviceCapabilities.systemCapabilities.isRemoteDiscovery,
                                                                 "isSystemBackup": onvifInstance?.serviceCapabilities.systemCapabilities.isSystemBackup,
                                                                 "isSystemLogging": onvifInstance?.serviceCapabilities.systemCapabilities.isSystemLogging,
                                                                 "isFirmwareUpgrade": onvifInstance?.serviceCapabilities.systemCapabilities.isFirmwareUpgrade,
                                                                 "isHttpFirmwareUpgrade": onvifInstance?.serviceCapabilities.systemCapabilities.isHttpFirmwareUpgrade,
                                                                 "isHttpSystemBackup": onvifInstance?.serviceCapabilities.systemCapabilities.isHttpSystemBackup,
                                                                 "isHttpSystemLogging": onvifInstance?.serviceCapabilities.systemCapabilities.isHttpSystemLogging,
                                                                 "isHttpSupportInformation": onvifInstance?.serviceCapabilities.systemCapabilities.isHttpSupportInformation,
                                                                 "isStorageConfiguration": onvifInstance?.serviceCapabilities.systemCapabilities.isStorageConfiguration,
                                                                 "maxStorageConfigurations": onvifInstance?.serviceCapabilities.systemCapabilities.maxStorageConfigurations,
                                                                 "geoLocationEntries": onvifInstance?.serviceCapabilities.systemCapabilities.geoLocationEntries,
                                                                 "autoGeo": onvifInstance?.serviceCapabilities.systemCapabilities.autoGeo,
                                                                 "storageTypesSupported": onvifInstance?.serviceCapabilities.systemCapabilities.storageTypesSupported,
                                                                 "auxiliaryCommands": onvifInstance?.serviceCapabilities.auxiliaryCommands
        ]
        
        _serviceCapabilitiesDictionary = serviceCapabilitiesInitializer
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
        return _serviceCapabilityKeysArray.count
    }

    /* ################################################################## */
    /**
     */
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "basic-cell", for: indexPath)
        
        let key = _serviceCapabilityKeysArray[indexPath.row]
        var text = ""
        
        if let boolVal = _serviceCapabilitiesDictionary[key] as? Bool {
            text = String(key[key.index(key.startIndex, offsetBy: 2)...]) + ": " + (boolVal ? "true" : "false")
        } else if let intVal = _serviceCapabilitiesDictionary[key] as? Int {
            text = key.firstUppercased + ": " + String(intVal)
        } else {
            text = "\(key.firstUppercased): NOT SPECIFIED"
        }

        cell.textLabel?.text = text
        
        return cell
    }
}
