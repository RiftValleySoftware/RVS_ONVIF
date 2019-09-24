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
// MARK: - Enum, for defining dialog components.
/* ################################################################################################################################## */
enum RVS_ONVIF_tvOS_Test_Harness_DialogComponents {
    typealias CallbackHandler = (UIView?) -> Void
    case textEntry(defaultValue: String, callback: CallbackHandler)
    case textDisplay(value: String, callback: CallbackHandler)
    case pickOne(values: [String], selectedIndex: Int, callback: CallbackHandler)
}

/* ################################################################################################################################## */
// MARK: - Main View Controller Class
/* ################################################################################################################################## */
class RVS_ONVIF_tvOS_Test_Harness_FunctionData_ViewController: UIViewController {
    /* ############################################################################################################################## */
    // MARK: - Static Properties
    /* ############################################################################################################################## */
    static let parameterScreenStoryBoardID = "dynamicDataEntry"

    /* ############################################################################################################################## */
    // MARK: - Class Functions
    /* ############################################################################################################################## */
    /* ################################################################## */
    /**
     */
    class func insertSpecialView(_ inSubView: UIView, into inContainer: UIView, topConstraint inTopAnchor: NSLayoutYAxisAnchor! = nil) {
        inContainer.addSubview(inSubView)
        inSubView.translatesAutoresizingMaskIntoConstraints = false
        if nil != inTopAnchor {
            inSubView.topAnchor.constraint(equalTo: inTopAnchor, constant: 4).isActive = true
        } else {
            inSubView.topAnchor.constraint(equalTo: inContainer.topAnchor, constant: 0).isActive = true
        }
        inSubView.trailingAnchor.constraint(equalTo: inContainer.trailingAnchor, constant: 20).isActive = true
        inSubView.leadingAnchor.constraint(equalTo: inContainer.leadingAnchor, constant: 20).isActive = true
        inSubView.heightAnchor.constraint(equalToConstant: 30.0).isActive = true
    }
    
    /* ################################################################## */
    /**
     */
    class func dialogFactory(_ inCustomerOrder: [String: RVS_ONVIF_tvOS_Test_Harness_DialogComponents], command inCommand: RVS_ONVIF_DeviceRequestProtocol, dispatcher inDispatcher: RVS_ONVIF_tvOS_Test_Harness_Dispatcher!) -> RVS_ONVIF_tvOS_Test_Harness_FunctionData_ViewController! {
        if  let windowViewController = RVS_ONVIF_tvOS_Test_Harness_AppDelegate.delegateObject.openNamespaceHandlerScreen,
            let ret = windowViewController.storyboard?.instantiateViewController(withIdentifier: parameterScreenStoryBoardID) as? RVS_ONVIF_tvOS_Test_Harness_FunctionData_ViewController {
            ret.command = inCommand
            ret.customerOrder = inCustomerOrder
            ret.dispatcher = inDispatcher
            return ret
        }
        
        return nil
    }
    
    /* ############################################################################################################################## */
    // MARK: - Instance Properties
    /* ############################################################################################################################## */
    /* ################################################################## */
    /**
     */
    var callbackHash: [AnyHashable: RVS_ONVIF_tvOS_Test_Harness_DialogComponents.CallbackHandler] = [:]
    
    /* ################################################################## */
    /**
     */
    var command: RVS_ONVIF_DeviceRequestProtocol!
    
    /* ################################################################## */
    /**
     */
    var dispatcher: RVS_ONVIF_tvOS_Test_Harness_Dispatcher!

    /* ################################################################## */
    /**
     */
    var customerOrder: [String: RVS_ONVIF_tvOS_Test_Harness_DialogComponents] = [:]
    
    /* ############################################################################################################################## */
    // MARK: - Instance IB Properties
    /* ############################################################################################################################## */
    /* ################################################################## */
    /**
     */
    @IBOutlet weak var cancelButton: UIButton!
    
