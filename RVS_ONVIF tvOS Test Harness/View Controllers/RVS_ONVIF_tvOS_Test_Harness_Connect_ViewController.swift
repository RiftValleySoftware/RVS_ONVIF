/**
 © Copyright 2019, The Great Rift Valley Software Company. All rights reserved.
 
 This code is proprietary and confidential code,
 It is NOT to be reused or combined into any application,
 unless done so, specifically under written license from The Great Rift Valley Software Company.
 
 The Great Rift Valley Software Company: https://riftvalleysoftware.com
 */

import UIKit
import RVS_ONVIF_tvOS

/* ################################################################################################################################## */
// MARK: - Main Class for the Connect Screen
/* ################################################################################################################################## */
class RVS_ONVIF_tvOS_Test_Harness_Connect_ViewController: RVS_ONVIF_tvOS_Test_Harness_Base_ViewController {
    /* ############################################################################################################################## */
    // MARK: - Internal Instance Properties
    /* ############################################################################################################################## */
    @IBOutlet weak var ipAddressTextEntry: UITextField!
    @IBOutlet weak var tcpPortTextEntry: UITextField!
    @IBOutlet weak var loginIDTextEntry: UITextField!
    @IBOutlet weak var passwordTextEntry: UITextField!
    @IBOutlet weak var soapKeyTextEntry: UITextField!
    @IBOutlet weak var authTypeSegmentedSwitch: UISegmentedControl!
    @IBOutlet weak var connectButton: UIButton!
    @IBOutlet weak var connectingActivityContainerView: UIView!
    
    var isConnecting: Bool = false
    
    /* ############################################################################################################################## */
    // MARK: - Private Instance Methods
    /* ############################################################################################################################## */
    /* ################################################################## */
    /**
     This simply takes a snapshot of all the text fields, and saves them in the app defaults container.
     */
    private func _saveState() {
        var savingPrefs: [String: Any] = [:]
        savingPrefs["ip_address"] = ""
        savingPrefs["tcp_port"] = 0
        savingPrefs["login_id"] = ""
        savingPrefs["password"] = ""
        savingPrefs["soap_key"] = ""
        savingPrefs["auth_type"] = 0
        
        if  let address = ipAddressTextEntry?.text?.ipAddress,
            address.isValidAddress {
            savingPrefs["ip_address"] = address.address
        }
        
        if  let tcpPort = tcpPortTextEntry?.text,
            let tcpInt = Int(tcpPort) {
            savingPrefs["tcp_port"] = tcpInt
        }
        
        if  let loginText = loginIDTextEntry?.text {
            savingPrefs["login_id"] = loginText
        }
    
        if let passwordText = passwordTextEntry?.text {
            savingPrefs["password"] = passwordText
        }

        if  let soapKeyText = soapKeyTextEntry?.text {
            savingPrefs["soap_key"] = soapKeyText
        }

        let value = Int(authTypeSegmentedSwitch.selectedSegmentIndex)
        savingPrefs["auth_type"] = value
        
        #if DEBUG
            print("saving Prefs: \(savingPrefs)")
        #endif
        
        persistentPrefs.values = savingPrefs
    }
    
    /* ################################################################## */
    /**
     This reads anything in the app defaults container, and applies them to set up the text fields.
     */
    private func _loadState() {
        #if DEBUG
            print("Loaded Prefs: \(String(describing: persistentPrefs))")
        #endif
    
        if let addressText = persistentPrefs["ip_address"] as? String {
            ipAddressTextEntry?.text = addressText
        }
        
        if let port = persistentPrefs["tcp_port"] as? UInt, 0 < port {
            tcpPortTextEntry?.text = String(port)
        }
        
        if let loginText = persistentPrefs["login_id"] as? String {
            loginIDTextEntry?.text = loginText
        }
        
        if let passwordText = persistentPrefs["password"] as? String {
            passwordTextEntry?.text = passwordText
        }
        
        if let soapy = persistentPrefs["soap_key"] as? String {
            soapKeyTextEntry?.text = soapy
        }
        
        if let authy = persistentPrefs["auth_type"] as? Int {
            authTypeSegmentedSwitch.selectedSegmentIndex = authy
        }
        
        updateUI()
    }

