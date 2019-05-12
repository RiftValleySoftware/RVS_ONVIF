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
// MARK: - Main TableView Controller Class for the Profile List Screen
/* ################################################################################################################################## */
class RVS_ONVIF_Test_Harness_ONVIF_TableViewController: UITableViewController {
    /* ############################################################################################################################## */
    // MARK: - Internal Instance Properties
    /* ############################################################################################################################## */
    /* ################################################################## */
    /**
     */
    var onvifInstance: RVS_ONVIF!
}

/* ################################################################################################################################## */
// MARK: - Main View Controller Class for the Initial Login Screen
/* ################################################################################################################################## */
class RVS_ONVIF_Test_Harness_Connect_ViewController: UIViewController, UITextFieldDelegate, RVS_ONVIFDelegate {
    /* ############################################################################################################################## */
    // MARK: - Private Class Methods
    /* ############################################################################################################################## */
    /* ################################################################## */
    /**
     */
    private class func _isValidIPAddress(_ inAddress: String) -> Bool {
        return nil != inAddress.ipAddress
    }
    
    /* ############################################################################################################################## */
    // MARK: - Private Instance Calculated Properties
    /* ############################################################################################################################## */
    /* ################################################################## */
    /**
     */
    private var _isValid: Bool {
        return nil != _credentials && nil != _addressAndPort
    }
    
    /* ################################################################## */
    /**
     */
    private var _addressAndPort: String! {
        if let addressText = ipAddressTextField.text, type(of: self)._isValidIPAddress(addressText), let portText = portTextField?.text, let port = Int(portText), var addressString = addressText.ipAddress {
            addressString.port = port
            return addressString.addressAndPort
        }
        
        return nil
    }
    
    /* ################################################################## */
    /**
     */
    private var _credentials: RVS_ONVIF.LoginCredentialTuple! {
        let loginID = loginIDTextField?.text
        let password = passwordTextField?.text
        
        if let loginID = loginID, let password = password, !loginID.isEmpty, !password.isEmpty {
            return RVS_ONVIF.LoginCredentialTuple(login: loginID, password: password)
        }
        
        return nil
    }
    
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

        if let addressText = ipAddressTextField?.text, type(of: self)._isValidIPAddress(addressText) {
            let addressCompArray = addressText.components(separatedBy: ".")
            let addressIntArray: [UInt] = addressCompArray.compactMap { UInt($0) }
            let addressStringArray: [String] = addressIntArray.compactMap { String($0) }
            savingPrefs["ip_address"] = addressStringArray.joined(separator: ".")
        }
        
        if let portText = portTextField?.text, let portInt = UInt(portText), 0 < portInt {
            savingPrefs["tcp_port"] = portInt
        }
        
        if let loginText = loginIDTextField?.text {
            savingPrefs["login_id"] = loginText
        }
        
        if let passwordText = passwordTextField?.text {
            savingPrefs["password"] = passwordText
        }
        
        if let soapKeyText = soapKeyTextField?.text {
            savingPrefs["soap_key"] = soapKeyText
        }

        let value = Int(authMethodSlider.value)
        savingPrefs["auth_type"] = value

        #if DEBUG
            print("saving Prefs: \(savingPrefs)")
        #endif
        
