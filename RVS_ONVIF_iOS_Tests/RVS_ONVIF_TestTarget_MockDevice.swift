/**
 © Copyright 2019, The Great Rift Valley Software Company. All rights reserved.
 
 This code is proprietary and confidential code,
 It is NOT to be reused or combined into any application,
 unless done so, specifically under written license from The Great Rift Valley Software Company.
 
 The Great Rift Valley Software Company: https://riftvalleysoftware.com
 */

import Foundation
import XCTest
import SwiftyXMLParser

/* ###################################################################################################################################### */
/**
 This is a ridiculously simple mock "ONVIF device" class. Use this to return data for a given stimulus.
 
 The default is a simple "match stimulus" lookup, but you are free to do what you want.
 */
public class RVS_ONVIF_TestTarget_MockDevice: NSObject, XMLParserDelegate {
    /* ################################################################## */
    /**
     The default lookup table uses a String as the key (built from the stimulus), and responds with XML, in a String.
     
     This needs to be filled out; either by subclasses, or by assignment.
     */
    var lookupTable: [String: String] = [:]

    /* ################################################################## */
    /**
     This will parse response XML, and return a parsed Dictionary.
     
     - parameter inXML: The response data as an XML String
     - returns: A Dictionary, containing the parsed response.
     */
    func parseXML(_ inXML: String) -> [String: Any]? {
        if !inXML.isEmpty, let data = inXML.data(using: .utf8) {
        }
        return nil
    }

    /* ################################################################## */
    /**
     This will return a response Dictionary, derived from the given stimulus Dictionary.
     This is the default, which simply assumes the input Dictionary is [String: String], and returns a "brute force" lookup from the table.
     
     - parameter inCommand: The command that is to be "sent" to the "device".
     - returns: A Dictionary, containing the parsed response.
     */
    func makeTransaction(_ inCommand: [String: Any]) -> [String: Any]? {
        if let inputDictionary = inCommand as? [String: String] {
            let key = inputDictionary.values.joined()   // Brute-force join
            
            if let xml = lookupTable[key] {
                return parseXML(xml)
            }
        }
        return nil
    }
}
