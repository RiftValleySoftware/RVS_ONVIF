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
// MARK: -
/* ################################################################################################################################## */
protocol RVS_ONVIF_Dispatcher: RVS_ONVIF_CoreDelegate, RVS_ONVIF_Profile_SDelegate {
    var scope: ProfileHandlerProtocol { get set }
    init(scope: ProfileHandlerProtocol)
    func handleCommand(_ onvifInstance: RVS_ONVIF, command: RVS_ONVIF_DeviceRequestProtocol) -> Bool
    func isAbleToHandleThisCommand(_ inCommand: RVS_ONVIF_DeviceRequestProtocol) -> Bool
}

/* ################################################################################################################################## */
// MARK: -
/* ################################################################################################################################## */
extension RVS_ONVIF_Dispatcher {
    /* ################################################################## */
    /**
     */
    func isAbleToHandleThisCommand(_ inCommand: RVS_ONVIF_DeviceRequestProtocol) -> Bool {
        let commands = scope.availableCommands
        
        return commands.reduce(false, { (current, next) -> Bool in
            return current || next.rawValue == inCommand.rawValue
        })
    }

    /* ################################################################## */
    /**
     */
    func onvifInstance(_ inONVIFInstance: RVS_ONVIF, getWSDLURI: String!) { }
    
    /* ################################################################## */
    /**
     */
    func onvifInstance(_ inONVIFInstance: RVS_ONVIF, getHostname: RVS_ONVIF_Core.HostnameResponse!) { }
    
    /* ################################################################## */
    /**
     */
    func onvifInstance(_ inONVIFInstance: RVS_ONVIF, getDNS: RVS_ONVIF_Core.DNSRecord!) { }
    
    /* ################################################################## */
    /**
     */
    func onvifInstance(_ inONVIFInstance: RVS_ONVIF, getDynamicDNS: RVS_ONVIF_Core.DynamicDNSRecord!) { }
    
    /* ################################################################## */
    /**
     */
    func onvifInstance(_ inONVIFInstance: RVS_ONVIF, getNTP: RVS_ONVIF_Core.NTPRecord!) { }

    /* ################################################################## */
    /**
     */
    func onvifInstance(_ inONVIFInstance: RVS_ONVIF, getProfiles: [RVS_ONVIF_Profile_S.Profile]) { }
    
    /* ################################################################## */
    /**
     */
    func onvifInstance(_ inONVIFInstance: RVS_ONVIF, getStreamURI: RVS_ONVIF_Profile_S.Stream_URI) { }
    
    /* ################################################################## */
    /**
     */
    func onvifInstance(_ inONVIFInstance: RVS_ONVIF, getVideoSourceConfigurations: [RVS_ONVIF_Profile_S.VideoSourceConfiguration]) { }
}
