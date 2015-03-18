//
//  Infinitweet.swift
//  InfiniTweet
//
//  Created by Ruben on 3/1/15.
//  Copyright (c) 2015 Ruben. All rights reserved.
//

import Foundation
import UIKit

class Infinitweet {
    var image : UIImage
    let padding = 20.0 as CGFloat //default padding for all
    
    //prepare wordmark for later
    let wordmark = "Infinitweet" as NSString
    let wordmarkAttributes = [NSFontAttributeName: UIFont.boldSystemFontOfSize(14.0), NSForegroundColorAttributeName: UIColor(white: 0, alpha: 0.5)]
    
    init(text : NSAttributedString, background : UIColor, wordmarkHidden : Bool) {
        //set text properties
        let options = unsafeBitCast(NSStringDrawingOptions.UsesLineFragmentOrigin.rawValue |
            NSStringDrawingOptions.UsesFontLeading.rawValue,
            NSStringDrawingOptions.self)
        
        //set initial image attempt properties
        var width = 200 as CGFloat
        var imageSize = text.boundingRectWithSize(CGSizeMake(CGFloat(width), CGFloat.max),
            options: options,
            context: nil)
        
        //wordmark size
        let wordmarkSize = wordmark.boundingRectWithSize(CGSizeMake(CGFloat.max, CGFloat.max), options: options, attributes: wordmarkAttributes, context: nil)
        
        //avoid infinite loops
        var repeatLimitHit = false
        var lastWidth   = 0.0 as CGFloat
        var lastHeight  = 0.0 as CGFloat
        var repeatCount = 0
        
        var currentHeight = wordmarkHidden ? imageSize.height : imageSize.height+wordmarkSize.height+padding
        //if image is too narrow, make it wider
        while imageSize.width < currentHeight*1.9 && repeatLimitHit == false {
            //if width is really small, set to minimum width and exit loop
            width += 10
            imageSize = text.boundingRectWithSize(CGSizeMake(width, CGFloat.max), options: options, context: nil)
            
            //if the dimensions haven't changed, make sure we haven't hit an infinite loop
            if imageSize.width == lastWidth || imageSize.height == lastHeight {
                repeatCount++
                if repeatCount >= 200 {
                    repeatLimitHit = true
                }
            } else { //reset counter once we've seen something new
                repeatCount = 0
            }
            
            lastWidth = imageSize.width
            lastHeight = imageSize.height
            currentHeight = wordmarkHidden ? imageSize.height : imageSize.height+wordmarkSize.height+padding
        }
        
        //avoid infinite loops
        repeatLimitHit = false
        lastWidth = 0.0 as CGFloat
        lastHeight = 0.0 as CGFloat
        repeatCount = 0
        
        //if image is too long, make it narrower
        while imageSize.width > currentHeight*2.1 && repeatLimitHit == false {
            width -= 10
            imageSize = text.boundingRectWithSize(CGSizeMake(width, CGFloat.max), options: options, context: nil)
            
            //if the dimensions haven't changed, make sure we haven't hit an infinite loop
            if imageSize.width == lastWidth || imageSize.height == lastHeight {
                repeatCount++
                if repeatCount >= 200 {
                    repeatLimitHit = true
                }
            } else { //reset counter once we've seen something new
                repeatCount = 0
            }
            
            lastWidth = imageSize.width
            lastHeight = imageSize.height
            currentHeight = wordmarkHidden ? imageSize.height : imageSize.height+wordmarkSize.height+padding
        }
        
        //round widths and add padding
        let adjustedWidth = wordmarkHidden ? imageSize.width : max(CGFloat(ceilf(Float(imageSize.width))), CGFloat(ceilf(Float(wordmarkSize.width))))
        let adjustedHeight = CGFloat(ceilf(Float(currentHeight)))
        let outerRectSize = CGSizeMake(adjustedWidth + 2*padding, adjustedHeight + 2*padding)
        
        //generate image
        UIGraphicsBeginImageContextWithOptions(outerRectSize, true, 0.0)
        var image = UIGraphicsGetImageFromCurrentImageContext()
        
        image.drawInRect(CGRectMake(0,0,outerRectSize.width,outerRectSize.height))
        
        background.set()
        let outerRect = CGRectMake(0, 0, image.size.width, image.size.height)
        CGContextFillRect(UIGraphicsGetCurrentContext(), outerRect)
        
        //draw text
        let innerRect = CGRectMake(padding, padding, adjustedWidth, adjustedHeight)
        text.drawInRect(CGRectIntegral(innerRect))
        
        //draw infinitweet wordmark if necessary
        if !wordmarkHidden {
            let wordmarkOrigin = CGPoint(x: adjustedWidth-(wordmarkSize.width-padding), y: adjustedHeight-(wordmarkSize.height-padding))
            let wordmarkRect = CGRectMake(wordmarkOrigin.x, wordmarkOrigin.y, wordmarkSize.width, wordmarkSize.height)
            self.wordmark.drawInRect(wordmarkRect, withAttributes: wordmarkAttributes)
        }
        
        //save new image
        self.image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
    }
    
