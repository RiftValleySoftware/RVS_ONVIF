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
 This class implements the Profile S functionality.
 */
public class RVS_ONVIF_Profile_S: ProfileHandlerProtocol {
    /* ################################################################################################################################## */
    // MARK: - Private Static Properties
    /* ###################################################################################################################################### */
    /* ################################################################## */
    /**
     This is the key name for this class.
     */
    private static let _profileName = "PROFILE-S"
    
    /* ################################################################################################################################## */
    // MARK: - Private Instance Properties
    /* ###################################################################################################################################### */
    /** This is the internal stored property for the "owner" of this instance. */
    private let _owner: RVS_ONVIF!

    /* ############################################################################################################################## */
    // MARK: - Internal Enums
    /* ############################################################################################################################## */
    /* ################################################################## */
    /**
     This is inspired by the ONVIFCamera library, by Rémy Virin, but I'm a jerk, and couldn't leave well enough alone.
     These use ONVIF TitleCase, as opposed to the standard Swift camelCase, in order to match the SOAP request.
     */
    internal enum _DeviceRequest: String, RVS_ONVIF_DeviceRequestProtocol, CaseIterable {
        case GetProfiles
        case GetStreamUri
        case GetVideoSourceConfigurations
        
        /* ########################################################################################################################## */
        // MARK: - Internal Structs
        /* ########################################################################################################################## */
        /* ############################################################## */
        /**
         This is the profile key (for looking up in the profile hander list).
         */
        var profileKey: String {
            return "RVS_ONVIF_Profile_S"
        }

        /* ############################################################## */
        /**
         Indicate if we should retrieve the attributes inside the xml element, for instance it's needed
         in `getProfiles` to retrieve the token: `<Profiles token="MediaProfile000" fixed="true">`
         */
        var isRetrieveAttributes: Bool {
            return .GetProfiles == self || .GetVideoSourceConfigurations == self
        }
        
        /* ############################################################## */
        /**
         Return whether or not the particular call requires additional parameters, or can be called standalone.
         */
        var isRequiresParameters: Bool {
            var ret = false
            
            switch self {
            case .GetStreamUri:
                ret = true
                
            default:
                break
            }
            
            return ret
        }
    }

    /* ################################################################################################################################## */
    // MARK: - Internal Instance Properties
    /* ################################################################################################################################## */
    /* ################################################################## */
    /**
     This caches the last GetProfiles call. It stores them by token, for quick retrieval.
     */
    internal var _cachedProfiles: [String: RVS_ONVIF_Profile_S.Profile] = [:]

    /* ################################################################################################################################## */
    // MARK: - Internal Instance Initializer
    /* ###################################################################################################################################### */
    /* ################################################################## */
    /**
     We make this internal, so it doesn't get instantiated willy-nilly.
     
     - parameter owner: The "Owning" main ONVIF instance. It is guaranteed to have an instance of this class in its ".profileS" variable.
     */
    internal init(owner inOwner: RVS_ONVIF) {
        _owner = inOwner
    }

    /* ################################################################################################################################## */
    // MARK: - Internal Instance Methods
    /* ###################################################################################################################################### */
    /* ################################################################## */
    /**
     This begins the process of fetching a Stream URI, for the given profile.
     
     This is meant to be called from within an Profile instance.
     
     - parameter token: The String token for the profile requesting this.
     - parameter andStreamType: The Stream type (RTP-Unicast or RTP-Multicast).
     - parameter andProtocol: The transport protocol (UDP or TCP).
     */
    internal func _fetchStreamURI(withToken inToken: String, andStreamType inStreamType: String, andProtocol inProtocol: String) {
        let request = _DeviceRequest.GetStreamUri
        owner.performRequest(request, params: ["StreamSetup": ["\(request.paramSpace):Stream": inStreamType, "\(request.paramSpace):Transport": ["\(request.paramSpace):Protocol": inProtocol]], "ProfileToken": inToken])
    }

