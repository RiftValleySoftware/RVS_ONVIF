/**
 © Copyright 2019, The Great Rift Valley Software Company. All rights reserved.
 
 This code is proprietary and confidential code,
 It is NOT to be reused or combined into any application,
 unless done so, specifically under written license from The Great Rift Valley Software Company.
 
 The Great Rift Valley Software Company: https://riftvalleysoftware.com
 */

import Foundation
import SOAPEngine64

/* ###################################################################################################################################### */
/**
 This extension of the main class implements methods and data types that are not meant to be exported to users of the framework.
 */
extension RVS_ONVIF {
    /* ################################################################################################################################## */
    // MARK: - Callback Handlers
    /* ################################################################################################################################## */
    /* ################################################################## */
    /**
     This is called if there was an error during the SOAP request.
     
     - parameter inReason: An Errors enum, with associated values, that defines what happened.
     - parameter soapRequest: The SOAP request object call, as a String. This is optional. Defaul is empty string.
     - parameter soapEngine: The SOAPEngine object that executed the request. This is optional. Default is nil.
     */
    internal func _errorCallback(_ inReason: RVS_Fault!, soapRequest inSOAPRequest: String = "", soapEngine inSOAPEngine: SOAPEngine! = nil) {
        #if DEBUG
            print("Unsuccessful \(inSOAPRequest) SOAP Call. Reason: \(String(describing: inReason))")
        #endif
        
        delegate?.onvifInstance(self, failureWithReason: inReason)
    }
    
    /* ################################################################## */
    /**
     This is called upon a successful SOAP call.
     
     - parameter inResponseDictionary: The Dictionary ([String: Any]) of the response data.
     - parameter soapRequest: The SOAP request object call, as a String
     - parameter soapEngine: The SOAPEngine object that executed the request.
     */
    internal func _successCallback(_ inResponseDictionary: [String: Any], soapRequest inSOAPRequest: String, soapEngine inSOAPEngine: SOAPEngine! = nil) {
        #if DEBUG
            print("Response from \(inSOAPRequest) SOAP Call. Data: " + String(describing: inResponseDictionary))
        #endif
        
        // We try each profile handler. If it eats the callback, we simply drop out.
        for profileHandler in profiles where profileHandler.value.callbackHandler(inResponseDictionary, soapRequest: inSOAPRequest, soapEngine: inSOAPEngine) {
            return
        }
        
        // If we made it all the way here without being eaten, then we have an unhandled response, and it's an error.
        _errorCallback(RVS_Fault(faultCode: .UnknownSOAPError(error: nil)), soapRequest: inSOAPRequest, soapEngine: inSOAPEngine)
    }
    
    /* ################################################################## */
    /**
     This is called after the first GetServices call. We set up our appropriate profile handlers, here, and assign them each their supported namespaces.
     */
    internal func _setUpProfileHandlers() {
        if let scopeArray = scopes {
            scopeArray.forEach {
                switch $0.category {
                case .Profile(let profileVal):
                    if .S("") == profileVal {
                        let newProfile = RVS_ONVIF_Profile_S(owner: self)
                        _addProfile(newProfile)
                    }

                default:
                    break
                }
            }
        }
    }
    
    /* ################################################################## */
    /**
     This adds the selected profile to our list.
     
     - parameter inProfile: The profile instance we'll be adding.
     */
    internal func _addProfile(_ inProfile: ProfileHandlerProtocol) {
        var profile = inProfile
        
        // We use namespaces, instead of scopes, just to make sure all our bases are covered.
        services.forEach {
            if type(of: profile).namespaces.contains($0.value.namespace) {
                profile.supportedNamespaces.append($0.value.namespace)
            }
        }
        
        let profileTag = String(describing: type(of: profile).self)
        _profiles[profileTag] = profile
    }

