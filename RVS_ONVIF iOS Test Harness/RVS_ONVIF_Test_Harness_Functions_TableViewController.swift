/**
 © Copyright 2019, The Great Rift Valley Software Company. All rights reserved.
 
 This code is proprietary and confidential code,
 It is NOT to be reused or combined into any application,
 unless done so, specifically under written license from The Great Rift Valley Software Company.
 
 The Great Rift Valley Software Company: https://riftvalleysoftware.com
 */

import UIKit
import RVS_ONVIF_iOS

/* ################################################################################################################################## */
// MARK: - Protocol for Profile Handlers
/* ################################################################################################################################## */
protocol RVS_ONVIF_Test_Harness_ProfileDispatcherProtocol {
    /* ################################################################## */
    /**
     */
    var profileObject: ProfileHandlerProtocol! { get set }
    
    /* ################################################################## */
    /**
     */
    var owner: RVS_ONVIF_Test_Harness_Functions_TableViewController! { get set }

    /* ################################################################## */
    /**
     */
    func updateUI()

    /* ################################################################## */
    /**
     */
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    
    /* ################################################################## */
    /**
     */
    func tableView(_ inTableView: UITableView, heightForRowAt inIndexPath: IndexPath) -> CGFloat

    /* ################################################################## */
    /**
     */
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    
    /* ################################################################## */
    /**
     */
    func onvifInstance(_ instance: RVS_ONVIF, simpleResponseToRequest: RVS_ONVIF_DeviceRequestProtocol!)
}

/* ################################################################################################################################## */
/* ################################################################################################################################## */
extension RVS_ONVIF_Test_Harness_ProfileDispatcherProtocol {
    /* ################################################################## */
    /**
     */
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return profileObject?.availableCommands.count ?? 0
    }
}

/* ################################################################################################################################## */
/* ################################################################################################################################## */
class RVS_ONVIF_Test_Harness_Functions_ButtonOnly_TableViewCell: UITableViewCell {
    @IBOutlet var button: UIButton!
}

/* ################################################################################################################################## */
/* ################################################################################################################################## */
class RVS_ONVIF_Test_Harness_Functions_ButtonEdit_TableViewCell: UITableViewCell {
    @IBOutlet var button: UIButton!
    @IBOutlet var textField: UITextField!
}

/* ################################################################################################################################## */
/* ################################################################################################################################## */
class DNSEditorButton: UIButton {
    @IBOutlet var isDHCPSwitch: UISwitch!
    @IBOutlet var searchDomainsTextField: UITextField!
    @IBOutlet var dnsServerIPsTextField: UITextField!
    var command: RVS_ONVIF_DeviceRequestProtocol!
}

/* ################################################################################################################################## */
/* ################################################################################################################################## */
class DynDNSEditorButton: UIButton {
    @IBOutlet var typeSegmentedSwitch: UISegmentedControl!
    @IBOutlet var ttlTextField: UITextField!
    @IBOutlet var nameTextField: UITextField!
    var command: RVS_ONVIF_DeviceRequestProtocol!
}

/* ################################################################################################################################## */
/* ################################################################################################################################## */
class NTPEditorButton: UIButton {
    @IBOutlet var isDHCPSwitch: UISwitch!
    @IBOutlet var ntpServerAddressTextField: UITextField!
    var command: RVS_ONVIF_DeviceRequestProtocol!
}

/* ################################################################################################################################## */
/* ################################################################################################################################## */
class RVS_ONVIF_Test_Harness_Functions_DynDNS_TableViewCell: UITableViewCell {
    @IBOutlet var button: DynDNSEditorButton!
}

/* ################################################################################################################################## */
/* ################################################################################################################################## */
class RVS_ONVIF_Test_Harness_Functions_DNS_TableViewCell: UITableViewCell {
    @IBOutlet var button: DNSEditorButton!
}

/* ################################################################################################################################## */
/* ################################################################################################################################## */
class RVS_ONVIF_Test_Harness_Functions_NTP_TableViewCell: UITableViewCell {
    @IBOutlet var button: NTPEditorButton!
}

/* ################################################################################################################################## */
// MARK: - Main Table View Controller Class for the Dispatcher Screen
/* ################################################################################################################################## */
class RVS_ONVIF_Test_Harness_Functions_TableViewController: RVS_ONVIF_Test_Harness_ONVIF_TableViewController, RVS_ONVIFDelegate, RVS_ONVIF_CoreDelegate, RVS_ONVIF_Profile_SDelegate {
    /* ################################################################## */
    /**
     */
    static let textOnlyCellID = "text-only-cell"
    
    /* ################################################################## */
    /**
     */
    static let buttonOnlyCellID = "button-only-cell"
    
    /* ################################################################## */
    /**
     */
    static let buttonEditCellID = "button-edit-text-cell"
    
