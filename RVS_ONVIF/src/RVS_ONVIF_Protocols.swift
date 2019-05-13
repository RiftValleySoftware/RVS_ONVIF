/**
 © Copyright 2019, The Great Rift Valley Software Company. All rights reserved.
 
 This code is proprietary and confidential code,
 It is NOT to be reused or combined into any application,
 unless done so, specifically under written license from The Great Rift Valley Software Company.
 
 The Great Rift Valley Software Company: https://riftvalleysoftware.com
 */

import Foundation
import SOAPEngine64

/* ###################################################################################################################################### */
/**
 This file contains a number of protocols used in the ONVIF Framework.
 
 It was inspired by the ONVIFCamera library, by Rémy Virin, but is a great deal more robust. He did an excellent job, but I'm a "fiddler."
 
 It uses SOAPEngine, by Danilo Priore (http://www.prioregroup.com) to handle the stuff below the session layer.
 If you want to use this on a device (as opposed to the simulator), you need to purchase a SOAPEngine license from the Priore Group (see URI, above).
 */
/* ###################################################################################################################################### */

/* ###################################################################################################################################### */
/**
 This is the delegate protocol for use with the RVS_ONVIF framework. It has all required methods.
 
 This is a "pure" Swift protocol, requiring that it be applied to a class.
 
 These methods are all called in the main thread.
 */
public protocol RVS_ONVIFDelegate: class {
    /* ################################################################## */
    /**
     This is a "general purpose" callback that is made immediately before any other callback. It allows the client to interrupt the parsing process.
     It contains the information that would be sent to the following specialized callback, but as the initial partially-parsed dictionary from SOAPEngine.
     This is not called for errors.
     
     - parameter instance: The RVS_ONVIF instance that is calling the delegate.
     - parameter rawDataPreview: The partially-parsed data to be sent for specific parsing in the next callback (can be nil).
     - parameter deviceRequest: The request object (can be nil).
     - returns: false, if the following specialized callback should be made. If true, then the following callback will not be made.
     */
    func onvifInstance(_ instance: RVS_ONVIF, rawDataPreview: [String: Any]!, deviceRequest: RVS_ONVIF_DeviceRequestProtocol!) -> Bool
    
    /* ################################################################## */
    /**
     This is called whenever an error is encountered by the RVS_ONVIF framework.
     
     This is not required, but you'd be well-advised to implement it.
     
     - parameter instance: The RVS_ONVIF instance that is calling the delegate.
     - parameter failureWithReason: An enumeration, with associated values that refine the issue.
     */
    func onvifInstance(_ instance: RVS_ONVIF, failureWithReason: RVS_ONVIF.RVS_Fault!)
    
    /* ################################################################## */
    /**
     This is called when a response is a simple empty packet. It is a simple "ack."
     
     This is not required, but it's a good idea to implement it, as many responses use it.
     
     - parameter instance: The RVS_ONVIF instance that is calling the delegate.
     - parameter simpleResponseToRequest: An enumeration, with the request that is being satisfied by this response.
     */
    func onvifInstance(_ instance: RVS_ONVIF, simpleResponseToRequest: RVS_ONVIF_DeviceRequestProtocol!)
    
    /* ################################################################## */
    /**
     This is called if the instance is completely initialized. It is optional.
     
     - parameter instance: The RVS_ONVIF instance that is calling the delegate.
     */
    func onvifInstanceInitialized(_ instance: RVS_ONVIF)
    
    /* ################################################################## */
    /**
     This is called if the instance is "deinitialized." It is optional.
     
     - parameter instance: The RVS_ONVIF instance that is calling the delegate.
     */
    func onvifInstanceDeinitialized(_ instance: RVS_ONVIF)
}

/* ###################################################################################################################################### */
/**
 This is just here to make the protocol optional. It deliberately does not do anything.
 */
