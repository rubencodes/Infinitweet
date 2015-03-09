//
//  SettingsViewController.swift
//  InfiniTweet
//
//  Created by Ruben on 1/5/15.
//  Copyright (c) 2015 Ruben. All rights reserved.
//

import UIKit

class SettingsViewController: UIViewController, UIPopoverPresentationControllerDelegate {
    @IBOutlet weak var fontControl: UISegmentedControl!
    @IBOutlet weak var fontSizeSlider: UISlider!
    @IBOutlet weak var fontSizeLabel: UILabel!
    @IBOutlet weak var paddingSlider: UISlider!
    @IBOutlet weak var paddingLabel: UILabel!
    @IBOutlet weak var textColorButton: UIButton!
    @IBOutlet weak var backgroundColorButton: UIButton!
    @IBOutlet weak var wordmarkHiddenSwitch: UISwitch!
    
    override func viewWillAppear(animated: Bool) {
        var defaults = NSUserDefaults(suiteName: "group.Codes.Ruben.InfinitweetPro")!
        
        var fontName = defaults.objectForKey("FontName") as String
        var fontSize = defaults.integerForKey("FontSize") as Int
        
        var colorArray = defaults.objectForKey("TextColor") as [CGFloat]
        var color = colorArray.toUIColor()
        var backgroundColorArray = defaults.objectForKey("BackgroundColor") as [CGFloat]
        var backgroundColor = backgroundColorArray.toUIColor()
        
        var padding = defaults.integerForKey("Padding")
        var wordmark = defaults.boolForKey("WordmarkHidden")
        
        for segmentIndex in 0..<fontControl.numberOfSegments {
            if fontControl.titleForSegmentAtIndex(segmentIndex) == fontName {
                fontControl.selectedSegmentIndex = segmentIndex
            }
        }
        
        fontSizeSlider.value = Float(fontSize)
        fontSizeLabel.text = "\(fontSize)px"
        textColorButton.backgroundColor = color
        backgroundColorButton.backgroundColor = backgroundColor
        paddingSlider.value = Float(padding)
        paddingLabel.text = "\(padding)px"
        wordmarkHiddenSwitch.on = wordmark
        
        self.textColorButton.addObserver(self, forKeyPath: "backgroundColor", options: NSKeyValueObservingOptions.New, context: nil)
        self.backgroundColorButton.addObserver(self, forKeyPath: "backgroundColor", options: NSKeyValueObservingOptions.New, context: nil)

        super.viewWillAppear(animated)
    }
    
    override func viewWillDisappear(animated: Bool) {
        self.textColorButton.removeObserver(self, forKeyPath: "backgroundColor")
        self.backgroundColorButton.removeObserver(self, forKeyPath: "backgroundColor")
    }
    
    @IBAction func fontDidChange(sender: UISegmentedControl) {
        var defaults = NSUserDefaults(suiteName: "group.Codes.Ruben.InfinitweetPro")!
        var fontName = sender.titleForSegmentAtIndex(sender.selectedSegmentIndex) as String!
        defaults.setObject(fontName, forKey: "FontName")
        defaults.synchronize()
    }
    
    @IBAction func fontSizeDidChange(sender: UISlider) {
        var size = Int(round(sender.value))
        var defaults = NSUserDefaults(suiteName: "group.Codes.Ruben.InfinitweetPro")!
        defaults.setInteger(size, forKey: "FontSize")
        defaults.synchronize()
        
        fontSizeLabel.text = "\(size)px"
    }
    
    @IBAction func paddingDidChange(sender: UISlider) {
        var size = Int(round(sender.value))
        var defaults = NSUserDefaults(suiteName: "group.Codes.Ruben.InfinitweetPro")!
        defaults.setInteger(size, forKey: "Padding")
        defaults.synchronize()
        
        paddingLabel.text = "\(size)px"
    }
    
    @IBAction func colorButtonTapped(sender: UIButton) {
        let popoverVC = storyboard?.instantiateViewControllerWithIdentifier("colorPickerPopover") as ColorPickerViewController
        popoverVC.modalPresentationStyle = .Popover
        popoverVC.preferredContentSize = CGSizeMake(284, 446)
        if let popoverController = popoverVC.popoverPresentationController {
            popoverController.sourceView = sender
            popoverController.sourceRect = CGRect(x: 0, y: 0, width: 85, height: 30)
            popoverController.permittedArrowDirections = .Any
            popoverController.delegate = self
            popoverVC.callerTag = sender.tag
            popoverVC.delegate = sender
        }
        self.presentViewController(popoverVC, animated: true, completion: nil)
    }
    
    @IBAction func wordmarkSwitchTapped(sender : UISwitch) {
        var defaults = NSUserDefaults(suiteName: "group.Codes.Ruben.InfinitweetPro")!
        defaults.setBool(sender.on, forKey: "WordmarkHidden")
        defaults.synchronize()
    }
    
    //background/text color did change
    override func observeValueForKeyPath(keyPath: String, ofObject object: AnyObject, change: [NSObject : AnyObject], context: UnsafeMutablePointer<Void>) {
        var defaults = NSUserDefaults(suiteName: "group.Codes.Ruben.InfinitweetPro")!
        
        //empty rgba pointers, to be initialized by color
        var r = CGFloat()
        var g = CGFloat()
        var b = CGFloat()
        var a = CGFloat()
        
        if (object as UIButton) == self.textColorButton {
            var color = self.textColorButton.backgroundColor!
            color.getRed(&r, green: &g, blue: &b, alpha: &a)
            defaults.setObject([r, g, b, a], forKey: "TextColor")
        } else if (object as UIButton) == self.backgroundColorButton {
            var color = self.backgroundColorButton.backgroundColor!
            color.getRed(&r, green: &g, blue: &b, alpha: &a)
            defaults.setObject([r, g, b, a], forKey: "BackgroundColor")
        }
        
        defaults.synchronize()
    }
    
    // Override the iPhone behavior that presents a popover as fullscreen
    func adaptivePresentationStyleForPresentationController(controller: UIPresentationController!) -> UIModalPresentationStyle {
        // Return no adaptive presentation style, use default presentation behaviour
        return .None
    }
}