    /* ############################################################################################################################## */
    // MARK: - Internal Classes
    /* ############################################################################################################################## */
    /* ################################################################## */
    /**
     This is inspired by the ONVIFCamera library, by Rémy Virin, but I'm a jerk, and couldn't leave well enough alone.
     
     This is a class that we use to manage a basic HTTP probe of the device, in order to trigger an authentication challenge.
     */
    internal class _AuthorizationSetup: NSObject, URLSessionTaskDelegate, URLSessionDelegate {
        /// This will hold the active URLSession
        private var _session: URLSession!
        /// This will hold the Dispatch Group we are using to synchronize the threads.
        private var _group: DispatchGroup!
        /// This will hold the authorization credentials.
        private var _authCred: [String: String] = [:]
        
        /* ############################################################## */
        /**
         This is a basic "post and parse" method. It sends the SOAP request, then parses the Www-Authenticate header.
         
         - parameter urlString: The URI to check, as a String
         
         - returns: a String, with the realm. Nil, if there was a problem.
         */
        private func _post(urlString inURIString: String) -> [String: String]? {
            if let url = URL(string: inURIString) {
                // We use a dispatch group, even though we have only one thread, because we want to make sure we wait until it's done.
                _group = DispatchGroup()
                _group.enter()
                var request = URLRequest(url: url)
                request.httpMethod = "POST"
                
                // What we do, is "poke" the device, and expect to get a challenge in response, with a Www-Authenticate header, containing the SOAP realm for authentication.
                let xmlString = "<?xml version=\"1.0\" encoding=\"utf-8\"?><soap:Envelope xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\" xmlns:soap=\"http://www.w3.org/2003/05/soap-envelope\"  xmlns:trt=\"http://www.onvif.org/ver10/device/wsdl\"><soap:Body><trt:GetDeviceInformation/></soap:Body></soap:Envelope>"
                
                request.httpBody = xmlString.data(using: .utf8)
                
                let sessionConfig = URLSessionConfiguration.ephemeral   // We use an ephemeral session in order to avoid having the realm cached.
                sessionConfig.timeoutIntervalForRequest = 1             // Short timeout to catch naughty Digest responses.

                _session = URLSession(configuration: sessionConfig)
                
                let task = _session.downloadTask(with: request) { [unowned self] (_ inURL: URL?, _ inResponse: URLResponse?, _ inError: Error?) in
                    #if DEBUG
                        print("Data: \(String(describing: inURL))")
                        print("Response: \(String(describing: inResponse))")
                        print("Error: \(String(describing: inError))")
                        print("HTTP Response: \(String(describing: inResponse))")
                    #endif
                    // Upon return, we should have a response that can be parsed. We ignore errors, if the header is there.
                    if let httpStatus = inResponse as? HTTPURLResponse, httpStatus.statusCode == 401, let authenticateHeader = httpStatus.allHeaderFields["Www-Authenticate"] as? String {
                        // Get the realm and other params from the authentication challenge.
                        self._authCred = self._extractAuthenticateParams(authenticateHeader: authenticateHeader).reduce(into: [String: String](), { (reductionBase, elem) in
                            let key = elem.key.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
                            var value = elem.value.trimmingCharacters(in: .whitespacesAndNewlines)
                            switch key {
                            case "stale":
                                // Make sure that we have something in the stale flag.
                                value = "true" == value.lowercased() ? "true" : "false"
                            case "url":
                                value = url.relativePath    // This is the path that applies to the auth header. It is server-relative.
                            case "method":
                                value = "POST" // We always ring twice (We always POST).
                            default:
                                ()
                            }
                            
                            reductionBase[key] = value
                        })
                    }
                    
                    // Make sure that we wrap everything up.
                    self._session.invalidateAndCancel()
                    self._group.leave()
                }

                task.resume()
                
                _group.wait()
                _group = nil
                _session = nil
            }
            
            return _authCred.isEmpty ? nil : _authCred
        }

