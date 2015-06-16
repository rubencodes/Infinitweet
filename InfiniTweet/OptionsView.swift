//
//  OptionsView.swift
//  InfiniTweet
//
//  Created by Ruben on 6/9/15.
//  Copyright (c) 2015 Ruben. All rights reserved.
//

import Foundation
import UIKit
import QuartzCore

class OptionsView : UIView, TextOptionsDelegate, ColorOptionsViewDelegate {
    var minSize = CGRectMake(0, 0, 300, 274)
    var delegate : OptionsViewDelegate!
    var visibleColorOptions : [ColorOptionsView] = []

    @IBOutlet var colorLabel : UILabel!
    @IBOutlet var backgroundLabel : UILabel!
    @IBOutlet var highlightLabel : UILabel!
    @IBOutlet var boldButton : UIButton!
    @IBOutlet var italicsButton : UIButton!
    @IBOutlet var underlineButton : UIButton!
    @IBOutlet var alignmentControl : UISegmentedControl!
    @IBOutlet var fontControl : UISegmentedControl!
    @IBOutlet var highlightRow : UIView!
    @IBOutlet var colorRow : UIView!
    @IBOutlet var backgroundRow : UIView!
    
    var currentFontSize : Double = 500.0
    
    @IBAction func formatButtonTapped(sender : UIButton) {
        self.delegate.formatSelectedText(TextFormat(rawValue: sender.tag)!)
    }
    
    @IBAction func changeFontSizeButtonTapped(sender : UIStepper) {
        if currentFontSize < sender.value {
            self.delegate.changedFontSizeForSelectedText(increased: true)
        } else if currentFontSize > sender.value {
            self.delegate.changedFontSizeForSelectedText(increased: false)
        }
        
        currentFontSize = sender.value
    }
    
    @IBAction func colorButtonTapped(sender : UITapGestureRecognizer) {
        if visibleColorOptions.count > 0 {
            self.hideColorOptionsView(visibleColorOptions.first!)
        }
        
        var row : UIView?
        var attribute : ColorAttribute?
        
        switch ColorAttribute(rawValue: sender.view!.tag)! {
        case ColorAttribute.Text:
            row = self.colorRow
            attribute = ColorAttribute.Text
        case ColorAttribute.Background:
            row = self.backgroundRow
            attribute = ColorAttribute.Background
        case ColorAttribute.Highlight:
            row = self.highlightRow
            attribute = ColorAttribute.Highlight
        }
        
        if row != nil && attribute != nil {
            showColorOptionsViewInPlaceOfRow(row!, tag: attribute!.rawValue)
        }
    }
    
    @IBAction func fontChanged(sender : UISegmentedControl) {
        var newFont : UIFont?
        switch Font(rawValue: sender.selectedSegmentIndex)! {
        case Font.Sans:
            newFont = UIFont(name: "Helvetica", size: 12)
        case Font.Serif:
            newFont = UIFont(name: "Times New Roman", size: 12)
        case Font.Mono:
            newFont = UIFont(name: "Courier New", size: 12)
        }
        
        self.delegate.changedFontForSelectedText(newFont!)
    }
    
    @IBAction func alignmentChanged(sender : UISegmentedControl) {
        self.delegate.changedAlignmentForSelectedText(Alignment(rawValue: sender.selectedSegmentIndex)!)
    }
    