public extension RVS_ONVIFDelegate {
    /* ################################################################## */
    /**
     This is a "general purpose" callback that is made immediately before any other callback. It allows the client to interrupt the parsing process.
     It contains the information that would be sent to the following specialized callback, but as the initial partially-parsed dictionary from SOAPEngine.
     This is not called for errors.
     
     - parameter instance: The RVS_ONVIF instance that is calling the delegate.
     - parameter rawDataPreview: The partially-parsed data to be sent for specific parsing in the next callback (can be nil).
     - parameter deviceRequest: The request object (can be nil).
     - returns: false, if the following specialized callback should be made. If true, then the following callback will not be made.
     */
    func onvifInstance(_ instance: RVS_ONVIF, rawDataPreview: [String: Any]!, deviceRequest: RVS_ONVIF_DeviceRequestProtocol!) -> Bool {
        #if DEBUG
            print("onvifInstance:rawDataPreview(\(String(describing: rawDataPreview)), deviceRequest: \(String(describing: deviceRequest))")
        #endif
        return false
    }
    
    /* ################################################################## */
    /**
     This is called whenever an error is encountered by the RVS_ONVIF framework.
     
     This is not required, but you'd be well-advised to implement it.
     
     - parameter instance: The RVS_ONVIF instance that is calling the delegate.
     - parameter failureWithReason: An enumeration, with associated values that refine the issue.
     */
    func onvifInstance(_ instance: RVS_ONVIF, failureWithReason: RVS_ONVIF.RVS_Fault!) {
        #if DEBUG
            print("onvifInstance:failureWithReason(\(String(describing: failureWithReason))")
        #endif
    }
    
    /* ################################################################## */
    /**
     This is called when a response is a simple empty packet. It is a simple "ack."

     This is not required, but it's a good idea to implement it, as many responses use it.
     
     - parameter instance: The RVS_ONVIF instance that is calling the delegate.
     - parameter simpleResponseToRequest: An enumeration, with the request that is being satisfied by this response.
     */
    func onvifInstance(_ instance: RVS_ONVIF, simpleResponseToRequest: RVS_ONVIF_DeviceRequestProtocol!) {
        #if DEBUG
            print("onvifInstance:simpleResponseToRequest(\(String(describing: simpleResponseToRequest))")
        #endif
    }
    
    /* ################################################################## */
    /**
     This is called if the instance is completely initialized. It is optional.

     - parameter instance: The RVS_ONVIF instance that is calling the delegate.
     */
    func onvifInstanceInitialized(_ instance: RVS_ONVIF) {
        #if DEBUG
            print("onvifInstance:onvifInstanceInitialized")
        #endif
    }

    /* ################################################################## */
    /**
     This is called if the instance is "deinitialized." It is optional.
     
     - parameter instance: The RVS_ONVIF instance that is calling the delegate.
     */
    func onvifInstanceDeinitialized(_ instance: RVS_ONVIF) {
        #if DEBUG
            print("onvifInstance:onvifInstanceDeinitialized")
        #endif
    }
}

/* ###################################################################################################################################### */
/**
 This is a base protocol for structs returned from the ONVIF object. They can all refer back to their "owner."
 */
public protocol OwnedInstanceProtocol {
    /** This is the RVS_ONVIF instance that "owns" this struct. */
    var owner: RVS_ONVIF! { get }
}

/* ###################################################################################################################################### */
/**
 This protocol is used to define the basic interface for our ONVIF Profile implementation classes.
 */