        type(of: self).persistentPrefs.values = savingPrefs
    }
    
    /* ################################################################## */
    /**
     This reads anything in the app defaults container, and applies them to set up the text fields.
     */
    private func _loadState() {
        #if DEBUG
            print("Loaded Prefs: \(String(describing: type(of: self).persistentPrefs))")
        #endif
        
        if let addressText = type(of: self).persistentPrefs["ip_address"] as? String {
            ipAddressTextField.text = addressText
        }
        
        if let port = type(of: self).persistentPrefs["tcp_port"] as? UInt, 0 < port {
            portTextField.text = String(port)
        }

        if let loginText = type(of: self).persistentPrefs["login_id"] as? String {
            loginIDTextField.text = loginText
        }

        if let passwordText = type(of: self).persistentPrefs["password"] as? String {
            passwordTextField.text = passwordText
        }

        if let soapy = type(of: self).persistentPrefs["soap_key"] as? String {
            soapKeyTextField.text = soapy
        }

        if let authy = type(of: self).persistentPrefs["auth_type"] as? Int {
            authMethodSlider.value = Float(authy)
        }

        _setUIState()
    }
    
    /* ################################################################## */
    /**
     */
    private func _setUIState() {
        connectButton.isEnabled = true
        
        if nil == onvifInstance {   // If we are connected, the connect button is always enabled.
            // Otherwise, we need to have something in all the fields. These can contain crap, but they need to contain something.
            if let textItem = ipAddressTextField.text, (textItem.isEmpty || !type(of: self)._isValidIPAddress(textItem)) {
                connectButton.isEnabled = false
            } else if let textItem = portTextField.text, textItem.isEmpty {
                connectButton.isEnabled = false
            } else if let textItem = loginIDTextField.text, textItem.isEmpty {
                connectButton.isEnabled = false
            } else if let textItem = passwordTextField.text, textItem.isEmpty {
                connectButton.isEnabled = false
            }
        }

        activityIndicatorView.isHidden = true
        connectButton.setTitle((nil != onvifInstance ? "DIS" : "") + "CONNECT", for: .normal)
        connectedItemsContainerView.isHidden = nil == onvifInstance
        handlersButton.isEnabled = nil != onvifInstance
        ipAddressTextField.isEnabled = nil == onvifInstance
        portTextField.isEnabled = nil == onvifInstance
        loginIDTextField.isEnabled = nil == onvifInstance
        passwordTextField.isEnabled = nil == onvifInstance
        soapKeyTextField.isEnabled = nil == onvifInstance
        authMethodSlider.isEnabled = nil == onvifInstance
    }

    /* ############################################################################################################################## */
    // MARK: - Internal Static Properties
    /* ############################################################################################################################## */
    /* ################################################################## */
    /**
     */
    static var persistentPrefs: RVS_PersistentPrefs!
    
    /* ############################################################################################################################## */
    // MARK: - Internal Instance Properties
    /* ############################################################################################################################## */
    /* ################################################################## */
    /**
     */
    var onvifInstance: RVS_ONVIF!
    
    /* ############################################################################################################################## */
    // MARK: - Internal @IB Instance Properties
    /* ############################################################################################################################## */
    /* ################################################################## */
    /**
     */
    @IBOutlet weak var ipAddressTextField: UITextField!
    
    /* ################################################################## */
    /**
     */
    @IBOutlet weak var portTextField: UITextField!
    
    /* ################################################################## */
    /**
     */
    @IBOutlet weak var loginIDTextField: UITextField!
    
    /* ################################################################## */
    /**
     */
    @IBOutlet weak var passwordTextField: UITextField!
    
    /* ################################################################## */
    /**
     */
    @IBOutlet weak var connectButton: UIButton!
    
    /* ################################################################## */
    /**
     */
    @IBOutlet weak var soapKeyTextField: UITextField!

    /* ################################################################## */
    /**
     */
    @IBOutlet weak var activityIndicatorView: UIView!
    
    /* ################################################################## */
    /**
     */
    @IBOutlet weak var handlersButton: UIBarButtonItem!
    
    /* ################################################################## */
    /**
     */
    @IBOutlet weak var authMethodSlider: UISlider!
    
    /* ################################################################## */
    /**
     */
    @IBOutlet weak var connectedItemsContainerView: UIView!
    
    /* ############################################################################################################################## */
    // MARK: - Internal Instance Superclass Override Methods
    /* ############################################################################################################################## */
    /* ################################################################## */
    /**
     */
    override func viewDidLoad() {
        super.viewDidLoad()

        let defaultPrefs: [String: Any] = ["ip_address": "", "tcp_port": 0, "login_id": "", "password": "", "soap_key": "", "auth_method": 0]
        
        type(of: self).persistentPrefs = RVS_PersistentPrefs(tag: "TestONVIFSettings", values: defaultPrefs)
        _loadState()
    }
    
    /* ################################################################## */
    /**
     */
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        onvifInstance?.delegate = self
    }

    /* ################################################################## */
    /**
     */
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        _saveState()
        if let onvifInstance = onvifInstance {
            if let destination = segue.destination as? RVS_ONVIF_Test_Harness_ONVIF_TableViewController {
                destination.onvifInstance = onvifInstance
            }
        }
        super.prepare(for: segue, sender: sender)
    }

    /* ############################################################################################################################## */
    // MARK: - Internal @IBAction Instance Methods
    /* ############################################################################################################################## */
    /* ################################################################## */
    /**
     */
    @IBAction func connectButtonHit(_ inButton: UIButton) {
        if nil == onvifInstance, let credentials = _credentials, let addressAndPort = _addressAndPort {
            let licenseKey = soapKeyTextField?.text ?? ""
            activityIndicatorView.isHidden = false
            ipAddressTextField.isEnabled = false
            portTextField.isEnabled = false
            loginIDTextField.isEnabled = false
            passwordTextField.isEnabled = false
            soapKeyTextField.isEnabled = false
            authMethodSlider.isEnabled = false
            onvifInstance = nil
            let authMethodSliderVal: RVS_ONVIF.SOAPAuthMethod = authMethodSlider.value == -1 ? .basic : authMethodSlider.value == 0 ? .both : .digest
            _ = RVS_ONVIF.makeONVIFInstance(ipAddressAndPort: addressAndPort, loginCredentials: credentials, soapEngineLicenseKey: licenseKey, authMethod: authMethodSliderVal, delegate: self)
        } else {
            onvifInstance?.deinitializeConnection()
        }
        inButton.isEnabled = false
    }
    
    /* ################################################################## */
    /**
     */
    @IBAction func authMethodSliderChanged(_ inSlider: UISlider) {
        var newValue: Float = 0
        
        switch inSlider.value {
        case -1.0...(-0.5):
            newValue = -1.0
        case 0.5...1.0:
            newValue = 1.0
        default:
            newValue = 0.0
        }
        
        inSlider.value = newValue
        _saveState()
    }

    /* ############################################################################################################################## */
    // MARK: - Internal Instance UITextFieldDelegate Methods
    /* ############################################################################################################################## */
    /* ################################################################## */
    /**
     */
    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        textField.text = "" // Force the text to be clear right away, so it saves in the state.
        _saveState()
        _setUIState()
        return false    // We're good. No need to do anything more.
    }
    
    /* ################################################################## */
    /**
     */
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if let nsString = textField.text as NSString? {
            textField.text = nsString.replacingCharacters(in: range, with: string)
        }
        
        _saveState()
        _setUIState()
        return false
    }

    /* ############################################################################################################################## */
    // MARK: - Internal Instance RVS_ONVIFDelegate Methods
    /* ############################################################################################################################## */
    /* ################################################################## */
    /**
     */
    func onvifInstance(_ inONVIFInstance: RVS_ONVIF, failureWithReason inReason: RVS_ONVIF.RVS_Fault!) {
        activityIndicatorView.isHidden = true
        if let reason = inReason {
            RVS_ONVIF_Test_Harness_AppDelegate.displayAlert("ERROR!", inMessage: reason.fault.localizedFullDescription + "-" + reason.reason)
        } else {
            RVS_ONVIF_Test_Harness_AppDelegate.displayAlert("UNKNOWN ERROR!", inMessage: "WTF Just Happened?")
        }
        _setUIState()
    }
    
    /* ################################################################## */
    /**
     */
    func onvifInstance(_ inONVIFInstance: RVS_ONVIF, simpleResponseToRequest inSimpleResponseToRequest: RVS_ONVIF_DeviceRequestProtocol!) {
        #if DEBUG
        print("Simple Response: \(String(describing: inSimpleResponseToRequest))")
        #endif
        
        _setUIState()
    }

    /* ################################################################## */
    /**
     */
    func onvifInstanceInitialized(_ inONVIFInstance: RVS_ONVIF) {
        onvifInstance = inONVIFInstance
        _setUIState()
    }
    
    /* ################################################################## */
    /**
     */
    func onvifInstanceDeinitialized(_: RVS_ONVIF) {
        onvifInstance = nil
        _setUIState()
    }
}
