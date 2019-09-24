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
    func getHierarchyAsString(_ inInitialString: String = "", from inObject: Any! = nil, withIndent inIndent: Int = 0) -> String {
        #if DEBUG
            print("RVS_ONVIF_tvOS_Test_Harness_Dispatcher::getHierarchyAsString:\(String(describing: inInitialString)), from: \(String(describing: inObject)), withIndent: \(inIndent)")
        #endif
        
        var ret = inInitialString
        
        if let objectToTest = inObject {
            let mirrored_object = Mirror(reflecting: objectToTest)
            if 0 < mirrored_object.children.count {
                mirrored_object.children.forEach {
                    let value = $0.value
                    var propertyName = $0.label ?? ""
                    if "owner" != propertyName, case Optional<Any>.some = value {
                        if !ret.isEmpty {
                            ret += "\n\n"
                        }
                        
                        if "some" == propertyName {
                            propertyName = ""
                        } else if !propertyName.isEmpty {
                            propertyName += ": "
                        }
                        
                        ret += propertyName + String(reflecting: $0.value)
                    }
                }
            } else if let object = inObject {
                ret += String(reflecting: object)
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
    @discardableResult public func deliverResponseHandler(_ inCommand: RVS_ONVIF_DeviceRequestProtocol, params inParams: Any!) -> Bool {
        #if DEBUG
            print("RVS_ONVIF_tvOS_Test_Harness_Dispatcher::deliverResponseHandler:\(String(describing: inCommand)), params: \(String(describing: inParams))")
        #endif
        
        if let colonIndex = inCommand.soapAction.firstIndex(of: ":") {
            if let params = inParams {
                let header = String(inCommand.soapAction[inCommand.soapAction.index(after: colonIndex)...])
                let body = getHierarchyAsString(from: params)
                
                if  let windowViewController = RVS_ONVIF_tvOS_Test_Harness_AppDelegate.delegateObject.openNamespaceHandlerScreen,
                    let dataEntryDialog = windowViewController.storyboard?.instantiateViewController(withIdentifier: RVS_ONVIF_tvOS_Test_Harness_DisplayResponse_ViewController.storyboardID) as? RVS_ONVIF_tvOS_Test_Harness_DisplayResponse_ViewController {
                    dataEntryDialog.titleText = header
                    dataEntryDialog.contentText = body
                    windowViewController.present(dataEntryDialog, animated: true, completion: nil)
                }
            }
        }
        
        return true
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
        return deliverResponseHandler(inCommand, params: inParams)
    }
}