        /* ############################################################## */
        /**
         This is a parser for the realm components, parsing the response header.
         
         - parameter authenticateHeader: The Www-Authenticate header value.
         
         - returns: a Dictionary, with the realm and nonce parameters.
         */
        private func _extractAuthenticateParams(authenticateHeader inAuthenticateHeader: String) -> [String: String] {
            let header = String(inAuthenticateHeader.dropFirst(7))  // We drop the first seven characters ("Digest").
            
            let ret = header.split(separator: ",").reduce(into: [String: String](), {
                let pair = $1.split(separator: "=")
                
                if let key = pair.first?.trimmingCharacters(in: .whitespacesAndNewlines),
                    let value = pair.last?.trimmingCharacters(in: .whitespacesAndNewlines).replacingOccurrences(of: "\"", with: "") {
                    $0[key] = value
                }
            })
            
            return ret
        }
        
        /* ############################################################################################################################## */
        // MARK: - Internal Instance Methods
        /* ############################################################################################################################## */
        /* ############################################################## */
        /**
         This is actually just an internal accessor for the private method.
         
         - parameter for: The URI, as a String, that we are fetching a realm for.
         - returns: The Digest auth data, in a Dictionary.
         */
        internal func authCreds(for inURL: String) -> [String: String]? {
            return _post(urlString: inURL)
        }
    }
    
    /* ############################################################################################################################## */
    // MARK: - Internal Class Methods
    /* ############################################################################################################################## */
    /* ################################################################## */
    /**
     This just tests a given string to ensure that it's a valid IP and port address.
     */
    internal class func _isValidIPAddressAndPort(_ inAddressAndPort: String) -> Bool {
        return nil != inAddressAndPort.ipAddress
    }

    /* ################################################################################################################################## */
    // MARK: - Internal Instance Methods
    /* ################################################################################################################################## */
    /* ################################################################################################################################## */
    // MARK: - Robust Leaf Parsers
    /* ################################################################################################################################## */
    /**
     The following few methods are used to provide robust parsing for "leaf" values (at the end of parse trees).
     These will attempt numerous ways to decipher the value, as they can be presented in more than one way.
     */
    /* ################################################################## */
    /**
     This parses a simple string.
     
     - parameter inDictionary: The Dictionary, partially parsed by SOAPEngine.
     - parameter key: The key for the Dictionary element we'll be parsing.
     
     - returns: The String that was parsed. Nil, if the parse failed.
     */
    internal func _parseString(_ inDictionary: [String: Any], key inKey: String) -> String! {
        if let valStr = inDictionary[inKey] as? String {
            return valStr
        } else if let valContainer = inDictionary[inKey] as? [String: Any] {
            if let valStr = valContainer["value"] as? String {
                return valStr
            }
        } else if let attributes = inDictionary["attributes"] as? [String: String], let valStr = attributes[inKey] {
            return valStr
        } else if let valStr = inDictionary[inKey] as? [String], 1 == valStr.count {
            return valStr[0]
        }
        
        return nil
    }

    /* ################################################################## */
    /**
     This parses a generic Dictionary with a bunch of "value" parameters.
     
     It "cleans" the Dictionary, so the value is the actual entry value, not one a couple of steps removed.
     
     - parameter inValueDict: The raw Dictionary. If the entries don't have a "value" member, they will simply be copied verbatim.
     
     - returns: A Dictionary, with the "value" fetched and set as the main entry value. No other interpretation is done.
     */
    internal func _parseValueDict(_ inValueDict: [String: Any]) -> [String: Any] {
        var ret: [String: Any] = [:]
        
        inValueDict.forEach {
            if let valueItem = $0.value as? [String: Any], let value = valueItem["value"] {
                ret[$0.key] = value
            } else {    // Just a straight copy, if no "value" member.
                ret[$0.key] = $0.value
            }
        }
        
        return ret
    }

