//
//  ColorOptionsView.swift
//  InfiniTweet
//
//  Created by Ruben on 6/10/15.
//  Copyright (c) 2015 Ruben. All rights reserved.
//

import Foundation
import UIKit

class ColorOptionsView: UIView {
    var delegate : ColorOptionsViewDelegate!
    
    @IBAction func colorTapped(sender: UITapGestureRecognizer) {
        delegate.colorWasSelected(sender.view!.backgroundColor!, sender: self)
    }
}

protocol ColorOptionsViewDelegate {
    func colorWasSelected(color : UIColor, sender : ColorOptionsView)
}

extension UIColor {
    convenience init(rgbaArray : [CGFloat]) {
        self.init(red: rgbaArray[0], green: rgbaArray[1], blue: rgbaArray[2], alpha: rgbaArray[3])
    }
    
    func colorName() -> String? {
        let currentColor = self.toCGFloatArray()
        
        let black   = [0.0, 0.0, 0.0, 1.0] as [CGFloat]
        let white   = [1.0, 1.0, 1.0, 1.0] as [CGFloat]
        let red     = [250/255, 60/255, 60/255, 1.0] as [CGFloat]
        let orange  = [255/255, 180/255, 0, 1.0]     as [CGFloat]
        let yellow  = [255/255, 255/255, 30/255, 1.0] as [CGFloat]
        let green   = [30/255, 200/255, 0/255, 1.0] as [CGFloat]
        let blue    = [0/255, 130/255, 255/255, 1.0] as [CGFloat]
        let pink    = [255/255, 110/255, 210/255, 1.0] as [CGFloat]
        let alpha   = [1.0, 1.0, 1.0, 0.0] as [CGFloat]
        
        if currentColor == black {
            return "Black"
        } else if currentColor == white {
            return "White"
        } else if currentColor == red {
            return "Red"
        } else if currentColor == blue {
            return "Blue"
        } else if currentColor == pink {
            return "Pink"
        } else if currentColor == green {
            return "Green"
        } else if currentColor == orange {
            return "Orange"
        } else if currentColor == yellow {
            return "Yellow"
        } else if currentColor == alpha {
            return "Transparent"
        } else {
            return nil
        }
    }
}