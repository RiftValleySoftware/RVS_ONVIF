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
 This is the protocol that adds support for the Profile S capabilities to the core protocol.
 
 This is a "pure" Swift protocol, requiring that it be applied to a class.
 
 These methods are all called in the main thread.
 */
public protocol RVS_ONVIF_Profile_SDelegate: RVS_ONVIFDelegate {
    /* ################################################################## */
    /**
     This is called to deliver the device ONVIF profiles.
     
     - parameter instance: The RVS_ONVIF instance that is calling the delegate.
     - parameter getProfiles: An Array of Profile objects.
     */
    func onvifInstance(_ instance: RVS_ONVIF, getProfiles: [RVS_ONVIF_Profile_S.Profile])
    
    /* ################################################################## */
    /**
     This is called to deliver the device stream URI.
     
     - parameter instance: The RVS_ONVIF instance that is calling the delegate.
     - parameter getStreamURI: The Stream_URI instance that contains the ONVIF response.
     */
    func onvifInstance(_ instance: RVS_ONVIF, getStreamURI: RVS_ONVIF_Profile_S.Stream_URI)
    
    /* ################################################################## */
    /**
     This is called to deliver the device stream URI.
     
     - parameter instance: The RVS_ONVIF instance that is calling the delegate.
     - parameter getVideoSourceConfigurations: An Array of video source configuration structs.
     */
    func onvifInstance(_ instance: RVS_ONVIF, getVideoSourceConfigurations: [RVS_ONVIF_Profile_S.VideoSourceConfiguration])
}

/* ###################################################################################################################################### */
/**
 These are just here to make the protocol optional. They deliberately do not do anything.
 */
public extension RVS_ONVIF_Profile_SDelegate {
    /* ################################################################## */
    /**
     This is called to deliver the device ONVIF profiles.
     
     - parameter instance: The RVS_ONVIF instance that is calling the delegate.
     - parameter getProfiles: An Array of Profile objects.
     */
    func onvifInstance(_ instance: RVS_ONVIF, getProfiles: [RVS_ONVIF_Profile_S.Profile]) {
        #if DEBUG
            print("onvifInstance:simpleResponseToRequest(\(String(describing: getProfiles))")
        #endif
    }
    
    /* ################################################################## */
    /**
     This is called to deliver the device stream URI.
     
     - parameter instance: The RVS_ONVIF instance that is calling the delegate.
     - parameter getStreamURI: The Stream_URI instance that contains the ONVIF response.
     */
    func onvifInstance(_ instance: RVS_ONVIF, getStreamURI: RVS_ONVIF_Profile_S.Stream_URI) {
        #if DEBUG
            print("onvifInstance:simpleResponseToRequest(\(String(describing: getStreamURI))")
        #endif
    }
    
    /* ################################################################## */
    /**
     This is called to deliver the device stream URI.
     
     - parameter instance: The RVS_ONVIF instance that is calling the delegate.
     - parameter getVideoSourceConfigurations: An Array of video source configuration structs.
     */
    func onvifInstance(_ instance: RVS_ONVIF, getVideoSourceConfigurations: [RVS_ONVIF_Profile_S.VideoSourceConfiguration]) {
        #if DEBUG
            print("onvifInstance:simpleResponseToRequest(\(String(describing: getVideoSourceConfigurations))")
        #endif
    }
}

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
        case error
        case h264
        case h265
        case hevc
        case jpeg
        case mpeg = "mpeg-4"
    }

    /* ###################################################################################################################################### */
    /**
     These are the type parameter values for H.264
     */
    public enum H264EncodingParameters: String {
        case error
        case baseline
        case main
        case extended
        case high
    }

    /* ###################################################################################################################################### */
    /**
     These are the type parameters for MPEG-4
     */
    public enum MPEG4EncodingParameters: String {
        case error
        case simple
        case advanced
    }

    /* ###################################################################################################################################### */
    /**
     These are the streaming protocol types.
     */
    public enum StreamingProtocol: String {
        case error
        case RTSP
        case RTP_Unicast = "RTP-Unicast"
        case RTP_Multicast = "RTP-Multicast"
    }

    /* ###################################################################################################################################### */
    /**
     These are the basic IP transport protocols.
     */
    public enum TransportProtocol: String {
        case error
        case TCP
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
        public init(owner inOwner: RVS_ONVIF, name inName: String, useCount inUseCount: Int = 0, token inToken: String = "", bounds inBounds: CGRect = CGRect.zero) {
            owner = inOwner
            name = inName
            useCount = inUseCount
            token = inToken
            bounds = inBounds
        }
    }
}