    /* ############################################################################################################################## */
    // MARK: - Internal Instance Methods
    /* ############################################################################################################################## */
    /* ################################################################## */
    /**
     */
    override func updateUI() {
        if isConnected {
            isConnecting = false
        }
        connectingActivityContainerView.isHidden = !isConnecting
        ipAddressTextEntry?.isEnabled = !isConnected && !isConnecting
        tcpPortTextEntry?.isEnabled = !isConnected && !isConnecting
        loginIDTextEntry?.isEnabled = !isConnected && !isConnecting
        passwordTextEntry?.isEnabled = !isConnected && !isConnecting
        soapKeyTextEntry?.isEnabled = !isConnected && !isConnecting
        authTypeSegmentedSwitch?.isEnabled = !isConnected && !isConnecting
        connectButton?.isEnabled = !isConnecting
        connectButton.setTitle(isConnecting ? "CONNECTING..." : isConnected ? "DISCONNECT" : "CONNECT", for: .normal)

        if !isConnected, !isConnecting {
            if  let ipAddress = ipAddressTextEntry?.text?.ipAddress,
                ipAddress.isValidAddress,
                let tcpPort = tcpPortTextEntry?.text,
                let tcpInt = Int(tcpPort),
                0 != tcpInt,
                let loginID = loginIDTextEntry?.text,
                !loginID.isEmpty,
                let password = passwordTextEntry?.text,
                !password.isEmpty {
                    connectButton?.isEnabled = true
            } else {
                connectButton?.isEnabled = false
            }
        }
    }
    
    /* ############################################################################################################################## */
    // MARK: - Internal IBAction Methods
    /* ############################################################################################################################## */
    /* ################################################################## */
    /**
     */
    @IBAction func connectButtonHit(_ sender: Any) {
        if let tabBarController = tabBarController as? RVS_ONVIF_tvOS_Test_Harness_UITabBarController {
            if !isConnected {
                guard var ipAddress = ipAddressTextEntry?.text?.ipAddress, ipAddress.isValidAddress else { return }
                guard let tcpPort = tcpPortTextEntry?.text, let tcpInt = Int(tcpPort), 0 != tcpInt else { return }
                ipAddress.port = tcpInt
                guard let loginID = loginIDTextEntry?.text, !loginID.isEmpty else { return }
                guard let password = passwordTextEntry?.text, !password.isEmpty else { return }
                let loginCreds = RVS_ONVIF.LoginCredentialTuple(login: loginID, password: password)
                let soapKey = soapKeyTextEntry?.text
                var authMode: RVS_ONVIF.SOAPAuthMethod! = .both
                if let selectedMode = authTypeSegmentedSwitch?.selectedSegmentIndex {
                    switch selectedMode {
                    case 0:
                        authMode = .basic
                    case 2:
                        authMode = .digest
                    default:
                        authMode = .both
                    }
                }
                
                _saveState()
                isConnecting = true
                updateUI()
                
                _ = RVS_ONVIF.makeONVIFInstance(ipAddressAndPort: ipAddress.addressAndPort, loginCredentials: loginCreds, soapEngineLicenseKey: soapKey, authMethod: authMode, delegate: tabBarController)
            } else {
                onvifInstance?.deinitializeConnection()
            }
        }
    }

    /* ################################################################## */
    /**
     */
    @IBAction func textFieldEditingChanged(_ sender: UITextField) {
        updateUI()
    }
    
    /* ############################################################################################################################## */
    // MARK: - Internal Base Class Override Methods
    /* ############################################################################################################################## */
    /* ################################################################## */
    /**
     */
    override func viewDidLoad() {
        super.viewDidLoad()
        _loadState()
    }
}
