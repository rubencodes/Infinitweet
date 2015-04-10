//
//  ActionViewController.swift
//  InfiniTweetAction
//
//  Created by Ruben on 1/2/15.
//  Copyright (c) 2015 Ruben. All rights reserved.
//

import UIKit
import MobileCoreServices

class ActionViewController: UIViewController, UINavigationBarDelegate, UITextViewDelegate, UIPopoverPresentationControllerDelegate, ColorPickerDelegate {
    @IBOutlet weak var tweetView: UITextView!
    @IBOutlet weak var shareButton: UIBarButtonItem!
    @IBOutlet var toolbar : UIToolbar?
    @IBOutlet var alignmentButton: UIBarButtonItem?
    @IBOutlet var fontButton: UIBarButtonItem?
    @IBOutlet var colorButton: UIBarButtonItem!
    @IBOutlet var backgroundButton: UIBarButtonItem!
    @IBOutlet var formatButton: UIBarButtonItem!
    @IBOutlet var highlightButton: UIBarButtonItem!
    var keyboardIsShown : Bool?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //prepare for keyboard, etc
        self.automaticallyAdjustsScrollViewInsets = false
        self.tweetView.delegate = self
        self.tweetView.textContainer.lineFragmentPadding = 0
        self.tweetView.allowsEditingTextAttributes = true
        
        //handle select menu
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "menuControllerWillShow", name: UIMenuControllerWillShowMenuNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "menuControllerWillHide", name: UIMenuControllerWillHideMenuNotification, object: nil)
        
