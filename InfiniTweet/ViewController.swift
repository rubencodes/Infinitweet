//
//  ViewController.swift
//  InfiniTweet
//
//  Created by Ruben on 1/1/15.
//  Copyright (c) 2015 Ruben. All rights reserved.
//

import UIKit
import iAd

class ViewController: UIViewController, UITextViewDelegate {
    @IBOutlet var navItem: UINavigationItem!
    @IBOutlet weak var tweetView: UITextView!
    var clearButton: UIBarButtonItem?
    var shareButton: UIBarButtonItem?
    var text = ""
    var keyboardIsShown : Bool?
    
    override func viewDidLoad() {
        self.clearButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Trash, target: self, action: "clearTextField")
        self.shareButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Action, target: self, action: "shareInfinitweet")
        navItem.setRightBarButtonItems([self.shareButton!, self.clearButton!], animated: false)
        
        super.viewDidLoad()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        self.automaticallyAdjustsScrollViewInsets = false
        self.tweetView.text = text
        self.tweetView.delegate = self
        self.tweetView.textContainer.lineFragmentPadding = 0
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillShow:", name: UIKeyboardWillShowNotification, object: self.view.window)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillHide:", name: UIKeyboardWillHideNotification, object: self.view.window)
        
        self.keyboardIsShown = false
        
        var defaults = NSUserDefaults(suiteName: "group.Codes.Ruben.InfinitweetPro")!
        // Do any additional setup after loading the view, typically from a nib.
        if !defaults.boolForKey("TutorialShown") {
            defaults.setObject("Helvetica", forKey: "DefaultFont")
            defaults.setObject(CGFloat(14.0), forKey: "DefaultFontSize")
            defaults.setObject("000000", forKey: "DefaultColor")
            defaults.setObject("ffffff", forKey: "DefaultBackgroundColor")
            defaults.setFloat(20, forKey: "DefaultPadding")
            defaults.synchronize()
            beginTutorial()
        } else {
            var fontName = defaults.objectForKey("DefaultFont") as String
            var fontSize = defaults.objectForKey("DefaultFontSize") as CGFloat
            var font = UIFont(name: fontName, size: fontSize)
            
            var colorString = defaults.objectForKey("DefaultColor") as String
            var color = colorString.hexStringToUIColor()
            var backgroundColorString = defaults.objectForKey("DefaultBackgroundColor") as String
            var backgroundColor = backgroundColorString.hexStringToUIColor()
            
            tweetView.font = font
            tweetView.textColor = color
            tweetView.backgroundColor = backgroundColor
            tweetView.becomeFirstResponder()
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
    
    func generateInfinitweetWithFont(font : UIFont, color : UIColor, background : UIColor, text : String, padding : CGFloat) -> UIImage {
        //set text properties
        var textAttributes = [NSFontAttributeName: font, NSForegroundColorAttributeName: color]
        
        //set image properties
        var imageSize = (text as NSString).boundingRectWithSize(CGSizeMake(self.view.frame.width, CGFloat.max), options: NSStringDrawingOptions.UsesLineFragmentOrigin, attributes: textAttributes, context: nil)
        var adjustedWidth = CGFloat(ceilf(Float(imageSize.width)))
        var adjustedHeight = CGFloat(ceilf(Float(imageSize.height)))
        var outerRectSize = CGSizeMake(adjustedWidth + 2*padding, adjustedHeight + 2*padding)
        
        //generate image
        UIGraphicsBeginImageContextWithOptions(outerRectSize, true, 0.0)
        var image = UIGraphicsGetImageFromCurrentImageContext()
        
        image.drawInRect(CGRectMake(0,0,outerRectSize.width,outerRectSize.height))
        
        background.set()
        var outerRect = CGRectMake(0, 0, image.size.width, image.size.height)
        CGContextFillRect(UIGraphicsGetCurrentContext(), outerRect)
        
        //draw text
        var innerRect = CGRectMake(padding, padding, adjustedWidth, adjustedHeight)
        text.drawInRect(CGRectIntegral(innerRect), withAttributes: textAttributes)
        //save new image
        var newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage
    }
    
    func shareInfinitweet() {
        if self.text != "" {
            var defaults = NSUserDefaults(suiteName: "group.Codes.Ruben.InfinitweetPro")!
            
            var fontName = defaults.objectForKey("DefaultFont") as String
            var fontSize = defaults.objectForKey("DefaultFontSize") as CGFloat
            var font = UIFont(name: fontName, size: fontSize)
            
            var colorString = defaults.objectForKey("DefaultColor") as String
            var color = colorString.hexStringToUIColor()
            var backgroundColorString = defaults.objectForKey("DefaultBackgroundColor") as String
            var backgroundColor = backgroundColorString.hexStringToUIColor()
            var padding = CGFloat(defaults.floatForKey("DefaultPadding"))
            
            var imageToShare = generateInfinitweetWithFont(font!, color: color, background: backgroundColor, text: self.text, padding: padding)
            
            var shareText : String?
            if !defaults.boolForKey("FirstShare") {
                shareText = "Sharing from @InfinitweetApp for the first time!"
                defaults.setBool(true, forKey: "FirstShare")
                defaults.synchronize()
            } else {
                shareText = "via @InfinitytweetApp"
            }
            
            //add objects to share
            var items = [AnyObject]()
            items.append(imageToShare)
            let activityViewController = UIActivityViewController(activityItems: items, applicationActivities: nil)
            activityViewController.popoverPresentationController!.barButtonItem = self.shareButton!
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
        self.text = ""
    }
}


extension String {
    // This function converts from HTML colors (hex strings of the form '#ffffff') to UIColors
    mutating func hexStringToUIColor() -> UIColor {
        var cString:String = self.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet() as NSCharacterSet).uppercaseString
        
        if (cString.hasPrefix("#")) {
            cString = cString.substringFromIndex(advance(cString.startIndex, 1))
        }
        
        if (countElements(cString) != 6) {
            return UIColor.grayColor()
        }
        
        var rgbValue:UInt32 = 0
        NSScanner(string: cString).scanHexInt(&rgbValue)
        
        return UIColor(
            red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
            alpha: CGFloat(1.0)
        )
    }
}