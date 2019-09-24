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

import XCTest

/* ###################################################################################################################################### */
/**
 This is a special testing subclass of the RVS_ONVIF class. It will implement the ability to insert mock transactions above the SOAPEngine.
 
 Unfortunately, we can't inject into SOAPEngine, so these tests exclude it. However, we have to assume that SOAPEngine is solid. Good bet.
 */
class RVS_ONVIF_TestTarget: RVS_ONVIF {
    /// The mock device being used to test this.
    var targetMock: RVS_ONVIF_TestTarget_MockDevice!
    
    /* ################################################################## */
    /**
     This is a special intializer for this class. We eschew the main factory method in favor of our own instantiator.
     
     - parameter mock: This is an instance of a subclass of RVS_ONVIF_TestTarget_MockDevice. It's the "device" that we'll test with.
     - parameter delegate: This is an optional (default is nil) parameter that allows you to specify a delegate up front. If it is provided, the instance will be immediately initialized.
     - parameter dispatchers: This is an optional (default is empty) Array of dispatchers.
     */
    internal init(mock inMock: RVS_ONVIF_TestTarget_MockDevice, delegate inDelegate: RVS_ONVIFDelegate! = nil, dispatchers inDispatchers: [RVS_ONVIF_Dispatcher] = []) {
        super.init()
        targetMock = inMock
        ipAddressAndPort = "127.0.0.1:80"
        loginCredentials = RVS_ONVIF.LoginCredentialTuple(login: "test", password: "test")
        _testingSetup = true    // By setting this to true, we intercept communications to a device, allowing us to inject our own data.
        dispatchers = inDispatchers
        defer { // We do this, to make sure that didSet gets called.
            let core = (RVS_ONVIF_Core(owner: self))
            core.supportedNamespaces = type(of: core).namespaces
            _profiles[String(describing: type(of: core).self)] = core
            authMethod = .both
            delegate = inDelegate
        }
    }
    
    /* ################################################################################################################################## */
    // MARK: - Internal Instance Methods
    /* ################################################################################################################################## */
    /* ################################################################## */
    /**
     Bypass a SOAP request
     Responses happen through the error and success instance callbacks.
     
     - parameter request: The Device Request instance.
     - parameter params: An optional (default is nil) parameter that contains parameters to be added to the SOAP request.
     - parameter asSSL: An optional Bool (default is false), that requires the request to be made as SSL (HTTPS).
     - parameter path: An optional (default is empty string) path. If provided, it will trump the one in the request.
     */
    override internal func _performSOAPRequest(request inRequest: RVS_ONVIF_DeviceRequestProtocol, params inParams: [String: Any]! = nil, asSSL inAsSSL: Bool = false, path inPath: String = "") {
        let path = inPath.isEmpty ? inRequest.pathFor(self) : inPath
        var soup: [String: Any] = ["action": inRequest.soapAction]
        
        // See if we need to make this HTTPS.
        let reqURLString = "http" + (inAsSSL ? "s" : "") + "://" + self.ipAddressAndPort + path
        
        #if DEBUG
            print("Test SOAP Request URL: \(reqURLString)")
        #endif
        
        // Set up the parameters for the SOAP call.
        if let params = inParams {
            #if DEBUG
                print("Test SOAP Request Parameters: \(params)")
            #endif
            var modifiedParams: [String: Any] = [:]
            
            params.forEach {
                var namespace = ""
                if nil == $0.key.firstIndex(of: ":") {
                    namespace = inRequest.soapSpace + ":"
                }
                modifiedParams["\(namespace)\($0.key)"] = $0.value
            }
            
            modifiedParams.forEach {
                let param = $0
                if let array = param.value as? [Any] {
                    array.forEach {
                        soup[param.key] = $0
                    }
                } else {
                    soup[param.key] = param.value
                }
            }
        }
        
        #if DEBUG
            print("Test SOAP Request: \(String(describing: soup))")
        #endif
        
        if let response = targetMock.makeTransaction(soup) {
            // We do this, so that we test against a separate thread.
            DispatchQueue.global().async { [unowned self] in
                self._successCallback(response, soapRequest: inRequest.soapAction)
            }
        }
    }
}
