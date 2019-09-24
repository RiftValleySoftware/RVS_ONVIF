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
// MARK: - The Main Video Display View Controller
/* ################################################################################################################################## */
class RVS_ONVIF_Mac_Test_Harness_VideoDisplayViewController: NSViewController, VLCMediaPlayerDelegate {
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
    var streamingURL: URL!

    /* ################################################################## */
    /**
     */
    @IBOutlet weak var videoDisplayView: NSView!
    
    /* ################################################################## */
    /**
     */
    @IBOutlet weak var throbber: NSProgressIndicator!
    
    /* ################################################################## */
    /**
     */
    override func viewDidLoad() {
        mediaPlayer.delegate = self
        mediaPlayer.drawable = videoDisplayView
        media = nil
        throbber?.startAnimation(nil)
        displayStreamingURI(streamingURL)
    }
    
    /* ################################################################## */
    /**
     */
    override func viewWillAppear() {
        super.viewWillAppear()
        RVS_ONVIF_Mac_Test_Harness_AppDelegate.appDelegateObject.displayVideoScreen = self
    }

    /* ################################################################## */
    /**
     */
    override func viewWillDisappear() {
        mediaPlayer.stop()
        media = nil
        super.viewWillDisappear()
        RVS_ONVIF_Mac_Test_Harness_AppDelegate.appDelegateObject.displayVideoScreen = nil
    }

    /* ################################################################## */
    /**
     */
    func displayStreamingURI(_ inURI: URL!) {
        if let uri = inURI {
            var login_id: String = ""
            var password: String = ""
            
            if let login_id_string = RVS_ONVIF_Mac_Test_Harness_AppDelegate.appDelegateObject.currentPrefs["login_id"], let password_string = RVS_ONVIF_Mac_Test_Harness_AppDelegate.appDelegateObject.currentPrefs["password"] {
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
    func mediaPlayerStateChanged(_ aNotification: Notification!) {
        if nil != mediaPlayer.time.value {
            throbber?.stopAnimation(nil)
            videoDisplayView.isHidden = false
        }
    }
}
