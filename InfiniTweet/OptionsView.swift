//
//  OptionsView.swift
//  InfiniTweet
//
//  Created by Ruben on 6/9/15.
//  Copyright (c) 2015 Ruben. All rights reserved.
//

import Foundation
import UIKit

class OptionsView : UIView, TextOptionsDelegate {
    var minSize = CGRectMake(0, 0, 300, 300)
    var delegate : OptionsViewDelegate!
    @IBOutlet var fontLabel : UILabel!
    @IBOutlet var colorLabel : UILabel!
    @IBOutlet var backgroundLabel : UILabel!
    @IBOutlet var highlightLabel : UILabel!
    @IBOutlet var boldButton : UIButton!
    @IBOutlet var italicsButton : UIButton!
    @IBOutlet var underlineButton : UIButton!
    @IBOutlet var alignmentControl : UISegmentedControl!
    
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
    
    @IBAction func highlightButtonTapped() {
        
    }
    
    @IBAction func fontColorButtonTapped() {
    
    }
    
    @IBAction func fontButtonTapped() {
    
    }
    
    @IBAction func alignmentChanged(sender : UISegmentedControl) {
        self.delegate.changedAlignmentForSelectedText(Alignment(rawValue: sender.selectedSegmentIndex)!)
    }
    
    func selectedTextHasProperties(font : UIFont, alignment : NSTextAlignment, highlight : UIColor?, color : UIColor, background : UIColor) {
        self.fontLabel!.text = font.familyName
        
        switch alignment {
        case NSTextAlignment.Left:
            alignmentControl.selectedSegmentIndex = 0
        case NSTextAlignment.Center:
            alignmentControl.selectedSegmentIndex = 1
        case NSTextAlignment.Right:
            alignmentControl.selectedSegmentIndex = 2
        case NSTextAlignment.Justified:
            alignmentControl.selectedSegmentIndex = 3
        default:
            alignmentControl.selectedSegmentIndex = 0
        }
        
        self.highlightLabel!.text = highlight != nil ? highlight?.colorName() : "No Highlight"
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
}

extension UIColor {
    func colorName() -> String? {
        let color = self.toCGFloatArray()
        
        let black = [0, 0, 0] as [CGFloat]
        let white = [1, 1, 1] as [CGFloat]
        let red   = [255/255, 60/255, 60/255]
        let blue  = [0/255, 130/255, 255/255]
        let pink  = [255/255, 110/255, 210/255]
        let green = [30/255, 200/255, 0/255]
        let orange = [255/255, 180/25, 0]
        let yellow = [255/255, 255/255, 30/255]
        
        if color == black {
            return "Black"
        } else if color == white {
            return "White"
        } else if color == red {
            return "Red"
        } else if color == blue {
            return "Blue"
        } else if color == pink {
            return "Pink"
        } else if color == green {
            return "Green"
        } else if color == orange {
            return "Orange"
        } else if color == yellow {
            return "Yellow"
        } else {
            return nil
        }
    }
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

protocol TextOptionsDelegate {
    func selectedTextHasProperties(font : UIFont, alignment : NSTextAlignment, highlight : UIColor?, color : UIColor, background : UIColor)
}

protocol OptionsViewDelegate {
    func formatSelectedText(format : TextFormat)
    func changedFontSizeForSelectedText(#increased : Bool)
    func changedAlignmentForSelectedText(newAlignment : Alignment)
    
    func highlightSelectedText()
    func colorSelectedText()
    func changeBackgroundColor()
}