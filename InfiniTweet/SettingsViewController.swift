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
    @IBOutlet weak var textColorButton: UIButton!
    @IBOutlet weak var backgroundColorButton: UIButton!
    @IBOutlet weak var wordmarkHiddenSwitch: UISwitch!
    @IBOutlet weak var alignmentControl: UISegmentedControl!
    
    override func viewWillAppear(animated: Bool) {
        var defaults = NSUserDefaults(suiteName: "group.Codes.Ruben.InfinitweetPro")!
        
        let alignment = defaults.objectForKey("Alignment") as String
        let fontName = defaults.objectForKey("FontName") as String
        let fontSize = defaults.integerForKey("FontSize") as Int
        
        var colorArray = defaults.objectForKey("TextColor") as [CGFloat]
        let color = colorArray.toUIColor()
        var backgroundColorArray = defaults.objectForKey("BackgroundColor") as [CGFloat]
        let backgroundColor = backgroundColorArray.toUIColor()
        
        let wordmark = defaults.boolForKey("WordmarkHidden")
        
        //select correct alignment
        for segmentIndex in 0..<alignmentControl.numberOfSegments {
            if alignmentControl.titleForSegmentAtIndex(segmentIndex) == alignment {
                alignmentControl.selectedSegmentIndex = segmentIndex
            }
        }
        
        //select correct font
        for segmentIndex in 0..<fontControl.numberOfSegments {
            if fontControl.titleForSegmentAtIndex(segmentIndex) == fontName {
                fontControl.selectedSegmentIndex = segmentIndex
            }
        }
        
        fontSizeSlider.value = Float(fontSize)
        fontSizeLabel.text = "\(fontSize)px"
        textColorButton.backgroundColor = color
        backgroundColorButton.backgroundColor = backgroundColor
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
        let fontName = sender.titleForSegmentAtIndex(sender.selectedSegmentIndex) as String!
        defaults.setObject(fontName, forKey: "FontName")
        defaults.synchronize()
    }
    
    @IBAction func fontSizeDidChange(sender: UISlider) {
        var defaults = NSUserDefaults(suiteName: "group.Codes.Ruben.InfinitweetPro")!
        let size = Int(round(sender.value))
        defaults.setInteger(size, forKey: "FontSize")
        defaults.synchronize()
        
        fontSizeLabel.text = "\(size)px"
    }
    
    @IBAction func alignmentDidChange(sender: UISegmentedControl) {
        var defaults = NSUserDefaults(suiteName: "group.Codes.Ruben.InfinitweetPro")!
        let alignment = sender.titleForSegmentAtIndex(sender.selectedSegmentIndex) as String!
        defaults.setObject(alignment, forKey: "Alignment")
        defaults.synchronize()
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
        if (object as UIButton) == self.textColorButton || (object as UIButton) == self.backgroundColorButton {
            var defaults = NSUserDefaults(suiteName: "group.Codes.Ruben.InfinitweetPro")!
            
            //empty rgba pointers, to be initialized by color
            var r = CGFloat()
            var g = CGFloat()
            var b = CGFloat()
            var a = CGFloat()
            
            if (object as UIButton) == self.textColorButton {
                let color = self.textColorButton.backgroundColor!
                color.getRed(&r, green: &g, blue: &b, alpha: &a)
                defaults.setObject([r, g, b, a], forKey: "TextColor")
            } else if (object as UIButton) == self.backgroundColorButton {
                let color = self.backgroundColorButton.backgroundColor!
                color.getRed(&r, green: &g, blue: &b, alpha: &a)
                defaults.setObject([r, g, b, a], forKey: "BackgroundColor")
            }
            
            defaults.synchronize()
        }
    }
    
    // Override the iPhone behavior that presents a popover as fullscreen
    func adaptivePresentationStyleForPresentationController(controller: UIPresentationController!) -> UIModalPresentationStyle {
        // Return no adaptive presentation style, use default presentation behaviour
        return .None
    }
}