    /* ################################################################## */
    /**
     This parses a duration out of the given Dictionary.
     
     - parameter inDictionary: The Dictionary, partially parsed by SOAPEngine.
     - parameter key: The key for the Dictionary element we'll be parsing.
     
     - returns: A DateComponents instance, with the parsed duration. Nil, if the parse failed.
     */
    internal func _parseDuration(_ inDictionary: [String: Any], key inKey: String) -> DateComponents! {
        if let target = _parseString(inDictionary, key: inKey) {
            return target.asXMLDuration
        }
        return nil
    }
 
    /* ################################################################## */
    /**
     This parses an IP Address (any kind). It ignores the type, and makes up its own mind.
     
     - parameter inDictionary: The Dictionary, partially parsed by SOAPEngine.
     - parameter key: The key for the Dictionary element we'll be parsing.
     
     - returns: An instance of RVS_IPAddress, set to the type of IP address.
     */
    internal func _parseIPAddress(_ inDictionary: [String: Any]) -> RVS_IPAddress! {
        if let ipAddressString = (inDictionary["IPv6Address"] ?? inDictionary["IPv4Address"] ?? inDictionary["Address"]) as? String {
            return ipAddressString.ipAddress
        } else if let ipAddressStringWrapper = (inDictionary["IPv6Address"] ?? inDictionary["IPv4Address"] ?? inDictionary["Address"]) as? [String: Any],
            let ipAddressString = ipAddressStringWrapper["value"] as? String {
            return ipAddressString.ipAddress
        }
        return nil
    }

    /* ################################################################## */
    /**
     This parses a simple Boolean value from the given Dictionary.
     
     - parameter inDictionary: The Dictionary, partially parsed by SOAPEngine.
     - parameter key: The key for the Dictionary element we'll be parsing.
     
     - returns: True or False, dependent upon the Bool value. False will be returned if the parse fails.
     */
    internal func _parseBoolean(_ inDictionary: [String: Any], key inKey: String) -> Bool {
        if let valStr = _parseString(inDictionary, key: inKey) {
            return "true" == valStr
        }
        
        return false
    }
    
    /* ################################################################## */
    /**
     This parses a simple integer from the given Dictionary.
     
     - parameter inDictionary: The Dictionary, partially parsed by SOAPEngine.
     - parameter key: The key for the Dictionary element we'll be parsing.
     
     - returns: The parsed integer. Nil, if the parse failed.
     */
    internal func _parseInteger(_ inDictionary: [String: Any], key inKey: String) -> Int! {
        if let valStr = _parseString(inDictionary, key: inKey) {
            return (valStr as NSString).integerValue
        }
        
        return nil
    }
    
    /* ################################################################## */
    /**
     This parses a floating-point number from the given Dictionary.
     
     - parameter inDictionary: The Dictionary, partially parsed by SOAPEngine.
     - parameter key: The key for the Dictionary element we'll be parsing.
     
     - returns: The parsed float. Nil, if the parse failed.
     */
    internal func _parseFloat(_ inDictionary: [String: Any], key inKey: String) -> Float! {
        if let valStr = _parseString(inDictionary, key: inKey) {
            return (valStr as NSString).floatValue
        }
        
        return nil
    }
    
    /* ################################################################## */
    /**
     This parses a size from the given Dictionary.
     
     - parameter inDictionary: The Dictionary, partially parsed by SOAPEngine.
     - parameter key: The key for the Dictionary element we'll be parsing.
     
     - returns: The parsed size. Nil, if the parse failed.
     */
    internal func _parseSize(_ inDictionary: [String: Any], key inKey: String) -> CGSize! {
        if let wrapper = inDictionary[inKey] as? [String: Any], let width = _parseFloat(wrapper, key: "Width"), let height = _parseFloat(wrapper, key: "Height") {
            return CGSize(width: CGFloat(width), height: CGFloat(height))
        }
        
        return nil
    }

