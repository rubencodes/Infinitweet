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
                                if !defaults.boolForKey(Infinitweet.currentDefaultKey()) {
                                    Infinitweet.setDefaults()
                                } else {
                                    let settings = Infinitweet.getDisplaySettings() //get the current defaults
                                    
                                    self.tweetView.font = settings.font
                                    self.tweetView.textColor = settings.color
                                    self.tweetView.backgroundColor = settings.background
                                    self.view.backgroundColor = settings.background
                                }
                                
                            }
                        }
                    })
                    
                    textFound = true
                    break
                }
            }
            
            if textFound {
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
    
    @IBAction func shareInfinitweet() {
        if self.text != "" { //if text exists
            //get properties for new infinitweet
            let settings = Infinitweet.getDisplaySettings()

            //create infinitweet with properties
            var infinitweet = Infinitweet(text: self.tweetView.attributedText, background: settings.background, wordmarkHidden: true)
            
            //preload text on share
            var shareText : String?
            var defaults = NSUserDefaults(suiteName: "group.Codes.Ruben.InfinitweetPro")!
            if !defaults.boolForKey("FirstShare") {
                shareText = "Sharing from @InfinitweetApp for the first time!"
                defaults.setBool(true, forKey: "FirstShare")
                defaults.synchronize()
            } else {
                shareText = "via @InfinitweetApp"
            }
            
            //add objects to share
            var items = [AnyObject]()
            items.append(infinitweet.image)
            
            //create share menu, handle iPad case
            let activityViewController = UIActivityViewController(activityItems: items, applicationActivities: nil)
            if (UIDevice.currentDevice().model.hasPrefix("iPad")) {
                activityViewController.popoverPresentationController!.barButtonItem = self.shareButton!
            }
            
            //once finished sharing, display success message if completed
            activityViewController.completionHandler = {(activityType, completed:Bool) in
                if completed {
                    var alert = UIAlertController(title: "Success!", message: "", preferredStyle: UIAlertControllerStyle.Alert)
                    
                    self.presentViewController(alert, animated: true, completion: { () -> Void in
                        delay(0.75, { () -> () in
                            UIView.animateWithDuration(0.25, animations: { () -> Void in
                                alert.view.alpha = 0
                                }, completion: { (Bool) -> Void in
                                    alert.dismissViewControllerAnimated(false, completion: nil)
                            })
                        })
                    })
                }
            }
            
            //show the share menu
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