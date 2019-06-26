/**
 © Copyright 2019, The Great Rift Valley Software Company. All rights reserved.
 
 This code is proprietary and confidential code,
 It is NOT to be reused or combined into any application,
 unless done so, specifically under written license from The Great Rift Valley Software Company.
 
 The Great Rift Valley Software Company: https://riftvalleysoftware.com
 */

import SwiftyXMLParser

/* ###################################################################################################################################### */
/**
 This is a ridiculously simple mock "ONVIF device" class. Use this to return data for a given stimulus.
 
 The default is a simple "match stimulus" lookup, but you are free to do what you want.
 */
public class RVS_ONVIF_TestTarget_MockDevice: NSObject, XMLParserDelegate {
    /* ################################################################## */
    /**
     This just strips the namespace off of element names.
     
     - parameter inElementName: A String, with the fully-qualified element name.
     
     - returns: the element name, minus the namespace header, and the namespace header, minus the element name.
     */
    class func stripNamespace(_ inElementName: String) -> (namespace: String, element: String)! {
        if let colonIndex = inElementName.firstIndex(of: ":") {
            return (namespace: String(inElementName.prefix(upTo: colonIndex)), element: String(inElementName.suffix(from: inElementName.index(after: colonIndex))))
        }
        
        return nil
    }
    
    /* ################################################################## */
    /**
     This is a simple lookup table that returns raw XML in response to keys.
     */
    var lookupTable: [String: String] = [:]

    /* ################################################################## */
    /**
     This is a brute-force parser for XML elements. We use this to translate from the SwiftyXML object model into a simple string-key Dictionary.
     
     - parameter inPreparsed: The SwiftyXML preparsed object.
     
     - returns: A Dictionary, keyed on the unqualified names, of the contents of the object.
     */
    class func recursiveParser(_ inPreparsed: XML.Element) -> [String: Any] {
        var ret: [String: Any] = [:]
            
        for child in inPreparsed.childElements {
            if let elemName = stripNamespace(child.name) {
                if 0 < child.childElements.count {
                    var contents: [String: Any] = [:]
                    for shorty in child.childElements {
                        if let shortyName = stripNamespace(shorty.name) {
                            // We do this, so we don't have to pick the value out of an unnecessary Dictionary.
                            if 0 < shorty.childElements.count {
                                contents[shortyName.element] = recursiveParser(shorty)
                            } else {
                                contents[shortyName.element] = shorty.text  // Shouldn't be nil, but if so, what the hell...
                            }
                        }
                    }
                    ret[elemName.element] = contents
                } else {
                    ret[elemName.element] = child.text ?? ""
                }
            }
        }
        
        return ret
    }
    
    /* ################################################################## */
    /**
     This will parse response XML, and return a parsed Dictionary.
     
     - parameter inXML: The response data as an XML String
     - returns: A Dictionary, containing the parsed response.
     */
    func parseXML(_ inXML: String, action inAction: String) -> [String: Any]? {
        var ret: [String: Any]!
        
        if !inXML.isEmpty {
            let parsedObject = try! XML.parse(inXML)
            let soapBody = parsedObject["SOAP-ENV:Envelope", "SOAP-ENV:Body"]   // Strip off the SOAP stuff.
            if let elem = soapBody.element {
                ret = type(of: self).recursiveParser(elem)
            }
        }
        
        return ret
    }

    /* ################################################################## */
    /**
     This will return a response Dictionary, derived from the given stimulus Dictionary.
     This is the default, which simply assumes the input Dictionary is [String: String], and returns a "brute force" lookup from the table.
     
     - parameter inCommand: The command that is to be "sent" to the "device".
     - returns: A Dictionary, containing the parsed response.
     */
    func makeTransaction(_ inCommand: [String: Any]) -> [String: Any]? {
        if let inputDictionary = inCommand as? [String: String], let action = inputDictionary["action"] {
            let key = inputDictionary.values.joined()   // Brute-force join
            if let xml = lookupTable[key] {
                return parseXML(xml, action: action)
            }
        }
        return nil
    }
}