    /* ############################################################################################################################## */
    // MARK: - GetProfiles Parsers
    /* ############################################################################################################################## */
    /* ################################################################## */
    /**
     This parses the response to the profile request, and builds up a list of profiles for the device.
     
     - parameter inResponseBody: The Dictionary ([String: Any]) of the response body data.
     - returns: An Array of Profile struct instances, created from the response data.
     */
    internal func _parseProfilesDictionary(_ inResponseBody: [String: Any]) -> [RVS_ONVIF_Profile_S.Profile] {
        var ret: [RVS_ONVIF_Profile_S.Profile] = []
        
        if let profileResponse = inResponseBody["GetProfilesResponse"] as? [String: Any], let profiles = profileResponse["Profiles"] as? [[String: Any]] {
            profiles.forEach {
                if let nameDict = $0["Name"] as? [String: Any], let name = nameDict["value"] as? String {
                    if let attributes = $0["attributes"] as? [String: Any], let token = attributes["token"] as? String {
                        var ptzConfiguration: PTZConfiguration!
                        var videoEncoderConfiguration: VideoEncoderConfiguration!
                        
                        if let ptzConfig = $0["PTZConfiguration"] as? [String: Any], let nameDict = ptzConfig["Name"] as? [String: Any], let name = nameDict["value"] as? String {
                            var panTiltLimits: PanTiltLimits!
                            var zoomLimits: ZoomLimits!
                            var token: String!
                            
                            if let panTilt = ptzConfig["PanTiltLimits"] as? [String: Any] {
                                panTiltLimits = _parsePanTiltLimits(panTilt)
                            }
                            
                            if let zoom = ptzConfig["ZoomLimits"] as? [String: Any] {
                                zoomLimits = _parseZoomLimits(zoom)
                            }
                            
                            if let attributes = ptzConfig["attributes"] as? [String: Any], let tokenStr = attributes["token"] as? String {
                                token = tokenStr
                            }
                            
                            ptzConfiguration = PTZConfiguration(owner: owner, name: name, token: token, panTiltLimits: panTiltLimits, zoomLimits: zoomLimits)
                        }
                        
                        if let vcConfig = $0["VideoEncoderConfiguration"] as? [String: Any] {
                            #if DEBUG
                            print(vcConfig)
                            #endif
                            videoEncoderConfiguration = _parseVideoEncoderConfiguration(vcConfig)
                        }
                        
                        let newProfile = RVS_ONVIF_Profile_S.Profile(owner: owner, name: name, token: token, ptzConfiguration: ptzConfiguration, videoEncoderConfiguration: videoEncoderConfiguration)
                        ret.append(newProfile)
                    }
                }
            }
        }
        
        return ret
    }

    /* ################################################################## */
    /**
     This parses the video encoder config for this profile.
     
     - parameter inVideoEncoderConfiguration: The encoder raw Dictionary.
     
     - returns: A populated VideoEncoderConfiguration instance. Nil, if there was an issue.
     */
    internal func _parseVideoEncoderConfiguration(_ inVideoEncoderConfiguration: [String: Any]) -> VideoEncoderConfiguration! {
        var name: String!
        var useCount: Int!
        var token: String!
        var rateControl: RateControl!
        var multicast: Multicast!
        var quality: Int!
        var encodingParameters: [String: Any]!
        var encoding: EncodingTypes = .error
        var resolution: CGSize = CGSize.zero
        var timeoutInSeconds: Int = 0
        
        if let nameDict = inVideoEncoderConfiguration["Name"] as? [String: Any], let nameStr = nameDict["value"] as? String {
            name = nameStr
        }
        
        if let ucDict = inVideoEncoderConfiguration["UseCount"] as? [String: Any], let useCountInt = (ucDict["value"] as? NSString)?.integerValue {
            useCount = useCountInt
        }
        
        if let attributes = inVideoEncoderConfiguration["attributes"] as? [String: Any], let tokenStr = attributes["token"] as? String {
            token = tokenStr
        }
        
        if let multicastDict = inVideoEncoderConfiguration["Multicast"] as? [String: Any] {
            multicast = _parseMulticastConfiguration(multicastDict)
        }
        
        if let rateControlDict = inVideoEncoderConfiguration["RateControl"] as? [String: Any] {
            rateControl = _parseRateControlConfiguration(rateControlDict)
        }
        
        if let qDict = inVideoEncoderConfiguration["Quality"] as? [String: Any], let qInt = (qDict["value"] as? NSString)?.integerValue {
            quality = qInt
        }
        
        if let encDict = inVideoEncoderConfiguration["Encoding"] as? [String: Any], let encVal = EncodingTypes(rawValue: (encDict["value"] as? String)?.lowercased() ?? "error") {
            encoding = encVal
        }
        
        if let timeoutDict = inVideoEncoderConfiguration["SessionTimeout"] as? [String: Any], let attributes = timeoutDict["attributes"] as? [String: Any], let timeoutStr = attributes["value"] as? String {
            let numFormatter = NumberFormatter()
            numFormatter.numberStyle = .decimal
            if let tmInt = numFormatter.number(from: timeoutStr)?.intValue {
                timeoutInSeconds = tmInt
            }
        }
        
        if let encParameters = inVideoEncoderConfiguration[encoding.rawValue.uppercased()] as? [String: Any] {
            encodingParameters = _parseValueDict(encParameters)
        }
        
        if let rDict = inVideoEncoderConfiguration["Resolution"] as? [String: Any] {
            if let widthDict = rDict["Width"] as? [String: Any],
                let widthVal = (widthDict["value"] as? NSString)?.floatValue,
                let heightDict = rDict["Height"] as? [String: Any],
                let heightVal = (heightDict["value"] as? NSString)?.floatValue {
                resolution = CGSize(width: CGFloat(widthVal), height: CGFloat(heightVal))
            }
        }
        
        if nil != name || nil != useCount || nil != token || nil != rateControl || nil != multicast || nil != encodingParameters || nil != quality {
            return VideoEncoderConfiguration(owner: owner, name: name, useCount: useCount, token: token, encoding: encoding, timeoutInSeconds: timeoutInSeconds, rateControl: rateControl, multicast: multicast, quality: quality, resolution: resolution, encodingParameters: encodingParameters)
        }
        
        return nil
    }
    
