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
 These are the public structs and types, used to provide the core data to the delegate.
 */
extension RVS_ONVIF_Profile_S {
    /* ###################################################################################################################################### */
    // MARK: - Public Enums
    /* ###################################################################################################################################### */
    /**
     These are the video encoding types available.
     */
    public enum EncodingTypes: String {
        /// Error
        case error
        /// H264
        case h264
        /// H265
        case h265
        /// HEVC
        case hevc
        /// Motion JPEG
        case jpeg
        /// MPEG/MP4
        case mpeg = "mpeg-4"
    }

    /* ###################################################################################################################################### */
    /**
     These are the type parameter values for H.264
     */
    public enum H264EncodingParameters: String {
        /// Error
        case error
        /// H264 Baseline
        case baseline
        /// H264 Main
        case main
        /// H264 Extended
        case extended
        /// H24 High
        case high
    }

    /* ###################################################################################################################################### */
    /**
     These are the type parameters for MPEG-4
     */
    public enum MPEG4EncodingParameters: String {
        /// Error
        case error
        /// Simple
        case simple
        /// Advanced
        case advanced
    }

    /* ###################################################################################################################################### */
    /**
     These are the streaming protocol types.
     */
    public enum StreamingProtocol: String {
        /// Error
        case error
        /// RTSP
        case RTSP
        /// RTP (unicast)
        case RTP_Unicast = "RTP-Unicast"
        /// RTP (multicast)
        case RTP_Multicast = "RTP-Multicast"
    }

    /* ###################################################################################################################################### */
    /**
     These are the basic IP transport protocols.
     */
    public enum TransportProtocol: String {
        /// Error
        case error
        /// TCP
        case TCP
        /// UDP
        case UDP
    }

    /* ################################################################################################################################## */
    // MARK: - Public Structs
    /* ###################################################################################################################################### */
    /**
     This struct describes the PTZ limits for a profile. It aggregates the next two structs.
     */
    public struct PTZConfiguration: ConfigurationProtocol {
        /* ############################################################## */
        /**
         This is us.
         */
        public let owner: RVS_ONVIF!
        /* ############################################################## */
        /**
         The name of this state.
         */
        public let name: String
        /* ############################################################## */
        /**
         The token string.
         */
        public let token: String
        /* ############################################################## */
        /**
         The limits for PT
         */
        public let panTiltLimits: PanTiltLimits!
        /* ############################################################## */
        /**
         The limits for Z
         */
        public let zoomLimits: ZoomLimits!
    }

    /* ###################################################################################################################################### */
    /**
     This struct describes the PTZ XY-limits for a profile.
     */
    public struct PanTiltLimits {
        /* ############################################################## */
        /**
         This is us.
         */
        public let owner: RVS_ONVIF!
        /* ############################################################## */
        /**
         The range (inclusive) of values for the pan (X-axis).
         */
        public let xRange: ClosedRange<Float>
        /* ############################################################## */
        /**
         The range (inclusive) of values for the tilt (Y-axis).
         */
        public let yRange: ClosedRange<Float>
        /* ############################################################## */
        /**
         The standard URI.
         */
        public let uri: URL
    }

    /* ###################################################################################################################################### */
    /**
     This struct describes the PTZ Z-limits for a profile.
     */
    public struct ZoomLimits: OwnedInstanceProtocol {
        /* ############################################################## */
        /**
         This is us.
         */
        public let owner: RVS_ONVIF!
        /* ############################################################## */
        /**
         The range (inclusive) of values for the zoom (Z-axis, but it's called "X" in this).
         */
        public let xRange: ClosedRange<Float>
        /* ############################################################## */
        /**
         The standard URI.
         */
        public let uri: URL
    }

