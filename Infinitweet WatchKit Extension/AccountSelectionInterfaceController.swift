//
//  AccountSelectionInterfaceController.swift
//  InfiniTweet
//
//  Created by Ruben on 2/7/15.
//  Copyright (c) 2015 Ruben. All rights reserved.
//

import WatchKit
import Foundation
import Accounts

protocol AccountSelectionDelegate {
    func postImageToAccount(account : ACAccount)
}

class AccountSelectionInterfaceController: WKInterfaceController {
    @IBOutlet var menu : WKInterfaceTable!
    var accounts : [ACAccount]?
    var delegate : AccountSelectionDelegate?
    
    override func awakeWithContext(context: AnyObject?) {
        super.awakeWithContext(context)
                
        // Configure interface objects here.
        if context != nil {
            self.accounts = context!.objectForKey("accounts") as? [ACAccount]
            self.delegate = (context!.objectForKey("delegate") as! PresentationViewController)
            self.menu.setNumberOfRows(self.accounts!.count, withRowType: "AccountRow")
            for var i = 0; i < self.menu.numberOfRows; i++ {
                var row = menu.rowControllerAtIndex(i) as! AccountRow
                row.name.setText("@\(self.accounts![i].username)")
            }
        }
    }
    
    override func table(table: WKInterfaceTable, didSelectRowAtIndex rowIndex: Int) {
        delegate?.postImageToAccount(self.accounts![rowIndex])
        self.dismissController()
    }

    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
    }

    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }

    
}