    /* ################################################################## */
    /**
     This parses a generic Dictionary with a bunch of "value" parameters.
     
     It "cleans" the Dictionary, so the value is the actual entry value, not one a couple of steps removed.
     
     - parameter inValueDict: The raw Dictionary. If the entries don't have a "value" member, they will not be included.
     
     - returns: A Dictionary, with the "value" fetched and set as the main entry value. No other interpretation is done.
     */
    internal func _parseValueDict(_ inValueDict: [String: Any]) -> [String: Any] {
        var ret: [String: Any] = [:]
        
        inValueDict.forEach {
            if let valueItem = $0.value as? [String: Any], let value = valueItem["value"] {
                ret[$0.key] = value
            }
        }
        
        return ret
    }
    
    /* ################################################################## */
    /**
     This parses a Multicast Dictionary. We ignore type, and simply create an IP address from what they give us.
     
     - parameter inMulticastConfiguration: The raw Dictionary.
     
     - returns: A populated Multicast instance. Nil, if there was an issue.
     */
    internal func _parseMulticastConfiguration(_ inMulticastConfiguration: [String: Any]) -> Multicast! {
        if let addressDict = inMulticastConfiguration["Address"] as? [String: Any] {
            var ipAddress: RVS_IPAddress!
            var autoStart: Bool = false
            var port: Int = 0
            var ttl = DateComponents()
            
            if let asString = owner._parseString(addressDict, key: "AutoStart") {
                autoStart = "true" == asString.lowercased()
            }
            
            if let portInt = owner._parseInteger(addressDict, key: "Port") {
                port = portInt
            }
            
            if let ttlInt = owner._parseDuration(addressDict, key: "TTL") {
                ttl = ttlInt
            }
            
            ipAddress = owner._parseIPAddress(addressDict)
            
            return Multicast(owner: owner, ipAddress: ipAddress, autoStart: autoStart, port: port, ttl: ttl)
        }
        
        return nil
    }
    
