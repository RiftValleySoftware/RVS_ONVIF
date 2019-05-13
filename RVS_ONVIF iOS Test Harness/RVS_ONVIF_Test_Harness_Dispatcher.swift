/**
 © Copyright 2019, The Great Rift Valley Software Company. All rights reserved.
 
 This code is proprietary and confidential code,
 It is NOT to be reused or combined into any application,
 unless done so, specifically under written license from The Great Rift Valley Software Company.
 
 The Great Rift Valley Software Company: https://riftvalleysoftware.com
 */

import Foundation
import RVS_ONVIF_iOS

/* ################################################################################################################################## */
// MARK: -
/* ################################################################################################################################## */
public protocol RVS_ONVIF_Test_Harness_Dispatcher {
    var sendParameters: [String: Any]! { get set }
    func setupCommandParameters(_ inCommand: RVS_ONVIF_DeviceRequestProtocol)
    func sendSpecificCommand(_ inCommand: RVS_ONVIF_DeviceRequestProtocol)
    // We repeat this, because we will be calling it, based on this protocol, not the RVS_ONVIF-defined one, which includes this.
    @discardableResult func sendRequest(_ inCommand: RVS_ONVIF_DeviceRequestProtocol) -> Bool
}

/* ################################################################################################################################## */
// MARK: -
/* ################################################################################################################################## */
extension RVS_ONVIF_Test_Harness_Dispatcher {
    /* ################################################################## */
    /**
     This method is required to be implemented by the final dispatcher. This method is called to deliver the response from the device.
     
     - parameter inCommand: The command to which this is a response.
     - parameter params: The data returned (and parsed) from the device. It can be any one of the various data types.
     - returns: true, if the response was consumed. Can be ignored.
     */
    @discardableResult public func deliverResponse(_ inCommand: RVS_ONVIF_DeviceRequestProtocol, params inParams: Any!) -> Bool {
        #if DEBUG
            print("RVS_ONVIF_Mac_Test_Harness_Dispatcher::deliverResponse:\(String(describing: inCommand)), params: \(String(describing: inParams))")
        #endif
        
        let header = "\(inCommand.rawValue)Response:"
        var body = ""
        if let params = inParams {
            body = String(reflecting: params)
        }
        RVS_ONVIF_Test_Harness_AppDelegate.appDelegateObject.openNamespaceHandlerScreen.displayResult(header: header, data: body)
        return true
    }
}