public protocol ProfileHandlerProtocol: OwnedInstanceProtocol {
    /* ############################################################## */
    /**
     This is the scope enum for this handler.
     */
    static var scopeProfile: RVS_ONVIF_Core.Scope.ProfileType { get }
    /* ############################################################## */
    /**
     These are the namespaces handled by this profile handler.
     */
    static var namespaces: [String] { get }
    /* ############################################################## */
    /**
     This is which of the profile namespaces are supported by this device. Latest version is last.
     */
    var supportedNamespaces: [String] { get set }
    /* ############################################################## */
    /**
     This is the profile name key.
     */
    var profileName: String { get }
    /* ############################################################## */
    /**
     This is a list of the commands (as enum values) available for this enum
     */
    var availableCommands: [RVS_ONVIF_DeviceRequestProtocol] { get }
    /* ############################################################## */
    /**
     This is a list of the commands (as Strings) available for this handler
     */
    var availableCommandsAsStrings: [String] { get }
    
    /* ############################################################## */
    /**
     This is the profile namespace (for looking up in the services list).
     
     - parameter inIndex: This is an index into the namespace array.
     */
    func profileNamespace(_ inIndex: Int) -> String
    
    /* ################################################################## */
    /**
     This is called upon a successful SOAP call.
     
     - parameter inResponseDictionary: The Dictionary ([String: Any]) of the response data.
     - parameter soapRequest: The SOAP request object call, as a String
     - parameter soapEngine: The SOAPEngine object that executed the request.
     - returns: true, if the callback was handled (including as an error).
     */
    func callbackHandler(_ responseDictionary: [String: Any], soapRequest: String, soapEngine: SOAPEngine) -> Bool
}

/* ###################################################################################################################################### */
/**
 This extension allows us to have a default for one of the defined variables that simply turns our specific lists of commands into Strings.
 */
extension ProfileHandlerProtocol {
    /* ############################################################## */
    /**
     This is the profile namespace (for looking up in the services list).
     
     - parameter inIndex: This is an index into the namespace array. Default is 0.
     */
    public func profileNamespace(_ inIndex: Int = 0) -> String {
        let useIndex = min(inIndex, supportedNamespaces.count - 1)
        return supportedNamespaces[useIndex]
    }
    
    /* ############################################################## */
    /**
     This is a list of the commands (as Strings) available for this handler
     */
    public var availableCommandsAsStrings: [String] {
        let cases = availableCommands
        var ret: [String] = []
        
        for oneCase in cases {
            ret.append(String(describing: oneCase))
        }
        
        return ret
    }
}

/* ###################################################################################################################################### */
/**
 This protocol defines the basic structure of our SOAP command enums.
 */
public protocol RVS_ONVIF_DeviceRequestProtocol {
    /* ############################################################## */
    /**
     This is the profile key (for looking up in the profile hander list).
     */
    var profileKey: String { get }
    /* ############################################################## */
    /**
     This allows us to use enum rawValues in our defaults.
     I got the idea for this here: https://stackoverflow.com/a/33571134/879365
     */
    var rawValue: String { get }
    /* ############################################################## */
    /**
     This is the namespace indicator for the SOAP action.
     */
    var soapSpace: String { get }
    /* ############################################################## */
    /**
     This is the namespace indicator for the SOAP action's parameters.
     */
    var paramSpace: String { get }
    /* ############################################################## */
    /**
     This is the actual SOAP XML element name for the command.
     */
    var soapAction: String { get }
    /* ############################################################## */
    /**
     If true, then the SOAP call will include decoded attributes (not just node values).
     */
    var isRetrieveAttributes: Bool { get }
    /* ############################################################## */
    /**
     If true, then this operation requires additional parameters (needs a custom setup). Default is false.
     */
    var isRequiresParameters: Bool { get }

    /* ############################################################## */
    /**
     This is the namespace, converted to a string for inclusion in the SOAP envelope element.
     - parameter inONVIF_Handler: The RVS_ONVIF instance that "owns" this transaction.
     - returns: a String, with the namespace.
     */
    func headerNamespaceFor(_ inONVIF_Handler: RVS_ONVIF!) -> String
    /* ############################################################## */
    /**
     This is the path for our ONVIF call.
     */
    func pathFor(_: RVS_ONVIF!) -> String
}

/* ################################################################## */
/**
 Set a couple of defaults for the path and attributes flag.
 */
