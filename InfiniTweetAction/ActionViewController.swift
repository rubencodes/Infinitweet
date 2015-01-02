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
    var text : String?

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
                                self.text = text as? String
                                self.tweetView.text = text as? String
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
    
    @IBAction func generateAndShare(sender: AnyObject) {
        //size of text
        var textAttributes = [NSFontAttributeName: UIFont.systemFontOfSize(14.0)]
        var size = (self.text! as NSString).boundingRectWithSize(CGSizeMake(400, CGFloat.max), options: NSStringDrawingOptions.UsesLineFragmentOrigin, attributes: textAttributes, context: nil)
        var adjustedSize = CGSizeMake(CGFloat(ceilf(Float(size.width))), CGFloat(ceilf(Float(size.height))))
        
        //generate image
        UIGraphicsBeginImageContextWithOptions(adjustedSize, true, 0.0)
        var image = UIGraphicsGetImageFromCurrentImageContext()
        image.drawInRect(CGRectMake(0,0,image.size.width,image.size.height))
        var rect = CGRectMake(0, 0, image.size.width, image.size.height)
        
        UIColor.whiteColor().set()
        CGContextFillRect(UIGraphicsGetCurrentContext(), rect)
        
        UIColor.blackColor().set()
        self.text!.drawInRect(CGRectIntegral(rect), withAttributes: textAttributes)
        var newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        //add objects to share
        var items = [AnyObject]()
        items.append(newImage)
        let activityViewController = UIActivityViewController(activityItems: items, applicationActivities: nil)
        self.presentViewController(activityViewController, animated: true, completion: nil)
    }

}
