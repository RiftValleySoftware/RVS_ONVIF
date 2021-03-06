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

import SWXMLHash

/* ###################################################################################################################################### */
/**
 This is a ridiculously simple mock "ONVIF device" class. Use this to return data for a given stimulus.
 
 The default is a simple "match stimulus" lookup, but you are free to do what you want.
 
 This will ONLY test the bare minimum "Does the Patient Have A Pulse?" bar. It will only act as a reader; writing is not supported.
*/
open class RVS_ONVIF_TestTarget_MockDevice {
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
     This is a basic recursive routine that grabs the parsed values from the input SWXMLHas element.
     
     - parameter inParsedXML: A single parsed XML element
     - returns: Some kind of data. It could be an end node, resolved to String, Int or Double, or it could be a Dictionary, containing child elements, or it could be an Array, also containing child elements.
     */
    class func downTheRabbithole(_ inParsedXML: SWXMLHash.XMLElement) -> Any? {
        var ret: Any? = nil
        
        if !(inParsedXML.text).trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
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
            
            let chilluns = inParsedXML.children
            var retArray: [[String: Any]] = []
            for child in chilluns {
                if let childElement = child as? XMLElement, let val = downTheRabbithole(childElement) {
                    retArray.append([childElement.name: val])
                } else if let child = child as? String {
                    retArray.append(["value": child])
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
            
            if nil != children && nil == attributes {
                ret = children
            } else if nil != attributes && nil == children {
                ret = attributes
            } else if let attributes = attributes, let children = children {
                if var retTemp = children as? [String: Any] {
                    retTemp["attributes"] = attributes
                    ret = retTemp
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
    internal func parseXML(_ inXML: String, action inAction: String) -> [String: Any]? {
        let strippedAction = type(of: self).stripNamespace(inAction)
        var ret: [String: Any]! = nil
        
        if !inXML.isEmpty {
            let xml = SWXMLHash.config { config in
                config.shouldProcessNamespaces = true   // No namespaces. We are copying the way SOAPEngine does it.
                config.detectParsingErrors = true
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
    internal func makeTransaction(_ inCommand: [String: Any]) -> [String: Any]? {
        var command = inCommand
        if let action = command["action"] as? String {
            command.removeValue(forKey: "action")
            var key: String = ""
            if let stringy = command as? [String: String] {
                key = stringy.values.sorted().joined()
            } else {
                var paramsArray: [String] = []
                command.values.forEach {
                    if let value = $0 as? String {
                        paramsArray.append(value)
                    }
                }
                key = paramsArray.sorted().joined()
            }
            key = action + key
            if let xml = lookupTable[key] {
                return parseXML(xml, action: action)
            }
        }
        return nil
    }

    /* ################################################################################################################################## */
    // MARK: - Override These -
    /* ################################################################################################################################## */
    /* ################################################################## */
    /**
     This is a simple lookup table that returns raw XML in response to keys (Get-only).
     
     The included keys are required for all mocks.
     
     The key is the (namespace included) command, with the values (not the keys) of any parameters smashed onto the end.
     The value needs to be pure (100% complete) XML, as returned in response to that command, from the device. Quotes (") need to be escaped.
     */
    var lookupTable: [String: String]  {
        return [
            /// Core GetDeviceInformation
            "trt:GetDeviceInformation":
            "",
            
            /// Core GetServices (with the include service capabilities parameter set to true).
            "trt:GetServicestrue":
            "",
            
            /// Core GetServiceCapabilities
            "trt:GetServiceCapabilities":
            "",
            
            /// Core GetScopes
            "trt:GetScopes":
            "",
            
            /// Core GetNetworkInterfaces
            "trt:GetNetworkInterfaces":
            "",
            
            /// Core GetNetworkProtocols
            "trt:GetNetworkProtocols":
            "",
            
            /// Core GetNetworkDefaultGateway
            "trt:GetNetworkDefaultGateway":
            "",

            /// Core GetCapabilities
            "trt:GetCapabilities":
            "",
            
            /// Get Streaming Profiles
            "trt:GetProfiles":
            ""
        ]
    }
    
    /* ################################################################## */
    /**
     This is a name for the mock device.
     Get-only.
     */
    var name: String { return "ERROR" }
}
