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
// MARK: - Dispatch Core Functions
/* ################################################################################################################################## */
class RVS_ONVIF_Mac_Test_Harness_CoreDispatcher: RVS_ONVIF_Mac_Test_Harness_Dispatcher, RVS_ONVIF_CoreDispatcher {
    /* ################################################################## */
    /**
     This is the RVS_ONVIF instance that the dispatcher references. It is required to be implemented (and populated) by the final dispatcher instance.
     */
    var owner: RVS_ONVIF!
    var ntpRecord: RVS_ONVIF_Core.NTPRecord!
    var sendParameters: [String: Any]!
    
    /* ################################################################## */
    /**
     Initializer.
     
     - parameter owner: The RVS_ONVIF instance that is referenced by this dispatcher.
     */
    init(owner inOwner: RVS_ONVIF) {
        owner = inOwner
    }

    /* ################################################################## */
    /**
     */
    func ttlCallback(_ inControl: NSView?) {
        sendParameters["TTL"] = (inControl as? NSTextField)?.stringValue
    }

    /* ################################################################## */
    /**
     */
    func nameCallback(_ inControl: NSView?) {
        sendParameters["Name"] = (inControl as? NSTextField)?.stringValue
    }

    /* ################################################################## */
    /**
     */
    func fromDHCPCallback(_ inControl: NSView?) {
        sendParameters["FromDHCP"] = (0 == (inControl as? NSSegmentedControl)?.selectedSegment ?? 0) ? "false" : "true"
    }

    /* ################################################################## */
    /**
     */
    func dynDNSTypeCallback(_ inControl: NSView?) {
        if let control = inControl as? NSSegmentedControl {
            let type = control.label(forSegment: control.selectedSegment)
            sendParameters["Type"] = type
        }
    }

    /* ################################################################## */
    /**
     */
    func dnsIPAddressListCallback(_ inControl: NSView?) {
        if let control = inControl as? NSSegmentedControl {
            sendParameters["FromDHCP"] = 1 == control.selectedSegment
        } else if let control = inControl as? NSTextField, !control.stringValue.isEmpty {
            let servers: [String] = control.stringValue.split(separator: ",").compactMap { return String($0) }
            let ipAddresses: [RVS_IPAddress] = servers.compactMap {
                return $0.ipAddress
            }
            
            var ips: [[String: String]] = []
            
            ipAddresses.forEach {
                let type = $0.isV6 ? "IPv6" : "IPv4"
                let key = "tt:" + type + "Address"
                let val: [String: String] = ["tt:Type": type, key: $0.address]
                ips.append(val)
            }
            
            sendParameters["DNSManual"] = ips
        }
    }

    /* ################################################################## */
    /**
     */
    func ntpIPAddressListCallback(_ inControl: NSView?) {
        if let control = inControl as? NSSegmentedControl {
            sendParameters["FromDHCP"] = 1 == control.selectedSegment
        } else if let control = inControl as? NSTextField, !control.stringValue.isEmpty {
            let servers: [String] = control.stringValue.split(separator: ",").compactMap { return String($0) }
            var adNames: (names: [String], ipAddresses: [RVS_IPAddress]) = (names: [String](), ipAddresses: [RVS_IPAddress]())
            adNames = servers.reduce(into: adNames, { (adNames, nextVal) in
                if nextVal.ipAddress?.isValidAddress ?? false {
                    adNames.ipAddresses.append(nextVal.ipAddress!)
                } else {
                    adNames.names.append(nextVal)
                }
            })
            
            var ips: [[String: String]] = []
            
            adNames.ipAddresses.forEach {
                let type = $0.isV6 ? "IPv6" : "IPv4"
                let key = "tt:" + type + "Address"
                let val: [String: String] = ["tt:Type": type, key: $0.address]
                ips.append(val)
            }
            
            for name in adNames.names {
                let val: [String: String] = ["tt:Type": "DNS", "tt:DNSname": name]
                ips.append(val)
            }
            
            sendParameters["NTPManual"] = ips
        }
    }

