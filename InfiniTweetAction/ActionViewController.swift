//
//  ActionViewController.swift
//  InfiniTweetAction
//
//  Created by Ruben on 1/2/15.
//  Copyright (c) 2015 Ruben. All rights reserved.
//

import UIKit
import MobileCoreServices

class ActionViewController: UIViewController {
    @IBOutlet weak var tweetView: UITextView!
    @IBOutlet weak var shareButton: UIBarButtonItem!
    
    var text = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        // Get the item[s] we're handling from the extension context.
        
        // For example, look for an text and place it into a text view.
        var textFound = false
        for item: AnyObject in self.extensionContext!.inputItems {
            let inputItem = item as NSExtensionItem
            for provider: AnyObject in inputItem.attachments! {
                let itemProvider = provider as NSItemProvider
                if itemProvider.hasItemConformingToTypeIdentifier(kUTTypeText as NSString) {
                    // This is text. We'll load it, then place it in our text view.
                    itemProvider.loadItemForTypeIdentifier(kUTTypeText as NSString, options: nil, completionHandler: { (text, error) in
                        if text != nil {
                            NSOperationQueue.mainQueue().addOperationWithBlock {
                                self.text = text as String
                                self.tweetView.text = text as? String
                                
                                var defaults = NSUserDefaults(suiteName: "group.Codes.Ruben.InfinitweetPro")!
                                // Do any additional setup after loading the view, typically from a nib.
                                if !defaults.boolForKey("TutorialShown") {
                                    defaults.setObject("Helvetica", forKey: "DefaultFont")
                                    defaults.setObject(CGFloat(14.0), forKey: "DefaultFontSize")
                                    defaults.setObject("000000", forKey: "DefaultColor")
                                    defaults.setObject("ffffff", forKey: "DefaultBackgroundColor")
                                    defaults.setFloat(20, forKey: "DefaultPadding")
                                    defaults.synchronize()
                                } else {
                                    var fontName = defaults.objectForKey("DefaultFont") as String
                                    var fontSize = defaults.objectForKey("DefaultFontSize") as CGFloat
                                    var font = UIFont(name: fontName, size: fontSize)
                                    
                                    var colorString = defaults.objectForKey("DefaultColor") as String
                                    var color = colorString.hexStringToUIColor()
                                    var backgroundColorString = defaults.objectForKey("DefaultBackgroundColor") as String
                                    var backgroundColor = backgroundColorString.hexStringToUIColor()
                                    
                                    self.tweetView.font = font
                                    self.tweetView.textColor = color
                                    self.tweetView.backgroundColor = backgroundColor
                                }
                                
                            }
                        }
                    })
                    
                    textFound = true
                    break
                }
            }
            
            if (textFound) {
                // We only handle one text, so stop looking for more.
                break
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func done() {
        // Return any edited content to the host app.
        // This template doesn't do anything, so we just echo the passed in items.
        self.extensionContext!.completeRequestReturningItems(self.extensionContext!.inputItems, completionHandler: nil)
    }
    
    
    func generateInfinitweetWithFont(font : UIFont, color : UIColor, background : UIColor, text : String, padding : CGFloat) -> UIImage {
        //set text properties
        var textAttributes = [NSFontAttributeName: font, NSForegroundColorAttributeName: color]
        
        //set initial image attempt properties
        var width = 200
        var imageSize = (text as NSString).boundingRectWithSize(CGSizeMake(CGFloat(width), CGFloat.max), options: NSStringDrawingOptions.UsesLineFragmentOrigin, attributes: textAttributes, context: nil)
        
        //avoid infinite loops
        var repeatLimitHit = false
        var lastWidth = 0.0 as CGFloat
        var lastHeight = 0.0 as CGFloat
        var repeatCount = 0
        
        //if image is too narrow, make it wider
        while imageSize.width < imageSize.height*1.9 && repeatLimitHit == false {
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
        }
        
        //avoid infinite loops
        repeatLimitHit = false
        lastWidth = 0.0 as CGFloat
        lastHeight = 0.0 as CGFloat
        repeatCount = 0
        
        //if image is too long, make it narrower
        while imageSize.width > imageSize.height*2.1 && repeatLimitHit == false {
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
        }
        
        //round widths and add padding
        var adjustedWidth = CGFloat(ceilf(Float(imageSize.width)))
        var adjustedHeight = CGFloat(ceilf(Float(imageSize.height)))
        var outerRectSize = CGSizeMake(adjustedWidth + 2*padding, adjustedHeight + 2*padding)
        
        //generate image
        UIGraphicsBeginImageContextWithOptions(outerRectSize, true, 0.0)
        var image = UIGraphicsGetImageFromCurrentImageContext()
        
        image.drawInRect(CGRectMake(0,0,outerRectSize.width,outerRectSize.height))
        
        background.set()
        var outerRect = CGRectMake(0, 0, image.size.width, image.size.height)
        CGContextFillRect(UIGraphicsGetCurrentContext(), outerRect)
        
        //draw text
        var innerRect = CGRectMake(padding, padding, adjustedWidth, adjustedHeight)
        text.drawInRect(CGRectIntegral(innerRect), withAttributes: textAttributes)
        //save new image
        var newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage
    }
    
    @IBAction func shareInfinitweet() {
        if self.text != "" {
            var defaults = NSUserDefaults(suiteName: "group.Codes.Ruben.InfinitweetPro")!
            
            var fontName = defaults.objectForKey("DefaultFont") as String
            var fontSize = defaults.objectForKey("DefaultFontSize") as CGFloat
            var font = UIFont(name: fontName, size: fontSize)
            
            var colorString = defaults.objectForKey("DefaultColor") as String
            var color = colorString.hexStringToUIColor()
            var backgroundColorString = defaults.objectForKey("DefaultBackgroundColor") as String
            var backgroundColor = backgroundColorString.hexStringToUIColor()
            var padding = CGFloat(defaults.floatForKey("DefaultPadding"))
            
            var imageToShare = generateInfinitweetWithFont(font!, color: color, background: backgroundColor, text: self.text, padding: padding)
            
            var shareText : String?
            if !defaults.boolForKey("FirstShare") {
                shareText = "Sharing from @InfinitweetApp for the first time!"
                defaults.setBool(true, forKey: "FirstShare")
                defaults.synchronize()
            } else {
                shareText = "via @InfinitweetApp"
            }
            
            //add objects to share
            var items = [AnyObject]()
            items.append(imageToShare)
            let activityViewController = UIActivityViewController(activityItems: items, applicationActivities: nil)
            if (UIDevice.currentDevice().model.hasPrefix("iPad")) {
                activityViewController.popoverPresentationController!.barButtonItem = self.shareButton!
            }
            self.presentViewController(activityViewController, animated: true, completion: nil)
        } else {
            var title = "Oops!"
            var message = "Please enter some text first, then we'll turn it into a shareable image."
            
            var error = UIAlertController(title: title,
                message: message,
                preferredStyle: UIAlertControllerStyle.Alert)
            
            var OK = UIAlertAction(title: "OK",
                style: UIAlertActionStyle.Default,
                handler: {
                    (action : UIAlertAction!) in
                    self.tweetView.becomeFirstResponder()
                    return
            })
            
            error.addAction(OK)
            
            self.presentViewController(error, animated: true, completion: nil)
        }
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