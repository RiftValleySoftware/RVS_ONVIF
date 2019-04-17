/**
 © Copyright 2019, The Great Rift Valley Software Company. All rights reserved.
 
 This code is proprietary and confidential code,
 It is NOT to be reused or combined into any application,
 unless done so, specifically under written license from The Great Rift Valley Software Company.
 
 The Great Rift Valley Software Company: https://riftvalleysoftware.com
 */

import Cocoa
import RVS_ONVIF_MacOS

/* ################################################################################################################################## */
// MARK: - Login Screen View Controller
/* ################################################################################################################################## */
class RVS_ONVIF_Mac_Test_Harness_LoginScreen_ViewController: NSViewController {
    /* ############################################################################################################################## */
    // MARK: - Internal Static Properties
    /* ############################################################################################################################## */
    /* ################################################################## */
    /**
     */
    static let showInfoSegue = "show-info-screen"
    
    /* ############################################################################################################################## */
    // MARK: - IB References
    /* ############################################################################################################################## */
    @IBOutlet weak var ipAddressTextField: NSTextField!
    @IBOutlet weak var portTextField: NSTextField!
    @IBOutlet weak var loginIDTextField: NSTextField!
    @IBOutlet weak var passwordTextField: NSTextField!
    @IBOutlet weak var soapKeyTextField: NSTextField!
    @IBOutlet weak var connectButton: NSButton!
    @IBOutlet weak var authModeSegmentedControl: NSSegmentedControl!
    @IBOutlet weak var progressIndicator: NSProgressIndicator!
    
    /* ############################################################################################################################## */
    // MARK: - Internal Stored Properties
    /* ############################################################################################################################## */
    var isConnecting: Bool = false
    var myViews: [AnyHashable: NSViewController] = [:]
    
    /* ############################################################################################################################## */
    // MARK: - Internal Calculated Properties
    /* ############################################################################################################################## */
    /* ################################################################## */
    /**
     */
    var isConnected: Bool {
        return nil != RVS_ONVIF_Mac_Test_Harness_AppDelegate.appDelegateObject.onvifInstance
    }
    
    /* ############################################################################################################################## */
    // MARK: - IB Actions
    /* ############################################################################################################################## */
    /* ################################################################## */
    /**
     */
    @IBAction func textFieldChanged(_ inTextField: NSTextField) {
        saveState()
        updateUI()
    }

    /* ################################################################## */
    /**
     */
    @IBAction func authModeSegmentedSwitchChanged(_ sender: NSSegmentedControl) {
        saveState()
        updateUI()
    }
    
    /* ################################################################## */
    /**
     */
    @IBAction func connectButtonHit(_ inButton: NSButton) {
        if !isConnected {
            guard var ipAddress = ipAddressTextField?.stringValue.ipAddress, ipAddress.isValidAddress else { return }
            guard let tcpPort = portTextField?.intValue, 0 != tcpPort else { return }
            ipAddress.port = Int(tcpPort)
            guard let loginID = loginIDTextField?.stringValue, !loginID.isEmpty else { return }
            guard let password = passwordTextField?.stringValue, !password.isEmpty else { return }
            let loginCreds = RVS_ONVIF.LoginCredentialTuple(login: loginID, password: password)
            let soapKey = soapKeyTextField?.stringValue
            var authMode: RVS_ONVIF.SOAPAuthMethod! = .both
            if let selectedMode = authModeSegmentedControl?.selectedSegment {
                switch selectedMode {
                case 0:
                    authMode = .basic
                case 2:
                    authMode = .digest
                default:
                    authMode = .both
                }
            }
            
            isConnecting = true
            updateUI()
            
            _ = RVS_ONVIF.makeONVIFInstance(ipAddressAndPort: ipAddress.addressAndPort, loginCredentials: loginCreds, soapEngineLicenseKey: soapKey, authMethod: authMode, delegate: RVS_ONVIF_Mac_Test_Harness_AppDelegate.appDelegateObject)
        } else {
            RVS_ONVIF_Mac_Test_Harness_AppDelegate.appDelegateObject.onvifInstance.deinitializeConnection()
        }
    }
    
    /* ############################################################################################################################## */
    // MARK: - Internal Methods
    /* ############################################################################################################################## */
    /* ################################################################## */
    /**
     This simply takes a snapshot of all the text fields, and saves them in the app defaults container.
     */
    func saveState() {
        _ = RVS_ONVIF_Mac_Test_Harness_AppDelegate.appDelegateObject.currentPrefs   // Make sure we have at least the defaults.
        var val: [String: String] = [:]
        RVS_ONVIF_Mac_Test_Harness_AppDelegate.prefsKeys.forEach {
            switch $0 {
            case "ip_address_and_port":
                if var ipAddress = ipAddressTextField?.stringValue.ipAddress, ipAddress.isValidAddress, let tcpPort = Int(portTextField?.stringValue ?? "") {
                    ipAddress.port = tcpPort
                    val[$0] = ipAddress.addressAndPort
                } else {
                    val[$0] = ""
                }
            case "login_id":
                if let loginID = loginIDTextField?.stringValue, !loginID.isEmpty {
                    val[$0] = loginID
                } else {
                    val[$0] = ""
                }
            case "password":
                if let password = passwordTextField?.stringValue, !password.isEmpty {
                    val[$0] = password
                } else {
                    val[$0] = ""
                }
            case "soap_key":
                if let soap_key = soapKeyTextField?.stringValue, !soap_key.isEmpty {
                    val[$0] = soap_key
                } else {
                    val[$0] = ""
                }
            case "auth_method":
                if let selectedMode = authModeSegmentedControl?.selectedSegment, (0..<3).contains(selectedMode) {
                    val[$0] = String(selectedMode)
                } else {
                    val[$0] = ""
                }
            default:
                val[$0] = ""
            }
        }
        #if DEBUG
            print("Saving Prefs: \(String(describing: val))")
        #endif

        RVS_ONVIF_Mac_Test_Harness_AppDelegate.appDelegateObject.currentPrefs = val
    }
    
