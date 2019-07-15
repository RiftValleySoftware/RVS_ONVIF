/**
 © Copyright 2019, The Great Rift Valley Software Company. All rights reserved.
 
 This code is proprietary and confidential code,
 It is NOT to be reused or combined into any application,
 unless done so, specifically under written license from The Great Rift Valley Software Company.
 
 The Great Rift Valley Software Company: https://riftvalleysoftware.com
 
 Version 1.0
 */

import Foundation

/* ###################################################################################################################################### */
/**
 This file contains extensions and simple utilities that form a baseline of extra runtime seasoning for our projects.
 */
/* ###################################################################################################################################### */
/**
 This cool little extension comes straight from here: https://stackoverflow.com/a/55796671/879365
 */
public extension Sequence {
    /* ################################################################## */
    /**
     This allows us to sort through a sequence container of various instances,
     looking for ones that match a given protocol.
     
     - parameter of: The type that we are filtering for.
     - returns: An Array of elements that conform to the given type.
     */
    func filterForInstances<T>(of: T.Type) -> [T] {
        return self.compactMap { $0 as? T }
    }
}
