//
//  ViewController.swift
//  InfiniTweet
//
//  Created by Ruben on 1/1/15.
//  Copyright (c) 2015 Ruben. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UITextViewDelegate {
    @IBOutlet var navItem: UINavigationItem!
    @IBOutlet weak var tweetView: UITextView!
    var clearButton: UIBarButtonItem?
    var shareButton: UIBarButtonItem?
    var text = NSAttributedString(string: "")
    var keyboardIsShown : Bool?
    
    override func viewDidLoad() {
        self.clearButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Trash, target: self, action: "clearTextField")
        self.shareButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Action, target: self, action: "shareInfinitweet")
        self.navItem.setRightBarButtonItems([self.shareButton!, self.clearButton!], animated: false)
        
        super.viewDidLoad()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        self.automaticallyAdjustsScrollViewInsets = false
        self.tweetView.delegate = self
        self.tweetView.textContainer.lineFragmentPadding = 0
        self.tweetView.allowsEditingTextAttributes = true
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillShow:", name: UIKeyboardWillShowNotification, object: self.view.window)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillHide:", name: UIKeyboardWillHideNotification, object: self.view.window)
        
        self.keyboardIsShown = false
        
        var defaults = NSUserDefaults(suiteName: "group.Codes.Ruben.InfinitweetPro")!
        // Do any additional setup after loading the view, typically from a nib.
        if !defaults.boolForKey("Defaults2") {
            defaults.setBool(true, forKey: "Defaults2")
            defaults.setObject("Helvetica", forKey: "FontName")
            defaults.setInteger(14, forKey: "FontSize")
            
            var whiteColor = [CGFloat(0), CGFloat(0), CGFloat(0), CGFloat(1)]
            var blackColor = [CGFloat(1), CGFloat(1), CGFloat(1), CGFloat(1)]
            defaults.setObject(whiteColor, forKey: "TextColor")
            defaults.setObject(blackColor, forKey: "BackgroundColor")
            defaults.setInteger(20, forKey: "Padding")
            defaults.setBool(false, forKey: "WordmarkHidden")
            defaults.synchronize()
            
            if !defaults.boolForKey("TutorialShown") {
                self.beginTutorial()
            } else {
                self.tweetView.becomeFirstResponder()
            }
        } else {
            var fontName = defaults.objectForKey("FontName") as String
            var fontSize = CGFloat(defaults.integerForKey("FontSize"))
            var font = UIFont(name: fontName, size: fontSize)
            
            var colorArray = defaults.objectForKey("TextColor") as [CGFloat]
            var color = colorArray.toUIColor()
            var backgroundColorArray = defaults.objectForKey("BackgroundColor") as [CGFloat]
            var backgroundColor = backgroundColorArray.toUIColor()
            
            if self.tweetView.font.familyName != font!.familyName {
                self.tweetView.font = UIFont(name: font!.familyName, size: self.tweetView.font.pointSize)
            }
            
            if self.tweetView.font.pointSize != font!.pointSize {
                self.tweetView.font = UIFont(name: self.tweetView.font.familyName, size: font!.pointSize)
            }
            
            self.tweetView.textColor = color
            self.tweetView.backgroundColor = backgroundColor
            self.view.backgroundColor = backgroundColor
            self.tweetView.becomeFirstResponder()
            
        }
    }
    
    func beginTutorial() {
        var defaults = NSUserDefaults(suiteName: "group.Codes.Ruben.InfinitweetPro")!
        
        var title = "Welcome!"
        var message = "Welcome to Infinitweet! To start, enter text into the textfield. When you're ready, tap the Share icon on the upper right to share to Twitter (or elsewhere). Additionally, you can use our Action Extension to share text from within any app that supports it (e.g. Notes)."
        
        var tutorial = UIAlertController(title: title,
            message: message,
            preferredStyle: UIAlertControllerStyle.Alert)
        
        var OK = UIAlertAction(title: "OK",
            style: UIAlertActionStyle.Default,
            handler: {
                (action : UIAlertAction!) in
                defaults.setBool(true, forKey: "TutorialShown")
                defaults.synchronize()
                self.tweetView.becomeFirstResponder()
        })
        
        tutorial.addAction(OK)
        
        self.presentViewController(tutorial, animated: true, completion: nil)
    }
    
    override func viewWillDisappear(animated: Bool) {
        self.tweetView.resignFirstResponder()
        super.viewWillDisappear(animated)
        
        NSNotificationCenter.defaultCenter().removeObserver(self)
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
        
        //buggy - either uncomment, and text < 1 screen is lost, or comment and carriage returns screw it up
//        var viewFrame = self.tweetView.frame
//        viewFrame.size.height -= keyboardSize!.height
//        
//        UIView.beginAnimations(nil, context: nil)
//        UIView.setAnimationBeginsFromCurrentState(true)
//        self.tweetView.frame = viewFrame
//        UIView.commitAnimations()
        
        self.keyboardIsShown = true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func textViewDidChange(textView: UITextView) {
        self.text = self.tweetView.attributedText
    }
    
    func shareInfinitweet() {
        if self.tweetView.text != "" { //if text exists
            //get properties for new infinitweet
            var defaults = NSUserDefaults(suiteName: "group.Codes.Ruben.InfinitweetPro")!
            var fontName = defaults.objectForKey("FontName") as String
            var fontSize = CGFloat(defaults.integerForKey("FontSize"))
            var font = UIFont(name: fontName, size: fontSize)
            
            var colorArray = defaults.objectForKey("TextColor") as [CGFloat]
            var color = colorArray.toUIColor()
            var backgroundColorArray = defaults.objectForKey("BackgroundColor") as [CGFloat]
            var backgroundColor = backgroundColorArray.toUIColor()
            var padding = CGFloat(defaults.integerForKey("Padding"))
            var wordmark = defaults.boolForKey("WordmarkHidden")
            
            //create infinitweet with properties
            var infinitweet = Infinitweet(text: self.tweetView.attributedText, background: backgroundColor, padding: padding, wordmarkHidden: wordmark)
            
            //preload text on share
            var shareText : String?
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
    
    func clearTextField() {
        self.tweetView.text = ""
        self.text = NSAttributedString(string: "")
    }
}