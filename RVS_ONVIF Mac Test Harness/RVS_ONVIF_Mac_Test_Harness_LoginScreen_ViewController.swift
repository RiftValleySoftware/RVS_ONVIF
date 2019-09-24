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
    static let showScopesSegue = "show-scopes-screen"
    static let showCapabilitiesSegue = "show-capabilities-screen"
    static let showServiceCapabilitiesSegue = "show-service-cap-screen"
    static let showServicesSegue = "show-services-screen"
    static let showHandlersSegue = "show-handlers-screen"
    static let showNetworkInterfacesSegue = "show-networkinterfaces-screen"

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
    var isConnecting: Bool = false {
        didSet {
            connectButton.isHidden = isConnecting
        }
    }
    
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
            
            saveState()
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
        ipAddressTextField?.isEnabled = !isConnected && !isConnecting
        portTextField?.isEnabled = !isConnected && !isConnecting
        loginIDTextField?.isEnabled = !isConnected && !isConnecting
        passwordTextField?.isEnabled = !isConnected && !isConnecting
        soapKeyTextField?.isEnabled = !isConnected && !isConnecting
        authModeSegmentedControl?.isEnabled = !isConnected && !isConnecting
        
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
        if nil == myViews["RVS_ONVIF_Mac_Test_Harness_Info_ViewController"], isConnected {
            performSegue(withIdentifier: type(of: self).showInfoSegue, sender: nil)
        }
    }
    
    /* ################################################################## */
    /**
     */
    func openScopesScreen() {
        if nil == myViews["RVS_ONVIF_Mac_Test_Harness_Scopes_ViewController"], isConnected {
            performSegue(withIdentifier: type(of: self).showScopesSegue, sender: nil)
        }
    }
    
    /* ################################################################## */
    /**
     */
    func openCapabilitiesScreen() {
        if nil == myViews["RVS_ONVIF_Mac_Test_Harness_Capabilities_ViewController"], isConnected {
            performSegue(withIdentifier: type(of: self).showCapabilitiesSegue, sender: nil)
        }
    }
    
    /* ################################################################## */
    /**
     */
    func openServiceCapabilitiesScreen() {
        if nil == myViews["RVS_ONVIF_Mac_Test_Harness_ServiceCapabilities_ViewController"], isConnected {
            performSegue(withIdentifier: type(of: self).showServiceCapabilitiesSegue, sender: nil)
        }
    }
    
    /* ################################################################## */
    /**
     */
    func openServicesScreen() {
        if nil == myViews["RVS_ONVIF_Mac_Test_Harness_Services_ViewController"], isConnected {
            performSegue(withIdentifier: type(of: self).showServicesSegue, sender: nil)
        }
    }
    
    /* ################################################################## */
    /**
     */
    func openHandlersScreen() {
        if nil == myViews["RVS_ONVIF_Mac_Test_Harness_Handlers_ViewController"], isConnected {
            performSegue(withIdentifier: type(of: self).showHandlersSegue, sender: nil)
        }
    }
    
    /* ################################################################## */
    /**
     */
    func openNetworkInterfacesScreen() {
        if nil == myViews["RVS_ONVIF_Mac_Test_Harness_NetwokInterfaces_ViewController"], isConnected {
            performSegue(withIdentifier: type(of: self).showNetworkInterfacesSegue, sender: nil)
        }
    }

    /* ################################################################## */
    /**
     */
    func scramTheReactor() {
        isConnecting = false
        RVS_ONVIF_Mac_Test_Harness_AppDelegate.appDelegateObject.displayVideoScreen?.dismiss(nil)
        RVS_ONVIF_Mac_Test_Harness_AppDelegate.appDelegateObject.displayVideoScreen = nil
        RVS_ONVIF_Mac_Test_Harness_AppDelegate.appDelegateObject.displayProfilesScreen?.dismiss(nil)
        RVS_ONVIF_Mac_Test_Harness_AppDelegate.appDelegateObject.displayProfilesScreen = nil
        RVS_ONVIF_Mac_Test_Harness_AppDelegate.appDelegateObject.functionHandlerScreen?.dismiss(nil)
        RVS_ONVIF_Mac_Test_Harness_AppDelegate.appDelegateObject.functionHandlerScreen = nil
        myViews.forEach {
            $0.value.view.window?.performClose(nil)
        }
        view.window?.title = "CONNECT"
        myViews = [:]
        updateUI(true)
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