    /* ################################################################################################################################## */
    // MARK: - Connection Lifecycle Methods
    /* ################################################################################################################################## */
    /* ################################################################## */
    /**
     This is called to initialize the connection.
     */
    internal func _initializeConnection() {
        if let core = _profiles[String(describing: RVS_ONVIF_Core.self)] as? RVS_ONVIF_Core, nil != delegate {
            core.deviceInformation = [:]
            core.services = [:]
            core.scopes = []
            core.capabilities = nil
            core.serviceCapabilities = nil
            _profiles = [String(describing: RVS_ONVIF_Core.self): core] // Just the core, for now. We will add the other handlers as needed.
            core._fetchDeviceInformation()
        }
    }

    /* ################################################################## */
    /**
     This is called to deinitialize the connection.
     */
    internal func _deinitializeConnection() {
        if let core = _profiles[String(describing: RVS_ONVIF_Core.self)] as? RVS_ONVIF_Core, nil != delegate {
            core.deviceInformation = [:]
            core.services = [:]
            core.scopes = []
            core.capabilities = nil
            core.serviceCapabilities = nil
            _authData = [:]
            _profiles = [String(describing: RVS_ONVIF_Core.self): core] // Make sure that we leave the core handler, for if we want to reinitialize.
            DispatchQueue.main.async {  // We always make callbacks in the main thread.
                self.delegate?.onvifInstanceDeinitialized(self)
            }
        }
    }
    
    /* ################################################################################################################################## */
    // MARK: - Internal SOAPEngine Caller
    /* ################################################################################################################################## */
    /* ################################################################## */
    /**
     This may be called in non-main threads.
     
     This is a special base method that is designed to be overridden. If the module is set to be tested, then this is called, instead of the regular method.
     
     - parameter inSOAPEngine: The SOAPEngine instance calling this method. It may be nil.
     - parameter didBeforeSendingURLRequest: This is a URL Request that will be sent. You can modify this.
     - returns nil.
     */
    @objc internal func _soapEngine(_ soapEngine: SOAPEngine!, didBeforeSendingURLRequest inRequest: NSMutableURLRequest!) -> NSMutableURLRequest! {
        return nil
    }

    /* ################################################################################################################################## */
    // MARK: - Public SOAPEngineDelegate Instance Methods
    /* ################################################################################################################################## */
    /**
     These callbacks need to be declared as public, even though there is no reason to expose them.
     */
    /* ################################################################## */
    /**
     This may be called in non-main threads.
     
     This is called before sending out a request. It has the request formed by SOAPEngine.
     We use this method to form our own Digest Auth.
     
     - parameter inSOAPEngine: The SOAPEngine instance calling this method. It may be nil.
     - parameter didBeforeSendingURLRequest: This is a URL Request that will be sent. You can modify this.
     - returns the NSURLRequest object.
     */
    public func soapEngine(_ soapEngine: SOAPEngine!, didBeforeSendingURLRequest inRequest: NSMutableURLRequest!) -> NSMutableURLRequest! {
        #if DEBUG
            print("didBeforeSendingURLRequest: \(String(describing: inRequest))")
            if _testingSetup {
                print("Testing Setup -Communication Will be Interrupted.")
            }
        #endif
        // If we are testing,
        if _testingSetup {
            return _soapEngine(soapEngine, didBeforeSendingURLRequest: inRequest)
        } else {
            // Build an RFC2617 authentication header (https://tools.ietf.org/html/rfc2617)
            if .AUTH_CUSTOM == soapEngine.authorizationMethod, let username = _authData?["username"], let realm = _authData?["realm"], let password = _authData?["password"], let uri = _authData?["uri"], let method = _authData?["method"], let nonce = _authData?["nonce"], let qop = _authData?["qop"], let body = String(data: inRequest.httpBody ?? Data(), encoding: .utf8) {
                let cnonce = NSUUID().uuidString.replacingOccurrences(of: "-", with: "")
                var ha1: String = "\(username):\(realm):\(password)".md5
                var ha2: String = "\(method):\(uri)".md5
                var response = ""
                var extra = ""
                
                if let opaque = _authData?["opaque"] {
                    extra = ", opaque=\"\(opaque)\""
                }
                
                if "MD5-sess" == method {
                    ha1 = (ha1 + ":\(nonce):\(cnonce)").md5
                }
                
                switch qop {
                case "auth-int":
                    ha2 = ("\(method):\(uri):" + body.md5).md5
                    fallthrough
                    
                case "auth":
                    response = "\(ha1):\(nonce):\(String(_nonceCount)):\(cnonce):\(qop):\(ha2)".md5
                    _nonceCount += 1
                    
                default:
                    response = "\(ha1):\(nonce):\(ha2)".md5
                }
                
                let authenticationHeader = "Digest response=\"\(response)\", nonce=\"\(nonce)\", method=\"\(method)\", username=\"\(username)\", uri=\"\(uri)\", qop=\"\(qop)\", cnonce=\"\(cnonce)\"" + extra
                
                soapEngine.header = authenticationHeader
            }
            
            return inRequest
        }
    }
    
