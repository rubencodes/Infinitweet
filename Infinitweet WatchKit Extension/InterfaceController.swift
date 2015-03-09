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
                var fontName = defaults.objectForKey("FontName") as String
                var fontSize = CGFloat(defaults.integerForKey("FontSize"))
                var font = UIFont(name: fontName, size: fontSize)
                
                var colorArray = defaults.objectForKey("TextColor") as [CGFloat]
                var color = colorArray.toUIColor()
                var backgroundColorArray = defaults.objectForKey("BackgroundColor") as [CGFloat]
                var backgroundColor = backgroundColorArray.toUIColor()
                var padding = CGFloat(defaults.integerForKey("Padding"))
                
                //create infinitweet with properties
                var infinitweet = Infinitweet(text: text, font: font!, color: color, background: backgroundColor, padding: padding, wordmarkHidden : true)
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