/**
 © Copyright 2019, The Great Rift Valley Software Company. All rights reserved.
 
 This code is proprietary and confidential code,
 It is NOT to be reused or combined into any application,
 unless done so, specifically under written license from The Great Rift Valley Software Company.
 
 The Great Rift Valley Software Company: https://riftvalleysoftware.com
 */

import UIKit
import AVKit
import RVS_ONVIF_iOS

/* ###################################################################################################################################### */
// MARK: - AV Player View Class -
/* ###################################################################################################################################### */
/**
 */
class RVS_ONVIF_Test_Harness_VideoPlayerView: UIView {
}

class RVS_ONVIF_Test_Harness_Stream_Inspector_ViewController: UIViewController, RVS_ONVIF_CoreDelegate, RVS_ONVIF_Profile_SDelegate, VLCMediaPlayerDelegate {
    /* ################################################################## */
    /**
     */
    var oldDelegate: (RVS_ONVIF_CoreDelegate & RVS_ONVIF_Profile_SDelegate)!
    
    /* ################################################################## */
    /**
     */
    var onvifInstance: RVS_ONVIF!
    
    /* ################################################################## */
    /**
     */
    var profile: RVS_ONVIF_Profile_S.Profile!
    
    /* ################################################################## */
    /**
     */
    var params: [String: String] = [:]
    
    /* ################################################################## */
    /**
     */
    var mediaPlayer: VLCMediaPlayer = VLCMediaPlayer()
    
    /* ################################################################## */
    /**
     */
    var media: VLCMedia!

    /* ################################################################## */
    /**
     */
    @IBOutlet weak var myPlayerView: RVS_ONVIF_Test_Harness_VideoPlayerView!

    /* ################################################################## */
    /**
     */
    @IBOutlet weak var waitView: UIView!
    
    /* ################################################################## */
    /**
     */
    @IBOutlet weak var avPlayerContainerView: UIView!

    /* ################################################################## */
    /**
     */
    override func viewDidLoad() {
        oldDelegate = onvifInstance.delegate
        onvifInstance.delegate = self
        super.viewDidLoad()
        waitView.isHidden = false
        avPlayerContainerView.isHidden = true
        mediaPlayer.delegate = self
        mediaPlayer.drawable = myPlayerView
        media = nil
        if let streamType = params["streamType"], let pr = params["protocol"] {
            profile.fetchURI(streamType: streamType, andProtocol: pr)
        }
    }
    
    /* ################################################################## */
    /**
     */
    override func viewWillDisappear(_ animated: Bool) {
        onvifInstance.delegate = oldDelegate
        mediaPlayer.stop()
        media = nil
        super.viewWillDisappear(animated)
    }
    
    /* ################################################################## */
    /**
     */
    func displayStreamingURI(_ inURI: URL!) {
        if let uri = inURI {
            waitView.isHidden = true
            avPlayerContainerView.isHidden = false
            var login_id: String = ""
            var password: String = ""
            
            if let login_id_string = RVS_ONVIF_Test_Harness_Connect_ViewController.persistentPrefs["login_id"] as? String, let password_string = RVS_ONVIF_Test_Harness_Connect_ViewController.persistentPrefs["password"] as? String {
                login_id = login_id_string
                password = password_string
            }
            
            media = VLCMedia(url: uri)
            media.addOptions([
                "network-caching": 0,
                "network-synchronisation": true,
                "sout-x264-preset": "ultrafast",
                "sout-x264-tune": "zerolatency",
                "sout-x264-lookahead": 15,
                "sout-x264-keyint": 10,
                "sout-x264-intra-refresh": true,
                "sout-x264-mvrange-thread": -1,
                "rtsp-user": login_id,
                "rtsp-pwd": password
            ])
            mediaPlayer.media = media
            mediaPlayer.play()
        }
    }
    
    /* ################################################################## */
    /**
     */
    func onvifInstance(_ inONVIFInstance: RVS_ONVIF, getStreamURI inStreamObject: RVS_ONVIF_Profile_S.Stream_URI) {
        displayStreamingURI(inStreamObject.uri)
    }

    /* ################################################################## */
    /**
     */
    func onvifInstance(_ inONVIFInstance: RVS_ONVIF, getWSDLURI inWSDLURI: String!) {
        oldDelegate.onvifInstance(inONVIFInstance, getWSDLURI: inWSDLURI)
    }

    /* ################################################################## */
    /**
     */
    func onvifInstance(_ inONVIFInstance: RVS_ONVIF, getHostname inHostname: RVS_ONVIF_Core.HostnameResponse!) {
        oldDelegate.onvifInstance(inONVIFInstance, getHostname: inHostname)
    }

    /* ################################################################## */
    /**
     */
    func onvifInstance(_ inONVIFInstance: RVS_ONVIF, getProfiles inProfileArray: [RVS_ONVIF_Profile_S.Profile]) {
        oldDelegate.onvifInstance(inONVIFInstance, getProfiles: inProfileArray)
    }
    
    /* ################################################################## */
    /**
     */
    func onvifInstance(_ inONVIFInstance: RVS_ONVIF, getVideoSourceConfigurations inConfigurationsArray: [RVS_ONVIF_Profile_S.VideoSourceConfiguration]) {
        oldDelegate.onvifInstance(inONVIFInstance, getVideoSourceConfigurations: inConfigurationsArray)
    }
    
    /* ################################################################## */
    /**
     */
    func onvifInstance(_ inONVIFInstance: RVS_ONVIF, failureWithReason inFailureReason: RVS_ONVIF.RVS_Fault!) {
        self.navigationController?.popViewController(animated: true)
        oldDelegate.onvifInstance(inONVIFInstance, failureWithReason: inFailureReason)
    }
}
