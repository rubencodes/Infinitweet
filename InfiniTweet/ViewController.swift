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

        //have we set the latest defaults?
        if !defaults.boolForKey(Infinitweet.currentDefaultKey()) {
            Infinitweet.setDefaults() //set the default text attributes in memory
            
            //have we shown the tutorial?
            if !defaults.boolForKey("TutorialShown") {
                self.beginTutorial() //if not, show it
            } else {
                self.tweetView.becomeFirstResponder() //else just focus on the textview
            }
        } else { //if so, make the tweetView reflect the defaults
            self.setTweetViewDefaults()
        }
    }
    
    //sets the default attributes within the tweetView
    func setTweetViewDefaults() {
        let settings = Infinitweet.getDisplaySettings() //get the current defaults
        
        self.tweetView.textAlignment = settings.alignment //set the alignment
        
        //if there was a font change
        if self.tweetView.font != settings.font {
            //if there is a font set,
            if self.tweetView.font != nil {
                //if the font family is different, we must update the entire font
                if self.tweetView.font.familyName != settings.font.familyName {
                    self.tweetView.font = settings.font
                }
                    //if just the point size is different, change ONLT the point size, not the font
                else if self.tweetView.font.pointSize != settings.font.pointSize {
                    //make a mutable copy of the attributed text
                    var mutableCopy = NSMutableAttributedString(attributedString: self.tweetView.attributedText)
                    var textRange = NSMakeRange(0, self.tweetView.attributedText.length) //get the range of the text
                    
                    //iterate over the various text attributes
                    self.tweetView.attributedText.enumerateAttributesInRange(textRange, options: NSAttributedStringEnumerationOptions.LongestEffectiveRangeNotRequired, usingBlock: { (attributes, range, stop) -> Void in
                        var newAttributes = attributes as [NSObject : AnyObject] //make a copy of the attributes
                        
                        //if we have a font set, change the size of the font ONLY
                        if newAttributes[NSFontAttributeName] != nil {
                            let currentFont = newAttributes[NSFontAttributeName] as UIFont
                            let newFont = UIFont(name: currentFont.fontName, size: settings.font.pointSize)
                            newAttributes[NSFontAttributeName] = newFont
                        }
                        
                        //update the attributes to new standard
                        mutableCopy.addAttributes(newAttributes, range: range)
                    })
                    
                    //set the attributes of our attributed text to the updated copy
                    self.tweetView.attributedText = mutableCopy
                }
            } else {
                self.tweetView.font = settings.font
            }
        }
        
        self.tweetView.textColor = settings.color //set the text color
        self.tweetView.backgroundColor = settings.background //set the background color
        self.view.backgroundColor = settings.background //set the background color (of view)
        self.tweetView.becomeFirstResponder()
    }
    
    func beginTutorial() {
        var defaults = NSUserDefaults(suiteName: "group.Codes.Ruben.InfinitweetPro")!
        
        let title = "Welcome!"
        let message = "Welcome to Infinitweet! To start, enter text into the textfield. When you're ready, tap the Share icon on the upper right to share to Twitter (or elsewhere). Additionally, you can use our Action Extension to share text from within any app that supports it (e.g. Notes)."
        
        let tutorial = UIAlertController(title: title,
            message: message,
            preferredStyle: UIAlertControllerStyle.Alert)
        
        let OK = UIAlertAction(title: "OK",
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
        let userInfo = notification.userInfo as [NSObject : AnyObject]!
        
        let keyboardSize = userInfo[UIKeyboardFrameBeginUserInfoKey]?.CGRectValue().size
        
        let contentInsets = UIEdgeInsetsZero
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
        
        let userInfo = notification.userInfo as [NSObject : AnyObject]!
        
        let keyboardSize = userInfo[UIKeyboardFrameBeginUserInfoKey]?.CGRectValue().size
        
        let contentInsets = UIEdgeInsetsMake(0.0, 0.0, keyboardSize!.height, 0.0)
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
            var backgroundColorArray = defaults.objectForKey("BackgroundColor") as [CGFloat]
            let backgroundColor = backgroundColorArray.toUIColor()
            let wordmark = defaults.boolForKey("WordmarkHidden")
            
            //create infinitweet with properties
            let infinitweet = Infinitweet(text: self.tweetView.attributedText, background: backgroundColor, wordmarkHidden: wordmark)
            
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
                    let alert = UIAlertController(title: "Success!", message: "", preferredStyle: UIAlertControllerStyle.Alert)
                    
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
            let title = "Oops!"
            let message = "Please enter some text first, then we'll turn it into a shareable image."
            
            let error = UIAlertController(title: title,
                message: message,
                preferredStyle: UIAlertControllerStyle.Alert)
            
            let OK = UIAlertAction(title: "OK",
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