    /* ################################################################## */
    /**
     This reads anything in the app defaults container, and applies them to set up the text fields.
     */
    func loadState() {
        let curPrefs = RVS_ONVIF_Mac_Test_Harness_AppDelegate.appDelegateObject.currentPrefs
        
        #if DEBUG
            print("Loaded Prefs: \(String(describing: curPrefs))")
        #endif
        
        RVS_ONVIF_Mac_Test_Harness_AppDelegate.prefsKeys.forEach {
            if let value = curPrefs[$0] {
                switch $0 {
                case "ip_address_and_port":
                    ipAddressTextField?.stringValue = value.ipAddress?.address ?? ""
                    portTextField?.stringValue = String(value.ipAddress?.port ?? 0)
                case "login_id":
                    loginIDTextField?.stringValue = value
                case "password":
                    passwordTextField?.stringValue = value
                case "soap_key":
                    soapKeyTextField?.stringValue = value
                case "auth_method":
                    if let authVal = Int(value) {
                        authModeSegmentedControl?.selectedSegment = authVal
                    }
                default:
                    break
                }
            }
        }
    }
    
    /* ################################################################## */
    /**
     */
    func updateUI(_ inResetConnect: Bool = false) {
        ipAddressTextField?.isEnabled = !isConnected
        portTextField?.isEnabled = !isConnected
        loginIDTextField?.isEnabled = !isConnected
        passwordTextField?.isEnabled = !isConnected
        soapKeyTextField?.isEnabled = !isConnected
        authModeSegmentedControl?.isEnabled = !isConnected
        
        if isConnecting {
            progressIndicator?.startAnimation(nil)
        }
        
        if !isConnecting || inResetConnect {
            progressIndicator?.stopAnimation(nil)
            connectButton?.isEnabled = true
            connectButton?.title = "DISCONNECT"
            
            if inResetConnect {
                isConnecting = false
                loadState()
            }
            
            if !isConnected {
                connectButton?.isEnabled = false
                if !isConnecting {
                    guard let ipAddress = ipAddressTextField?.stringValue.ipAddress, ipAddress.isValidAddress else { return }
                    guard let tcpPort = portTextField?.intValue, 0 != tcpPort else { return }
                    guard let loginID = loginIDTextField?.stringValue, !loginID.isEmpty else { return }
                    guard let password = passwordTextField?.stringValue, !password.isEmpty else { return }
                    connectButton?.isEnabled = true
                    connectButton?.title = "CONNECT"
                }
            }
        } else {
            connectButton?.isEnabled = false
            connectButton?.title = "CONNECTING..."
        }
    }
    
    /* ################################################################## */
    /**
     */
    func openInfoScreen() {
        if nil == myViews["RVS_ONVIF_Mac_Test_Harness_Base_ViewController"], isConnected {
            performSegue(withIdentifier: type(of: self).showInfoSegue, sender: nil)
        }
    }
    
    /* ################################################################## */
    /**
     */
    func scramTheReactor() {
        myViews.forEach {
            $0.value.view.window?.performClose(nil)
        }
        view.window?.title = "CONNECT"
        myViews = [:]
    }

    /* ############################################################################################################################## */
    // MARK: - Overrides
    /* ############################################################################################################################## */
    /* ################################################################## */
    /**
     */
    override func viewDidLoad() {
        super.viewDidLoad()
        RVS_ONVIF_Mac_Test_Harness_AppDelegate.appDelegateObject.connectionScreen = self
    }
    
    /* ################################################################## */
    /**
     */
    override func viewWillAppear() {
        super.viewWillAppear()
        RVS_ONVIF_Mac_Test_Harness_AppDelegate.appDelegateObject.connectionScreen = self
        updateUI(true)
    }
    
    /* ################################################################## */
    /**
     */
    override func viewWillDisappear() {
        super.viewWillDisappear()
        saveState()
        scramTheReactor()
        RVS_ONVIF_Mac_Test_Harness_AppDelegate.appDelegateObject.onvifInstance?.deinitializeConnection()
        RVS_ONVIF_Mac_Test_Harness_AppDelegate.appDelegateObject.connectionScreen = nil
        NSApp.terminate(self)
    }
    
    /* ################################################################## */
    /**
     */
    override func prepare(for inSegue: NSStoryboardSegue, sender inSender: Any?) {
        if let windowController = inSegue.destinationController as? NSWindowController, let viewController = windowController.contentViewController as? RVS_ONVIF_Mac_Test_Harness_Base_ViewController {
            viewController.loginViewController = self
        }
    }
}
