/**
 © Copyright 2019, The Great Rift Valley Software Company. All rights reserved.
 
 This code is proprietary and confidential code,
 It is NOT to be reused or combined into any application,
 unless done so, specifically under written license from The Great Rift Valley Software Company.
 
 The Great Rift Valley Software Company: https://riftvalleysoftware.com
 
 Version 1.1
 */

import UIKit

/* ###################################################################################################################################### */
/**
 This file contains extensions and simple utilities that form a baseline of extra runtime seasoning for our projects.
 */

/* ###################################################################################################################################### */
// MARK: - Extensions -
/* ###################################################################################################################################### */
/**
 This adds some functionality for UIView
 */
extension UIView {
    /* ################################################################## */
    /**
     This allows us to add a subview, and set it up with auto-layout constraints to fill the superview.
     
     - parameter inSubview: The subview we want to add.
     */
    func addContainedView(_ inSubView: UIView) {
        addSubview(inSubView)
        
        inSubView.translatesAutoresizingMaskIntoConstraints = false
        
        addConstraints([
            NSLayoutConstraint(item: inSubView,
                               attribute: .top,
                               relatedBy: .equal,
                               toItem: self,
                               attribute: .top,
                               multiplier: 1.0,
                               constant: 0),
            NSLayoutConstraint(item: inSubView,
                               attribute: .left,
                               relatedBy: .equal,
                               toItem: self,
                               attribute: .left,
                               multiplier: 1.0,
                               constant: 0),
            NSLayoutConstraint(item: inSubView,
                               attribute: .bottom,
                               relatedBy: .equal,
                               toItem: self,
                               attribute: .bottom,
                               multiplier: 1.0,
                               constant: 0),
            NSLayoutConstraint(item: inSubView,
                               attribute: .right,
                               relatedBy: .equal,
                               toItem: self,
                               attribute: .right,
                               multiplier: 1.0,
                               constant: 0)])
    }
    
    /* ################################################################## */
    /**
     - returns: the first responder view. Nil, if no view is a first responder.
     */
    var currentFirstResponder: UIResponder! {
        if isFirstResponder {
            return self
        }
        
        for view in subviews {
            if let responder = view.currentFirstResponder {
                return responder
            }
        }
        
        return nil
    }
}

/* ###################################################################################################################################### */
/**
 This extension adds some nice features for UIImage
 */
extension UIImage {
    /* ################################################################## */
    /**
     This allows us to create a simple "filled color" image.
     
     From here: https://stackoverflow.com/a/33675160/879365
     
     - parameter color: The UIColor we want to fill the image with.
     - parameter size: An optional parameter (default is 1 X 1) that designates the size of the image.
     */
    public convenience init?(color: UIColor, size: CGSize = CGSize(width: 1, height: 1)) {
        let rect = CGRect(origin: .zero, size: size)
        UIGraphicsBeginImageContextWithOptions(rect.size, false, 0.0)
        color.setFill()
        UIRectFill(rect)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        guard let cgImage = image?.cgImage else { return nil }
        self.init(cgImage: cgImage)
    }
}

/* ###################################################################################################################################### */
/**
 This extension adds some syntactic Sweet & Low for HSB and Grayscale.
 */
extension UIColor {
    /* ################################################################## */
    /**
     This just allows us to get an HSB color from a standard UIColor.
     From here: https://stackoverflow.com/a/30713456/879365
     
     - returns: A tuple, containing the HSBA color.
     */
    var hsba:(h: CGFloat, s: CGFloat, b: CGFloat, a: CGFloat) {
        var h: CGFloat = 0, s: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
        if getHue(&h, saturation: &s, brightness: &b, alpha: &a) {
            return (h: h, s: s, b: b, a: a)
        }
        return (h: 0, s: 0, b: 0, a: 0)
    }
    
    /* ################################################################## */
    /**
     - returns true, if the color is grayscale (or black or white).
     */
    var isGrayscale: Bool {
        var h: CGFloat = 0, s: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
        if !getHue(&h, saturation: &s, brightness: &b, alpha: &a) {
            return true
        }
        return 0 == s   // Saturation of zero means no color.
    }
    
    /* ################################################################## */
    /**
     - returns true, if the color is clear.
     */
    var isClear: Bool {
        var white: CGFloat = 0, h: CGFloat = 0, s: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
        if !getHue(&h, saturation: &s, brightness: &b, alpha: &a) {
            return 0.0 == a
        } else if getWhite(&white, alpha: &a) {
            return 0.0 == a
        }
        
        return false
    }
    
    /* ################################################################## */
    /**
     - returns the white level of the color.
     */
    var whiteLevel: CGFloat {
        var white: CGFloat = 0, alpha: CGFloat = 0
        if getWhite(&white, alpha: &alpha) {
            return white
        }
        return 0
    }
}
