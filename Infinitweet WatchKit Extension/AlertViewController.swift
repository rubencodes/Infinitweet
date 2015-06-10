//
//  AlertViewController.swift
//  InfiniTweet
//
//  Created by Ruben on 2/27/15.
//  Copyright (c) 2015 Ruben. All rights reserved.
//

import Foundation
import WatchKit

class AlertViewController: WKInterfaceController {
    @IBOutlet var textLabel : WKInterfaceLabel!
    @IBOutlet var group : WKInterfaceGroup!
    
    override func awakeWithContext(context: AnyObject?) {
        super.awakeWithContext(context)
        
        if context != nil {
            if let text = context!.stringForKey("alert") {
                textLabel.setText(text)
                let positive = context!.boolForKey("positive")
                
                if positive {
                    group.setBackgroundColor(UIColor.greenColor())
                } else {
                    group.setBackgroundColor(UIColor.redColor())
                }
            }
        }
    }
    
    override func willActivate() {
        delay(1, { () -> () in
            self.dismissController()
            self.popToRootController()
        })
    }
}