    /* ################################################################## */
    /**
     */
    static let button2LineEditCellID = "button-2-line-edit-text-cell"

    /* ################################################################## */
    /**
     */
    static let dnsCellID = "dns-cell"
    
    /* ################################################################## */
    /**
     */
    static let dynDnsCellID = "dyn-dns-cell"
    
    /* ################################################################## */
    /**
     */
    static let ntpCellID = "ntp-cell"
    
    /* ################################################################## */
    /**
     */
    var oldDelegate: (RVS_ONVIFDelegate & RVS_ONVIF_CoreDelegate & RVS_ONVIF_Profile_SDelegate)!
    
    /* ################################################################## */
    /**
     */
    var protocolDisplayHandlers: [RVS_ONVIF_Test_Harness_ProfileDispatcherProtocol] = []

    /* ################################################################## */
    /**
     */
    func simpleCall(_ inRequest: RVS_ONVIF_DeviceRequestProtocol) {
        onvifInstance?.performRequest(inRequest)
    }

    /* ################################################################## */
    /**
     */
    func paramCall(_ inRequest: RVS_ONVIF_DeviceRequestProtocol, params: [String: Any]) {
        onvifInstance?.performRequest(inRequest, params: params)
    }
    
    /* ################################################################################################################################## */
    // MARK: - UIViewController Overrides
    /* ################################################################################################################################## */
    /* ################################################################## */
    /**
     */
    override func viewDidLoad() {
        super.viewDidLoad()
        protocolDisplayHandlers = []
        
        if let profileArray = onvifInstance?.profilesAsArray {
            for profile in profileArray {
                switch profile {
                case is RVS_ONVIF_Core:
                    protocolDisplayHandlers.append(RVS_ONVIF_Test_Harness_ProfileDispatcher_Core(profile: profile, owner: self))
                    
                case is RVS_ONVIF_Profile_S:
                    protocolDisplayHandlers.append(RVS_ONVIF_Test_Harness_ProfileDispatcher_Profile_S(profile: profile, owner: self))

                default:
                    break
                }
            }
        }
    }
    
