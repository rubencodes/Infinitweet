//
//  ActionViewController.swift
//  InfiniTweetAction
//
//  Created by Ruben on 1/2/15.
//  Copyright (c) 2015 Ruben. All rights reserved.
//

import UIKit
import MobileCoreServices

class ActionViewController: UIViewController, UINavigationBarDelegate, UITextViewDelegate, OptionsViewDelegate {
    @IBOutlet weak var tweetView: UITextView!
    @IBOutlet weak var navBar: UINavigationBar!
    @IBOutlet weak var navItem: UINavigationItem!
    var shareButton: UIBarButtonItem!
    var optionsButton: UIBarButtonItem!
    
    var optionsView : OptionsView?
    var delegate : TextOptionsDelegate?
    var editingText : Bool = false
    var optionsAreShown : Bool = false
    var keyboardIsShown : Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //navbar prep
        navBar.setBackgroundImage(UIImage(), forBarMetrics: UIBarMetrics.Default)
        navBar.backgroundColor = UIColor.whiteColor()
        navBar.shadowImage = UIImage()
        
        self.optionsButton = UIBarButtonItem(image: UIImage(named: "format"), style: UIBarButtonItemStyle.Plain, target: self, action: "showOptionsView")
        self.optionsButton?.imageInsets = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: -10)
        
        self.shareButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Action, target: self, action: "shareInfinitweet")
        self.navItem.setRightBarButtonItems([self.shareButton!, self.optionsButton!], animated: false)
        
        //prepare for keyboard, etc
        self.automaticallyAdjustsScrollViewInsets = false
        self.tweetView.delegate = self
        self.tweetView.textContainer.lineFragmentPadding = 0
        self.tweetView.allowsEditingTextAttributes = true
        
        //handle select menu
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "menuControllerWillShow", name: UIMenuControllerWillShowMenuNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "menuControllerWillHide", name: UIMenuControllerWillHideMenuNotification, object: nil)
        
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
                                do {
                                    self.tweetView.attributedText = try NSAttributedString(data: textData, options: [ NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType], documentAttributes: nil)
                                } catch _ {
                                    self.tweetView.attributedText = nil
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
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    func positionForBar(bar: UIBarPositioning) -> UIBarPosition  {
        return UIBarPosition.TopAttached
    }

    @IBAction func done() {
        // Return any edited content to the host app.
        // This template doesn't do anything, so we just echo the passed in items.
        self.extensionContext!.completeRequestReturningItems(self.extensionContext!.inputItems, completionHandler: nil)
    }
    
    //sets the default attributes within the tweetView
    func setTweetViewDefaults() {
        let settings = Infinitweet.getDisplaySettings() //get the current defaults
        
        self.tweetView.textAlignment = settings.alignment //set the alignment
        self.tweetView.font = settings.font
        self.tweetView.textColor = settings.color //set the text color
        
        let mutableCopy = NSMutableAttributedString(attributedString: self.tweetView.attributedText)
        let textRange = NSMakeRange(0, self.tweetView.attributedText.length)
        //for attributes in this range, change toolbar buttons to match,
        self.tweetView.attributedText.enumerateAttributesInRange(textRange, options: NSAttributedStringEnumerationOptions.LongestEffectiveRangeNotRequired, usingBlock: { (attributes, range, stop) -> Void in
            var newAttributes = attributes as [String : AnyObject] //make a copy of the attributes
            
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
        
        self.tweetView.backgroundColor = settings.background //set the background color
        self.view.backgroundColor = settings.background //set the background color (of view)
    }
    
    func shareInfinitweet() {
        dispatch_async(dispatch_get_main_queue()) {
            if self.tweetView.text != "" { //if text exists
                if self.optionsAreShown {
                    self.hideOptionsView()
                }
                
                //get properties for new infinitweet
                let settings = Infinitweet.getDisplaySettings()
                
                //create infinitweet with properties
                let infinitweet = Infinitweet(text: self.tweetView.attributedText ?? NSAttributedString(string: self.tweetView.text), background: self.tweetView.backgroundColor ?? settings.background, wordmarkHidden: settings.wordmarkHidden)
                
                //preload text on share
                var shareText : String?
                let defaults = NSUserDefaults(suiteName: "group.Codes.Ruben.InfinitweetPro")!
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
                            delay(0.75, closure: { () -> () in
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
        
        let keyboardSize = userInfo[UIKeyboardFrameBeginUserInfoKey]?.CGRectValue.size
        
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
        if keyboardIsShown {
            return
        }
        
        let userInfo = notification.userInfo as [NSObject : AnyObject]!
        
        let keyboardSize = userInfo[UIKeyboardFrameBeginUserInfoKey]?.CGRectValue.size
        
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
        
        keyboardIsShown = true
    }
    
    //Edit menu is about to show, make sure it doesn't cover the toolbar
    func menuControllerWillShow() {
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIMenuControllerWillShowMenuNotification, object: nil)
        
        let menuController = UIMenuController.sharedMenuController()
        if menuController.menuFrame.origin.y < navBar.frame.origin.y+navBar.frame.height {
            let size = menuController.menuFrame.size
            let origin = CGPoint(x: menuController.menuFrame.origin.x, y: menuController.menuFrame.origin.y+size.height)
            let menuFrame = CGRect(origin: origin, size: size)
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
    
    
    //resizes TweetView when options are shown
    func optionsViewWillShow() {
        if self.optionsAreShown {
            return
        }
        
        let optionsSize = OptionsView().minSize
        
        let contentInsets = UIEdgeInsetsMake(0.0, 0.0, optionsSize.height, 0.0)
        self.tweetView.contentInset = contentInsets
        self.tweetView.scrollIndicatorInsets = contentInsets
    }
    
    func optionsViewWillHide() {
        let optionsSize = OptionsView().minSize
        
        let contentInsets = UIEdgeInsetsZero
        self.tweetView.contentInset = contentInsets
        self.tweetView.scrollIndicatorInsets = contentInsets
        
        var viewFrame = self.tweetView.frame
        
        viewFrame.size.height += optionsSize.height
        
        UIView.beginAnimations(nil, context: nil)
        UIView.setAnimationBeginsFromCurrentState(true)
        self.tweetView.frame = viewFrame
        UIView.commitAnimations()
    }
    
    func showOptionsView() {
        if !optionsAreShown {
            optionsViewWillShow()
            
//            let window = UIApplication.sharedApplication().windows.last! as! UIWindow
            self.tweetView.resignFirstResponder()
            
            if optionsView == nil {
                optionsView = NSBundle.mainBundle().loadNibNamed("OptionsView", owner: self, options: nil).first as? OptionsView
                optionsView!.delegate = self as OptionsViewDelegate
                self.delegate = optionsView!
            }
            optionsAreShown = true
            
            let hiddenFrame = CGRectMake(0, self.view.frame.size.height, self.view.frame.size.width, optionsView!.minSize.height)
            
//            window.addSubview(optionsView!)
//            window.bringSubviewToFront(optionsView!)
            self.view.addSubview(optionsView!)
            
            optionsView!.frame = hiddenFrame
            updateOptionsView()
            
            let transform = CGAffineTransformMakeTranslation(0, -optionsView!.minSize.height)
            UIView.animateWithDuration(0.2, animations: { () -> Void in
                self.optionsView!.transform = transform
            })
        } else {
            self.hideOptionsView()
        }
    }
    
    func hideOptionsView() {
        if optionsAreShown {
            optionsViewWillHide()
            
            self.tweetView.resignFirstResponder()
            
            let transform = CGAffineTransformMakeTranslation(0, 0)
            UIView.animateWithDuration(0.2, animations: { () -> Void in
                self.optionsView!.transform = transform
                }) { (Bool) in
                    self.tweetView.becomeFirstResponder()
                    self.optionsView!.removeFromSuperview()
                    self.optionsAreShown = false
            }
        }
    }
    
    func updateOptionsView() {
        var textFont : UIFont?
        var textColor : UIColor?
        var highlightColor : UIColor?
        var alignment : NSTextAlignment?
        
        //gets range with most applicable attributes
        var textRange : NSRange?
        if self.tweetView.attributedText.length > 0 {
            textRange = self.tweetView.selectedRange.location > 0 && self.tweetView.selectedRange.length == 0
                ? NSMakeRange(self.tweetView.selectedRange.location-1, 1)
                : NSMakeRange(self.tweetView.selectedRange.location, 1)
            
            //for attributes in this range, change toolbar buttons to match,
            self.tweetView.attributedText.enumerateAttributesInRange(textRange!, options: NSAttributedStringEnumerationOptions.LongestEffectiveRangeNotRequired, usingBlock: { (attributes, range, stop) -> Void in
                
                textFont = attributes[NSFontAttributeName] as? UIFont
                textColor = attributes[NSForegroundColorAttributeName] as? UIColor
                highlightColor = attributes[NSBackgroundColorAttributeName] as? UIColor
                if let paragraphStyle = attributes[NSParagraphStyleAttributeName] as? NSParagraphStyle {
                    alignment = paragraphStyle.alignment
                }
            })
        }
        if textFont == nil {
            textFont = self.tweetView.font ?? UIFont.systemFontOfSize(12)
        }
        if textColor == nil {
            textColor = self.tweetView.textColor ?? UIColor.blackColor()
        }
        if alignment == nil {
            alignment = self.tweetView.textAlignment
        }
        
        self.delegate!.selectedTextHasProperties(textFont!, alignment: alignment!, highlight: highlightColor, color: textColor!, background: self.view.backgroundColor!)
    }
    
    //user moved the cursor; update toolbar buttons to match current formatting
    func textViewDidChangeSelection(textView: UITextView) {
        if !editingText && optionsView != nil  {
            updateOptionsView()
        }
    }
    
    //something changed in the text view; update lastKnownState (and background)
    func textViewDidChange(textView: UITextView) {
        if optionsAreShown {
            updateOptionsView()
        }
    }
    
    // Delegate Protocol Implementation
    func formatSelectedText(format : TextFormat) {
        editingText = true
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
        switch format {
        case TextFormat.Bold:
            self.tweetView.toggleBoldface(self)
        case TextFormat.Italics:
            self.tweetView.toggleItalics(self)
        case TextFormat.Underline:
            self.tweetView.toggleUnderline(self)
        }
        
        self.textViewDidChange(self.tweetView) //text changed
        editingText = false
    }
    
    func changedFontSizeForSelectedText(increased increased : Bool) {
        editingText = true
        //get the selected text, if available
        var selectedRange = self.tweetView.selectedRange
        
        //if there is no text, make changes globally
        if self.tweetView.text.isEmpty {
            var newFontSize = self.tweetView.font!.pointSize
            if increased && self.tweetView.font!.pointSize < 60 {
                newFontSize = self.tweetView.font!.pointSize + 2
            }
            if !increased && self.tweetView.font!.pointSize > 8 {
                newFontSize = self.tweetView.font!.pointSize - 2
            }
            
            self.tweetView.font = self.tweetView.font!.fontWithSize(newFontSize)
            
            self.textViewDidChange(self.tweetView) //text changed
            
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
        
        if increased {
            self.tweetView.increaseSize(self)
        } else {
            self.tweetView.decreaseSize(self)
        }
        
        self.textViewDidChange(self.tweetView) //text changed
        editingText = false
    }
    
    func changedFontForSelectedText(newFont : UIFont) {
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
            let currentFont = self.tweetView.font! as UIFont
            let updatedFont = UIFont(name: newFont.fontName, size: currentFont.pointSize)
            self.tweetView.font = updatedFont
        } else {
            let mutableCopy = NSMutableAttributedString(attributedString: self.tweetView.attributedText)
            
            self.tweetView.attributedText.enumerateAttributesInRange(selectedRange, options: NSAttributedStringEnumerationOptions.LongestEffectiveRangeNotRequired, usingBlock: { (attributes, range, stop) -> Void in
                var newAttributes = attributes as [String : AnyObject] //make a copy of the attributes
                
                //if we have a font set, change the size of the font ONLY
                if newAttributes[NSFontAttributeName] != nil {
                    let currentFont = newAttributes[NSFontAttributeName] as! UIFont
                    let updatedFont = UIFont(name: newFont.fontName, size: currentFont.pointSize)
                    newAttributes[NSFontAttributeName] = updatedFont
                }
                
                //update the attributes to new standard
                mutableCopy.addAttributes(newAttributes, range: range)
            })
            
            //set the attributes of our attributed text to the updated copy
            self.tweetView.attributedText = mutableCopy
            self.tweetView.selectedRange = selectedRange
        }
        
        self.textViewDidChange(self.tweetView) //text changed
    }
    
    func changedAlignmentForSelectedText(newAlignment : Alignment) {
        editingText = true
        //extract the actual font; size is just a placeholder
        var alignPicked : NSTextAlignment?
        switch newAlignment {
        case Alignment.Left:
            alignPicked = NSTextAlignment.Left
        case Alignment.Right:
            alignPicked = NSTextAlignment.Right
        case Alignment.Center:
            alignPicked = NSTextAlignment.Center
        case Alignment.Justify:
            alignPicked = NSTextAlignment.Justified
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
            let mutableCopy = NSMutableAttributedString(attributedString: self.tweetView.attributedText)
            
            self.tweetView.attributedText.enumerateAttributesInRange(selectedRange, options: NSAttributedStringEnumerationOptions.LongestEffectiveRangeNotRequired, usingBlock: { (attributes, range, stop) -> Void in
                var newAttributes = attributes as [String : AnyObject] //make a copy of the attributes
                
                //if we have a font set, change the size of the font ONLY
                if newAttributes[NSParagraphStyleAttributeName] != nil {
                    let style = NSMutableParagraphStyle()
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
        
        self.textViewDidChange(self.tweetView) //text changed
        editingText = false
    }
    
    func changedColorTo(color : UIColor, forColorAttribute attribute : ColorAttribute) {
        editingText = true
        //TODO: Make this change optionsView colors
        if attribute == ColorAttribute.Background { //background color
            self.tweetView.backgroundColor = color //set the background color
            self.view.backgroundColor = color //set the background color (of view)
            
        } else if attribute == ColorAttribute.Text || attribute == ColorAttribute.Highlight {
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
                let mutableCopy = NSMutableAttributedString(attributedString: self.tweetView.attributedText)
                
                self.tweetView.attributedText.enumerateAttributesInRange(selectedRange, options: NSAttributedStringEnumerationOptions.LongestEffectiveRangeNotRequired, usingBlock: { (attributes, range, stop) -> Void in
                    var newAttributes = attributes as [String : AnyObject] //make a copy of the attributes
                    
                    //ichange the color of the font ONLY
                    if attribute == ColorAttribute.Text {
                        newAttributes[NSForegroundColorAttributeName] = color
                    } else if attribute == ColorAttribute.Highlight {
                        newAttributes[NSBackgroundColorAttributeName] = color
                    }
                    
                    
                    //update the attributes to new standard
                    mutableCopy.addAttributes(newAttributes, range: range)
                })
                
                //set the attributes of our attributed text to the updated copy
                self.tweetView.attributedText = mutableCopy
                self.tweetView.selectedRange = selectedRange
            }
        }
        
        self.textViewDidChange(self.tweetView) //text changed
        editingText = false
    }
}