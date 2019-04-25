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
class RVS_ONVIF_Mac_Test_Harness_CoreDispatcher: RVS_ONVIF_Dispatcher {
    var scope: ProfileHandlerProtocol
    
    /* ################################################################## */
    /**
     */
    required init(scope inScope: ProfileHandlerProtocol) {
        scope = inScope
    }
    
    /* ################################################################## */
    /**
     */
    func isAbleToHandleThisCommand(_ inCommand: RVS_ONVIF_DeviceRequestProtocol) -> Bool {
        if let profileHandler = RVS_ONVIF_Mac_Test_Harness_AppDelegate.appDelegateObject.onvifInstance.profiles["RVS_ONVIF_Core"] {
            if profileHandler.availableCommandsAsStrings.contains(inCommand.rawValue) {
                return true
            }
        }
        
        return false
    }
    
    /* ################################################################## */
    /**
     */
    func handleCommand(_ inONVIFInstance: RVS_ONVIF, command inCommand: RVS_ONVIF_DeviceRequestProtocol) -> Bool {
        if isAbleToHandleThisCommand(inCommand) {
            return true
        }
        return false
    }
    
    /* ################################################################## */
    /**
     This is called to deliver the WSDL URI.
     
     - parameter instance: The RVS_ONVIF instance that is calling the delegate.
     - parameter getWSDLURI: The WSDL URI instance. Nil, if there is none available.
     */
    func onvifInstance(_ instance: RVS_ONVIF, getWSDLURI: String!) {
        #if DEBUG
            print("Delegate onvifInstance:getWSDLURI:\(String(describing: getWSDLURI))")
        #endif
    }
    
    /* ################################################################## */
    /**
     This is called to deliver the Hostname.
     
     - parameter instance: The RVS_ONVIF instance that is calling the delegate.
     - parameter getHostname: The returned hostname tuple. Nil, if there is none available.
     */
    func onvifInstance(_ instance: RVS_ONVIF, getHostname: RVS_ONVIF_Core.HostnameResponse!) {
        #if DEBUG
            print("Delegate onvifInstance:getHostname:\(String(describing: getHostname))")
        #endif
    }
    
    /* ################################################################## */
    /**
     This is called to deliver the DNS.
     
     - parameter instance: The RVS_ONVIF instance that is calling the delegate.
     - parameter getDNS: The DNS Response. Nil, if there is none available.
     */
    func onvifInstance(_ instance: RVS_ONVIF, getDNS: RVS_ONVIF_Core.DNSRecord!) {
        #if DEBUG
            print("Delegate onvifInstance:getDNS:\(String(describing: getDNS))")
        #endif
    }
    
    /* ################################################################## */
    /**
     This is called to deliver the Dynamic DNS.
     
     - parameter instance: The RVS_ONVIF instance that is calling the delegate.
     - parameter getDynamicDNS: The Dynamic DNS Response. Nil, if there is none available.
     */
    func onvifInstance(_ instance: RVS_ONVIF, getDynamicDNS: RVS_ONVIF_Core.DynamicDNSRecord!) {
        #if DEBUG
            print("Delegate onvifInstance:getDynamicDNS:\(String(describing: getDynamicDNS))")
        #endif
    }
    
    /* ################################################################## */
    /**
     This is called to deliver the NTP Record.
     
     - parameter instance: The RVS_ONVIF instance that is calling the delegate.
     - parameter getNTP: The NTP Response. Nil, if there is none available.
     */
    func onvifInstance(_ instance: RVS_ONVIF, getNTP: RVS_ONVIF_Core.NTPRecord!) {
        #if DEBUG
            print("Delegate onvifInstance:getNTP:\(String(describing: getNTP))")
        #endif
    }
}