    /* ###################################################################################################################################### */
    /**
     This struct describes a profile.
     */
    public struct Profile: ConfigurationProtocol {
        /* ############################################################## */
        /**
         This is us.
         */
        public let owner: RVS_ONVIF!
        /* ############################################################## */
        /**
         The name of this state.
         */
        public let name: String
        /* ############################################################## */
        /**
         The token string.
         */
        public let token: String
        /* ############################################################## */
        /**
         This is the current PTZ configuration
         */
        public let ptzConfiguration: PTZConfiguration!
        /* ############################################################## */
        /**
         This is the video encoder configuration.
         */
        public let videoEncoderConfiguration: VideoEncoderConfiguration!
        /* ############################################################## */
        /**
         This is the video source configuration.
         */
        public let videoSourceConfiguration: VideoSourceConfiguration!

        /* ############################################################## */
        /**
         This method fetches the streaming URI for this profile. The delegate will be called with the URI, when it is received.
         
         - parameter streamType: The streaming protocol. It is optional, and default is "RTSP."
         - parameter andProtocol: This is the TCP protocol for the streaming. It is optional, and default is "UDP."
         */
        public func fetchURI(streamType inStreamType: String = "RTSP", andProtocol inProtocol: String = "UDP") {
            if let profileS = owner.profiles[String(describing: RVS_ONVIF_Profile_S.self)] as? RVS_ONVIF_Profile_S {
                profileS._fetchStreamURI(withToken: token, andStreamType: inStreamType, andProtocol: inProtocol)
            }
        }
    }

    /* ###################################################################################################################################### */
    /**
     This struct describes a streaming URI (response to "fetchURI()")
     */
    public struct Stream_URI: OwnedInstanceProtocol {
        /* ############################################################## */
        /**
         This is us.
         */
        public let owner: RVS_ONVIF!
        /* ############################################################## */
        /**
         The streaming URI, without authentication.
         */
        public let uri: URL!
        /* ############################################################## */
        /**
         True, if the URI is invalid immediately after connection.
         */
        public let invalidAfterConnect: Bool
        /* ############################################################## */
        /**
         True, if the URI is invalid immediately after a reboot.
         */
        public let invalidAfterReboot: Bool
        /* ############################################################## */
        /**
         The timeout for the stream, in seconds.
         */
        public let timeoutInSeconds: Int
    }

    /* ###################################################################################################################################### */
    /**
     This struct describes a profile's video encoder configuration.
     */
    public struct VideoEncoderConfiguration: ConfigurationProtocol {
        /* ############################################################## */
        /**
         This is us.
         */
        public let owner: RVS_ONVIF!
        /* ############################################################## */
        /**
         The name of this state.
         */
        public let name: String
        /* ############################################################## */
        /**
         How many instances use this.
         */
        public let useCount: Int
        /* ############################################################## */
        /**
         The token string.
         */
        public let token: String
        /* ############################################################## */
        /**
         */
        public let encoding: EncodingTypes
        /* ############################################################## */
        /**
         */
        public let timeoutInSeconds: Int
        /* ############################################################## */
        /**
         */
        public let rateControl: RateControl!
        /* ############################################################## */
        /**
         */
        public let multicast: Multicast!
        /* ############################################################## */
        /**
         */
        public let quality: Int!
        /* ############################################################## */
        /**
         */
        public let resolution: CGSize!
        /* ############################################################## */
        /**
         */
        public let encodingParameters: [String: Any]!
    }

    /* ###################################################################################################################################### */
    // MARK: - Public Core Data Structures
    /* ###################################################################################################################################### */
    /**
     This struct describes a Multicast profile capability.
     */
    public struct Multicast: OwnedInstanceProtocol {
        /* ############################################################## */
        /**
         This is us.
         */
        public let owner: RVS_ONVIF!
        /* ############################################################## */
        /**
         This is the multicast IP address
         */
        public let ipAddress: RVS_IPAddress!
        /* ############################################################## */
        /**
         If autostarting, this is true.
         */
        public let autoStart: Bool
        /* ############################################################## */
        /**
         This is the TCP port for multicasting.
         */
        public let port: Int
        /* ############################################################## */
        /**
         Time to live 0-255.
         */
        public let ttl: DateComponents
    }

