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
    
    override func viewWillAppear(animated: Bool) {
        var defaults = NSUserDefaults(suiteName: "group.Codes.Ruben.InfinitweetPro")!
        
        var fontName = defaults.objectForKey("DefaultFont") as String
        var fontSize = defaults.objectForKey("DefaultFontSize") as CGFloat
        
        var colorString = defaults.objectForKey("DefaultColor") as String
        var color = colorString.hexStringToUIColor()
        var backgroundColorString = defaults.objectForKey("DefaultBackgroundColor") as String
        var backgroundColor = backgroundColorString.hexStringToUIColor()
        var padding = defaults.floatForKey("DefaultPadding")
        
        
        for segmentIndex in 0..<fontControl.numberOfSegments {
            if fontControl.titleForSegmentAtIndex(segmentIndex) == fontName {
                fontControl.selectedSegmentIndex = segmentIndex
            }
        }
        fontSizeSlider.value = Float(fontSize)
        fontSizeLabel.text = "\(round(fontSize*10)/10)px"
        textColorButton.backgroundColor = color
        backgroundColorButton.backgroundColor = backgroundColor
        paddingSlider.value = padding
        paddingLabel.text = "\(round(padding*10)/10)px"
        
        super.viewWillAppear(animated)
    }
    
    @IBAction func fontDidChange(sender: UISegmentedControl) {
        var defaults = NSUserDefaults(suiteName: "group.Codes.Ruben.InfinitweetPro")!
        var fontName = sender.titleForSegmentAtIndex(sender.selectedSegmentIndex) as String!
        defaults.setObject(fontName, forKey: "DefaultFont")
        defaults.synchronize()
    }
    
    @IBAction func fontSizeDidChange(sender: UISlider) {
        var defaults = NSUserDefaults(suiteName: "group.Codes.Ruben.InfinitweetPro")!
        defaults.setObject(CGFloat(sender.value), forKey: "DefaultFontSize")
        defaults.synchronize()
        
        fontSizeLabel.text = "\(round(sender.value*10)/10)px"
    }
    
    @IBAction func paddingDidChange(sender: UISlider) {
        var defaults = NSUserDefaults(suiteName: "group.Codes.Ruben.InfinitweetPro")!
        defaults.setFloat(sender.value, forKey: "DefaultPadding")
        defaults.synchronize()
        
        paddingLabel.text = "\(round(sender.value*10)/10)px"
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
            popoverVC.delegate = self
        }
        presentViewController(popoverVC, animated: true, completion: nil)
    }
    
    func setColor(tag: Int, hexString: String) {
        var colorString = hexString
        var defaults = NSUserDefaults(suiteName: "group.Codes.Ruben.InfinitweetPro")!
        switch tag {
        case textColorButton.tag:
            textColorButton.backgroundColor = colorString.hexStringToUIColor()
            defaults.setObject(hexString, forKey: "DefaultColor")
            defaults.synchronize()
        case backgroundColorButton.tag:
            backgroundColorButton.backgroundColor = colorString.hexStringToUIColor()
            defaults.setObject(hexString, forKey: "DefaultBackgroundColor")
            defaults.synchronize()
        default:
            break
        }
    }
    
    // Override the iPhone behavior that presents a popover as fullscreen
    func adaptivePresentationStyleForPresentationController(controller: UIPresentationController!) -> UIModalPresentationStyle {
        // Return no adaptive presentation style, use default presentation behaviour
        return .None
    }
}