    /* ################################################################## */
    /**
     */
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        onvifInstance?.delegate = self
    }

    /* ################################################################################################################################## */
    // MARK: - Table view data source
    /* ################################################################################################################################## */
    /* ################################################################## */
    /**
     */
    override func numberOfSections(in tableView: UITableView) -> Int {
        return onvifInstance?.profilesAsArray.count ?? 0
    }

    /* ################################################################## */
    /**
     */
    override func tableView(_ tableView: UITableView, titleForHeaderInSection inSection: Int) -> String? {
        return protocolDisplayHandlers[inSection].profileObject.profileName
    }

    /* ################################################################## */
    /**
     */
    override func tableView(_ inTableView: UITableView, heightForRowAt inIndexPath: IndexPath) -> CGFloat {
        return protocolDisplayHandlers[inIndexPath.section].tableView(inTableView, heightForRowAt: inIndexPath)
    }
    
    /* ################################################################## */
    /**
     */
    override func tableView(_ inTableView: UITableView, numberOfRowsInSection inSection: Int) -> Int {
        return protocolDisplayHandlers[inSection].tableView(inTableView, numberOfRowsInSection: inSection)
    }
    
    /* ################################################################## */
    /**
     */
    override func tableView(_ inTableView: UITableView, cellForRowAt inIndexPath: IndexPath) -> UITableViewCell {
        return protocolDisplayHandlers[inIndexPath.section].tableView(inTableView, cellForRowAt: inIndexPath)
    }
    
    /* ################################################################################################################################## */
    // MARK: - RVS_ONVIFDelegate Methods
    /* ################################################################################################################################## */
    /* ################################################################## */
    /**
     */
    func onvifInstance(_ inONVIFInstance: RVS_ONVIF, failureWithReason inReason: RVS_ONVIF.RVS_Fault!) {
        if let reason = inReason {
            RVS_ONVIF_Test_Harness_AppDelegate.displayAlert("ERROR!", inMessage: reason.fault.localizedFullDescription + "-" + reason.reason)
        } else {
            RVS_ONVIF_Test_Harness_AppDelegate.displayAlert("UNKNOWN ERROR!", inMessage: "WTF Just Happened?")
        }
    }
    
    /* ################################################################## */
    /**
     */
    func onvifInstance(_ inONVIFInstance: RVS_ONVIF, simpleResponseToRequest inSimpleResponseToRequest: RVS_ONVIF_DeviceRequestProtocol!) {
        for handlerObject in protocolDisplayHandlers {
            if let handler = handlerObject as? RVS_ONVIF_Test_Harness_ProfileDispatcher_Profile_S {
                handler.onvifInstance(inONVIFInstance, simpleResponseToRequest: inSimpleResponseToRequest)
            }
        }
    }
    
    /* ################################################################## */
    /**
     */
    func onvifInstance(_ inONVIFInstance: RVS_ONVIF, rawDataPreview inRawDataPreview: [String: Any]!, deviceRequest inDeviceRequest: RVS_ONVIF_DeviceRequestProtocol!) -> Bool {
        #if DEBUG
            print("Callback Preview: \(String(describing: inDeviceRequest))\n\tData Preview: \(String(describing: inRawDataPreview))")
        #endif
        return false
    }

    /* ################################################################################################################################## */
    // MARK: - RVS_ONVIF_CoreDelegate Methods
    /* ################################################################################################################################## */
    /* ################################################################## */
    /**
     */
    func onvifInstance(_ inONVIFInstance: RVS_ONVIF, getWSDLURI inWSDLURI: String!) {
        #if DEBUG
            print("URI: \(String(describing: inWSDLURI))")
        #endif
        if let handler = protocolDisplayHandlers[0] as? RVS_ONVIF_Test_Harness_ProfileDispatcher_Core {
            handler.onvifInstance(inONVIFInstance, getWSDLURI: inWSDLURI)
        }
    }
    
    /* ################################################################## */
    /**
     */
    func onvifInstance(_ inONVIFInstance: RVS_ONVIF, getHostname inHostname: RVS_ONVIF_Core.HostnameResponse!) {
        #if DEBUG
            print("Hostname: \(String(describing: inHostname))")
        #endif
        if let handler = protocolDisplayHandlers[0] as? RVS_ONVIF_Test_Harness_ProfileDispatcher_Core {
            handler.onvifInstance(inONVIFInstance, getHostname: inHostname)
        }
    }
    
    /* ################################################################## */
    /**
     */
    func onvifInstance(_ inONVIFInstance: RVS_ONVIF, getDNS inGetDNS: RVS_ONVIF_Core.DNSRecord!) {
        #if DEBUG
            print("DNS:\(String(describing: inGetDNS))")
        #endif
        if let handler = protocolDisplayHandlers[0] as? RVS_ONVIF_Test_Harness_ProfileDispatcher_Core {
            handler.onvifInstance(inONVIFInstance, getDNS: inGetDNS)
        }
    }
    
    /* ################################################################## */
    /**
     */
    func onvifInstance(_ inONVIFInstance: RVS_ONVIF, getDynamicDNS inGetDynamicDNS: RVS_ONVIF_Core.DynamicDNSRecord!) {
        #if DEBUG
            print("Dynamic DNS Record: \(String(describing: inGetDynamicDNS))")
        #endif
        if let handler = protocolDisplayHandlers[0] as? RVS_ONVIF_Test_Harness_ProfileDispatcher_Core {
            handler.onvifInstance(inONVIFInstance, getDynamicDNS: inGetDynamicDNS)
        }
    }

    /* ################################################################## */
    /**
     */
    func onvifInstance(_ inONVIFInstance: RVS_ONVIF, getNTP inGetNTP: RVS_ONVIF_Core.NTPRecord!) {
        #if DEBUG
            print("NTP:\(String(describing: inGetNTP))")
        #endif
        if let handler = protocolDisplayHandlers[0] as? RVS_ONVIF_Test_Harness_ProfileDispatcher_Core {
            handler.onvifInstance(inONVIFInstance, getNTP: inGetNTP)
        }
    }

    /* ################################################################################################################################## */
    // MARK: - RVS_ONVIF_Profile_SDelegate Methods
    /* ################################################################################################################################## */
    /* ################################################################## */
    /**
     */
    func onvifInstance(_ inONVIFInstance: RVS_ONVIF, getProfiles inProfileArray: [RVS_ONVIF_Profile_S.Profile]) {
        for handlerObject in protocolDisplayHandlers {
            if let handler = handlerObject as? RVS_ONVIF_Test_Harness_ProfileDispatcher_Profile_S {
                handler.onvifInstance(inONVIFInstance, getProfiles: inProfileArray)
            }
        }
    }
    
    /* ################################################################## */
    /**
     */
    func onvifInstance(_ inONVIFInstance: RVS_ONVIF, getVideoSourceConfigurations inConfigurationsArray: [RVS_ONVIF_Profile_S.VideoSourceConfiguration]) {
        for handlerObject in protocolDisplayHandlers {
            if let handler = handlerObject as? RVS_ONVIF_Test_Harness_ProfileDispatcher_Profile_S {
                handler.onvifInstance(inONVIFInstance, getVideoSourceConfigurations: inConfigurationsArray)
            }
        }
    }

    /* ################################################################## */
    /**
     */
    func onvifInstance(_ inONVIFInstance: RVS_ONVIF, getStreamURI inStreamObject: RVS_ONVIF_Profile_S.Stream_URI) {
        #if DEBUG
            print("Stream: \(String(describing: inStreamObject))")
        #endif
        preconditionFailure("This should not be called.")
    }
}