extension RVS_ONVIF_DeviceRequestProtocol {
    /* ############################################################## */
    /**
     This is the namespace indicator for the SOAP action.
     */
    var soapSpace: String {
        return "trt"
    }
    
    /* ############################################################## */
    /**
     This is the namespace indicator for the SOAP action's parameters.
     */
    var paramSpace: String {
        return "tt"
    }
    
    /* ############################################################## */
    /**
     This allows us to use String enums to define our SOAP calls.
     */
    var soapAction: String {
        return "\(soapSpace):\(rawValue)"
    }
    
    /* ############################################################## */
    /**
     Default is false.
     */
    var isRetrieveAttributes: Bool {
        return false
    }
    /* ############################################################## */
    /**
     Default is false.
     */
    var isRequiresParameters: Bool {
        return false
    }

    /* ############################################################## */
    /**
     This is the namespace, converted to a string for inclusion in the SOAP envelope element.
     */
    func namespaceFor(_ inONVIF_Handler: RVS_ONVIF!) -> String {
        var ret = ""
        if  nil != inONVIF_Handler,
            let profile = inONVIF_Handler?.profiles[profileKey] {
            ret = profile.profileNamespace(1)
        }
        return ret
    }

    /* ############################################################## */
    /**
     This is the namespace, with additional information added.
     */
    public func headerNamespaceFor(_ inONVIF_Handler: RVS_ONVIF!) -> String {
        var ret = ""
        if  nil != inONVIF_Handler {
            ret = " xmlns:trt=\"\(namespaceFor(inONVIF_Handler))\""
            
            if isRequiresParameters {
                ret += " xmlns:tt=\"http://www.onvif.org/ver10/schema\""
            }
        }
        return ret
    }

    /* ############################################################## */
    /**
     This is the default ONVIF path handler. It looks up the path in the ONVIF driver instance.
     
     - parameter inONVIF_Handler: The RVS_ONVIF instance that is using this.
     - returns: A String, with the relative path.
     */
    func pathFor(_ inONVIF_Handler: RVS_ONVIF! = nil) -> String {
        var ret = "/onvif/device_service"   // This is the default.
        if  let service = inONVIF_Handler?.services[namespaceFor(inONVIF_Handler)] {
            ret = service.xAddr.path
        }
        
        return ret
    }
}

/* ###################################################################################################################################### */
/**
 This protocol defines the three main parameters of most configuration structs.
 */
public protocol ConfigurationProtocol: OwnedInstanceProtocol {
    /** Everything has a name. */
    var name: String { get }
    /** Most have a token. */
    var token: String { get }
    /** Several have a UseCount. */
    var useCount: Int { get }
}

/* ################################################################## */
/**
 Set a couple of defaults for the token and UseCount
 */
public extension ConfigurationProtocol {
    /** The token defaults to the name, but with spaces converted to underscores. */
    var token: String { return name.replacingOccurrences(of: " ", with: "_") }
    /** We assume 1 */
    var useCount: Int { return 1 }
}

/* ################################################################################################################################## */
// MARK: - This is a special protocol for developing "dispatcher" handlers for RVS_ONVIF instances.
/* ################################################################################################################################## */
public protocol RVS_ONVIF_Dispatcher {
    /* ################################################################## */
    /**
     This is the RVS_ONVIF instance that the dispatcher references. It is required to be implemented (and populated) by the final dispatcher instance.
     */
    var owner: RVS_ONVIF! { get set }
    /* ################################################################## */
    /**
     This is a String, returned by the dispatcher, that indicates which profile handler to use for it. It is implemented by the "first level" protocol override.
     */
    var profileSig: String { get }
    
    /* ################################################################## */
    /**
     This method is required to be implemented by the final dispatcher. It is called to handle a command (as opposed to a callback).
     
     - parameter inCommand: The command being sent.
     - returns: true, if the command is being handled. Can be ignored.
     */
    @discardableResult func sendRequest(_ inCommand: RVS_ONVIF_DeviceRequestProtocol) -> Bool
    