    /* ################################################################## */
    /**
     This parses a Rate Control Dictionary.
     
     - parameter inRateControlConfiguration: The raw Dictionary.
     
     - returns: A populated RateControl instance. Nil, if there was an issue.
     */
    internal func _parseRateControlConfiguration(_ inRateControlConfiguration: [String: Any]) -> RateControl! {
        var frameRateLimit: Float!
        var encodingInterval: Float!
        var bitRateLimit: Int!
        
        if let frameRateLimitDict = inRateControlConfiguration["FrameRateLimit"] as? [String: Any], let frameRateLimitFloat = (frameRateLimitDict["value"] as? NSString)?.floatValue {
            frameRateLimit = frameRateLimitFloat
        }
        
        if let encodingIntervalDict = inRateControlConfiguration["EncodingInterval"] as? [String: Any], let encodingIntervalFloat = (encodingIntervalDict["value"] as? NSString)?.floatValue {
            encodingInterval = encodingIntervalFloat
        }
        
        if let bitRateLimitDict = inRateControlConfiguration["BitrateLimit"] as? [String: Any], let bitRateLimitInt = (bitRateLimitDict["value"] as? NSString)?.integerValue {
            bitRateLimit = bitRateLimitInt
        }
        
        return RateControl(owner: owner, frameRateLimit: frameRateLimit, encodingInterval: encodingInterval, bitRateLimit: bitRateLimit)
    }
    
    /* ################################################################## */
    /**
     This parses a Pan/Tilt Limits Dictionary.
     
     - parameter inPanTiltLimits: The raw Dictionary.
     
     - returns: A populated PanTiltLimits instance. Nil, if there was an issue.
     */
    internal func _parsePanTiltLimits(_ inPanTiltLimits: [String: Any]) -> PanTiltLimits! {
        if let range = inPanTiltLimits["Range"] as? [String: Any],
            let uriDict = range["URI"] as? [String: Any],
            let uriStr = uriDict["value"] as? String,
            let uri = URL(string: uriStr),
            let xRange = range["XRange"] as? [String: Any],
            let yRange = range["YRange"] as? [String: Any] {
            if let xRangeMin = xRange["Min"] as? [String: Any],
                let xMin = (xRangeMin["value"] as? NSString)?.floatValue,
                let xRangeMax = xRange["Max"] as? [String: Any],
                let xMax = (xRangeMax["value"] as? NSString)?.floatValue,
                let yRangeMin = yRange["Min"] as? [String: Any],
                let yMin = (yRangeMin["value"] as? NSString)?.floatValue,
                let yRangeMax = yRange["Max"] as? [String: Any],
                let yMax = (yRangeMax["value"] as? NSString)?.floatValue {
                return PanTiltLimits(owner: owner, xRange: xMin...xMax, yRange: yMin...yMax, uri: uri)
            } else if let xMin = (xRange["Min"] as? NSString)?.floatValue,  // If the device sent back simple values without a "value" component.
                      let xMax = (xRange["Max"] as? NSString)?.floatValue,
                      let yMin = (yRange["Min"] as? NSString)?.floatValue,
                      let yMax = (yRange["Max"]  as? NSString)?.floatValue {
                return PanTiltLimits(owner: owner, xRange: xMin...xMax, yRange: yMin...yMax, uri: uri)
            }
        }
        return nil
    }
    
    /* ################################################################## */
    /**
     This parses a Zoom Limits Dictionary.
     
     - parameter inZoomLimits: The raw Dictionary.
     
     - returns: A populated ZoomLimits instance. Nil, if there was an issue.
     */
    internal func _parseZoomLimits(_ inZoomLimits: [String: Any]) -> ZoomLimits! {
        if let range = inZoomLimits["Range"] as? [String: Any],
            let uriDict = range["URI"] as? [String: Any],
            let uriStr = uriDict["value"] as? String,
            let uri = URL(string: uriStr),
            let xRange = range["XRange"] as? [String: Any] {
            if let xRangeMin = xRange["Min"] as? [String: Any],
                let xMin = (xRangeMin["value"] as? NSString)?.floatValue,
                let xRangeMax = xRange["Max"] as? [String: Any],
                let xMax = (xRangeMax["value"] as? NSString)?.floatValue {
                return ZoomLimits(owner: owner, xRange: xMin...xMax, uri: uri)
            } else if let xMin = (xRange["Min"] as? NSString)?.floatValue,  // If the device sent back simple values without a "value" component.
                      let xMax = (xRange["Max"] as? NSString)?.floatValue {
                return ZoomLimits(owner: owner, xRange: xMin...xMax, uri: uri)
            }
        }
        
        return nil
    }