    /* ################################################################## */
    /**
     */
    func dnsSearchDomainCallback(_ inControl: NSView?) {
        if let domainStr = (inControl as? NSTextField)?.stringValue {
            sendParameters["SearchDomain"] = domainStr.split(separator: ",")
        }
    }

    /* ################################################################################################################################## */
    // MARK: - Dispatcher Protocol Methods
    /* ################################################################################################################################## */
    /* ################################################################## */
    /**
     */
    func setupCommandParameters(_ inCommand: RVS_ONVIF_DeviceRequestProtocol) {
        sendParameters = [:]
        if inCommand.isRequiresParameters {
            var dataEntryDialog: RVS_ONVIF_Mac_Test_Harness_FunctionData_ViewController!
            
            switch inCommand.rawValue {
            case "SetHostname":
                dataEntryDialog = RVS_ONVIF_Mac_Test_Harness_FunctionData_ViewController.dialogFactory(["Name": .textEntry(defaultValue: "", callback: nameCallback)], command: inCommand, dispatcher: self)
                
            case "SetHostnameFromDHCP":
                dataEntryDialog = RVS_ONVIF_Mac_Test_Harness_FunctionData_ViewController.dialogFactory(["FromDHCP": .pickOne(values: ["false", "true"], selectedIndex: 0, callback: fromDHCPCallback)], command: inCommand, dispatcher: self)
                
            case "SetNTP":
                dataEntryDialog = RVS_ONVIF_Mac_Test_Harness_FunctionData_ViewController.dialogFactory(["FromDHCP": .pickOne(values: ["false", "true"], selectedIndex: 0, callback: fromDHCPCallback), "NTPManual": .textEntry(defaultValue: "", callback: ntpIPAddressListCallback)], command: inCommand, dispatcher: self)
                
            case "SetDNS":
                dataEntryDialog = RVS_ONVIF_Mac_Test_Harness_FunctionData_ViewController.dialogFactory(["SearchDomain": .textEntry(defaultValue: "", callback: dnsSearchDomainCallback), "FromDHCP": .pickOne(values: ["false", "true"], selectedIndex: 0, callback: fromDHCPCallback), "DNSManual": .textEntry(defaultValue: "", callback: dnsIPAddressListCallback)], command: inCommand, dispatcher: self)
                
            case "SetDynamicDNS":
                dataEntryDialog = RVS_ONVIF_Mac_Test_Harness_FunctionData_ViewController.dialogFactory(["Type": .pickOne(values: ["NoUpdate", "ServerUpdates", "ClientUpdates"], selectedIndex: 0, callback: dynDNSTypeCallback), "Name": .textEntry(defaultValue: "", callback: nameCallback), "TTL": .textEntry(defaultValue: "", callback: ttlCallback)], command: inCommand, dispatcher: self)
                
            default:
                ()
            }
            
            if nil != dataEntryDialog, let windowViewController = RVS_ONVIF_Mac_Test_Harness_AppDelegate.appDelegateObject.functionHandlerScreen {
                windowViewController.presentAsSheet(dataEntryDialog)
            }
        } else {
            sendRequest(inCommand)
        }
    }
    
    /* ################################################################## */
    /**
     */
    func sendSpecificCommand(_ inCommand: RVS_ONVIF_DeviceRequestProtocol) {
        switch inCommand.rawValue {
        case "SetHostname":
            if let name = sendParameters["Name"] as? String {
                setHostname(name)
            }
            
        case "SetHostnameFromDHCP":
            if let isOn = sendParameters["FromDHCP"] as? String {
                setHostnameFromDHCP("true" == isOn)
            }

        case "SetNTP":
            var isFromDHCP: Bool = false
            var addresses: [RVS_IPAddress] = []
            var names: [String] = []
            
            if let isOn = sendParameters["FromDHCP"] as? String {
                isFromDHCP = "true" == isOn
            }

            if let manualAddresses = sendParameters["NTPManual"] as? [[String: String]] {
                manualAddresses.forEach {
                    if let ipAddressStr = ($0["tt:IPV4Address"] ?? $0["tt:IPV6Address"]), let ipAddress = ipAddressStr.ipAddress {
                        addresses.append(ipAddress)
                    } else if let name = $0["tt:DNSName"] {
                        names.append(name)
                    }
                }
            }
            
            let ntpRecord = RVS_ONVIF_Core.NTPRecord(owner: owner, isFromDHCP: isFromDHCP, addresses: addresses, names: names)
            
            setNTP(ntpRecord)

        default:
            sendSpecificCommandPartDeux(inCommand)
        }
    }
    
