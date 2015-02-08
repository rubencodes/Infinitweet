//
//  InterfaceController.swift
//  Infinitweet WatchKit Extension
//
//  Created by Ruben on 2/5/15.
//  Copyright (c) 2015 Ruben. All rights reserved.
//

import WatchKit
import Foundation

class InterfaceController: WKInterfaceController {
    var imageToShare : UIImage?
    var imageWidth = 500 as CGFloat
    @IBOutlet weak var tweetButton: WKInterfaceButton!
    override func awakeWithContext(context: AnyObject?) {
        super.awakeWithContext(context)
        
        // Configure interface objects here.
    }

    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
        var defaults = NSUserDefaults(suiteName: "group.Codes.Ruben.InfinitweetPro")!
        // Do any additional setup after loading the view, typically from a nib.
        if !defaults.boolForKey("TutorialShown") {
            defaults.setObject("Helvetica", forKey: "DefaultFont")
            defaults.setObject(CGFloat(14.0), forKey: "DefaultFontSize")
            defaults.setObject("000000", forKey: "DefaultColor")
            defaults.setObject("ffffff", forKey: "DefaultBackgroundColor")
            defaults.setFloat(20, forKey: "DefaultPadding")
            defaults.synchronize()
        }
    }
    
    func generateInfinitweetWithFont(font : UIFont, color : UIColor, background : UIColor, text : String, padding : CGFloat) -> UIImage {
        //set text properties
        var textAttributes = [NSFontAttributeName: font, NSForegroundColorAttributeName: color]
        
        //set image properties
        var imageSize = (text as NSString).boundingRectWithSize(CGSizeMake(imageWidth, CGFloat.max), options: NSStringDrawingOptions.UsesLineFragmentOrigin, attributes: textAttributes, context: nil)
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

    @IBAction func captureTweet() {
        self.presentTextInputControllerWithSuggestions(["Testing Infinitweet via Apple Watch! Good to go!"], allowedInputMode: WKTextInputMode.Plain) { (results) -> Void in
            if results != nil && results.count > 0 {
                var text = results.first as String
                var defaults = NSUserDefaults(suiteName: "group.Codes.Ruben.InfinitweetPro")!
                
                var fontName = defaults.objectForKey("DefaultFont") as String
                var fontSize = defaults.objectForKey("DefaultFontSize") as CGFloat
                var font = UIFont(name: fontName, size: fontSize)
                
                var colorString = defaults.objectForKey("DefaultColor") as String
                var color = colorString.hexStringToUIColor()
                var backgroundColorString = defaults.objectForKey("DefaultBackgroundColor") as String
                var backgroundColor = backgroundColorString.hexStringToUIColor()
                var padding = CGFloat(defaults.floatForKey("DefaultPadding"))
                
                self.imageToShare = self.generateInfinitweetWithFont(font!, color: color, background: backgroundColor, text: text, padding: padding)
                
                self.presentControllerWithName("PresentationViewController", context: ["image": self.imageToShare!])
            }
        }
    }
    
    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
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
