/*
ColorPickerViewController.swift
Created by Ethan Strider on 11/28/14.
The MIT License (MIT)
Copyright (c) 2014 Ethan Strider
Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:
The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.
THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.
*/

import UIKit

class ColorPickerViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    // Global variables
    var tag: Int = 0
    var callerTag: Int?
    var color: UIColor = UIColor.grayColor()
    var delegate: SettingsViewController? = nil
    
    // UICollectionViewDataSource Protocol:
    // Returns the number of rows in collection view
    internal func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 10
    }
    // UICollectionViewDataSource Protocol:
    // Returns the number of columns in collection view
    internal func numberOfSectionsInCollectionView(collectionView: UICollectionView!) -> Int {
        return 16
    }
    // UICollectionViewDataSource Protocol:
    // Inilitializes the collection view cells
    internal func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        var cell = collectionView.dequeueReusableCellWithReuseIdentifier("Cell", forIndexPath: indexPath) as UICollectionViewCell
        cell.backgroundColor = UIColor.clearColor()
        cell.tag = tag++
        
        return cell
    }
    
    // Recognizes and handles when a collection view cell has been selected
    internal func collectionView(collectionView: UICollectionView!, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        
        var colorPalette: Array<String>
        
        // Get colorPalette array from plist file
        let path = NSBundle.mainBundle().pathForResource("colorPalette", ofType: "plist")
        let pListArray = NSArray(contentsOfFile: path!)
        
        if let colorPalettePlistFile = pListArray {
            colorPalette = colorPalettePlistFile as [String]
            
            var cell: UICollectionViewCell  = collectionView.cellForItemAtIndexPath(indexPath)! as UICollectionViewCell
            var hexString = colorPalette[cell.tag]
            color = hexString.hexStringToUIColor()
            self.view.backgroundColor = color
            delegate?.setColor(callerTag!, hexString: hexString)
        }
    }
}