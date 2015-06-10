//
//  ViewController.swift
//  InfiniTweet
//
//  Created by Ruben on 1/1/15.
//  Copyright (c) 2015 Ruben. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UITextViewDelegate, UIPopoverPresentationControllerDelegate, ColorPickerDelegate, OptionsViewDelegate {
    var delegate : TextOptionsDelegate?
    @IBOutlet var navItem: UINavigationItem!
    @IBOutlet var tweetView: UITextView!
    var clearButton: UIBarButtonItem?
    var settingsButton: UIBarButtonItem?
    var shareButton: UIBarButtonItem?
    var optionsButton: UIBarButtonItem?
    var optionsView: OptionsView?
    var keyboardIsShown : Bool = false
    var optionsAreShown : Bool = false
    var editingText : Bool = false
    
    //cache of last known state
    let cache = (NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0] as! String).stringByAppendingPathComponent("lastKnownState.infinitweet")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //navbar prep
        let navBar = self.navigationController!.navigationBar
        navBar.setBackgroundImage(UIImage(), forBarMetrics: UIBarMetrics.Default)
        navBar.backgroundColor = UIColor.whiteColor()
        navBar.shadowImage = UIImage()
        
        self.clearButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Trash, target: self, action: "clearTextField")
        self.optionsButton = UIBarButtonItem(image: UIImage(named: "format"), style: UIBarButtonItemStyle.Plain, target: self, action: "showOptionsView")
        self.optionsButton?.imageInsets = UIEdgeInsets(top: 0, left: -10, bottom: 0, right: 10)
        
        self.settingsButton = UIBarButtonItem(image: UIImage(named: "settings"), style: UIBarButtonItemStyle.Plain, target: self, action: "showDefaultSettings")
        self.settingsButton?.imageInsets = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: -10)
        self.shareButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Action, target: self, action: "shareInfinitweet")
        
        self.navItem.setRightBarButtonItems([self.shareButton!, self.settingsButton!], animated: false)
        self.navItem.setLeftBarButtonItems([self.clearButton!, self.optionsButton!], animated: false)
        
        var defaults = NSUserDefaults(suiteName: "group.Codes.Ruben.InfinitweetPro")!
        //have we set the latest defaults?
        if !defaults.boolForKey(Infinitweet.currentDefaultKey()) {
            Infinitweet.setDefaults() //set the default text attributes in memory
        } else { //if so, make the tweetView reflect the defaults
            self.setTweetViewDefaults()
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
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
        
        self.keyboardIsShown = false
        
        var defaults = NSUserDefaults(suiteName: "group.Codes.Ruben.InfinitweetPro")!
        //have we shown the tutorial?
        if !defaults.boolForKey("TutorialShown3") {
            self.beginTutorialPart(1) //if not, show it
        } else {
            //we have shown the tutorial, restore the last known state
            self.restoreLastKnownState()
            //then just focus on the textview
            self.tweetView.becomeFirstResponder()
        }
    }
    
    override func viewWillDisappear(animated: Bool) {
        self.hideOptionsView()
        
        self.tweetView.resignFirstResponder()
        
        super.viewWillDisappear(animated)
        
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //restores the last state if there was one; else, just sets everything to default
    func restoreLastKnownState() {
        var defaults = NSUserDefaults(suiteName: "group.Codes.Ruben.InfinitweetPro")!
        var error : NSError?
        var attrString = NSAttributedString(fileURL: NSURL(fileURLWithPath: self.cache)!, options: [NSDocumentTypeDocumentAttribute:NSRTFTextDocumentType], documentAttributes: nil, error: &error)
        
        //if we had a significant lastKnownState, restore it and the background; else set defaults
        if attrString != nil && attrString?.length > 0 {
            self.tweetView.attributedText  = attrString
            
            var lastKnownBackground = defaults.objectForKey("lastKnownBackground") as? [CGFloat]
            if let background = lastKnownBackground?.toUIColor() {
                self.tweetView.backgroundColor  = background
                self.view.backgroundColor       = background
            }
        } else {
            self.setTweetViewDefaults()
        }
    }
    
    //sets the default attributes within the tweetView
    func setTweetViewDefaults() {
        let settings = Infinitweet.getDisplaySettings() //get the current defaults
        
        self.tweetView.textAlignment = settings.alignment //set the alignment
        self.tweetView.font = settings.font
        self.tweetView.textColor = settings.color //set the text color
        
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
        
        self.tweetView.backgroundColor = settings.background //set the background color
        self.view.backgroundColor = settings.background //set the background color (of view)
    }
    
    //tutorial alers
    func beginTutorialPart(part : Int) {
        var defaults = NSUserDefaults(suiteName: "group.Codes.Ruben.InfinitweetPro")!
        
        var title : String?
        var message : String?
        var buttonTitle : String?
        
        if part == 1 {
            title = "Tutorial"
            message = "Welcome to Infinitweet! To start, type some text! You can use the toolbar above to change things like alignment, fonts, sizes, and colors. Select some of the text you wrote to change only that piece, or change everything. You can also bold, italicize, or underline using the iOS options you're familiar with."
            buttonTitle = "Next"
        } else if part == 2 {
            title = "Tutorial"
            message = "Lastly, you can the change default global settings by going to the Defaults menu on the top-left. When you're ready to share, tap the Share icon on the top-right to post your Infinitweet to Twitter (or elsewhere)."
            buttonTitle = "I'm Ready!"
        } else if part == 3 {
            title = "Congratulations!"
            message = "You've shared your first Infinitweet! Remember, you can also use our Action Extension to share text from within any app that supports it (e.g. Notes)."
            buttonTitle = "Cool!"
        }
        
        let tutorial = UIAlertController(title: title!,
            message: message!,
            preferredStyle: UIAlertControllerStyle.Alert)
        
        let OK = UIAlertAction(title: buttonTitle!,
            style: UIAlertActionStyle.Default,
            handler: {
                (action : UIAlertAction!) in
                
                if part == 1 {
                    self.beginTutorialPart(2)
                } else if part == 2 {
                    defaults.setBool(true, forKey: "TutorialShown3")
                    defaults.synchronize()
                    self.setTweetViewDefaults()
                    self.tweetView.becomeFirstResponder()
                } else if part == 3 {
                    defaults.setBool(true, forKey: "FirstShare")
                    defaults.synchronize()
                }
        })
        
        tutorial.addAction(OK)
        
        self.presentViewController(tutorial, animated: true, completion: nil)
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
        if self.keyboardIsShown {
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
        
        let navBar = self.navigationController!.navigationBar
        var menuController = UIMenuController.sharedMenuController()
        if menuController.menuFrame.origin.y < navBar.frame.origin.y+navBar.frame.height {
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
    
    func showOptionsView() {
        let window = UIApplication.sharedApplication().windows.last! as! UIWindow
        
        if optionsView == nil {
            optionsView = NSBundle.mainBundle().loadNibNamed("OptionsView", owner: self, options: nil).first as? OptionsView
            optionsView!.delegate = self
            self.delegate = optionsView!
        }
        
        optionsAreShown = true
        
        let hiddenFrame = CGRectMake(0, self.view.frame.size.height, self.view.frame.size.width, optionsView!.minSize.height)
        let finalFrame = CGRectMake(0, self.view.frame.size.height - optionsView!.minSize.height, self.view.frame.size.width, optionsView!.minSize.height)
        
        window.addSubview(optionsView!)
        window.bringSubviewToFront(optionsView!)
        
        optionsView!.frame = hiddenFrame
        updateOptionsView()
        
        UIView.animateWithDuration(0.2, animations: { () -> Void in
            self.optionsView!.frame = finalFrame
        })
    }
    
    func hideOptionsView() {
        if optionsAreShown {
            let hiddenFrame = CGRectMake(0, self.view.frame.size.height, self.view.frame.size.width, optionsView!.minSize.height)
            self.tweetView.resignFirstResponder()
            UIView.animateWithDuration(0.2, animations: { () -> Void in
                self.optionsView!.frame = hiddenFrame
                }) { (Bool) in
                    self.tweetView.becomeFirstResponder()
                    self.optionsView!.removeFromSuperview()
                    self.optionsAreShown = false
            }
        }
    }
    
    func updateOptionsView() {
        //gets range with most applicable attributes
        var textRange : NSRange?
        if self.tweetView.attributedText.length > 0 {
            textRange = self.tweetView.selectedRange.location > 0 && self.tweetView.selectedRange.length == 0
                ? NSMakeRange(self.tweetView.selectedRange.location-1, 1)
                : NSMakeRange(self.tweetView.selectedRange.location, 1)
        } else {
            textRange = NSMakeRange(self.tweetView.selectedRange.location, 0)
        }
        
        var textFont : UIFont?
        var textColor : UIColor?
        var highlightColor : UIColor?
        var alignment : NSTextAlignment?
        
        //for attributes in this range, change toolbar buttons to match,
        self.tweetView.attributedText.enumerateAttributesInRange(textRange!, options: NSAttributedStringEnumerationOptions.LongestEffectiveRangeNotRequired, usingBlock: { (attributes, range, stop) -> Void in
            
            if let font = attributes[NSFontAttributeName] as? UIFont {
                textFont = font
            } else {
                textFont = self.tweetView.font ?? UIFont.systemFontOfSize(12)
            }
            
            //if we have an attribute set, use it; else go for the default
            
            if let color = attributes[NSForegroundColorAttributeName] as? UIColor {
                textColor = color
            } else {
                textColor = self.tweetView.textColor ?? UIColor.blackColor()
            }
            
            if let highlight = attributes[NSBackgroundColorAttributeName] as? UIColor {
                highlightColor = highlight
            } else {
                highlightColor = self.tweetView.backgroundColor ?? UIColor.whiteColor()
            }
            
            if let paragraph = attributes[NSParagraphStyleAttributeName] as? NSParagraphStyle {
                alignment = paragraph.alignment
            } else {
                alignment = self.tweetView.textAlignment
            }
        })
        
        self.delegate!.selectedTextHasProperties(textFont!, alignment: alignment!, highlight: highlightColor!, color: textColor!, background: self.view.backgroundColor!)
    }
    
    //user moved the cursor; update toolbar buttons to match current formatting
    func textViewDidChangeSelection(textView: UITextView) {
        if !editingText {
            hideOptionsView()
        }
    }
    
    //something changed in the text view; update lastKnownState (and background)
    func textViewDidChange(textView: UITextView) {
        var rtfData = self.tweetView.attributedText.dataFromRange(NSMakeRange(0, self.tweetView.attributedText.length), documentAttributes:[NSDocumentTypeDocumentAttribute: NSRTFTextDocumentType], error:nil)
        
        rtfData?.writeToFile(self.cache, atomically: true)
        
        var defaults = NSUserDefaults(suiteName: "group.Codes.Ruben.InfinitweetPro")!
        defaults.setObject(self.tweetView.backgroundColor?.toCGFloatArray(), forKey: "lastKnownBackground")
        
        if optionsAreShown {
            updateOptionsView()
        }
    }
    
    //user wants to share the infinitweet
    func shareInfinitweet() {
        if self.tweetView.text != "" { //if text exists
            //get properties for new infinitweet
            let settings = Infinitweet.getDisplaySettings()
            
            //create infinitweet with properties
            let infinitweet = Infinitweet(text: self.tweetView.attributedText, background: self.tweetView.backgroundColor ?? UIColor.whiteColor(), wordmarkHidden: settings.wordmark)
            
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
                    
                    self.presentViewController(alert, animated: true, completion: { () -> Void in
                        delay(0.75, { () -> () in
                            UIView.animateWithDuration(0.25, animations: { () -> Void in
                                alert.view.alpha = 0
                            }, completion: { (Bool) -> Void in
                                alert.dismissViewControllerAnimated(false, completion: nil)
                                if firstShare {
                                    self.beginTutorialPart(3)
                                }
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
        self.textViewDidChange(self.tweetView)
        self.setTweetViewDefaults()
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
        //TODO: Make this change optionsView colors
        if sender.callerTag! == 0 { //background color
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
                    } else if sender.callerTag! == 2 {
                        attribute = NSBackgroundColorAttributeName
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
        
        self.textViewDidChange(self.tweetView) //text changed
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
//            fontPicker.popoverPresentationController!.barButtonItem = self.fontButton
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
        
        self.textViewDidChange(self.tweetView) //text changed
        self.tweetView.becomeFirstResponder()
    }
    
    func showDefaultSettings() {
        var storyboard = UIStoryboard(name: "Main", bundle: NSBundle.mainBundle())
        var vc = storyboard.instantiateViewControllerWithIdentifier("SettingsViewController") as! SettingsViewController

        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    // Override the iPhone behavior that presents a popover as fullscreen
    func adaptivePresentationStyleForPresentationController(controller: UIPresentationController) -> UIModalPresentationStyle {
        // Return no adaptive presentation style, use default presentation behaviour
        return .None
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
        default:
            break
        }
        
        self.textViewDidChange(self.tweetView) //text changed
        self.tweetView.becomeFirstResponder()
        editingText = false
    }
    
    func changedFontSizeForSelectedText(#increased : Bool) {
        editingText = true
        //get the selected text, if available
        var selectedRange = self.tweetView.selectedRange
        
        //if there is no text, make changes globally
        if self.tweetView.text.isEmpty {
            var newFontSize = self.tweetView.font.pointSize
            if increased && self.tweetView.font.pointSize < 60 {
                newFontSize = self.tweetView.font.pointSize + 2
            }
            if !increased && self.tweetView.font.pointSize > 8 {
                newFontSize = self.tweetView.font.pointSize - 2
            }
            
            self.tweetView.font = self.tweetView.font.fontWithSize(newFontSize)
            
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
        default:
            alignPicked = NSTextAlignment.Left
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
        
        self.textViewDidChange(self.tweetView) //text changed
        self.tweetView.becomeFirstResponder()
        editingText = false
    }
    
    func highlightSelectedText() {
        
    }
    
    func colorSelectedText() {
    
    }
    
    func changeBackgroundColor() {
    
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