    /* ################################################################## */
    /**
     */
    @IBOutlet weak var sendButton: UIButton!
    
    /* ################################################################## */
    /**
     */
    @IBOutlet weak var selectorSwitch: UISegmentedControl!
    
    /* ################################################################## */
    /**
     */
    @IBOutlet weak var stackView: UIStackView!
    
    /* ################################################################## */
    /**
     */
    @IBOutlet weak var titleLabel: UILabel!
    
    /* ################################################################## */
    /**
     */
    @IBAction func callbackDispatcher(_ inView: UIView) {
        if let callback = callbackHash[inView] {
            callback(inView)
        }
    }
    
    /* ################################################################## */
    /**
     */
    @IBAction func cancelButtonHit(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }

    /* ################################################################## */
    /**
     */
    @IBAction func sendButtonHit(_ sender: Any) {
        if 0 == selectorSwitch.selectedSegmentIndex {
            dispatcher?.sendRequest(command)
        } else {
            dispatcher?.sendSpecificCommand(command)
        }
        dismiss(animated: true, completion: nil)
    }
    
    /* ############################################################################################################################## */
    // MARK: - Base Class Override Methods
    /* ############################################################################################################################## */
    /* ################################################################## */
    /**
     */
    override func viewDidLoad() {
        super.viewDidLoad()
        if let colonIndex = command.soapAction.firstIndex(of: ":") {
            let nameString = command.soapAction[command.soapAction.index(after: colonIndex)...]
            titleLabel.text = nameString + "Request"
        }
        let label = UILabel()
        label.text = command.rawValue
        label.textAlignment = .center
        label.font = UIFont.boldSystemFont(ofSize: 20)
        type(of: self).insertSpecialView(label, into: stackView, topConstraint: selectorSwitch.bottomAnchor)
        
        var previousAnchor: NSLayoutYAxisAnchor = label.bottomAnchor
        
        customerOrder.forEach {
            let label = UILabel()
            label.text = $0.key
            label.textAlignment = .center
            label.font = UIFont.boldSystemFont(ofSize: 15)
            
            let control: UIView!    // OK for it to be let. We'll only initialize it once.
            
            let item = $0.value
            var callbackHandler: RVS_ONVIF_tvOS_Test_Harness_DialogComponents.CallbackHandler!
            
            switch item {
            case let .textDisplay(inValue, _):
                control = UILabel()
                (control as? UILabel)?.textAlignment = .center
                (control as? UILabel)?.font = UIFont.systemFont(ofSize: 15)
                (control as? UILabel)?.numberOfLines = 0
                (control as? UILabel)?.text = inValue

            case let .textEntry(inDefaultValue, inCallback):
                callbackHandler = inCallback
                control = UITextField()
                (control as? UITextField)?.font = UIFont.systemFont(ofSize: 15)
                (control as? UITextField)?.text = inDefaultValue
                let events: UIControl.Event = [.touchUpInside, .valueChanged, .editingChanged, .editingDidEnd, .editingDidEndOnExit]
                (control as? UITextField)?.addTarget(self, action: #selector(callbackDispatcher), for: events)
                
            case .pickOne(let inValues, let inSelectedIndex, let inCallback):
                callbackHandler = inCallback
                control = UISegmentedControl(items: inValues)
                (control as? UISegmentedControl)?.selectedSegmentIndex = inSelectedIndex
                (control as? UISegmentedControl)?.addTarget(self, action: #selector(callbackDispatcher), for: .valueChanged)
            }
            
            if nil != control {
                type(of: self).insertSpecialView(label, into: stackView, topConstraint: previousAnchor)
                type(of: self).insertSpecialView(control, into: stackView, topConstraint: label.bottomAnchor)
                previousAnchor = control!.bottomAnchor
                if nil != callbackHandler {
                    callbackHash[control!] = callbackHandler
                }
            }
        }
    }
}