    init(text : String, font : UIFont, color : UIColor, background : UIColor, wordmarkHidden : Bool) {
        //set text properties
        let textAttributes = [NSFontAttributeName: font, NSForegroundColorAttributeName: color]
        
        //set initial image attempt properties
        var width = 200
        var imageSize = (text as NSString).boundingRectWithSize(CGSizeMake(CGFloat(width), CGFloat.max), options: NSStringDrawingOptions.UsesLineFragmentOrigin, attributes: textAttributes, context: nil)
        
        //wordmark size
        let wordmarkSize = wordmark.boundingRectWithSize(CGSizeMake(CGFloat.max, CGFloat.max), options: NSStringDrawingOptions.UsesLineFragmentOrigin, attributes: wordmarkAttributes, context: nil)
        
        //avoid infinite loops
        var repeatLimitHit = false
        var lastWidth = 0.0 as CGFloat
        var lastHeight = 0.0 as CGFloat
        var repeatCount = 0
        
        var currentHeight = wordmarkHidden ? imageSize.height : imageSize.height+wordmarkSize.height+padding
        //if image is too narrow, make it wider
        while imageSize.width < currentHeight*1.9 && repeatLimitHit == false {
            //if width is really small, set to minimum width and exit loop
            width += 10
            imageSize = (text as NSString).boundingRectWithSize(CGSizeMake(CGFloat(width), CGFloat.max), options: NSStringDrawingOptions.UsesLineFragmentOrigin, attributes: textAttributes, context: nil)
            
            //if the dimensions haven't changed, make sure we haven't hit an infinite loop
            if imageSize.width == lastWidth && imageSize.height == lastHeight {
                repeatCount++
                if repeatCount >= 200 {
                    repeatLimitHit = true
                }
            } else { //reset counter once we've seen something new
                repeatCount = 0
            }
            
            lastWidth = imageSize.width
            lastHeight = imageSize.height
            currentHeight = wordmarkHidden ? imageSize.height : imageSize.height+wordmarkSize.height+padding
        }
        
        //avoid infinite loops
        repeatLimitHit = false
        lastWidth = 0.0 as CGFloat
        lastHeight = 0.0 as CGFloat
        repeatCount = 0
        
        //if image is too long, make it narrower
        while imageSize.width > currentHeight*2.1 && repeatLimitHit == false {
            width -= 10
            imageSize = (text as NSString).boundingRectWithSize(CGSizeMake(CGFloat(width), CGFloat.max), options: NSStringDrawingOptions.UsesLineFragmentOrigin, attributes: textAttributes, context: nil)
            
            //if the dimensions haven't changed, make sure we haven't hit an infinite loop
            if imageSize.width == lastWidth && imageSize.height == lastHeight {
                repeatCount++
                if repeatCount >= 200 {
                    repeatLimitHit = true
                }
            } else { //reset counter once we've seen something new
                repeatCount = 0
            }
            
            lastWidth = imageSize.width
            lastHeight = imageSize.height
            currentHeight = wordmarkHidden ? imageSize.height : imageSize.height+wordmarkSize.height+padding
        }
        
        //round widths and add padding
        let adjustedWidth = wordmarkHidden ? imageSize.width : max(CGFloat(ceilf(Float(imageSize.width))), CGFloat(ceilf(Float(wordmarkSize.width))))
        let adjustedHeight = CGFloat(ceilf(Float(currentHeight)))
        let outerRectSize = CGSizeMake(adjustedWidth + 2*padding, adjustedHeight + 2*padding)
        
        //generate image
        UIGraphicsBeginImageContextWithOptions(outerRectSize, true, 0.0)
        var image = UIGraphicsGetImageFromCurrentImageContext()
        
        image.drawInRect(CGRectMake(0,0,outerRectSize.width,outerRectSize.height))
        
        background.set()
        let outerRect = CGRectMake(0, 0, image.size.width, image.size.height)
        CGContextFillRect(UIGraphicsGetCurrentContext(), outerRect)
        
        //draw text
        let innerRect = CGRectMake(padding, padding, adjustedWidth, adjustedHeight)
        text.drawInRect(CGRectIntegral(innerRect), withAttributes: textAttributes)
        
        //draw infinitweet wordmark if necessary
        if !wordmarkHidden {
            let wordmarkOrigin = CGPoint(x: adjustedWidth-(wordmarkSize.width-padding), y: adjustedHeight-(wordmarkSize.height-padding))
            let wordmarkRect = CGRectMake(wordmarkOrigin.x, wordmarkOrigin.y, wordmarkSize.width, wordmarkSize.height)
            self.wordmark.drawInRect(wordmarkRect, withAttributes: wordmarkAttributes)
        }
        
        //save new image
        self.image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
    }
    