    /* ############################################################################################################################## */
    // MARK: - GetStreamURL Parsers
    /* ############################################################################################################################## */
    /* ################################################################## */
    /**
     This parses the response to the profile request, and builds up a list of profiles for the device.
     
     - parameter inResponseDictionary: The Dictionary ([String: Any]) of the response data.
     - returns: A Stream Struct, created from the response data.
     */
    internal func _parseURIDictionary(_ inResponseDictionary: [String: Any]) -> RVS_ONVIF_Profile_S.Stream_URI {
        #if DEBUG
            print(String(describing: inResponseDictionary))
        #endif
        var uri: URL!
        var invalidAfterConnect: Bool = false
        var invalidAfterReboot: Bool = false
        var timeoutInSeconds: Int = 0
        
        if let streamResponseDict = inResponseDictionary["GetStreamUriResponse"] as? [String: Any], let resultsList = streamResponseDict["MediaUri"] as? [String: String] {
            if let uriStr = resultsList["Uri"] {
                uri = URL(string: uriStr)
            }
            
            if let tf = resultsList["InvalidAfterConnect"] {
                invalidAfterConnect = tf == "true"
            }
            if let tf = resultsList["InvalidAfterReboot"] {
                invalidAfterReboot = tf == "true"
            }
            
            if let timeoutStr = resultsList["Timeout"] {
                let numFormatter = NumberFormatter()
                numFormatter.numberStyle = .decimal
                if let tmInt = numFormatter.number(from: timeoutStr)?.intValue {
                    timeoutInSeconds = tmInt
                }
            }
        } else if let streamResponseDict = inResponseDictionary["GetStreamUriResponse"] as? [String: String] {
            // It's entirely possible that we do not have a "wrapper," and need to access each item individually.
            if let uriStr = streamResponseDict["Uri"] {
                uri = URL(string: uriStr)
            }
            
            if let tf = streamResponseDict["InvalidAfterConnect"] {
                invalidAfterConnect = tf == "true"
            }
            
            if let tf = streamResponseDict["InvalidAfterReboot"] {
                invalidAfterReboot = tf == "true"
            }
            
            if let timeoutStr = streamResponseDict["Timeout"] {
                let numFormatter = NumberFormatter()
                numFormatter.numberStyle = .decimal
                if let tmInt = numFormatter.number(from: timeoutStr)?.intValue {
                    timeoutInSeconds = tmInt
                }
            }
        }
        
        return RVS_ONVIF_Profile_S.Stream_URI(owner: owner, uri: uri, invalidAfterConnect: invalidAfterConnect, invalidAfterReboot: invalidAfterReboot, timeoutInSeconds: timeoutInSeconds)
    }