    /* ################################################################## */
    /**
     This method is required to be implemented by the final dispatcher. This method is called to deliver the response from the device.
     
     - parameter inCommand: The command to which this is a response.
     - parameter params: The data returned (and parsed) from the device. It can be any one of the various data types.
     - returns: true, if the response was consumed. Can be ignored.
     */
    @discardableResult func deliverResponse(_ inCommand: RVS_ONVIF_DeviceRequestProtocol, params: Any!) -> Bool

    /* ################################################################## */
    /**
     This method is implemented by the final dispatcher, and is used to fetch the parameters for the given command.
     
     - parameter inCommand: The command being sent.
     - returns: a Dictionary<String, Any>, with the command parameters.
     */
    func getParametersForCommand(_ inCommand: RVS_ONVIF_DeviceRequestProtocol) -> [String: Any]!

    /* ################################################################## */
    /**
     This is a simple test, to see if the instance can handle the given command. It is implemented by this protocol, but is made final by the "first level" protocol override.

     - parameter inCommand: The command being sent.
     - returns: true, if the command can be handled by this instance.
     */
    func isAbleToHandleThisCommand(_ inCommand: RVS_ONVIF_DeviceRequestProtocol) -> Bool
}

/* ################################################################################################################################## */
// MARK: - This is a special protocol for developing "dispatcher" handlers for RVS_ONVIF instances.
/* ################################################################################################################################## */
extension RVS_ONVIF_Dispatcher {
    /* ################################################################## */
    /**
     This is a String, returned by the dispatcher, that indicates which profile handler to use for it. It is implemented by the "first level" protocol override.
     
     - returns: Blank, for the "root" dispatcher protocol.
     */
    public var profileSig: String {
        return ""
    }

    /* ################################################################## */
    /**
     This method is implemented by the final dispatcher, and is used to fetch the parameters for the given command. This implementation returns an empty command.
     
     - parameter inCommand: The command being sent.
     - returns: an empty Dictionary<String, Any>.
     */
    public func getParametersForCommand(_ inCommand: RVS_ONVIF_DeviceRequestProtocol) -> [String: Any]! {
        return [:]
    }

    /* ################################################################## */
    /**
     This is called to handle a command (as opposed to a callback).
     
     - parameter inCommand: The command being sent.
     - parameter params: A parameter Dictionary. Optional, and default is empty.
     - returns: true, if the command is being handled. Can be ignored.
     */
    @discardableResult public func sendRequest(_ inCommand: RVS_ONVIF_DeviceRequestProtocol) -> Bool {
        if isAbleToHandleThisCommand(inCommand) {
            // The final dispatcher will supply any required parameters.
            if let parameters = getParametersForCommand(inCommand), !parameters.isEmpty {
                owner.performRequest(inCommand, params: parameters)
                return true
            } else if !inCommand.isRequiresParameters {
                owner.performRequest(inCommand)
                return true
            }
        }
        return false
    }

    /* ################################################################## */
    /**
     This is a simple test, to see if the instance can handle the given command. It is implemented by this protocol, but is made final by the "first level" protocol override.
     
     - parameter inCommand: The command being sent.
     - returns: true, if the command can be handled by this instance.
     */
    public func isAbleToHandleThisCommand(_ inCommand: RVS_ONVIF_DeviceRequestProtocol) -> Bool {
        let profileSigRender = profileSig
        if let profileHandler = owner.profiles[profileSigRender] {
            if profileHandler.availableCommandsAsStrings.contains(inCommand.rawValue) {
                #if DEBUG
                    print("Handler \(String(reflecting: profileHandler)) Can Accept: \(String(reflecting: inCommand))")
                #endif
                return true
            }
        }
        
        return false
    }
}
