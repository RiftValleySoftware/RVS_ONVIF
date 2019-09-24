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

import UIKit
import RVS_ONVIF_tvOS

/* ################################################################################################################################## */
// MARK: - Class for The Main Stack View
/* ################################################################################################################################## */
class RVS_ONVIF_tvOS_Test_Harness_NetworkProtocols_Editor_ViewController_SegmentedSwitch: UISegmentedControl {
    var nextFocusTarget: UIFocusEnvironment!
    
    /* ################################################################## */
    /**
     */
    override var preferredFocusEnvironments: [UIFocusEnvironment] {
        return nil == nextFocusTarget ? super.preferredFocusEnvironments : [nextFocusTarget]
    }
}

/* ################################################################################################################################## */
// MARK: - Class for The Main Stack View
/* ################################################################################################################################## */
class RVS_ONVIF_tvOS_Test_Harness_NetworkProtocols_Editor_ViewController_View: UIView {
}

/* ################################################################################################################################## */
// MARK: - Class for The Main Vertical Stack View
/* ################################################################################################################################## */
class RVS_ONVIF_tvOS_Test_Harness_NetworkProtocols_Editor_ViewController_ButtonRowStack: UIStackView {
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var sendButton: UIButton!

    /* ################################################################## */
    /**
     */
    override func layoutSubviews() {
        axis = .horizontal
        super.layoutSubviews()
    }
}

/* ################################################################################################################################## */
// MARK: - Class for The Main Vertical Stack View
/* ################################################################################################################################## */
class RVS_ONVIF_tvOS_Test_Harness_NetworkProtocols_Editor_ViewController_MainStack: UIStackView {
    var nextFocusTarget: UIFocusEnvironment!

    /* ################################################################## */
    /**
     */
    @IBOutlet weak var buttonRow: RVS_ONVIF_tvOS_Test_Harness_NetworkProtocols_Editor_ViewController_ButtonRowStack!
    
    /* ################################################################## */
    /**
     */
    var protocolRows: [RVS_ONVIF_tvOS_Test_Harness_NetworkProtocols_Editor_ViewController_Row] = []
    
    /* ################################################################## */
    /**
     */
    override var preferredFocusEnvironments: [UIFocusEnvironment] {
        return [nextFocusTarget]
    }

    /* ################################################################## */
    /**
     */
    override func layoutSubviews() {
        spacing = 20
        axis = .vertical
        super.layoutSubviews()
        nextFocusTarget = protocolRows[0].portTextField
    }
    
    /* ################################################################## */
    /**
     */
    override func shouldUpdateFocus(in inContext: UIFocusUpdateContext) -> Bool {
        print(String(describing: inContext))
        if self == inContext.nextFocusedView {
            nextFocusTarget = buttonRow
            setNeedsFocusUpdate()
            return true
        } else {
            return super.shouldUpdateFocus(in: inContext)
        }
    }
    
    /* ################################################################## */
    /**
     */
    override func didUpdateFocus(in inContext: UIFocusUpdateContext, with inCoordinator: UIFocusAnimationCoordinator) {
        print(String(describing: inContext))
        if self == inContext.nextFocusedView {
            if (    inContext.previouslyFocusedView == buttonRow?.sendButton && .right == inContext.focusHeading)
                || (inContext.previouslyFocusedView == buttonRow?.sendButton && .up == inContext.focusHeading) {
                nextFocusTarget = protocolRows[0]
                setNeedsFocusUpdate()
            } else if   inContext.previouslyFocusedView != buttonRow?.cancelButton
                    &&  inContext.previouslyFocusedView != buttonRow?.sendButton
                    &&  .down == inContext.focusHeading {
                nextFocusTarget = buttonRow
                setNeedsFocusUpdate()
            }
        } else {
            super.didUpdateFocus(in: inContext, with: inCoordinator)
        }
    }
}

