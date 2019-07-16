/**
 © Copyright 2019, The Great Rift Valley Software Company. All rights reserved.
 
 This code is proprietary and confidential code,
 It is NOT to be reused or combined into any application,
 unless done so, specifically under written license from The Great Rift Valley Software Company.
 
 The Great Rift Valley Software Company: https://riftvalleysoftware.com
 */

import UIKit
import RVS_ONVIF_tvOS

/* ################################################################################################################################## */
// MARK: -
/* ################################################################################################################################## */
public protocol RVS_ONVIF_tvOS_Test_Harness_Dispatcher {
    var sendParameters: [String: Any]! { get set }
    func setupCommandParameters(_ inCommand: RVS_ONVIF_DeviceRequestProtocol)
    func sendSpecificCommand(_ inCommand: RVS_ONVIF_DeviceRequestProtocol)
    // We repeat this, because we will be calling it, based on this protocol, not the RVS_ONVIF-defined one, which includes this.
    @discardableResult func sendRequest(_ inCommand: RVS_ONVIF_DeviceRequestProtocol) -> Bool
}

/* ################################################################################################################################## */
// MARK: -
/* ################################################################################################################################## */
extension RVS_ONVIF_tvOS_Test_Harness_Dispatcher {
    /* ############################################################################################################################## */
    // MARK: - Internal Instance Methods
    /* ############################################################################################################################## */
    /* ################################################################## */
    /**
     */
    func getHierarchyAsString(_ inInitialString: String = "", from inObject: Any, withIndent inIndent: Int = 0) -> String {
        #if DEBUG
            print("RVS_ONVIF_tvOS_Test_Harness_Dispatcher::getHierarchyAsString:\(String(describing: inInitialString)), from: \(String(describing: inObject)), indent: \(inIndent)")
        #endif
        
        var ret = inInitialString
        
        let mirrored_object = Mirror(reflecting: inObject)

        if 0 < mirrored_object.children.count {
            mirrored_object.children.forEach {
                let value = $0.value
                
                if var propertyName = $0.label, "owner" != propertyName, case Optional<Any>.some = value {
                    if !ret.isEmpty {
                        ret += "\n"
                    }
                    
                    (0..<inIndent).forEach { _ in
                        ret += "\t"
                    }

                    if "some" == propertyName {
                        propertyName = ""
                    } else {
                        propertyName += ": "
                    }
                    
                    ret += propertyName
                    
                    if let urlValue = value as? URL {
                        ret += urlValue.absoluteString
                    } else if let boolVal = value as? Bool {
                        ret += boolVal ? "true" : "false"
                    } else if let intVal = value as? Int {
                        ret += String(intVal)
                    } else if let floatVal = value as? Float {
                        ret += String(floatVal)
                    } else if let ipAddress = value as? RVS_IPAddress {
                        ret += ipAddress.address
                    } else if let stringVal = value as? String {
                        ret += stringVal
                    } else if let arrVal = value as? [Any] {
                        arrVal.forEach { val in
                            ret = getHierarchyAsString(ret, from: val, withIndent: inIndent)
                        }
                    } else if !Mirror(reflecting: value).children.isEmpty {
                        var indent = inIndent
                        if !propertyName.isEmpty {
                            indent += 1
                        }
                        ret = getHierarchyAsString(ret, from: $0.value, withIndent: inIndent)
                    } else {
                        ret = getHierarchyAsString(ret, from: $0.value, withIndent: inIndent)
                    }
                }
            }
        } else {
            if let urlValue = inObject as? URL {
                ret += urlValue.absoluteString
            } else if let boolVal = inObject as? Bool {
                ret += boolVal ? "true" : "false"
            } else if let intVal = inObject as? Int {
                ret += String(intVal)
            } else if let floatVal = inObject as? Float {
                ret += String(floatVal)
            } else if let ipAddress = inObject as? RVS_IPAddress {
                ret += ipAddress.address
            } else if let stringVal = inObject as? String {
                ret += stringVal
            } else if let arrVal = inObject as? [Any] {
                arrVal.forEach { val in
                    ret = getHierarchyAsString(ret, from: val, withIndent: inIndent)
                }
            } else {
                ret = getHierarchyAsString(ret, from: inObject, withIndent: inIndent)
            }
        }
        
        return ret
    }
    
    /* ################################################################## */
    /**
     This method is called to deliver the response from the device.
     
     - parameter inCommand: The command to which this is a response.
     - parameter params: The data returned (and parsed) from the device. It can be any one of the various data types.
     - returns: true, if the response was consumed. Can be ignored.
     */
    @discardableResult public func deliverResponse(_ inCommand: RVS_ONVIF_DeviceRequestProtocol, params inParams: Any!) -> Bool {
        #if DEBUG
            print("RVS_ONVIF_tvOS_Test_Harness_Dispatcher::deliverResponse:\(String(describing: inCommand)), params: \(String(describing: inParams))")
        #endif
        
        if let colonIndex = inCommand.soapAction.firstIndex(of: ":") {
            if let params = inParams {
                let header = String(inCommand.soapAction[inCommand.soapAction.index(after: colonIndex)...])
                let body = getHierarchyAsString(from: params)

                RVS_ONVIF_tvOS_Test_Harness_AppDelegate.displayAlert(header, message: body, presentedBy: RVS_ONVIF_tvOS_Test_Harness_AppDelegate.delegateObject.openNamespaceHandlerScreen)
            }
        }
        
        return true
    }
}
