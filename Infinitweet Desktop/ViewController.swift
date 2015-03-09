//
//  ViewController.swift
//  Infinitweet Desktop
//
//  Created by Ruben on 3/3/15.
//  Copyright (c) 2015 Ruben. All rights reserved.
//

import Cocoa
import AppKit

class ViewController: NSViewController, NSSharingServicePickerDelegate {
    @IBOutlet var tweetView: NSTextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tweetView.textContainerInset = NSSize(width: 20, height: 20)

        // Do any additional setup after loading the view.
    }

    override var representedObject: AnyObject? {
        didSet {
        // Update the view, if already loaded.
        }
    }

    @IBAction func shareButtonClicked(sender : NSButton) {
        var infinitweet = Infinitweet(text: tweetView.string!, font: NSFont.systemFontOfSize(14), color: NSColor.blackColor(), background: NSColor.whiteColor(), padding: 20)
        var sharingServicePicker = NSSharingServicePicker(items: [infinitweet.image])
        sharingServicePicker.delegate = self
        
        sharingServicePicker.showRelativeToRect(sender.bounds, ofView: sender, preferredEdge: NSMinYEdge)
    }
}

