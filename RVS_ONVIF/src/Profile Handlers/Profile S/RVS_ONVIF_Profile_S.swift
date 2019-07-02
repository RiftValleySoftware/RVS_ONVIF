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
open class RVS_ONVIF_Profile_S: ProfileHandlerProtocol {
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
                if let name = owner._parseString($0, key: "Name"), let token = owner._parseString($0, key: "token") { // Name and token are required.
                    var ptzConfiguration: PTZConfiguration!
                    var videoEncoderConfiguration: VideoEncoderConfiguration!
                    var videoSourceConfiguration: VideoSourceConfiguration!

                    if let ptzConfig = $0["PTZConfiguration"] as? [String: Any], let name = owner._parseString(ptzConfig, key: "Name") {
                        var panTiltLimits: PanTiltLimits!
                        var zoomLimits: ZoomLimits!
                        let token: String! = owner._parseString($0, key: "token")

                        if let panTilt = ptzConfig["PanTiltLimits"] as? [String: Any] {
                            panTiltLimits = _parsePanTiltLimits(panTilt)
                        }
                        
                        if let zoom = ptzConfig["ZoomLimits"] as? [String: Any] {
                            zoomLimits = _parseZoomLimits(zoom)
                        }
                        
                        ptzConfiguration = PTZConfiguration(owner: owner, name: name, token: token, panTiltLimits: panTiltLimits, zoomLimits: zoomLimits)
                    }
                    
                    if let vcConfig = $0["VideoEncoderConfiguration"] as? [String: Any] {
                        videoEncoderConfiguration = _parseVideoEncoderConfiguration(vcConfig)
                    }
                    
                    if let sConfig = $0["VideoSourceConfiguration"] as? [String: Any] {
                        videoSourceConfiguration = _parseVideoSourceConfigurationsInternal(sConfig)
                    }

                    let newProfile = RVS_ONVIF_Profile_S.Profile(owner: owner, name: name, token: token, ptzConfiguration: ptzConfiguration, videoEncoderConfiguration: videoEncoderConfiguration, videoSourceConfiguration: videoSourceConfiguration)
                    
                    ret.append(newProfile)
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
        if let name = owner._parseString(inVideoEncoderConfiguration, key: "Name") { // A name is required.
            var rateControl: RateControl!
            var multicast: Multicast!
            var encodingParameters: [String: Any]!
            var encoding: EncodingTypes = .error
            var resolution: CGSize = CGSize.zero
            var timeoutInSeconds: Int = 0
            
            let useCount: Int! = owner._parseInteger(inVideoEncoderConfiguration, key: "UseCount")
            
            let quality: Int! = owner._parseInteger(inVideoEncoderConfiguration, key: "Quality")
            
            let token: String! = owner._parseString(inVideoEncoderConfiguration, key: "token")

            if let rateControlDict = inVideoEncoderConfiguration["RateControl"] as? [String: Any] {
                rateControl = _parseRateControlConfiguration(rateControlDict)
            }
            
            if let multicastDict = inVideoEncoderConfiguration["Multicast"] as? [String: Any] {
                multicast = _parseMulticastConfiguration(multicastDict)
            }
            
            if let encVal = EncodingTypes(rawValue: owner._parseString(inVideoEncoderConfiguration, key: "Encoding")?.lowercased() ?? "error") {
                encoding = encVal
            }
            
            // Some manufacturers like to use integers directly, instead of the proper XML Duration format.
            if let timeoutDur = owner._parseString(inVideoEncoderConfiguration, key: "SessionTimeout")?.asXMLDuration {
                var timeoutInSecondsTmp = (timeoutDur.second ?? 0)
                timeoutInSecondsTmp += ((timeoutDur.minute ?? 0) * 60)
                timeoutInSecondsTmp += ((timeoutDur.hour ?? 0) * 3600)
                
                timeoutInSeconds = timeoutInSecondsTmp
            } else if let asInt = owner._parseInteger(inVideoEncoderConfiguration, key: "SessionTimeout") {
                timeoutInSeconds = asInt
            }
            
            let encodingKey = encoding.rawValue.uppercased()
            
            if let encParameters = inVideoEncoderConfiguration[encodingKey] as? [String: Any] {
                encodingParameters = owner._parseValueDict(encParameters)
            }
            
            resolution = owner._parseSize(inVideoEncoderConfiguration, key: "Resolution")
            
            if nil != useCount || nil != token || nil != rateControl || nil != multicast || nil != encodingParameters || nil != quality {
                return VideoEncoderConfiguration(owner: owner, name: name, useCount: useCount, token: token, encoding: encoding, timeoutInSeconds: timeoutInSeconds, rateControl: rateControl, multicast: multicast, quality: quality, resolution: resolution, encodingParameters: encodingParameters)
            }
        }
        
        return nil
    }
    