    /* ###################################################################################################################################### */
    /**
     This struct describes the streaming rate control.
     */
    public struct RateControl: OwnedInstanceProtocol {
        /* ############################################################## */
        /**
         This is us.
         */
        public let owner: RVS_ONVIF!
        /* ############################################################## */
        /**
         The frame rate limit.
         */
        public let frameRateLimit: Float!
        /* ############################################################## */
        /**
         The encoding Interval.
         */
        public let encodingInterval: Float!
        /* ############################################################## */
        /**
         The bit rate (not byte rate) limit.
         */
        public let bitRateLimit: Int!
    }

    /* ###################################################################################################################################### */
    /**
     This struct descibes the videoencoder configuation OPTONS (not configuration).
     */
    public struct VideoEncoderConfigurationOptions: ConfigurationProtocol {
        /* ############################################################## */
        /**
         This is us.
         */
        public let owner: RVS_ONVIF!
        /* ############################################################## */
        /**
         The name of this state.
         */
        public let name: String
        /* ############################################################## */
        /**
         How many instances use this.
         */
        public let useCount: Int
        /* ############################################################## */
        /**
         The token string.
         */
        public let token: String
        /* ############################################################## */
        /**
         */
        public let qualityRange: ClosedRange<Int>!
    }
    
    /* ###################################################################################################################################### */
    /**
     This struct describes a video source configuration.
     */
    public struct VideoSourceConfiguration: ConfigurationProtocol {
        /* ############################################################## */
        /**
         This is us.
         */
        public let owner: RVS_ONVIF!
        /* ############################################################## */
        /**
         The name of this state.
         */
        public let name: String
        /* ############################################################## */
        /**
         The token string.
         */
        public let token: String
        /* ############################################################## */
        /**
         The source token string.
         */
        public let sourceToken: String
        /* ############################################################## */
        /**
         How many instances use this.
         */
        public let useCount: Int
        /* ############################################################## */
        /**
         The source bounds
         */
        public let bounds: CGRect!
        
        /* ############################################################## */
        /**
         Default initializer (lets us leave out a few).
         */
        public init(owner inOwner: RVS_ONVIF, name inName: String, useCount inUseCount: Int = 0, token inToken: String = "", sourceToken inSourceToken: String = "", bounds inBounds: CGRect = CGRect.zero) {
            owner = inOwner
            name = inName
            useCount = inUseCount
            token = inToken
            sourceToken = inSourceToken
            bounds = inBounds
        }
    }
}

/* ################################################################################################################################## */
// MARK: - Dispatch Profile S Functions
/* ################################################################################################################################## */
/**
 This protocol covers Profile S (Streaming) dispatcher expectations.
 */
public protocol RVS_ONVIF_Profile_SDispatcher: RVS_ONVIF_Dispatcher {
}

/* ################################################################################################################################## */
// MARK: - Dispatch Profile Defaults.
/* ################################################################################################################################## */
extension RVS_ONVIF_Profile_SDispatcher {
    /* ################################################################## */
    /**
     This is a String, returned by the dispatcher, that indicates which profile handler to use for it. It is implemented by the "first level" protocol override.
     
     - returns: "RVS_ONVIF_ProfileS"
     */
    public var profileSig: String {
        return "RVS_ONVIF_Profile_S"
    }

    /* ################################################################## */
    /**
     We need to reimplement this, because we obfuscate the GetStreamUri command.
     
     - parameter inCommand: The command being sent.
     - returns: true, if the command can be handled by this instance.
     */
    public func isAbleToHandleThisCommand(_ inCommand: RVS_ONVIF_DeviceRequestProtocol) -> Bool {
        switch inCommand.rawValue {
        case "GetProfiles", "GetStreamUri", "GetVideoSourceConfigurations":
            return true
            
        default:
            return false
        }
    }
}
