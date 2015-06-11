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
        let ratio = 2 as CGFloat //Twitter images in stream appear in 2:1 aspect ratio
        let delta = 10 as CGFloat //Amount to change image by per cycle
        let maxCycles = 1000 //After this many cycles, give up
        
        //set text properties
        let options = unsafeBitCast(NSStringDrawingOptions.UsesLineFragmentOrigin.rawValue |
            NSStringDrawingOptions.UsesFontLeading.rawValue,
            NSStringDrawingOptions.self)
        
        //set initial image attempt properties
        var currentWidth = 200 as CGFloat
        var imageSize = text.boundingRectWithSize(CGSizeMake(currentWidth, CGFloat.max),
            options: options,
            context: nil)
        
        //wordmark size
        let wordmarkSize = wordmark.boundingRectWithSize(CGSizeMake(CGFloat.max, CGFloat.max), options: options, attributes: wordmarkAttributes, context: nil)
        
        var cycleCount = 0
        
        var currentHeight = wordmarkHidden ? imageSize.height : imageSize.height+wordmarkSize.height+padding
        var lastRatio = currentWidth/currentHeight //current ratio
        var lastDelta = InfinitweetDelta.Positive  //default value
        
        //start out exponential, move to linear when/if we get stuck
        var currentMode = InfinitweetMode.Exponential
        
        while cycleCount++ < maxCycles {
            if currentMode == InfinitweetMode.Exponential {
                currentWidth *= ratio/lastRatio
            } else {
                if lastRatio >= ratio {
                    currentWidth -= delta
                    lastDelta = InfinitweetDelta.Negative
                } else {
                    currentWidth += delta
                    lastDelta = InfinitweetDelta.Positive
                }
            }
            
            //get updated size based off new currentWidth
            imageSize = text.boundingRectWithSize(CGSizeMake(currentWidth, CGFloat.max), options: options, context: nil)
            
            //recalculate ratio
            currentHeight = wordmarkHidden ? imageSize.height : imageSize.height+wordmarkSize.height+padding
            let currentRatio = currentWidth/currentHeight
            
            //if we're exponential and not getting any better, go incremental
            if currentMode == InfinitweetMode.Exponential && (currentWidth / (ratio/lastRatio) == currentWidth * (ratio/currentRatio)) {
                currentMode = InfinitweetMode.Linear
                lastRatio = currentRatio
            } else {
                //if we're NOT exponential and not getting any better, give up
                if currentMode == InfinitweetMode.Linear && abs(ratio-lastRatio) < abs(ratio-currentRatio) {
                    currentWidth = (lastDelta == InfinitweetDelta.Positive) ? currentWidth - delta : currentWidth + delta
                    imageSize = text.boundingRectWithSize(CGSizeMake(currentWidth, CGFloat.max), options: options, context: nil)
                    currentHeight = wordmarkHidden ? imageSize.height : imageSize.height+wordmarkSize.height+padding
                    break
                }
                
                //if we're already near our target, give up
                if abs(ratio-currentRatio) < 0.05 {
                    break
                } else { //else keep going
                    lastRatio = currentRatio
                }
            }
        }
        
        //round sizes and add padding
        let minSize = (width : CGFloat(440), height : CGFloat(220))
        let adjustedWidth  = max(CGFloat(ceilf(Float(currentWidth))), minSize.width)
        let adjustedHeight = max(CGFloat(ceilf(Float(currentHeight))), minSize.height)
        let outerRectSize  = CGSizeMake(adjustedWidth + 2*padding, adjustedHeight + 2*padding)
        
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
        let ratio = 2 as CGFloat //Twitter images in stream appear in 2:1 aspect ratio
        let delta = 10 as CGFloat //Amount to change image by per cycle
        let maxCycles = 1000 //After this many cycles, give up
        
        //set text properties
        let options = unsafeBitCast(NSStringDrawingOptions.UsesLineFragmentOrigin.rawValue |
            NSStringDrawingOptions.UsesFontLeading.rawValue,
            NSStringDrawingOptions.self)
        let textAttributes = [NSFontAttributeName: font, NSForegroundColorAttributeName: color]
        
        //set initial image attempt properties
        var currentWidth = 200 as CGFloat
        var imageSize = (text as NSString).boundingRectWithSize(CGSizeMake(currentWidth, CGFloat.max), options: options, attributes: textAttributes, context: nil)
        
        //wordmark size
        let wordmarkSize = wordmark.boundingRectWithSize(CGSizeMake(CGFloat.max, CGFloat.max), options: NSStringDrawingOptions.UsesLineFragmentOrigin, attributes: wordmarkAttributes, context: nil)
        
        var cycleCount = 0
        
        var currentHeight = wordmarkHidden ? imageSize.height : imageSize.height+wordmarkSize.height+padding
        var lastRatio = currentWidth/currentHeight //current ratio
        var lastDelta = InfinitweetDelta.Positive //default value
        
        //start out exponential, move to linear when/if we get stuck
        var currentMode = InfinitweetMode.Exponential
        
        while cycleCount++ < maxCycles {
            if currentMode == InfinitweetMode.Exponential {
                currentWidth *= ratio/lastRatio
            } else {
                if lastRatio >= ratio {
                    currentWidth -= delta
                    lastDelta = InfinitweetDelta.Negative
                } else {
                    currentWidth += delta
                    lastDelta = InfinitweetDelta.Positive
                }
            }
            
            //get updated size based off new currentWidth
            imageSize = (text as NSString).boundingRectWithSize(CGSizeMake(currentWidth, CGFloat.max), options: options, attributes: textAttributes, context: nil)
            
            //recalculate ratio
            currentHeight = wordmarkHidden ? imageSize.height : imageSize.height+wordmarkSize.height+padding
            let currentRatio = currentWidth/currentHeight
            
            //if we're exponential and not getting any better, go incremental
            if currentMode == InfinitweetMode.Exponential && (currentWidth / (ratio/lastRatio) == currentWidth * (ratio/currentRatio)) {
                currentMode = InfinitweetMode.Linear
                lastRatio = currentRatio
            } else {
                //if we're NOT exponential and not getting any better, give up
                if currentMode == InfinitweetMode.Linear && abs(ratio-lastRatio) < abs(ratio-currentRatio) {
                    currentWidth = (lastDelta == InfinitweetDelta.Positive) ? currentWidth - delta : currentWidth + delta
                    imageSize = (text as NSString).boundingRectWithSize(CGSizeMake(currentWidth, CGFloat.max), options: options, attributes: textAttributes, context: nil)
                    currentHeight = wordmarkHidden ? imageSize.height : imageSize.height+wordmarkSize.height+padding
                    break
                }
                
                //if we're already near our target, give up
                if abs(ratio-currentRatio) < 0.05 {
                    break
                } else { //else keep going
                    lastRatio = currentRatio
                }
            }
        }
        
        //round sizes and add padding
        let minSize = (width : CGFloat(440), height : CGFloat(220))
        let adjustedWidth  = CGFloat(ceilf(Float(currentWidth)))
        let adjustedHeight = CGFloat(ceilf(Float(currentHeight)))
        let outerRectSize  = CGSizeMake(adjustedWidth + 2*padding, adjustedHeight + 2*padding)
        
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
    
    class func getDisplaySettings() -> (font : UIFont, color : UIColor, background : UIColor, alignment : NSTextAlignment, wordmarkHidden : Bool) {
        let font = UIFont(name: "Helvetica", size: 18.0)
        let color = UIColor.blackColor()
        let backgroundColor = UIColor.whiteColor()
        let alignment = NSTextAlignment.Left
        
        return (font : font!, color : color, background : backgroundColor, alignment : alignment, wordmarkHidden : false)
    }
    
    class func currentDefaultKey() -> String {
        return "Defaults2-5"
    }
}

enum InfinitweetDelta {
    case Positive, Negative
}

enum InfinitweetMode {
    case Exponential, Linear
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

func delay(delay:Double, closure:()->()) {
    dispatch_after(
        dispatch_time(
            DISPATCH_TIME_NOW,
            Int64(delay * Double(NSEC_PER_SEC))
        ),
        dispatch_get_main_queue(), closure)
}