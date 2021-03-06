//
//  InfiniTweetDesktop.swift
//  InfiniTweet
//
//  Created by Ruben on 3/4/15.
//  Copyright (c) 2015 Ruben. All rights reserved.
//

import Foundation
import AppKit

class Infinitweet {
    var image : NSImage
    
    init(text : String, font : NSFont, color : NSColor, background : NSColor, padding : CGFloat) {
        //set text properties
        let textAttributes = [NSFontAttributeName: font, NSForegroundColorAttributeName: color]
        
        //set initial image attempt properties
        var width = 200
        var imageSize = (text as NSString).boundingRectWithSize(CGSizeMake(CGFloat(width), CGFloat.max), options: NSStringDrawingOptions.UsesLineFragmentOrigin, attributes: textAttributes)
        
        //avoid infinite loops
        var repeatLimitHit = false
        var lastWidth = 0.0 as CGFloat
        var lastHeight = 0.0 as CGFloat
        var repeatCount = 0
        
        //if image is too narrow, make it wider
        while imageSize.width < imageSize.height*1.9 && repeatLimitHit == false {
            //if width is really small, set to minimum width and exit loop
            if imageSize.width < CGFloat(width) {
                imageSize = CGRectMake(0, 0, (imageSize.height)*2, imageSize.height)
                break
            }
            
            width += 10
            imageSize = (text as NSString).boundingRectWithSize(CGSizeMake(CGFloat(width), CGFloat.max), options: NSStringDrawingOptions.UsesLineFragmentOrigin, attributes: textAttributes)
            
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
        }
        
        //avoid infinite loops
        repeatLimitHit = false
        lastWidth = 0.0 as CGFloat
        lastHeight = 0.0 as CGFloat
        repeatCount = 0
        
        //if image is too long, make it narrower
        while imageSize.width > imageSize.height*2.1 && repeatLimitHit == false {
            width -= 10
            imageSize = (text as NSString).boundingRectWithSize(CGSizeMake(CGFloat(width), CGFloat.max), options: NSStringDrawingOptions.UsesLineFragmentOrigin, attributes: textAttributes)
            
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
        }
        
        //round widths and add padding
        let adjustedWidth = CGFloat(ceilf(Float(imageSize.width)))
        let adjustedHeight = CGFloat(ceilf(Float(imageSize.height)))
        let outerRectSize = CGSizeMake(adjustedWidth + 2*padding, adjustedHeight + 2*padding)
        
        //generate image
        image = NSImage(size: outerRectSize)
        image.drawInRect(CGRectMake(0,0,outerRectSize.width,outerRectSize.height))
        
        background.set()
        
//        let outerRect = CGRectMake(0, 0, image.size.width, image.size.height)
//        var contextPointer = NSGraphicsContext.currentContext()!.graphicsPort
//        let context = UnsafePointer<CGContext>(contextPointer).memory
//        CGContextFillRect(context, outerRect)
        
        //draw text
        let innerRect = CGRectMake(padding, padding, adjustedWidth, adjustedHeight)
        text.drawInRect(CGRectIntegral(innerRect), withAttributes: textAttributes)
        
        //save new image
        var imageRep = image.representations.first as NSBitmapImageRep
//        var imageRep = NSBitmapImageRep(data: imageData)
        var imageProps = NSDictionary(object: 1.0 as NSNumber, forKey: NSImageCompressionFactor)
        var imageData = imageRep.representationUsingType(NSBitmapImageFileType.NSJPEGFileType, properties: imageProps)
        imageData!.writeToFile("~/Desktop/me.jpeg", atomically: true)
        
        println("Image was created")
        println(self.image.size.width)
        println(self.image.size.height)
    }
    
}