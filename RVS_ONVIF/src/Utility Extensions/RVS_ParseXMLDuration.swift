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

import Foundation

/* ################################################################################################################################## */
/**
 This extension adds the capability to parse a String as an xs:duration (XML duration), returning the duration as a DateComponents Set.
 
 The definition for duration is here: https://www.w3.org/TR/xmlschema11-2/#duration
 
 A more readable breakdown is here: http://www.datypic.com/sc/xsd/t-xsd_duration.html
 */
public extension String {
    /* ################################################################## */
    /**
     This calculated property will examine the String, and will parse it for xsd:duration.
     
     If it can successfully parse the String as a properly-formatted duration, then it will return a DateComponents instance, with the duration therein.
     
     - returns: An instance of DateComponents, set to the duration. Nil, if the parse failed for any reason.
     */
    var asXMLDuration: DateComponents! {
        /* ############################################################## */
        /**
         This is an embedded scanner routine that scans a provided String for xsd:duration values, and returns a DateComponents instance.
         
         - parameter inString: The String segment to be parsed. It can be nil, in which case nil is returned.
         - parameter isNegative: An optional Bool (default is false). True, if the duration is marked as negative.
         - parameter isDate: An optional Bool (default is false). True, if this String is the first part (the Date section).
         
         - returns: An instance of DateComponents, set to the duration. Nil, if the parse failed for any reason.
         */
        func _asXMLDurationScanString(_ inString: String!, isNegative: Bool = false, isDate: Bool = false) -> DateComponents! {
            var ret: DateComponents!
            
            if let parseTarget = inString {
                let numbers = CharacterSet.decimalDigits.union(CharacterSet(charactersIn: ".")) // Numbers and a decimal point.
                let valueIndicators = CharacterSet(charactersIn: "YMDHS")   // These are the value indicators (years, months/minutes, days, hours, seconds)
                let scanner = Scanner(string: parseTarget)  // Set up a scanner, with the string supplied.
                scanner.charactersToBeSkipped = numbers.union(valueIndicators).inverted  // Ignore everything but what we give you.
                while !scanner.isAtEnd {            // Keep going until the end.
                    var value: NSString?            // The numerical value that will be scanned. We use NSString for the scanner.
                    var typeIndicator: NSString?    // This is the value indicator.
                    
                    scanner.scanCharacters(from: numbers, into: &value)                 // Grab the numerical part first.
                    scanner.scanCharacters(from: valueIndicators, into: &typeIndicator) // Followed by the value indicator.
                    
                    // Quick validation and unwrapping.
                    if let value = value as String?, let doubleVal = Double(value), let typeIndicator = typeIndicator as String? {
                        if (isDate && "HS".contains(typeIndicator))                         // Any time values must come after "T".
                            || (floor(doubleVal) != doubleVal && "S" != typeIndicator) {    // Only seconds can have a decimal value.
                            return nil
                        }
                        
                        if nil == ret {
                            ret = DateComponents()                      // This is what we'll return (unless there's an error).
                        }
                        let multiplier: Double = isNegative ? -1 : 1    // This is used to make values negative. We parse an absval.
                        let intVal = Int(doubleVal * multiplier)
                        switch typeIndicator {                          // Which components are set depends upon which value indicator we got.
                        case "Y":   // Years
                            ret.year = intVal
                        case "M":   // Months or Minutes
                            if isDate {  // Which one depends on whether this is a date or a time.
                                ret.month = intVal
                            } else {
                                ret.minute = intVal
                            }
                        case "D":   // Days
                            ret.day = intVal
                        case "H":   // Hours
                            ret.hour = intVal
                        case "S":   // Seconds and Nanoseconds. Fractions of seconds will result in a second property of zero.
                            let nanosecond = (doubleVal - floor(doubleVal)) * 10000000000  // The fractional part of the value.
                            ret.second = intVal
                            if 0 < nanosecond { // We only supply a nanosecond value if we actually have a fractional part.
                                ret.nanosecond = Int(nanosecond * multiplier)
                            }
                            
                        default:    // Nothing else is allowed.
                            return nil
                        }
                    } else {
                        return nil
                    }
                }
            }
            
            return ret
        }

        // Start of Execution
        
        var target = self   // We make a copy, because we will be removing the first character.
        let isNegative = "-" == target.first
        if isNegative {
            target.removeFirst()
        }
        
        // Separate the date section from the time section.
        let timeDate = target.uppercased().components(separatedBy: "T")
        if 0 < timeDate.count,  // Do we have at least one substring?
            !(1 < timeDate.count && timeDate[1].isEmpty),   // Make sure that we don't have an empty time (trailing "T," which is illegal).
            "P" == timeDate[0].prefix(1),   // Always begin with a "P".
            "P-" != timeDate[0].prefix(2) { // We specifically check to make sure that we don't have a minus after the "P".
            let dateString = String(timeDate[0].dropFirst())    // Drop the "P". It's possible for this String to be empty, after that.
            let timeString = (1 < timeDate.count) ? timeDate[1] : nil   // See if we have a second (Time) string.
            
            // First, we check for a date.
            var returnValue = _asXMLDurationScanString(dateString, isNegative: isNegative, isDate: true)

            // Next, we check for a time.
            if let timeComp = _asXMLDurationScanString(timeString, isNegative: isNegative) {
                if nil != returnValue { // If we already had a date, then we simply add the time components.
                    returnValue?.hour = timeComp.hour
                    returnValue?.minute = timeComp.minute
                    returnValue?.second = timeComp.second
                    returnValue?.nanosecond = timeComp.nanosecond
                } else {    // Otherwise, we are the response.
                    returnValue = timeComp
                }
            }
            
            return returnValue
        }
        
        return nil
    }
}

