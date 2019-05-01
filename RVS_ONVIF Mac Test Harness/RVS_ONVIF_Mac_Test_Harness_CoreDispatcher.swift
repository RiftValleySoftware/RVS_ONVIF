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
    func setupCommandParameters(_ inCommand: RVS_ONVIF_DeviceRequestProtocol) {
        sendParameters = [:]
        if inCommand.isRequiresParameters {
            var dataEntryDialog: RVS_ONVIF_Mac_Test_Harness_FunctionData_ViewController!
            
            switch inCommand.rawValue {
            case "SetHostname":
                dataEntryDialog = RVS_ONVIF_Mac_Test_Harness_FunctionData_ViewController.dialogFactory(["Name": .textEntry(defaultValue: "", callback: hostNameCallback)], command: inCommand, dispatcher: self)
                
            case "SetHostnameFromDHCP":
                dataEntryDialog = RVS_ONVIF_Mac_Test_Harness_FunctionData_ViewController.dialogFactory(["FromDHCP": .pickOne(values: ["false", "true"], selectedIndex: 0, callback: fromDHCPCallback)], command: inCommand, dispatcher: self)

            case "SetNTP":
                dataEntryDialog = RVS_ONVIF_Mac_Test_Harness_FunctionData_ViewController.dialogFactory(["FromDHCP": .pickOne(values: ["false", "true"], selectedIndex: 0, callback: fromDHCPCallback), "NTPManual": .textEntry(defaultValue: "", callback: ntpListCallback)], command: inCommand, dispatcher: self)

            case "SetDNS":
                ()
                
            case "SetDynamicDNS":
                ()
                
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
    func hostNameCallback(_ inControl: NSView?) {
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
    func ntpListCallback(_ inControl: NSView?) {
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
        
        return isAbleToHandleThisCommand(inCommand)
    }
}