    /* ################################################################## */
    /**
     This parses a Multicast Dictionary. We ignore type, and simply create an IP address from what they give us.
     
     - parameter inMulticastConfiguration: The raw Dictionary.
     
     - returns: A populated Multicast instance. Nil, if there was an issue.
     */
    internal func _parseMulticastConfiguration(_ inMulticastConfiguration: [String: Any]) -> Multicast! {
        if let addressDict = inMulticastConfiguration["Address"] as? [String: Any] {
            let port = owner._parseInteger(inMulticastConfiguration, key: "Port") ?? 0
            let autoStart = owner._parseBoolean(inMulticastConfiguration, key: "AutoStart")
            var ttl = DateComponents()
            
            // Some manufacturers like to use integers directly, instead of the proper XML Duration format.
            if let extractedDate = owner._parseDuration(inMulticastConfiguration, key: "TTL") {
                ttl = extractedDate
            } else if let asInt = owner._parseInteger(inMulticastConfiguration, key: "TTL") {
                ttl = DateComponents(second: asInt)
            }
            let ipAddress = owner._parseIPAddress(addressDict)
            
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
        let frameRateLimit = owner._parseFloat(inRateControlConfiguration, key: "FrameRateLimit")
        let encodingInterval = owner._parseFloat(inRateControlConfiguration, key: "EncodingInterval")
        let bitRateLimit = owner._parseInteger(inRateControlConfiguration, key: "BitrateLimit")
        
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
            let uriStr = owner._parseString(range, key: "URI"),
            let uri = URL(string: uriStr),
            let xRange = range["XRange"] as? [String: Any],
            let xMin = owner._parseFloat(xRange, key: "Min"),
            let xMax = owner._parseFloat(xRange, key: "Max"),
            let yRange = range["YRange"] as? [String: Any],
            let yMin = owner._parseFloat(yRange, key: "Min"),
            let yMax = owner._parseFloat(yRange, key: "Max") {
            return PanTiltLimits(owner: owner, xRange: xMin...xMax, yRange: yMin...yMax, uri: uri)
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
            let uriStr = owner._parseString(range, key: "URI"),
            let uri = URL(string: uriStr),
            let xRange = range["XRange"] as? [String: Any],
            let xMin = owner._parseFloat(xRange, key: "Min"),
            let xMax = owner._parseFloat(xRange, key: "Max") {
            return ZoomLimits(owner: owner, xRange: xMin...xMax, uri: uri)
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
        if let name = owner._parseString(inVideoEncoderConfigurationOptions, key: "Name") { // A name is required.
            var qualityRange: ClosedRange<Int>!
            
            let useCount: Int! = owner._parseInteger(inVideoEncoderConfigurationOptions, key: "token")
            let token: String! = owner._parseString(inVideoEncoderConfigurationOptions, key: "token")

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
            
            if nil != useCount || nil != token || nil != qualityRange {
                return VideoEncoderConfigurationOptions(owner: owner, name: name, useCount: useCount, token: token, qualityRange: qualityRange)
            }
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
            if let newConfig = _parseVideoSourceConfigurationsInternal($0) {
                ret.append(newConfig)
            }
        }
        
        return ret
    }
    
    /* ################################################################## */
    /**
     This parses the response to the profile request, and builds up a list of profiles for the device.
     
     - parameter inResponseBody: The Dictionary ([String: Any]) of the response body data (for one configuration).
     - returns: An optional VideoSourceConfiguration struct instance, created from the response data. Nil if an error.
     */
    internal func _parseVideoSourceConfigurationsInternal(_ inResponseBody: [String: Any]) -> VideoSourceConfiguration? {
        var ret: VideoSourceConfiguration!
            if let name = owner._parseString(inResponseBody, key: "Name") { // A name is required.
                var sourceToken: String = ""
                var token: String = ""
                var useCount: Int = 0
                var bounds: CGRect = CGRect.zero
                
                if let uCount = owner._parseInteger(inResponseBody, key: "UseCount") {
                    useCount = uCount
                }
                
                if let tk = owner._parseString(inResponseBody, key: "token") {
                    token = tk
                }
                
                if let tk = owner._parseString(inResponseBody, key: "SourceToken") {
                    sourceToken = tk
                }

                // We convert the bounds to a CGRect.
                if let bnds = inResponseBody["Bounds"] as? [String: Any], let boundsAttr = bnds["attributes"] as? [String: Any] {
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
                
                ret = VideoSourceConfiguration(owner: owner, name: name, useCount: useCount, token: token, sourceToken: sourceToken, bounds: bounds)
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