    /* ############################################################################################################################## */
    // MARK: - GetVideoEncoderConfigurationOptions Parsers
    /* ############################################################################################################################## */
    /* ################################################################## */
    /**
     This parses the VideoEncoderConfigurationOptions Dictionary.
     
     - parameter inVideoEncoderConfigurationOptions: The raw Dictionary.
     
     - returns: A populated VideoEncoderConfigurationOptions instance. Nil, if there was an issue.
     */
    internal func _parseVideoEncoderConfigurationOptions(_ inVideoEncoderConfigurationOptions: [String: Any]) -> VideoEncoderConfigurationOptions! {
        var name: String!
        var useCount: Int!
        var token: String!
        var qualityRange: ClosedRange<Int>!
        
        if let nameDict = inVideoEncoderConfigurationOptions["Name"] as? [String: Any], let nameStr = nameDict["value"] as? String {
            name = nameStr
        }
        
        if let ucDict = inVideoEncoderConfigurationOptions["UseCount"] as? [String: Any], let useCountInt = (ucDict["value"] as? NSString)?.integerValue {
            useCount = useCountInt
        }
        
        if let attributes = inVideoEncoderConfigurationOptions["attributes"] as? [String: Any], let tokenStr = attributes["token"] as? String {
            token = tokenStr
        }
        
        if let qRDict = inVideoEncoderConfigurationOptions["QualityRange"] as? [String: Any] {
            if let qRangeMin = qRDict["Min"] as? [String: Any],
                let qMin = (qRangeMin["value"] as? NSString)?.integerValue,
                let qRangeMax = qRDict["Max"] as? [String: Any],
                let qMax = (qRangeMax["value"] as? NSString)?.integerValue {
                qualityRange = qMin...qMax
            } else if let qMin = (qRDict["Min"] as? NSString)?.integerValue,
                      let qMax = (qRDict["Max"] as? NSString)?.integerValue {
                qualityRange = qMin...qMax
            }
        }
        
        if nil != name || nil != useCount || nil != token || nil != qualityRange {
            return VideoEncoderConfigurationOptions(owner: owner, name: name, useCount: useCount, token: token, qualityRange: qualityRange)
        }
        
        return nil
    }
    /* ############################################################################################################################## */
    // MARK: - GetVideoSourceConfigurations Parsers
    /* ############################################################################################################################## */
    /* ################################################################## */
    /**
     This parses the response to the profile request, and builds up a list of profiles for the device.
     
     - parameter inResponseBody: The Dictionary ([String: Any]) of the response body data.
     - returns: An Array of VideoSourceConfiguration struct instances, created from the response data.
     */
    internal func _parseVideoSourceConfigurationsDictionary(_ inResponseBody: [String: Any]) -> [VideoSourceConfiguration] {
        var ret: [VideoSourceConfiguration] = []
        
        var configurations: [[String: Any]] = []
        
        // This unspeakable hack, is because some cameras will not return an array if there is only one configuration. They will simply return the configuration.
        if let configResponse = inResponseBody["GetVideoSourceConfigurationsResponse"] as? [String: Any] {
            if let configArray = configResponse["Configurations"] as? [[String: Any]] {
                configurations = configArray
            } else if let configSingle = configResponse["Configurations"] as? [String: Any] {
                configurations = [configSingle]
            }
        }

        // Loop through the configurations, building our object.
        configurations.forEach {
            if let name = owner._parseString($0, key: "Name") { // A name is required.
                var token: String = ""
                var useCount: Int = 0
                var bounds: CGRect = CGRect.zero
                
                if let uCount = owner._parseInteger($0, key: "UseCount") {
                    useCount = uCount
                }
                
                if let tk = owner._parseString($0, key: "SourceToken") {
                    token = tk
                }
                
                // We convert the bounds to a CGRect.
                if let bnds = $0["Bounds"] as? [String: Any], let boundsAttr = bnds["attributes"] as? [String: Any] {
                    if let left = owner._parseInteger(boundsAttr, key: "x") {
                        bounds.origin.x = CGFloat(left)
                    }
                    if let top = owner._parseInteger(boundsAttr, key: "y") {
                        bounds.origin.x = CGFloat(top)
                    }
                    if let width = owner._parseInteger(boundsAttr, key: "width") {
                        bounds.size.width = CGFloat(width)
                    }
                    if let height = owner._parseInteger(boundsAttr, key: "height") {
                        bounds.size.height = CGFloat(height)
                    }
                }
                
                let newConfig = VideoSourceConfiguration(owner: owner, name: name, useCount: useCount, token: token, bounds: bounds)
                ret.append(newConfig)
            }
        }

        return ret
    }
    
    /* ################################################################################################################################## */
    // MARK: - Public Static Properties
    /* ################################################################################################################################## */
    /* ############################################################## */
    /**
     These are the namespaces handled by this profile handler.
     */
    public static var namespaces: [String] {
        return ["http://www.onvif.org/ver10/media/wsdl", "http://www.onvif.org/ver20/media/wsdl"]
    }
    
    /* ############################################################## */
    /**
     This is the scope enum for this handler.
     */
    public static var scopeProfile: RVS_ONVIF_Core.Scope.ProfileType = RVS_ONVIF_Core.Scope.ProfileType.S("")

    /* ################################################################################################################################## */
    // MARK: - Public Instance Stored Properties
    /* ################################################################################################################################## */
    /* ############################################################## */
    /**
     This is which of the profile namespaces are supported by this device. Latest version is last.
     */
    public var supportedNamespaces: [String] = []

    /* ################################################################################################################################## */
    // MARK: - Public Instance Calculated Properties
    /* ################################################################################################################################## */
    /* ############################################################## */
    /**
     This is the profile name key.
     */
    public var profileName: String {
        return type(of: self)._profileName
    }