/* ################################################################################################################################## */
// MARK: - Class for One Row of the Protocol Screen
/* ################################################################################################################################## */
class RVS_ONVIF_tvOS_Test_Harness_NetworkProtocols_Editor_ViewController_Row: UIStackView {
    var nameLabel: UILabel!
    var portTextField: UITextField!
    var isEnabledSegmentedSwitch: UISegmentedControl!
}

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

    /* ################################################################## */
    /**
     */
    var betweenRowsAndButtonsFocusGuide = UIFocusGuide()

    /* ############################################################################################################################## */
    // MARK: - Instance Calculated Properties
    /* ############################################################################################################################## */
    /* ################################################################## */
    /**
     */
    var sendParameters: [String: Any] {
        var ret: [[String: String]] = []
        mainStackView.subviews.forEach {
            if  let rowView = $0 as? RVS_ONVIF_tvOS_Test_Harness_NetworkProtocols_Editor_ViewController_Row,
                let name = rowView.nameLabel?.text,
                let port = rowView.portTextField.text {
                let isEnabled = (0 == (rowView.isEnabledSegmentedSwitch?.selectedSegmentIndex ?? 1)) ? "true" : "false"
                ret.append(["tt:Name": name, "tt:Port": port, "tt:Enabled": isEnabled])
                }
            }
        
        return ["trt:NetworkProtocols": ret]
    }

    /* ############################################################################################################################## */
    // MARK: - IB Properties
    /* ############################################################################################################################## */
    /* ################################################################## */
    /**
     */
    @IBOutlet weak var mainStackView: RVS_ONVIF_tvOS_Test_Harness_NetworkProtocols_Editor_ViewController_MainStack!

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
        dispatcher?.sendParameters = sendParameters
        dispatcher?.sendRequest(command)
        
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
        
        let containerView = RVS_ONVIF_tvOS_Test_Harness_NetworkProtocols_Editor_ViewController_Row()
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
        containerView.nameLabel = nameLabel

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
        containerView.portTextField = portTextField

        let isEnabledSegmentedSwitch = RVS_ONVIF_tvOS_Test_Harness_NetworkProtocols_Editor_ViewController_SegmentedSwitch(items: ["Enabled", "Disabled"])
        isEnabledSegmentedSwitch.selectedSegmentIndex = enabled ? 0 : 1
        isEnabledSegmentedSwitch.setContentHuggingPriority(.required, for: .horizontal)
        containerView.addArrangedSubview(isEnabledSegmentedSwitch)
        containerView.isEnabledSegmentedSwitch = isEnabledSegmentedSwitch

        containerView.addArrangedSubview(UIView())

        mainStackView.protocolRows.append(containerView)
        mainStackView.insertArrangedSubview(containerView, at: max(0, mainStackView.subviews.count - 1))
        mainStackView.setNeedsFocusUpdate()
    }
    
    /* ################################################################## */
    /**
     */
    func setupFocus() {
        mainStackView.addLayoutGuide(betweenRowsAndButtonsFocusGuide)
        betweenRowsAndButtonsFocusGuide.heightAnchor.constraint(equalToConstant: 20).isActive = true
        betweenRowsAndButtonsFocusGuide.bottomAnchor.constraint(equalTo: mainStackView.buttonRow.topAnchor).isActive = true
        betweenRowsAndButtonsFocusGuide.leadingAnchor.constraint(equalTo: mainStackView.buttonRow.leadingAnchor).isActive = true
        betweenRowsAndButtonsFocusGuide.trailingAnchor.constraint(equalTo: mainStackView.buttonRow.trailingAnchor).isActive = true
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
            setupFocus()
            networkProtocolsObjects.forEach {
                addProtocol($0)
            }
        }
    }

    /* ################################################################## */
    /**
     */
    override func didUpdateFocus(in inContext: UIFocusUpdateContext, with inCoordinator: UIFocusAnimationCoordinator) {
        super.didUpdateFocus(in: inContext, with: inCoordinator)

        guard let lastSelectableRowField = mainStackView.protocolRows.last?.isEnabledSegmentedSwitch else { return }
        guard let secondToLastSelectableRowField = mainStackView.protocolRows.last?.portTextField else { return }
        guard let firstSelectableButtonField = mainStackView.buttonRow.cancelButton else { return }
        guard let lastSelectableButtonField = mainStackView.buttonRow.sendButton else { return }

        guard let nextFocusedView = inContext.nextFocusedView else { return }

        switch nextFocusedView {
        case firstSelectableButtonField:
            betweenRowsAndButtonsFocusGuide.preferredFocusEnvironments = [secondToLastSelectableRowField]
            
        case lastSelectableButtonField:
            betweenRowsAndButtonsFocusGuide.preferredFocusEnvironments = [lastSelectableRowField]
            
        case secondToLastSelectableRowField:
            betweenRowsAndButtonsFocusGuide.preferredFocusEnvironments = [firstSelectableButtonField]

        case lastSelectableRowField:
            betweenRowsAndButtonsFocusGuide.preferredFocusEnvironments = [lastSelectableButtonField]

        default:
            break
        }
    }
}