    func selectedTextHasProperties(font : UIFont, alignment : NSTextAlignment, highlight : UIColor?, color : UIColor, background : UIColor) {
        
        if font.familyName == "Helvetica" {
            fontControl.selectedSegmentIndex = Font.Sans.rawValue
        } else if font.familyName == "Times New Roman" {
            fontControl.selectedSegmentIndex = Font.Serif.rawValue
        } else {
            fontControl.selectedSegmentIndex = Font.Mono.rawValue
        }
        
        alignmentControl.selectedSegmentIndex = alignment.rawValue
                
        self.highlightLabel!.text = highlight != nil ? highlight!.colorName() : "Transparent"
        self.colorLabel!.text = color.colorName()
        self.backgroundLabel!.text = background.colorName()
        
//        if contains(formatting, TextFormat.Bold) {
//            boldButton!.backgroundColor = UIColor.darkGrayColor()
//            boldButton!.tintColor = UIColor.whiteColor()
//        } else {
//            boldButton!.backgroundColor = UIColor(white: 5/255, alpha: 0.03)
//            boldButton!.tintColor = UIColor.darkGrayColor()
//        }
//        
//        if contains(formatting, TextFormat.Italics) {
//            italicsButton!.backgroundColor = UIColor.darkGrayColor()
//            italicsButton!.tintColor = UIColor.whiteColor()
//        } else {
//            italicsButton!.backgroundColor = UIColor(white: 5/255, alpha: 0.03)
//            italicsButton!.tintColor = UIColor.darkGrayColor()
//        }
//        
//        if contains(formatting, TextFormat.Underline) {
//            underlineButton!.backgroundColor = UIColor.darkGrayColor()
//            underlineButton!.tintColor = UIColor.whiteColor()
//        } else {
//            underlineButton!.backgroundColor = UIColor(white: 5/255, alpha: 0.03)
//            underlineButton!.tintColor = UIColor.darkGrayColor()
//        }
    }
    
    func colorWasSelected(color: UIColor, sender: ColorOptionsView) {
        self.delegate.changedColorTo(color, forColorAttribute: ColorAttribute(rawValue: sender.tag)!)
        
        hideColorOptionsView(sender)
    }
    
    func showColorOptionsViewInPlaceOfRow(row : UIView, tag : Int) {
        let colorOptionsView = NSBundle.mainBundle().loadNibNamed("ColorOptionsView", owner: self, options: nil).first as! ColorOptionsView
        
        colorOptionsView.delegate = self
        colorOptionsView.tag = tag
        colorOptionsView.frame = CGRectMake(row.frame.width, row.frame.origin.y, row.frame.width, row.frame.height)
        self.addSubview(colorOptionsView)
        visibleColorOptions.append(colorOptionsView)
        
        let animation = POPSpringAnimation(propertyNamed: kPOPViewCenter)
        animation.toValue = NSValue(CGPoint: CGPointMake(row.center.x, row.center.y))
        colorOptionsView.pop_addAnimation(animation, forKey: "colorsIn")
    }
    
    func hideColorOptionsView(view : ColorOptionsView) {        
        let animation = POPSpringAnimation(propertyNamed: kPOPViewCenter)
        animation.toValue = NSValue(CGPoint: CGPointMake(view.center.x + view.frame.size.width, view.center.y))
        animation.completionBlock = { animation, finished in
            view.removeFromSuperview()
            self.visibleColorOptions.removeAtIndex(0)
        }
        view.pop_addAnimation(animation, forKey: "colorsOut")
    }
}

enum Font: Int {
    case Sans = 0
    case Serif = 1
    case Mono = 2
}

enum Alignment: Int {
    case Left = 0
    case Center = 1
    case Right = 2
    case Justify = 3
}

enum TextFormat: Int {
    case Bold = 0
    case Italics = 1
    case Underline = 2
}

enum ColorAttribute: Int {
    case Text = 0
    case Background = 1
    case Highlight = 2
}

protocol TextOptionsDelegate {
    func selectedTextHasProperties(font : UIFont, alignment : NSTextAlignment, highlight : UIColor?, color : UIColor, background : UIColor)
}

protocol OptionsViewDelegate {
    func formatSelectedText(format : TextFormat)
    func changedFontSizeForSelectedText(increased increased : Bool)
    func changedAlignmentForSelectedText(newAlignment : Alignment)
    func changedFontForSelectedText(newFont : UIFont)
    func changedColorTo(color : UIColor, forColorAttribute attribute : ColorAttribute)
}