    /* ############################################################## */
    /**
     This is a list of the commands (as enum values) available for this handler
     */
    public var availableCommands: [RVS_ONVIF_DeviceRequestProtocol] {
        var ret: [RVS_ONVIF_DeviceRequestProtocol] = []
        
        _DeviceRequest.allCases.forEach {
            switch $0 {
            // This goes through the profile instance. We don't call it directly.
            case .GetStreamUri:
                break

            default:
                ret.append($0)
            }
        }
        
        return ret
    }
    
    /* ################################################################## */
    /**
     This is the RVS_ONVIF instance that "owns" this instance.
     */
    public var owner: RVS_ONVIF! {
        return _owner
    }

    /* ################################################################################################################################## */
    // MARK: - Public Instance Methods
    /* ################################################################################################################################## */
    /* ################################################################## */
    /**
     This asks the device to send over its profiles. The delegate call will be made when they are received.
     */
    public func fetchProfiles() {
        _cachedProfiles = [:]
        owner.performRequest(_DeviceRequest.GetProfiles)
    }

    /* ################################################################## */
    /**
     */
    public func fetchVideoSourceConfigurations() {
        owner.performRequest(_DeviceRequest.GetVideoSourceConfigurations)
    }
    
    /* ################################################################################################################################## */
    // MARK: - Public Callback Handler Instance Method
    /* ################################################################################################################################## */
    /* ################################################################## */
    /**
     This is called upon a successful SOAP call. It must be public, because the protocol is public, but it will only be used internally.
     
     - parameter inResponseDictionary: The Dictionary ([String: Any]) of the response data.
     - parameter soapRequest: The SOAP request object call, as a String
     - parameter soapEngine: The SOAPEngine object that executed the request. This can be nil.
     - returns: true, if the callback was handled (including as an error).
     */
    public func callbackHandler(_ inResponseDictionary: [String: Any], soapRequest inSOAPRequest: String, soapEngine inSOAPEngine: SOAPEngine?) -> Bool {
        var ret = false
        
        switch inSOAPRequest {
        case _DeviceRequest.GetStreamUri.soapAction:
            let uriResponse = _parseURIDictionary(inResponseDictionary)
            if !(owner.delegate?.onvifInstance(owner, rawDataPreview: inResponseDictionary, deviceRequest: _DeviceRequest.GetStreamUri) ?? false) {
                owner.dispatchers.forEach {
                    if $0.isAbleToHandleThisCommand(_DeviceRequest.GetStreamUri) {
                        $0.deliverResponse(_DeviceRequest.GetStreamUri, params: uriResponse)
                    }
                }
            }
            ret = true
            
        case _DeviceRequest.GetProfiles.soapAction:
            _cachedProfiles = [:]   // We save the fetched profiles in our cache, so we can look them up later.
            let profiles = _parseProfilesDictionary(inResponseDictionary)
            profiles.forEach {
                _cachedProfiles[$0.token] = $0    // We use the token as the Dictionary key, which lets us find the profile quickly.
            }
            
            if !(owner.delegate?.onvifInstance(owner, rawDataPreview: inResponseDictionary, deviceRequest: _DeviceRequest.GetProfiles) ?? false) {
                owner.dispatchers.forEach {
                    if $0.isAbleToHandleThisCommand(_DeviceRequest.GetProfiles) {
                        $0.deliverResponse(_DeviceRequest.GetProfiles, params: profiles)
                    }
                }
            }
            ret = true
        
        case _DeviceRequest.GetVideoSourceConfigurations.soapAction:
            let configurations = _parseVideoSourceConfigurationsDictionary(inResponseDictionary)
            if !(owner.delegate?.onvifInstance(owner, rawDataPreview: inResponseDictionary, deviceRequest: _DeviceRequest.GetVideoSourceConfigurations) ?? false) {
                owner.dispatchers.forEach {
                    if $0.isAbleToHandleThisCommand(_DeviceRequest.GetVideoSourceConfigurations) {
                        $0.deliverResponse(_DeviceRequest.GetVideoSourceConfigurations, params: configurations)
                    }
                }
            }
            ret = true

        default:    // If we don't recognize the call we made, drop through.
            break
        }
        
        return ret
    }
}
