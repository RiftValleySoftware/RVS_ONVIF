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
    class func dialogFactory(_ inCustomerOrder: [String: RVS_ONVIF_Mac_Test_Harness_DialogComponents]) -> RVS_ONVIF_Mac_Test_Harness_FunctionData_ViewController! {
        let ret = RVS_ONVIF_Mac_Test_Harness_FunctionData_ViewController()

        inCustomerOrder.forEach {
            let label: NSTextView = NSTextView()
            label.string = $0.key
            let control: NSView!

            let item = $0.value
            var callbackHandler: RVS_ONVIF_Mac_Test_Harness_DialogComponents.CallbackHandler!
            
            switch item {
            case let .textDisplay(inValue, _):
                control = NSTextView()
                (control as? NSTextView)?.string = inValue
            case let .textEntry(inDefaultValue, inCallback):
                callbackHandler = inCallback
                control = NSTextField()
                (control as? NSTextField)?.stringValue = inDefaultValue
            case .pickOne(let inValues, let inSelectedIndex, let inCallback), .pickAny(let inValues, let inSelectedIndex, let inCallback):
                callbackHandler = inCallback
                control = NSSegmentedControl()
                for value in inValues.enumerated() {
                    (control as? NSSegmentedControl)?.setLabel(value.element, forSegment: value.offset)
                }
                if case .pickAny = item {
                    (control as? NSSegmentedControl)?.trackingMode = .selectAny
                } else {
                    (control as? NSSegmentedControl)?.trackingMode = .selectOne
                }
                
                (control as? NSSegmentedControl)?.selectedSegment = inSelectedIndex
            }
            
            if nil != control {
                insertSpecialView(label, into: ret.view)
                insertSpecialView(control, into: ret.view, topConstraint: label.bottomAnchor)
                if nil != callbackHandler {
                    (control as? NSControl)?.target = self
                    (control as? NSControl)?.action = #selector(callbackHandlerFunction)
                    ret.callbackHash[control] = callbackHandler
                }
            }
        }
        
        return ret
    }
    
    /* ################################################################## */
    /**
     */
    var callbackHash: [AnyHashable: RVS_ONVIF_Mac_Test_Harness_DialogComponents.CallbackHandler] = [:]
    
    /* ################################################################## */
    /**
     */
    @objc func callbackHandlerFunction(_ inControl: NSView) {
        if let callbackHandler = callbackHash[inControl] {
            callbackHandler(inControl)
        }
    }
    
    /* ################################################################## */
    /**
     */
    override func loadView() {
        view = NSView()
    }
}