    /* ################################################################## */
    /**
     */
    func sendSpecificCommandPartDeux(_ inCommand: RVS_ONVIF_DeviceRequestProtocol) {
        switch inCommand.rawValue {
        case "SetDNS":
            let searchDomain: [String] = sendParameters["SearchDomain"] as? [String] ?? []
            var isFromDHCP: Bool = false
            var addresses: [RVS_IPAddress] = []
            
            if let isOn = sendParameters["FromDHCP"] as? String {
                isFromDHCP = "true" == isOn
            }
            
            if let manualAddresses = sendParameters["DNSManual"] as? [[String: String]] {
                manualAddresses.forEach {
                    if let ipAddressStr = ($0["tt:IPV4Address"] ?? $0["tt:IPV6Address"]), let ipAddress = ipAddressStr.ipAddress {
                        addresses.append(ipAddress)
                    }
                }
            }
            
            let dnsRecord = RVS_ONVIF_Core.DNSRecord(owner: owner, searchDomain: searchDomain, isFromDHCP: isFromDHCP, addresses: addresses)
            
            setDNS(dnsRecord)
            
        case "SetDynamicDNS":
            if let typeStr = sendParameters["Type"] as? String {
                var type: RVS_ONVIF_Core.DynamicDNSRecord.DynDNSType
                
                switch typeStr {
                case "ClientUpdates":
                    let ttl = ((sendParameters["TTL"] as? String) ?? "").asXMLDuration
                    type = .ClientUpdates(name: sendParameters["Name"] as? String ?? "", ttl: ttl)
                case "ServerUpdates":
                    let ttl = ((sendParameters["TTL"] as? String) ?? "").asXMLDuration
                    type = .ServerUpdates(ttl: ttl)
                default:
                    type = .NoUpdate
                }
                
                let dynDNSRecord = RVS_ONVIF_Core.DynamicDNSRecord(owner: owner, type: type)
                
                setDynamicDNS(dynDNSRecord)
            }
            
        default:
            ()
        }
    }

    /* ################################################################## */
    /**
     This method is implemented by the final dispatcher, and is used to fetch the parameters for the given command. This implementation returns an empty command.
     
     - parameter inCommand: The command being sent.
     - returns: a Dictionary<String, Any>, with the sending parameters, of nil, if the call is to be canceled.
     */
    public func getGetParametersForCommand(_ inCommand: RVS_ONVIF_DeviceRequestProtocol) -> [String: Any]! {
        return sendParameters
    }
    
    /* ################################################################## */
    /**
     This method is required to be implemented by the final dispatcher. This method is called to deliver the response from the device.
     
     - parameter inCommand: The command to which this is a response.
     - parameter params: The data returned (and parsed) from the device. It can be any one of the various data types.
     - returns: true, if the response was consumed. Can be ignored.
     */
    @discardableResult public func deliverResponse(_ inCommand: RVS_ONVIF_DeviceRequestProtocol, params inParams: Any!) -> Bool {
        #if DEBUG
            print("RVS_ONVIF_Mac_Test_Harness_CoreDispatcher::deliverResponse:\(String(describing: inCommand)), params: \(String(describing: inParams))")
        #endif
        
        if isAbleToHandleThisCommand(inCommand) {
            let alert = NSAlert()
            alert.messageText = "\(inCommand.rawValue)Response:\n"
            alert.informativeText = String(describing: inParams)
            alert.addButton(withTitle: "OK")
            alert.runModal()
            return true
        }
        
        return false
    }
}