//        //watch for orientation
//        UIDevice.currentDevice().beginGeneratingDeviceOrientationNotifications()
//        NSNotificationCenter.defaultCenter().addObserver(self, selector: "orientationChanged:", name: UIApplicationDidChangeStatusBarOrientationNotification, object: nil)
        
        self.keyboardIsShown = false
        
        //handle keyboard hiding/showing
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillShow:", name: UIKeyboardWillShowNotification, object: self.view.window)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillHide:", name: UIKeyboardWillHideNotification, object: self.view.window)
    
        // Get the item[s] we're handling from the extension context.
        // For example, look for an text and place it into a text view.
        var textFound = false
        for item: AnyObject in self.extensionContext!.inputItems {
            let inputItem = item as! NSExtensionItem
            for provider: AnyObject in inputItem.attachments! {
                let itemProvider = provider as! NSItemProvider
                
                //watch for text
                if itemProvider.hasItemConformingToTypeIdentifier(kUTTypeText as String) {
                    // This is text. We'll load it, then place it in our text view.
                    itemProvider.loadItemForTypeIdentifier(kUTTypeText as String, options: nil) { (text, error) in
                        if text != nil {
                            dispatch_async(dispatch_get_main_queue()) {
                                let textData = (text as! NSString).dataUsingEncoding(NSUnicodeStringEncoding, allowLossyConversion: true)!
                                self.tweetView.attributedText = NSAttributedString(data: textData, options: [ NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType], documentAttributes: nil, error: nil)
                                
                                var defaults = NSUserDefaults(suiteName: "group.Codes.Ruben.InfinitweetPro")!
                                // Do any additional setup after loading the view, typically from a nib.
                                if !defaults.boolForKey(Infinitweet.currentDefaultKey()) {
                                    Infinitweet.setDefaults()
                                }
                                
                                self.setTweetViewDefaults()
                                
                                self.tweetView.becomeFirstResponder()
                            }
                        }
                    }
                    
                    textFound = true
                    break
                }
                //watch for webpage
                if itemProvider.hasItemConformingToTypeIdentifier(kUTTypePropertyList as String) {
                    // This is webpage data. We'll parse it, then place it in our text view.
                    itemProvider.loadItemForTypeIdentifier(kUTTypePropertyList as String, options: nil) { (item, error) in
                        dispatch_async(dispatch_get_main_queue()) {
                            let results = (item as! NSDictionary)[NSExtensionJavaScriptPreprocessingResultsKey] as! NSDictionary
                            let text = results["selection"] as! String
                            let title = results["title"] as! String
                            let url = results["URL"] as! String
                            self.tweetView.text = title+"\n\n"+text+"\n\nSource: "+url
                            
                            var defaults = NSUserDefaults(suiteName: "group.Codes.Ruben.InfinitweetPro")!
                            // Do any additional setup after loading the view, typically from a nib.
                            if !defaults.boolForKey(Infinitweet.currentDefaultKey()) {
                                Infinitweet.setDefaults()
                            }
                            
                            self.setTweetViewDefaults()
                            
                            self.tweetView.becomeFirstResponder()
                        }
                    }
                    
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
    
    func positionForBar(bar: UIBarPositioning) -> UIBarPosition  {
        return UIBarPosition.TopAttached
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
        dispatch_async(dispatch_get_main_queue()) {
            if self.tweetView.text != "" { //if text exists
                //get properties for new infinitweet
                let settings = Infinitweet.getDisplaySettings()
                
                //create infinitweet with properties
                let infinitweet = Infinitweet(text: self.tweetView.attributedText ?? NSAttributedString(string: self.tweetView.text), background: self.tweetView.backgroundColor ?? settings.background, wordmarkHidden: settings.wordmark)
                
                //preload text on share
                var shareText : String?
                var defaults = NSUserDefaults(suiteName: "group.Codes.Ruben.InfinitweetPro")!
                let firstShare = !defaults.boolForKey("FirstShare")
                if firstShare {
                    shareText = "Sharing from @InfinitweetApp for the first time!"
                } else {
                    shareText = "via @InfinitweetApp"
                }
                
                //add objects to share
                var items = [AnyObject]()
                items.append(infinitweet.image)
                items.append(shareText!)
                
                //create share menu, handle iPad case
                let activityViewController = UIActivityViewController(activityItems: items, applicationActivities: nil)
                if (UIDevice.currentDevice().model.hasPrefix("iPad")) {
                    activityViewController.popoverPresentationController!.barButtonItem = self.shareButton!
                }
                
                //once finished sharing, display success message if completed
                activityViewController.completionWithItemsHandler = {(activityType, completed, returnedItems, activityError) in
                    if completed {
                        let alert = UIAlertController(title: "Success!", message: "", preferredStyle: UIAlertControllerStyle.Alert)
                        defaults.setBool(true, forKey: "FirstShare")
                        
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
                        self.extensionContext!.completeRequestReturningItems(self.extensionContext!.inputItems, completionHandler: nil)
                        return
                })
                
                error.addAction(OK)
                
                self.presentViewController(error, animated: true, completion: nil)
            }
        }
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
    
    //Edit menu is about to show, make sure it doesn't cover the toolbar
    func menuControllerWillShow() {
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIMenuControllerWillShowMenuNotification, object: nil)
        
        var menuController = UIMenuController.sharedMenuController()
        if menuController.menuFrame.origin.y < self.toolbar!.frame.origin.y+self.toolbar!.frame.height {
            var size = menuController.menuFrame.size
            var origin = CGPoint(x: menuController.menuFrame.origin.x, y: menuController.menuFrame.origin.y+size.height)
            var menuFrame = CGRect(origin: origin, size: size)
            menuController.setMenuVisible(false, animated: false)
            
            menuController.arrowDirection = UIMenuControllerArrowDirection.Up
            menuController.setTargetRect(menuFrame, inView: self.view)
            menuController.setMenuVisible(true, animated: true)
        }
    }
    
    //Edit menu is about to hide, wait for it to show again
    func menuControllerWillHide() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "menuControllerWillShow", name: UIMenuControllerWillShowMenuNotification, object: nil)
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    //user moved the cursor; update toolbar buttons to match current formatting
    func textViewDidChangeSelection(textView: UITextView) {
        //gets range with most applicable attributes
        var textRange : NSRange?
        if self.tweetView.attributedText.length > 0 {
            textRange = self.tweetView.selectedRange.location > 0 && self.tweetView.selectedRange.length == 0
                ? NSMakeRange(self.tweetView.selectedRange.location-1, 1)
                : NSMakeRange(self.tweetView.selectedRange.location, 1)
        } else {
            textRange = NSMakeRange(self.tweetView.selectedRange.location, 0)
        }
        
        //for attributes in this range, change toolbar buttons to match,
        self.tweetView.attributedText.enumerateAttributesInRange(textRange!, options: NSAttributedStringEnumerationOptions.LongestEffectiveRangeNotRequired, usingBlock: { (attributes, range, stop) -> Void in
            //if we have an attribute set, use it; else go for the default
            if let color = attributes[NSForegroundColorAttributeName] as? UIColor {
                self.colorButton.tintColor = color
            } else {
                self.colorButton.tintColor = self.tweetView.textColor ?? UIColor.blackColor()
            }
            
            if let highlight = attributes[NSBackgroundColorAttributeName] as? UIColor {
                self.highlightButton.tintColor = highlight
            } else {
                self.highlightButton.tintColor = self.tweetView.backgroundColor ?? UIColor.whiteColor()
            }
            
            if let paragraph = attributes[NSParagraphStyleAttributeName] as? NSParagraphStyle {
                self.alignmentButton!.image = paragraph.alignment.image()
            } else {
                self.alignmentButton!.image = self.tweetView.textAlignment.image()
            }
        })
    }
    
    @IBAction func changeTextSize(sender : UIBarButtonItem) {
        //get the selected text, if available
        var selectedRange = self.tweetView.selectedRange
        
        //if there is no text, make changes globally
        if self.tweetView.text.isEmpty {
            var newFontSize = self.tweetView.font.pointSize + CGFloat(sender.tag) //tag is negative for decrease, positive otherwise
            self.tweetView.font = self.tweetView.font.fontWithSize(newFontSize)
            
            return //return early
        }
            //if nothing selected, select nearest word
        else if selectedRange.length == 0 {
            let position = self.tweetView.positionFromPosition(self.tweetView.beginningOfDocument, offset: selectedRange.location)
            let range = self.tweetView.tokenizer.rangeEnclosingPosition(position!, withGranularity: UITextGranularity.Word, inDirection: (UITextLayoutDirection.Right.rawValue as UITextDirection))
                ?? self.tweetView.tokenizer.rangeEnclosingPosition(position!, withGranularity: UITextGranularity.Word, inDirection: (UITextLayoutDirection.Left.rawValue as UITextDirection))
            
            //if there is a nearest word (range exists), select the nearest word
            if range != nil {
                let start = self.tweetView.offsetFromPosition(self.tweetView.beginningOfDocument, toPosition: range!.start)
                let end = self.tweetView.offsetFromPosition(self.tweetView.beginningOfDocument, toPosition: range!.end)
                self.tweetView.selectedRange = NSMakeRange(start, end-start)
                selectedRange = self.tweetView.selectedRange
            } else { //if we can't get the nearest word, just select everything
                self.tweetView.selectedRange = NSMakeRange(0, self.tweetView.attributedText.length)
                selectedRange = self.tweetView.selectedRange
            }
        }
        
        //decrease if negative, else increase
        if sender.tag < 0 {
            self.tweetView.decreaseSize(self)
        } else if sender.tag > 0 {
            self.tweetView.increaseSize(self)
        }
    }
    
    @IBAction func changeColor(sender : UIBarButtonItem) {
        self.tweetView.resignFirstResponder()
        let popoverVC = storyboard?.instantiateViewControllerWithIdentifier("colorPickerPopover") as! ColorPickerViewController
        popoverVC.modalPresentationStyle = .Popover
        popoverVC.preferredContentSize = CGSizeMake(284, 446)
        if let popoverController = popoverVC.popoverPresentationController {
            popoverController.barButtonItem = sender
            popoverController.sourceRect = CGRect(x: 0, y: 0, width: 85, height: 30)
            popoverController.permittedArrowDirections = .Any
            popoverController.delegate = self
            popoverVC.callerTag = sender.tag
            popoverVC.delegate = self
        }
        self.presentViewController(popoverVC, animated: true, completion: nil)
    }
    
    func colorPicked(sender : ColorPickerViewController, color : UIColor) {
        if sender.callerTag! == 0 { //background color
            self.backgroundButton.tintColor = color
            self.tweetView.backgroundColor = color //set the background color
            self.view.backgroundColor = color //set the background color (of view)
            
        } else if sender.callerTag! == 1 || sender.callerTag! == 2 { //text color
            var selectedRange = self.tweetView.selectedRange
            
            //if nothing selected, select nearest word
            if selectedRange.length == 0 {
                let position = self.tweetView.positionFromPosition(self.tweetView.beginningOfDocument, offset: selectedRange.location)
                let range = self.tweetView.tokenizer.rangeEnclosingPosition(position!, withGranularity: UITextGranularity.Word, inDirection: (UITextLayoutDirection.Right.rawValue as UITextDirection))
                    ?? self.tweetView.tokenizer.rangeEnclosingPosition(position!, withGranularity: UITextGranularity.Word, inDirection: (UITextLayoutDirection.Left.rawValue as UITextDirection))
                
                //if there is a nearest word (range exists), select the nearest word
                if range != nil {
                    let start = self.tweetView.offsetFromPosition(self.tweetView.beginningOfDocument, toPosition: range!.start)
                    let end = self.tweetView.offsetFromPosition(self.tweetView.beginningOfDocument, toPosition: range!.end)
                    self.tweetView.selectedRange = NSMakeRange(start, end-start)
                    selectedRange = self.tweetView.selectedRange
                } else { //if we can't get the nearest word, just select everything
                    self.tweetView.selectedRange = NSMakeRange(0, self.tweetView.attributedText.length)
                    selectedRange = self.tweetView.selectedRange
                }
            }
            
            //if there is no text, make changes globally
            if self.tweetView.text.isEmpty {
                self.tweetView.textColor = color
            } else {
                var mutableCopy = NSMutableAttributedString(attributedString: self.tweetView.attributedText)
                
                self.tweetView.attributedText.enumerateAttributesInRange(selectedRange, options: NSAttributedStringEnumerationOptions.LongestEffectiveRangeNotRequired, usingBlock: { (attributes, range, stop) -> Void in
                    var newAttributes = attributes as [NSObject : AnyObject] //make a copy of the attributes
                    
                    //ichange the color of the font ONLY
                    var attribute = ""
                    if sender.callerTag! == 1 {
                        attribute = NSForegroundColorAttributeName
                        
                        self.colorButton.tintColor = color //set the button color
                    } else if sender.callerTag! == 2 {
                        attribute = NSBackgroundColorAttributeName
                        self.highlightButton.tintColor = color //set the button color
                    }
                    newAttributes[attribute] = color
                    
                    //update the attributes to new standard
                    mutableCopy.addAttributes(newAttributes, range: range)
                })
                
                //set the attributes of our attributed text to the updated copy
                self.tweetView.attributedText = mutableCopy
                self.tweetView.selectedRange = selectedRange
            }
        }
        
        sender.dismissViewControllerAnimated(true, completion: { () -> Void in
            self.tweetView.becomeFirstResponder()
            return
        })
    }
    
    @IBAction func changeFont() {
        self.tweetView.resignFirstResponder()
        let fontPicker = UIAlertController(title: "Pick a Font...", message: "Note: Changing fonts will remove all bolding or italics.", preferredStyle: UIAlertControllerStyle.ActionSheet)
        let Helvetica  = UIAlertAction(title: "Helvetica", style: UIAlertActionStyle.Default, handler: fontPicked)
        let Times      = UIAlertAction(title: "Times New Roman", style: UIAlertActionStyle.Default, handler: fontPicked)
        let Georgia    = UIAlertAction(title: "Georgia", style: UIAlertActionStyle.Default, handler: fontPicked)
        let Courier    = UIAlertAction(title: "Courier", style: UIAlertActionStyle.Default, handler: fontPicked)
        let Cancel     = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel, handler: nil)
        
        fontPicker.addAction(Helvetica)
        fontPicker.addAction(Times)
        fontPicker.addAction(Georgia)
        fontPicker.addAction(Courier)
        fontPicker.addAction(Cancel)
        
        if (UIDevice.currentDevice().model.hasPrefix("iPad")) {
            fontPicker.popoverPresentationController!.barButtonItem = self.fontButton
        }
        self.presentViewController(fontPicker, animated: true, completion: nil)
    }
    
    func fontPicked(action : UIAlertAction!) {
        var fontName = action.title
        
        //extract the actual font; size is just a placeholder
        var fontPicked : UIFont?
        switch fontName {
        case "Helvetica":
            fontPicked = UIFont(name: "Helvetica", size: 10)
        case "Georgia":
            fontPicked = UIFont(name: "Georgia", size: 10)
        case "Times New Roman":
            fontPicked = UIFont(name: "Times New Roman", size: 10)
        case "Courier":
            fontPicked = UIFont(name: "Courier", size: 10)
        default:
            fontPicked = UIFont(name: "Helvetica", size: 10)
        }
        
        //get the selected text, if available
        var selectedRange = self.tweetView.selectedRange
        
        //if nothing selected, select nearest word
        if selectedRange.length == 0 {
            let position = self.tweetView.positionFromPosition(self.tweetView.beginningOfDocument, offset: selectedRange.location)
            let range = self.tweetView.tokenizer.rangeEnclosingPosition(position!, withGranularity: UITextGranularity.Word, inDirection: (UITextLayoutDirection.Right.rawValue as UITextDirection))
                ?? self.tweetView.tokenizer.rangeEnclosingPosition(position!, withGranularity: UITextGranularity.Word, inDirection: (UITextLayoutDirection.Left.rawValue as UITextDirection))
            
            //if there is a nearest word (range exists), select the nearest word
            if range != nil {
                let start = self.tweetView.offsetFromPosition(self.tweetView.beginningOfDocument, toPosition: range!.start)
                let end = self.tweetView.offsetFromPosition(self.tweetView.beginningOfDocument, toPosition: range!.end)
                self.tweetView.selectedRange = NSMakeRange(start, end-start)
                selectedRange = self.tweetView.selectedRange
            } else { //if we can't get the nearest word, just select everything
                self.tweetView.selectedRange = NSMakeRange(0, self.tweetView.attributedText.length)
                selectedRange = self.tweetView.selectedRange
            }
        }
        
        //if there is no text, make changes globally
        if self.tweetView.text.isEmpty {
            let currentFont = self.tweetView.font as UIFont
            let newFont = UIFont(name: fontPicked!.fontName, size: currentFont.pointSize)
            self.tweetView.font = newFont
        } else {
            var mutableCopy = NSMutableAttributedString(attributedString: self.tweetView.attributedText)
            
            self.tweetView.attributedText.enumerateAttributesInRange(selectedRange, options: NSAttributedStringEnumerationOptions.LongestEffectiveRangeNotRequired, usingBlock: { (attributes, range, stop) -> Void in
                var newAttributes = attributes as [NSObject : AnyObject] //make a copy of the attributes
                
                //if we have a font set, change the size of the font ONLY
                if newAttributes[NSFontAttributeName] != nil {
                    let currentFont = newAttributes[NSFontAttributeName] as! UIFont
                    let newFont = UIFont(name: fontPicked!.fontName, size: currentFont.pointSize)
                    newAttributes[NSFontAttributeName] = newFont
                }
                
                //update the attributes to new standard
                mutableCopy.addAttributes(newAttributes, range: range)
            })
            
            //set the attributes of our attributed text to the updated copy
            self.tweetView.attributedText = mutableCopy
            self.tweetView.selectedRange = selectedRange
        }
        
        self.tweetView.becomeFirstResponder()
    }
    
    @IBAction func changeAlignment(sender : UIBarButtonItem) {
        self.tweetView.resignFirstResponder()
        let alignPicker = UIAlertController(title: "Pick an Alignment...", message: "", preferredStyle: UIAlertControllerStyle.ActionSheet)
        let Left    = UIAlertAction(title: "Left", style: UIAlertActionStyle.Default, handler: alignPicked)
        let Right   = UIAlertAction(title: "Right", style: UIAlertActionStyle.Default, handler: alignPicked)
        let Center  = UIAlertAction(title: "Center", style: UIAlertActionStyle.Default, handler: alignPicked)
        let Justify = UIAlertAction(title: "Justify", style: UIAlertActionStyle.Default, handler: alignPicked)
        let Cancel  = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel, handler: nil)
        
        alignPicker.addAction(Left)
        alignPicker.addAction(Right)
        alignPicker.addAction(Center)
        alignPicker.addAction(Justify)
        alignPicker.addAction(Cancel)
        
        if (UIDevice.currentDevice().model.hasPrefix("iPad")) {
            alignPicker.popoverPresentationController!.barButtonItem = self.alignmentButton
        }
        self.presentViewController(alignPicker, animated: true, completion: nil)
    }
    
    func alignPicked(action : UIAlertAction!) {
        var alignName = action.title
        
        //extract the actual font; size is just a placeholder
        var alignPicked : NSTextAlignment?
        switch alignName {
        case "Left":
            alignPicked = NSTextAlignment.Left
        case "Right":
            alignPicked = NSTextAlignment.Right
        case "Center":
            alignPicked = NSTextAlignment.Center
        case "Justify":
            alignPicked = NSTextAlignment.Justified
        default:
            alignPicked = NSTextAlignment.Right
        }
        
        //get the selected text, if available
        var selectedRange = self.tweetView.selectedRange
        
        //if nothing selected, select nearest word
        if selectedRange.length == 0 {
            let position = self.tweetView.positionFromPosition(self.tweetView.beginningOfDocument, offset: selectedRange.location)
            let range = self.tweetView.tokenizer.rangeEnclosingPosition(position!, withGranularity: UITextGranularity.Paragraph, inDirection: (UITextLayoutDirection.Right.rawValue as UITextDirection))
                ?? self.tweetView.tokenizer.rangeEnclosingPosition(position!, withGranularity: UITextGranularity.Paragraph, inDirection: (UITextLayoutDirection.Left.rawValue as UITextDirection))
            
            //if there is a nearest word (range exists), select the nearest word
            if range != nil {
                let start = self.tweetView.offsetFromPosition(self.tweetView.beginningOfDocument, toPosition: range!.start)
                let end = self.tweetView.offsetFromPosition(self.tweetView.beginningOfDocument, toPosition: range!.end)
                self.tweetView.selectedRange = NSMakeRange(start, end-start)
                selectedRange = self.tweetView.selectedRange
            } else { //if we can't get the nearest word, just select everything
                self.tweetView.selectedRange = NSMakeRange(0, self.tweetView.attributedText.length)
                selectedRange = self.tweetView.selectedRange
            }
        }
        
        //if there is no text, make changes globally
        if self.tweetView.text.isEmpty {
            self.tweetView.textAlignment = alignPicked!
        } else {
            var mutableCopy = NSMutableAttributedString(attributedString: self.tweetView.attributedText)
            
            self.tweetView.attributedText.enumerateAttributesInRange(selectedRange, options: NSAttributedStringEnumerationOptions.LongestEffectiveRangeNotRequired, usingBlock: { (attributes, range, stop) -> Void in
                var newAttributes = attributes as [NSObject : AnyObject] //make a copy of the attributes
                
                //if we have a font set, change the size of the font ONLY
                if newAttributes[NSParagraphStyleAttributeName] != nil {
                    var style = NSMutableParagraphStyle()
                    style.alignment = alignPicked!
                    newAttributes[NSParagraphStyleAttributeName] = style
                }
                
                //update the attributes to new standard
                mutableCopy.addAttributes(newAttributes, range: range)
            })
            
            //set the attributes of our attributed text to the updated copy
            self.tweetView.attributedText = mutableCopy
            self.tweetView.selectedRange = selectedRange
        }
        
        self.alignmentButton!.image = alignPicked!.image()
        self.tweetView.becomeFirstResponder()
    }
    
    func setTweetViewDefaults() {
        let settings = Infinitweet.getDisplaySettings() //get the current defaults
        
        self.tweetView.textAlignment = settings.alignment //set the alignment
        self.tweetView.font = settings.font
        self.tweetView.textColor = settings.color //set the text color
        self.colorButton.tintColor = settings.color //set the button default color
        
        var mutableCopy = NSMutableAttributedString(attributedString: self.tweetView.attributedText)
        var textRange = NSMakeRange(0, self.tweetView.attributedText.length)
        //for attributes in this range, change toolbar buttons to match,
        self.tweetView.attributedText.enumerateAttributesInRange(textRange, options: NSAttributedStringEnumerationOptions.LongestEffectiveRangeNotRequired, usingBlock: { (attributes, range, stop) -> Void in
            var newAttributes = attributes as [NSObject : AnyObject] //make a copy of the attributes
            
            //if we have a font set, change the size of the font ONLY
            if newAttributes[NSBackgroundColorAttributeName] != nil {
                let newBG = settings.background
                newAttributes[NSBackgroundColorAttributeName] = newBG
            }
            
            //update the attributes to new standard
            mutableCopy.addAttributes(newAttributes, range: range)
        })
        //set the attributes of our attributed text to the updated copy
        self.tweetView.attributedText = mutableCopy
        
        self.highlightButton.tintColor = settings.background //set the highlight color to the bg
        self.tweetView.backgroundColor = settings.background //set the background color
        self.backgroundButton.tintColor = settings.background //set the button default color
        self.view.backgroundColor = settings.background //set the background color (of view)
    }
    
    @IBAction func changeFormatting() {
        self.tweetView.resignFirstResponder()
        let formatPicker = UIAlertController(title: "Toggle Styles", message: "Select to Add or Remove Style", preferredStyle: UIAlertControllerStyle.ActionSheet)
        let Bold      = UIAlertAction(title: "Bold", style: UIAlertActionStyle.Default, handler: formatPicked)
        let Italicize = UIAlertAction(title: "Italicize", style: UIAlertActionStyle.Default, handler: formatPicked)
        let Underline = UIAlertAction(title: "Underline", style: UIAlertActionStyle.Default, handler: formatPicked)
        
        formatPicker.addAction(Bold)
        formatPicker.addAction(Italicize)
        formatPicker.addAction(Underline)
        
        if (UIDevice.currentDevice().model.hasPrefix("iPad")) {
            formatPicker.popoverPresentationController!.barButtonItem = self.formatButton
        }
        self.presentViewController(formatPicker, animated: true, completion: nil)
    }
    
    func formatPicked(action : UIAlertAction!) {
        //get the selected text, if available
        var selectedRange = self.tweetView.selectedRange
        
        //if nothing selected, select nearest word
        if selectedRange.length == 0 {
            let position = self.tweetView.positionFromPosition(self.tweetView.beginningOfDocument, offset: selectedRange.location)
            let range = self.tweetView.tokenizer.rangeEnclosingPosition(position!, withGranularity: UITextGranularity.Word, inDirection: (UITextLayoutDirection.Right.rawValue as UITextDirection))
                ?? self.tweetView.tokenizer.rangeEnclosingPosition(position!, withGranularity: UITextGranularity.Word, inDirection: (UITextLayoutDirection.Left.rawValue as UITextDirection))
            
            //if there is a nearest word (range exists), select the nearest word
            if range != nil {
                let start = self.tweetView.offsetFromPosition(self.tweetView.beginningOfDocument, toPosition: range!.start)
                let end = self.tweetView.offsetFromPosition(self.tweetView.beginningOfDocument, toPosition: range!.end)
                self.tweetView.selectedRange = NSMakeRange(start, end-start)
                selectedRange = self.tweetView.selectedRange
            } else { //if we can't get the nearest word, just select everything
                self.tweetView.selectedRange = NSMakeRange(0, self.tweetView.attributedText.length)
                selectedRange = self.tweetView.selectedRange
            }
        }
        
        //if there is no text, make changes globally
        if self.tweetView.text.isEmpty {
            self.tweetView.selectedRange = NSMakeRange(0, self.tweetView.attributedText.length)
            selectedRange = self.tweetView.selectedRange
        }
        
        //apply changes
        var formatName = action.title
        switch formatName {
        case "Bold":
            self.tweetView.toggleBoldface(self)
        case "Italicize":
            self.tweetView.toggleItalics(self)
        case "Underline":
            self.tweetView.toggleUnderline(self)
        default:
            break
        }
        
        self.tweetView.becomeFirstResponder()
    }
    
    //bar button action
    func resetToDefaults() {
        self.tweetView.resignFirstResponder()
        var reset = UIAlertController(title: "Are you sure?", message: "This will reset the all text formatting to default, removing custom fonts, styling, alignment, etc.", preferredStyle: UIAlertControllerStyle.Alert)
        
        var yes = UIAlertAction(title: "Yes", style: UIAlertActionStyle.Default) { (action) -> Void in
            self.setTweetViewDefaults()
            self.tweetView.becomeFirstResponder()
        }
        
        var cancel = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel) { (action) -> Void in
            self.tweetView.becomeFirstResponder()
            return
        }
        
        reset.addAction(yes)
        reset.addAction(cancel)
        self.presentViewController(reset, animated: true, completion: nil)
    }
    
    // Override the iPhone behavior that presents a popover as fullscreen
    func adaptivePresentationStyleForPresentationController(controller: UIPresentationController) -> UIModalPresentationStyle {
        // Return no adaptive presentation style, use default presentation behaviour
        return .None
    }
}

extension NSTextAlignment {
    func image() -> UIImage {
        var image : UIImage?
        switch self {
        case NSTextAlignment.Left:
            image = UIImage(named: "align-left")
        case NSTextAlignment.Right:
            image = UIImage(named: "align-right")
        case NSTextAlignment.Center:
            image = UIImage(named: "align-center")
        case NSTextAlignment.Justified:
            image = UIImage(named: "align-justified")
        default:
            image = UIImage(named: "align-left")
            break
        }
        
        return image!
    }
}