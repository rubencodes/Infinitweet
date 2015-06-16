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
    @IBOutlet weak var tweetButton: WKInterfaceButton!
    
    override func awakeWithContext(context: AnyObject?) {
        super.awakeWithContext(context)
        // Configure interface objects here.
    }

    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
    }
    
    @IBAction func captureTweet() {
        self.presentTextInputControllerWithSuggestions(["Infinitweeting via Apple Watch! Good to go!"], allowedInputMode: WKTextInputMode.Plain) { (results) -> Void in
            if results.count > 0 {
                let text = results.first as! String
                
                let settings = Infinitweet.getDisplaySettings()
                
                //create infinitweet with properties
                let infinitweet = Infinitweet(text: text, font: settings.font, color: settings.color, background: settings.background, wordmarkHidden : settings.wordmarkHidden)
                
                self.dismissTextInputController()
                self.pushControllerWithName("PreviewController", context: ["image": infinitweet.image])
            }
        }
    }
    
    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }
}