/**
 © Copyright 2019, The Great Rift Valley Software Company. All rights reserved.
 
 This code is proprietary and confidential code,
 It is NOT to be reused or combined into any application,
 unless done so, specifically under written license from The Great Rift Valley Software Company.
 
 The Great Rift Valley Software Company: https://riftvalleysoftware.com
 */

import SWXMLHash

/* ###################################################################################################################################### */
/**
 This is a ridiculously simple mock "ONVIF device" class. Use this to return data for a given stimulus.
 
 The default is a simple "match stimulus" lookup, but you are free to do what you want.
 */
public class RVS_ONVIF_TestTarget_MockDevice {
    /* ################################################################## */
    /**
     This just strips the namespace off of element names.
     
     - parameter inElementName: A String, with the fully-qualified element name.
     
     - returns: the element name, minus the namespace header, and the namespace header, minus the element name, or just the element name.
     */
    class func stripNamespace(_ inElementName: String) -> (namespace: String, element: String) {
        if let colonIndex = inElementName.firstIndex(of: ":") {
            return (namespace: String(inElementName.prefix(upTo: colonIndex)), element: String(inElementName.suffix(from: inElementName.index(after: colonIndex))))
        }
        
        return (namespace: "", element: inElementName)
    }

    /* ################################################################## */
    /**
     This is a simple lookup table that returns raw XML in response to keys.
     */
    var lookupTable: [String: String] = [:]
    
    /* ################################################################## */
    /**
     This is a basic recursive routine that grabs the parsed values from the input SWXMLHas element.
     
     - parameter inParsedXML: A single parsed XML element
     - returns: Some kind of data. It could be an end node, resolved to String, Int or Double, or it could be a Dictionary, containing child elements, or it could be an Array, also containing child elements.
     */
    class func downTheRabbithole(_ inParsedXML: SWXMLHash.XMLElement) -> Any? {
        var ret: Any? = nil
        
        if !inParsedXML.text.isEmpty {
            ret = inParsedXML.text
        } else {
            
            var attributes: Any? = nil
            
            if 0 < inParsedXML.allAttributes.count {
                let attrArray = inParsedXML.allAttributes
                var temp: [String: Any] = [:]
                for (key, value) in attrArray {
                    temp[key] = value.text
                }
                
                attributes = temp
            }
            
            var children: Any? = nil
            
            if let chilluns = inParsedXML.children as? [XMLElement] {
                var retArray: [[String: Any]] = []
                for child in chilluns {
                    if let val = downTheRabbithole(child) {
                        retArray.append([child.name: val])
                    }
                }
                
                // Now, check to see if we have any dupes. If not, we can just use the Dictionary. If so, then we strip the names and use the values as just Array elements.
                let retDict = retArray.reduce(into: [String: Any]()) { (current: inout [String: Any], next) in
                    for (key, value) in next {
                        current[key] = value
                    }
                }
                
                if retDict.count != retArray.count {
                    var tempDict: [String: [Any]] = [:]
                    tempDict = retArray.reduce(into: [String: [Any]]()) { (current: inout [String: [Any]], next) in
                        for (key, value) in next {
                            if nil == current[key] {
                                current[key] = []
                            }
                            current[key]?.append(value)
                        }
                    }
                    children = tempDict
                } else {
                    children = retDict
                }
            }
            
            if nil != children && nil == attributes {
                ret = children
            } else if nil != attributes && nil == children {
                ret = attributes
            } else if let attributes = attributes, let children = children {
                let retTemp: [String: Any] = ["attributes": attributes, "Values": children]
                ret = retTemp
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
        let strippedAction = type(of: self).stripNamespace(inAction)
        var ret: [String: Any]! = nil
        
        if !inXML.isEmpty {
            let xml = SWXMLHash.config { config in
                config.shouldProcessNamespaces = true   // No namespaces. We are copying the way SOAPEngine does it.
                }.parse(inXML)
            
            if let main = xml["Envelope"]["Body"]["\(strippedAction.element)Response"].element {
                ret = [:]
                if let val =  type(of: self).downTheRabbithole(main) {
                    ret["\(strippedAction.element)Response"] = val
                }
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
            let key = inputDictionary.values.sorted().joined()   // Brute-force join
            if let xml = lookupTable[key] {
                return parseXML(xml, action: action)
            }
        }
        return nil
    }
}
