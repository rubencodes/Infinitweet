//
//  ViewController.swift
//  InfiniTweet
//
//  Created by Ruben on 1/1/15.
//  Copyright (c) 2015 Ruben. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UITextViewDelegate {
    @IBOutlet weak var tweetView: UITextView!
    var text : String?
    var keyboardIsShown : Bool?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view, typically from a nib.
        if !NSUserDefaults.standardUserDefaults().boolForKey("HasLaunched") {
            beginTutorial()
        }
    }
    
    func beginTutorial() {
        var defaults = NSUserDefaults.standardUserDefaults()
        
        var title = "Welcome!"
        var message = "Welcome to Infinitweet! To start, enter text into the textfield. When you're ready, tap the Share icon on the upper right to share to Twitter (or elsewhere)."
        
        var tutorial = UIAlertController(title: title,
            message: message,
            preferredStyle: UIAlertControllerStyle.Alert)
        
        var OK = UIAlertAction(title: "OK",
            style: UIAlertActionStyle.Default,
            handler: {
                (action : UIAlertAction!) in
                defaults.setBool(true, forKey: "HasLaunched")
                defaults.synchronize()
        })
        
        tutorial.addAction(OK)
        
        self.presentViewController(tutorial, animated: true, completion: nil)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        self.automaticallyAdjustsScrollViewInsets = false
        self.tweetView.text = text
        self.tweetView.delegate = self
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillShow:", name: UIKeyboardWillShowNotification, object: self.view.window)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillHide:", name: UIKeyboardWillHideNotification, object: self.view.window)
        
        self.keyboardIsShown = false
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillShowNotification, object: self.view.window)
        
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillHideNotification, object: self.view.window)
    }
    
    func keyboardWillHide(notification : NSNotification) {
        var userInfo = notification.userInfo as [NSObject : AnyObject]!
        
        var keyboardSize = userInfo[UIKeyboardFrameBeginUserInfoKey]?.CGRectValue().size
        
        var contentInsets = UIEdgeInsetsZero
        self.tweetView.contentInset = contentInsets
        self.tweetView.scrollIndicatorInsets = contentInsets
        
        var viewFrame = self.tweetView.frame
        
        viewFrame.size.height += keyboardSize!.height
        
        UIView.beginAnimations(nil, context: nil)
        UIView.setAnimationBeginsFromCurrentState(true)
        self.tweetView.frame = viewFrame
        UIView.commitAnimations()
        
        self.keyboardIsShown = false
    }
    
    func keyboardWillShow(notification : NSNotification) {
        if self.keyboardIsShown! {
            return
        }
        
        var userInfo = notification.userInfo as [NSObject : AnyObject]!
        
        var keyboardSize = userInfo[UIKeyboardFrameBeginUserInfoKey]?.CGRectValue().size
        
        var contentInsets = UIEdgeInsetsMake(0.0, 0.0, keyboardSize!.height, 0.0)
        self.tweetView.contentInset = contentInsets
        self.tweetView.scrollIndicatorInsets = contentInsets
        
        var viewFrame = self.tweetView.frame
        viewFrame.size.height -= keyboardSize!.height
        
        UIView.beginAnimations(nil, context: nil)
        UIView.setAnimationBeginsFromCurrentState(true)
        self.tweetView.frame = viewFrame
        UIView.commitAnimations()
        
        self.keyboardIsShown = true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func textViewDidChange(textView: UITextView) {
        self.text = self.tweetView.text
    }

    
    @IBAction func generateAndShare(sender: AnyObject) {
        var defaults = NSUserDefaults.standardUserDefaults()
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
        
        var shareText : String?
        if !defaults.boolForKey("FirstShare") {
            shareText = "Sharing from @Infinitweet for the first time!"
            defaults.setBool(true, forKey: "FirstShare")
            defaults.synchronize()
        } else {
            shareText = "Tired of character limits? @Infinitytweet!"
        }
        
        //add objects to share
        var items = [AnyObject]()
        items.append(newImage)
        let activityViewController = UIActivityViewController(activityItems: items, applicationActivities: nil)
        self.presentViewController(activityViewController, animated: true, completion: nil)
    }
}

