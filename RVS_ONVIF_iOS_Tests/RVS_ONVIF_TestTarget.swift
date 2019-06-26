/**
 © Copyright 2019, The Great Rift Valley Software Company. All rights reserved.
 
 This code is proprietary and confidential code,
 It is NOT to be reused or combined into any application,
 unless done so, specifically under written license from The Great Rift Valley Software Company.
 
 The Great Rift Valley Software Company: https://riftvalleysoftware.com
 */

import XCTest

/* ###################################################################################################################################### */
/**
 This is a special testing subclass of the RVS_ONVIF class. It will implement the ability to insert mock transactions into the SOAPEngine.
 */
class RVS_ONVIF_TestTarget: RVS_ONVIF {
    var targetMock: RVS_ONVIF_TestTarget_MockDevice!
    
    /* ################################################################## */
    /**
     This is a special intializer for this class. We eschew the main factory method in favor of our own instantiator.
     
     - parameter delegate: This is an optional (default is nil) parameter that allows you to specify a delegate up front. If it is provided, the instance will be immediately initialized.
     */
    internal init(mock inMock: RVS_ONVIF_TestTarget_MockDevice, delegate inDelegate: RVS_ONVIFDelegate! = nil) {
        super.init()
        targetMock = inMock
        ipAddressAndPort = "127.0.0.1:80"
        loginCredentials = RVS_ONVIF.LoginCredentialTuple(login: "test", password: "test")
        _testingSetup = true    // By setting this to true, we intercept communications to a device, allowing us to inject our own data.
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
     This is inspired by the ONVIFCamera library, by Rémy Virin, but I'm a jerk, and couldn't leave well enough alone.
     
     Perform a SOAP request
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
            _successCallback(response, soapRequest: inRequest.soapAction)
        }
    }
}
