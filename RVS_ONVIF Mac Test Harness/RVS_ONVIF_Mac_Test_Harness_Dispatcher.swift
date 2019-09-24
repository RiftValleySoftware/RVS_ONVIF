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
// MARK: -
/* ################################################################################################################################## */
public protocol RVS_ONVIF_Mac_Test_Harness_Dispatcher {
    var sendParameters: [String: Any]! { get set }
    func setupCommandParameters(_ inCommand: RVS_ONVIF_DeviceRequestProtocol)
    func sendSpecificCommand(_ inCommand: RVS_ONVIF_DeviceRequestProtocol)
    // We repeat this, because we will be calling it, based on this protocol, not the RVS_ONVIF-defined one, which includes this.
    @discardableResult func sendRequest(_ inCommand: RVS_ONVIF_DeviceRequestProtocol) -> Bool
}

/* ################################################################################################################################## */
// MARK: -
/* ################################################################################################################################## */
extension RVS_ONVIF_Mac_Test_Harness_Dispatcher {
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
        
        let alert = NSAlert()
        alert.messageText = "\(inCommand.rawValue)Response:\n"
        alert.informativeText = String(describing: inParams)
        alert.addButton(withTitle: "OK")
        alert.runModal()
        return true
    }
}
