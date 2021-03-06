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
// MARK: - Dispatch Core Functions
/* ################################################################################################################################## */
class RVS_ONVIF_Mac_Test_Harness_Profile_SDispatcher: RVS_ONVIF_Mac_Test_Harness_Dispatcher, RVS_ONVIF_Profile_SDispatcher {
    var sendParameters: [String: Any]!
    
    /* ################################################################## */
    /**
     This is the RVS_ONVIF instance that the dispatcher references. It is required to be implemented (and populated) by the final dispatcher instance.
     */
    var owner: RVS_ONVIF!
    var profiles: [RVS_ONVIF_Profile_S.Profile] = []
    var profileScreen: RVS_ONVIF_Mac_Test_Harness_ProfileDisplayViewController!
    
    /* ################################################################## */
    /**
     Initializer.
     
     - parameter owner: The RVS_ONVIF instance that is referenced by this dispatcher.
     */
    init(owner inOwner: RVS_ONVIF) {
        owner = inOwner
    }

    /* ################################################################################################################################## */
    // MARK: - Dispatcher Protocol Methods
    /* ################################################################################################################################## */
    /* ################################################################## */
    /**
     */
    func sendSpecificCommand(_ inCommand: RVS_ONVIF_DeviceRequestProtocol) {
        switch inCommand.rawValue {
        default:
            ()
        }
    }

    /* ################################################################## */
    /**
     */
    func setupCommandParameters(_ inCommand: RVS_ONVIF_DeviceRequestProtocol) {
        sendParameters = [:]
        if inCommand.isRequiresParameters {
            switch inCommand.rawValue {
            default:
                ()
            }
        } else {
            sendRequest(inCommand)
        }
    }

    /* ################################################################## */
    /**
     This method is implemented by the final dispatcher, and is used to fetch the parameters for the given command. This implementation returns an empty command.
     
     - parameter inCommand: The command being sent.
     - returns: an empty Dictionary<String, Any>.
     */
    public func getParametersForCommand(_ inCommand: RVS_ONVIF_DeviceRequestProtocol) -> [String: Any]! {
        return [:]
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
            print("RVS_ONVIF_Mac_Test_Harness_Profile_SDispatcher::deliverResponse:\(String(describing: inCommand)), params: \(String(describing: inParams))")
        #endif
        
        if "GetProfiles" == inCommand.rawValue, let profileArray = inParams as? [RVS_ONVIF_Profile_S.Profile] {
            profiles = profileArray
            if  let windowViewController = RVS_ONVIF_Mac_Test_Harness_AppDelegate.appDelegateObject.functionHandlerScreen,
                let profileDisplayScreen = windowViewController.storyboard?.instantiateController(withIdentifier: "RVS_ONVIF_Mac_Test_Harness_ProfileDisplayViewController") as? RVS_ONVIF_Mac_Test_Harness_ProfileDisplayViewController {
                profileScreen = profileDisplayScreen
                profileScreen.profiles = profiles
                windowViewController.presentAsSheet(profileScreen)
            }
            return true
        } else if "GetStreamUri" == inCommand.rawValue, let streamingURI = inParams as? RVS_ONVIF_Profile_S.Stream_URI {
            if let videoDisplayScreen = profileScreen.storyboard?.instantiateController(withIdentifier: "RVS_ONVIF_Mac_Test_Harness_VideoDisplayViewController") as? RVS_ONVIF_Mac_Test_Harness_VideoDisplayViewController {
                videoDisplayScreen.streamingURL = streamingURI.uri
                #if DEBUG
                    print("StreamingURI: \(streamingURI.uri.absoluteString)")
                #endif
                profileScreen.presentAsSheet(videoDisplayScreen)
            }
            return true
        } else {
            let alert = NSAlert()
            alert.messageText = "\(inCommand.rawValue)Response:\n"
            alert.informativeText = String(describing: inParams)
            alert.addButton(withTitle: "OK")
            alert.runModal()
            return true
        }
    }
}
