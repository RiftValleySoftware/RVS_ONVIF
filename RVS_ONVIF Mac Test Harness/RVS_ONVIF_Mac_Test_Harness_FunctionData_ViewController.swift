/**
 © Copyright 2019, The Great Rift Valley Software Company. All rights reserved.
 
 This code is proprietary and confidential code,
 It is NOT to be reused or combined into any application,
 unless done so, specifically under written license from The Great Rift Valley Software Company.
 
 The Great Rift Valley Software Company: https://riftvalleysoftware.com
 */

import Cocoa
import RVS_ONVIF_MacOS

let viewControllerStoryboardID = "dynamicDataEntry"

/* ################################################################################################################################## */
// MARK: - Enum, for defining dialog components.
/* ################################################################################################################################## */
enum RVS_ONVIF_Mac_Test_Harness_DialogComponents {
    typealias CallbackHandler = (NSView?) -> Void
    case textEntry(defaultValue: String, callback: CallbackHandler)
    case textDisplay(value: String, callback: CallbackHandler)
    case pickOne(values: [String], selectedIndex: Int, callback: CallbackHandler)
    case pickAny(values: [String], selectedIndex: Int, callback: CallbackHandler)
}

/* ################################################################################################################################## */
// MARK: - Main View Controller Class
/* ################################################################################################################################## */
class RVS_ONVIF_Mac_Test_Harness_FunctionData_ViewController: NSViewController {
    /* ############################################################################################################################## */
    // MARK: - Static Properties
    /* ############################################################################################################################## */
    static let parameterScreenStoryBoardID = "RVS_ONVIF_Mac_Test_Harness_FunctionData_ViewController"
    
    /* ############################################################################################################################## */
    // MARK: - Class Functions
    /* ############################################################################################################################## */
    /* ################################################################## */
    /**
     */
    class func insertSpecialView(_ inSubView: NSView, into inContainer: NSView, topConstraint inTopAnchor: NSLayoutYAxisAnchor! = nil) {
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
    class func dialogFactory(_ inCustomerOrder: [String: RVS_ONVIF_Mac_Test_Harness_DialogComponents], command inCommand: RVS_ONVIF_DeviceRequestProtocol, dispatcher inDispatcher: RVS_ONVIF_Mac_Test_Harness_Dispatcher!) -> RVS_ONVIF_Mac_Test_Harness_FunctionData_ViewController! {
        if  let windowViewController = RVS_ONVIF_Mac_Test_Harness_AppDelegate.appDelegateObject.functionHandlerScreen,
            let ret = windowViewController.storyboard?.instantiateController(withIdentifier: parameterScreenStoryBoardID) as? RVS_ONVIF_Mac_Test_Harness_FunctionData_ViewController {
            ret.command = inCommand
            let label: NSTextView = NSTextView()
            label.string = inCommand.rawValue
            label.alignment = .center
            label.isEditable = false
            label.isSelectable = false
            label.font = NSFont.boldSystemFont(ofSize: 20)
            insertSpecialView(label, into: ret.view, topConstraint: ret.selectorSwitch.bottomAnchor)

            var previousAnchor: NSLayoutYAxisAnchor = label.bottomAnchor
            
            inCustomerOrder.forEach {
                let label: NSTextView = NSTextView()
                label.string = $0.key
                label.alignment = .center
                label.isEditable = false
                label.isSelectable = false
                label.font = NSFont.boldSystemFont(ofSize: 15)
                
                let control: NSView!

                let item = $0.value
                var callbackHandler: RVS_ONVIF_Mac_Test_Harness_DialogComponents.CallbackHandler!
                
                switch item {
                case let .textDisplay(inValue, _):
                    control = NSTextView()
                    (control as? NSTextView)?.alignment = .center
                    (control as? NSTextView)?.isEditable = false
                    (control as? NSTextView)?.isSelectable = false
                    (control as? NSTextView)?.font = NSFont.systemFont(ofSize: 15)
                    (control as? NSTextView)?.string = inValue
                case let .textEntry(inDefaultValue, inCallback):
                    callbackHandler = inCallback
                    control = NSTextField()
                    (control as? NSTextField)?.stringValue = inDefaultValue
                case .pickOne(let inValues, let inSelectedIndex, let inCallback):
                    callbackHandler = inCallback
                    control = NSSegmentedControl(labels: inValues, trackingMode: .selectOne, target: nil, action: nil)
                    (control as? NSSegmentedControl)?.selectedSegment = inSelectedIndex
                case .pickAny(let inValues, let inSelectedIndex, let inCallback):
                    callbackHandler = inCallback
                    control = NSSegmentedControl(labels: inValues, trackingMode: .selectAny, target: nil, action: nil)
                    (control as? NSSegmentedControl)?.selectedSegment = inSelectedIndex
                }
                
                if nil != control {
                    insertSpecialView(label, into: ret.view, topConstraint: previousAnchor)
                    insertSpecialView(control, into: ret.view, topConstraint: label.bottomAnchor)
                    previousAnchor = control.bottomAnchor
                    if nil != callbackHandler {
                        ret.callbackHash[control] = callbackHandler
                    }
                }
            }
            
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
    var callbackHash: [AnyHashable: RVS_ONVIF_Mac_Test_Harness_DialogComponents.CallbackHandler] = [:]
    
    /* ################################################################## */
    /**
     */
    var command: RVS_ONVIF_DeviceRequestProtocol!
    
    /* ################################################################## */
    /**
     */
    var dispatcher: RVS_ONVIF_Mac_Test_Harness_Dispatcher!

    /* ############################################################################################################################## */
    // MARK: - Instance IB Properties
    /* ############################################################################################################################## */
    /* ################################################################## */
    /**
     */
    @IBOutlet weak var cancelButton: NSButton!
    
    /* ################################################################## */
    /**
     */
    @IBOutlet weak var selectorSwitch: NSSegmentedControl!
    
    /* ############################################################################################################################## */
    // MARK: - Base Class Override Methods
    /* ############################################################################################################################## */
    /* ################################################################## */
    /**
     */
    override func dismiss(_ inSender: Any?) {
        if let button = inSender as? NSButton, button != cancelButton {
            callbackHash.forEach {
                if let view = $0.key as? NSView {
                    $0.value(view)
                }
            }
        }
        
        super.dismiss(inSender)
    }
}