/* ################################################################################################################################## */
/**
 This extension provides the reverse of asXMLDuration.
 
 You can have an instance of DateComponents express itself as a legal, optimized xs:duration String.
 */
public extension DateComponents {
    /* ################################################################## */
    /**
     This calculated property will return a properly-formatted xsd:duration String, based upon the current state of this DateComponents instance.
     
     - returns: A String, if the parse was successful. Nil, if not.
     */
    var asXMLDuration: String! {
        // First, extract all of the components we're interested in. We either have a value, or 0.
        let componentArray: [Int] = [
            self.year ?? 0,
            self.month ?? 0,
            self.day ?? 0,
            self.hour ?? 0,
            self.minute ?? 0,
            self.second ?? 0,
            self.nanosecond ?? 0
        ]
        
        // Now, if one is negative, they must ALL be negative. -1 is negative, 1 is positive, and -2 or 0 (no valid values) is error.
        let multiplier = componentArray.reduce(0, { (current, nextItem) -> Int in
            if -2 != current {  // Are we BORK?
                if (nextItem < 0 && -1 == current) || (nextItem >= 0 && 1 == current) {  // We assume that we are on the same page as the previous value.
                    return current
                } else if 0 == current {    // If this is the first valid value, then we set the agenda.
                    return nextItem < 0 ? -1 : 1
                } else {        // BORK
                    return -2
                }
            } else {
                return current  // BORK
            }
        })
        
        if 1 == abs(multiplier) {                               // -2 means we have an illegal situation (some are negative, and some are not). 0 means that we have no valid numbers.
            // This allows us to loop through.
            let tagArray: [String] = ["Y", "M", "D", "H", "M"]
            
            let components = componentArray.map(abs)            // Remove any negative influences. Feng Shui...
            var resultString = -1 == multiplier ? "-P" : "P"    // Start your engines...
            
            let hasTime = 0 != components[3] || 0 != components[4] || 0 != components[5] || 0 != components[6]
            
            // The first lot are easy and straightforward.
            for index in 0..<tagArray.count {
                if 3 == index && hasTime {
                    resultString += "T" // Time for time...
                }
                if 0 != components[index] {
                    resultString += String(components[index]) + tagArray[index]
                }
            }
            
            // Seconds takes a bit more work, as it could be fractional.
            if 0 != components[tagArray.count] || 0 != components[tagArray.count + 1] {
                let mainValue = Int(components[tagArray.count])
                var fractionalValue = Double(components[tagArray.count + 1]) / 10000000000
                if 0 != fractionalValue {   // Number formatter gives us what we need.
                    fractionalValue += Double(mainValue)
                    let formatter = NumberFormatter()
                    formatter.minimumIntegerDigits = 1
                    formatter.minimumFractionDigits = 0
                    formatter.maximumFractionDigits = 4
                    let floatNumber = fractionalValue as NSNumber
                    resultString += String(formatter.string(from: floatNumber) ?? "")
                } else if 0 != mainValue {
                    resultString += String(mainValue)
                }
                resultString += "S"
            }
            
            return  "P" != resultString ? resultString : nil
        }
        
        return nil
    }
}
