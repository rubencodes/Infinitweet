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
    override func awakeWithContext(context: AnyObject?) {
        super.awakeWithContext(context)
    }
    
    override func willActivate() {
        delay(1, { () -> () in
            self.popToRootController()
        })
    }
}