    class func setDefaults() {
        var defaults = NSUserDefaults(suiteName: "group.Codes.Ruben.InfinitweetPro")!
        defaults.setBool(true, forKey: self.currentDefaultKey())
        defaults.setObject("Left", forKey: "Alignment")
        defaults.setObject("Helvetica", forKey: "FontName")
        defaults.setInteger(14, forKey: "FontSize")
        
        let whiteColor = [CGFloat(0), CGFloat(0), CGFloat(0), CGFloat(1)]
        let blackColor = [CGFloat(1), CGFloat(1), CGFloat(1), CGFloat(1)]
        defaults.setObject(whiteColor, forKey: "TextColor")
        defaults.setObject(blackColor, forKey: "BackgroundColor")
        defaults.setInteger(20, forKey: "Padding")
        defaults.setBool(false, forKey: "WordmarkHidden")
        defaults.synchronize()
    }
    
    class func getDisplaySettings() -> (font : UIFont, color : UIColor, background : UIColor, alignment : NSTextAlignment, wordmark : Bool) {
        var defaults = NSUserDefaults(suiteName: "group.Codes.Ruben.InfinitweetPro")!
        let alignmentName = defaults.objectForKey("Alignment") as String
        let fontName = defaults.objectForKey("FontName") as String
        let fontSize = CGFloat(defaults.integerForKey("FontSize"))
        let font = UIFont(name: fontName, size: fontSize)
        
        var colorArray = defaults.objectForKey("TextColor") as [CGFloat]
        let color = colorArray.toUIColor()
        var backgroundColorArray = defaults.objectForKey("BackgroundColor") as [CGFloat]
        let backgroundColor = backgroundColorArray.toUIColor()
        
        let wordmark = defaults.boolForKey("WordmarkHidden")
        
        var alignment : NSTextAlignment
        switch alignmentName {
        case "Left":
            alignment = NSTextAlignment.Left
        case "Center":
            alignment = NSTextAlignment.Center
        case "Right":
            alignment = NSTextAlignment.Right
        case "Justified":
            alignment = NSTextAlignment.Justified
        default:
            alignment = NSTextAlignment.Left
        }
        
        return (font : font!, color : color, background : backgroundColor, alignment : alignment, wordmark : wordmark)
    }
    
    class func currentDefaultKey() -> String {
        return "Defaults2-5"
    }
}

extension Array {
    mutating func toUIColor() -> UIColor {
        var r = self[0] as CGFloat
        var g = self[1] as CGFloat
        var b = self[2] as CGFloat
        var a = self[3] as CGFloat
        return UIColor(red: r, green: g, blue: b, alpha: a)
    }
}

extension UIColor {
     func toCGFloatArray() -> [CGFloat] {
        var r = CGFloat()
        var g = CGFloat()
        var b = CGFloat()
        var a = CGFloat()
        self.getRed(&r, green: &g, blue: &b, alpha: &a)
        
        return [r, g, b, a]
    }
}

extension String {
    // This function converts from HTML colors (hex strings of the form '#ffffff') to UIColors
    mutating func hexStringToUIColor() -> UIColor {
        var cString:String = self.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet() as NSCharacterSet).uppercaseString
        
        if (cString.hasPrefix("#")) {
            cString = cString.substringFromIndex(advance(cString.startIndex, 1))
        }
        
        if (countElements(cString) != 6) {
            return UIColor.grayColor()
        }
        
        var rgbValue:UInt32 = 0
        NSScanner(string: cString).scanHexInt(&rgbValue)
        
        return UIColor(
            red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
            alpha: CGFloat(1.0)
        )
    }
}

func delay(delay:Double, closure:()->()) {
    dispatch_after(
        dispatch_time(
            DISPATCH_TIME_NOW,
            Int64(delay * Double(NSEC_PER_SEC))
        ),
        dispatch_get_main_queue(), closure)
}