    /* ################################################################## */
    /**
     This may be called in non-main threads.
     
     This is called if there was a SOAPEngine failure.
     
     - parameter inSOAPEngine: The SOAPEngine instance calling this method. It may be nil.
     - parameter didFailWithError: The actual error object from the SOAPEngine. It may be nil.
     */
    public func soapEngine(_ inSOAPEngine: SOAPEngine!, didFailWithError inError: Error!) {
        #if DEBUG
            print("didFailWithError: \(String(describing: inError))")
        #endif
        DispatchQueue.main.async {
            self.delegate?.onvifInstance(self, failureWithReason: RVS_Fault(faultCode: .UnknownSOAPError(error: inError)))
        }
    }
    
    /* ################################################################## */
    /**
     This may be called in non-main threads.
     
     This is called when the SOAPEngine has finished parsing the input data.
     
     - parameter inSOAPEngine: The SOAPEngine instance calling this method. It may be nil.
     - parameter didFinishLoadingWith: The data, parsed into a Dictionary.
     - parameter data: The data, unseasoned and uncooked.
     */
    public func soapEngine(_ inSOAPEngine: SOAPEngine!, didFinishLoadingWith inDict: [AnyHashable: Any]!, data inData: Data!) {
        #if DEBUG
            print("didFinishLoadingWith Dictionary: \(String(describing: inDict))")
        
            if let returnedData = String(data: inData, encoding: .utf8) {
                print("didFinishLoadingWith Data (Parsed): \(returnedData)")
            }
        #endif
        DispatchQueue.main.async {  // Handlers are always in the main thread.
            if let dict = inDict as? [String: Any] {
                if let fault = RVS_Fault(faultDictionary: dict) {   // If the response is a fault response, we'll get a fault object. Otherwise, it will be nil.
                    self._errorCallback(fault, soapRequest: inSOAPEngine.soapActionRequest, soapEngine: inSOAPEngine)
                } else if let responseBody = dict["Body"] as? [String: Any] { // We get here, we're golden. This is the Chosen Path...
                    self._successCallback(responseBody, soapRequest: inSOAPEngine.soapActionRequest, soapEngine: inSOAPEngine)
                } else {    // If neither of the above is true, then we have a different issue.
                    if let response = inSOAPEngine.response as? HTTPURLResponse {   // Let's see if we can at least get an HTTP response out the request.
                        let statusCode = response.statusCode
                        let fault = RVS_Fault(faultCode: .HTTPError(httpError: statusCode))
                        self._errorCallback(fault, soapRequest: inSOAPEngine.soapActionRequest, soapEngine: inSOAPEngine)
                    } else {    // We're on our own.
                        self._errorCallback(RVS_Fault(faultCode: .UnknownSOAPError(error: nil)), soapRequest: inSOAPEngine.soapActionRequest, soapEngine: inSOAPEngine)
                    }
                }
            } else {    // Nasty problem, here.
                self._errorCallback(RVS_Fault(faultCode: .UnknownSOAPError(error: nil)), soapRequest: inSOAPEngine.soapActionRequest, soapEngine: inSOAPEngine)
            }
        }
    }
}
