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
    @IBOutlet weak var alertGroup: WKInterfaceGroup!
    @IBOutlet weak var alertLabel: WKInterfaceLabel!
    
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
    
    @IBAction func captureTweet() {
        self.presentTextInputControllerWithSuggestions(["Infinitweeting via Apple Watch! Good to go!"], allowedInputMode: WKTextInputMode.Plain) { (results) -> Void in
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
                
                //create infinitweet with properties
                var infinitweet = Infinitweet(text: text, font: font!, color: color, background: backgroundColor, padding: padding)
                self.imageToShare = infinitweet.image
                
                self.dismissTextInputController()
                self.pushControllerWithName("PresentationViewController", context: ["image": self.imageToShare!])
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

func delay(delay:Double, closure:()->()) {
    dispatch_after(
        dispatch_time(
            DISPATCH_TIME_NOW,
            Int64(delay * Double(NSEC_PER_SEC))
        ),
        dispatch_get_main_queue(), closure)
}
