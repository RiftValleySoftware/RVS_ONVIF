/**
 © Copyright 2019, The Great Rift Valley Software Company. All rights reserved.
 
 This code is proprietary and confidential code,
 It is NOT to be reused or combined into any application,
 unless done so, specifically under written license from The Great Rift Valley Software Company.
 
 The Great Rift Valley Software Company: https://riftvalleysoftware.com
 */

import UIKit
import RVS_ONVIF_iOS

let viewControllerStoryboardID = "dynamicDataEntry"

/* ################################################################################################################################## */
// MARK: - Enum, for defining dialog components.
/* ################################################################################################################################## */
enum RVS_ONVIF_Test_Harness_DialogComponents {
    typealias CallbackHandler = (UIView?) -> Void
    case textEntry(defaultValue: String, callback: CallbackHandler)
    case textDisplay(value: String, callback: CallbackHandler)
    case pickOne(values: [String], selectedIndex: Int, callback: CallbackHandler)
    case pickAny(values: [String], selectedIndex: Int, callback: CallbackHandler)
}

/* ################################################################################################################################## */
// MARK: - Main View Controller Class
/* ################################################################################################################################## */
class RVS_ONVIF_Test_Harness_FunctionData_ViewController: UIViewController {
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
        inSubView.trailingAnchor.constraint(equalTo: inContainer.trailingAnchor, constant: 0).isActive = true
        inSubView.leadingAnchor.constraint(equalTo: inContainer.leadingAnchor, constant: 0).isActive = true
        inSubView.heightAnchor.constraint(equalToConstant: 30.0).isActive = true
    }
    
    /* ################################################################## */
    /**
     */
    class func dialogFactory(_ inCustomerOrder: [String: RVS_ONVIF_Test_Harness_DialogComponents], command inCommand: RVS_ONVIF_DeviceRequestProtocol, dispatcher inDispatcher: RVS_ONVIF_Test_Harness_Dispatcher!) -> RVS_ONVIF_Test_Harness_FunctionData_ViewController! {
        if  let windowViewController = RVS_ONVIF_Test_Harness_AppDelegate.appDelegateObject.openNamespaceHandlerScreen,
            let ret = windowViewController.storyboard?.instantiateViewController(withIdentifier: parameterScreenStoryBoardID) as? RVS_ONVIF_Test_Harness_FunctionData_ViewController {
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
    var callbackHash: [AnyHashable: RVS_ONVIF_Test_Harness_DialogComponents.CallbackHandler] = [:]
    
    /* ################################################################## */
    /**
     */
    var command: RVS_ONVIF_DeviceRequestProtocol!
    
    /* ################################################################## */
    /**
     */
    var dispatcher: RVS_ONVIF_Test_Harness_Dispatcher!

    /* ################################################################## */
    /**
     */
    var customerOrder: [String: RVS_ONVIF_Test_Harness_DialogComponents] = [:]
    
    /* ############################################################################################################################## */
    // MARK: - Instance IB Properties
    /* ############################################################################################################################## */
    /* ################################################################## */
    /**
     */
    @IBOutlet weak var cancelButton: UIBarButtonItem!
    
    /* ################################################################## */
    /**
     */
    @IBOutlet weak var sendButton: UIBarButtonItem!
    
    /* ################################################################## */
    /**
     */
    @IBOutlet weak var selectorSwitch: UISegmentedControl!
    
    /* ################################################################## */
    /**
     */
    @IBOutlet weak var navItem: UINavigationItem!

    /* ################################################################## */
    /**
     */
    @IBOutlet weak var scrollView: UIScrollView!
    
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
        navItem.title = command.soapAction + "Request"
        let label = UILabel()
        label.text = command.rawValue
        label.textAlignment = .center
        label.font = UIFont.boldSystemFont(ofSize: 20)
        type(of: self).insertSpecialView(label, into: scrollView, topConstraint: selectorSwitch.bottomAnchor)
        
        var previousAnchor: NSLayoutYAxisAnchor = label.bottomAnchor
        
        customerOrder.forEach {
            let label = UILabel()
            label.text = $0.key
            label.textAlignment = .center
            label.font = UIFont.boldSystemFont(ofSize: 15)
            
            let control: UIView!
            
            let item = $0.value
            var callbackHandler: RVS_ONVIF_Test_Harness_DialogComponents.CallbackHandler!
            
            switch item {
            case let .textDisplay(inValue, _):
                control = UITextView()
                (control as? UITextView)?.textAlignment = .center
                (control as? UITextView)?.isEditable = false
                (control as? UITextView)?.isSelectable = false
                (control as? UITextView)?.font = UIFont.systemFont(ofSize: 15)
                (control as? UITextView)?.text = inValue
            case let .textEntry(inDefaultValue, inCallback):
                callbackHandler = inCallback
                control = UITextField()
                (control as? UITextField)?.text = inDefaultValue
            case .pickOne(let inValues, let inSelectedIndex, let inCallback):
                callbackHandler = inCallback
                control = UISegmentedControl(items: inValues)
                (control as? UISegmentedControl)?.selectedSegmentIndex = inSelectedIndex
            case .pickAny(let inValues, let inSelectedIndex, let inCallback):
                callbackHandler = inCallback
                control = UISegmentedControl(items: inValues)
                (control as? UISegmentedControl)?.selectedSegmentIndex = inSelectedIndex
            }
            
            if nil != control {
                type(of: self).insertSpecialView(label, into: scrollView, topConstraint: previousAnchor)
                type(of: self).insertSpecialView(control, into: scrollView, topConstraint: label.bottomAnchor)
                previousAnchor = control.bottomAnchor
                if nil != callbackHandler {
                    callbackHash[control] = callbackHandler
                }
            }
        }
    }
}
