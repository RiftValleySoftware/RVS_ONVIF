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
// MARK: - Main View Controller Class
/* ################################################################################################################################## */
class RVS_ONVIF_tvOS_Test_Harness_NetworkProtocols_Editor_ViewController: UIViewController {
    /* ############################################################################################################################## */
    // MARK: - Class Calculated Properties
    /* ############################################################################################################################## */
    /* ################################################################## */
    /**
     */
    class var storyboardID: String {
        return "networkProtocolsInput"
    }
    
    /* ############################################################################################################################## */
    // MARK: - Instance Properties
    /* ############################################################################################################################## */
    /* ################################################################## */
    /**
     */
    var networkProtocolsObjects: [RVS_ONVIF_Core.NetworkProtocol]!
    
    /* ################################################################## */
    /**
     */
    var dispatcher: RVS_ONVIF_tvOS_Test_Harness_Dispatcher!
    
    /* ################################################################## */
    /**
     */
    var command: RVS_ONVIF_DeviceRequestProtocol!
    
    /* ################################################################## */
    /**
     */
    var selectedInterfaceObjectIndex: Int = 0

    /* ############################################################################################################################## */
    // MARK: - Instance Calculated Properties
    /* ############################################################################################################################## */
    /* ################################################################## */
    /**
     */
    var sendParameters: [String: Any] {
        return [:]
    }

    /* ############################################################################################################################## */
    // MARK: - IB Properties
    /* ############################################################################################################################## */
    /* ################################################################## */
    /**
     */
    @IBOutlet weak var mainStackView: UIStackView!
    
    /* ############################################################################################################################## */
    // MARK: - IBAction Methods
    /* ############################################################################################################################## */
    /* ################################################################## */
    /**
     */
    @IBAction func cancelButtonHit(_ inButton: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    /* ################################################################## */
    /**
     */
    @IBAction func sendButtonHit(_ inButton: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    /* ############################################################################################################################## */
    // MARK: - Instance Methods
    /* ############################################################################################################################## */
    /* ################################################################## */
    /**
     */
    func addProtocol(_ inType: RVS_ONVIF_Core.NetworkProtocol) {
        var name = ""
        var portInt = 0
        var enabled = false
        
        switch inType {
        case let .HTTP(port, isEnabled):
            name = "HTTP"
            portInt = port
            enabled = isEnabled
        case let .HTTPS(port, isEnabled):
            name = "HTTPS"
            portInt = port
            enabled = isEnabled
        case let .RTSP(port, isEnabled):
            name = "RTSP"
            portInt = port
            enabled = isEnabled
        }
        
        print("Add: \(name), Port: \(portInt), Enabled: \(enabled)")
        
        let containerView = UIStackView()
        containerView.axis = .horizontal
        containerView.spacing = 20
        containerView.translatesAutoresizingMaskIntoConstraints = false
        containerView.heightAnchor.constraint(equalToConstant: 80).isActive = true

        let nameLabel = UILabel()
        nameLabel.text = name
        nameLabel.font = UIFont.boldSystemFont(ofSize: 40)
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        nameLabel.widthAnchor.constraint(equalToConstant: 200).isActive = true
        containerView.addArrangedSubview(nameLabel)

        let portLabel = UILabel()
        portLabel.text = "Port:"
        portLabel.font = UIFont.boldSystemFont(ofSize: 40)
        portLabel.textAlignment = .right
        portLabel.setContentHuggingPriority(.required, for: .horizontal)
        containerView.addArrangedSubview(portLabel)

        let portTextField = UITextField()
        portTextField.text = String(portInt)
        portTextField.translatesAutoresizingMaskIntoConstraints = false
        portTextField.widthAnchor.constraint(equalToConstant: 200).isActive = true
        containerView.addArrangedSubview(portTextField)

        let enabledSegmentedView = UISegmentedControl(items: ["Enabled", "Disabled"])
        enabledSegmentedView.selectedSegmentIndex = enabled ? 0 : 1
        portLabel.setContentHuggingPriority(.required, for: .horizontal)
        containerView.addArrangedSubview(enabledSegmentedView)
        
        containerView.addArrangedSubview(UIView())

        mainStackView.addArrangedSubview(containerView)
    }
    
    /* ############################################################################################################################## */
    // MARK: - Base Class Override Methods
    /* ############################################################################################################################## */
    /* ################################################################## */
    /**
     */
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let networkProtocolsObjects = networkProtocolsObjects {
            mainStackView.spacing = 20

            networkProtocolsObjects.forEach {
                addProtocol($0)
            }
            
            mainStackView.addArrangedSubview(UIView())
        }
    }
}
