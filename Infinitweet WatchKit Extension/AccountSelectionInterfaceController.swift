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
import Social


class AccountSelectionInterfaceController: WKInterfaceController {
    @IBOutlet var menu : WKInterfaceTable!
    var twitterAccounts : [ACAccount]?
    var imageToShare : UIImage?
    
    override func awakeWithContext(context: AnyObject?) {
        super.awakeWithContext(context)
                
        // Configure interface objects here.
        self.twitterAccounts = context!.objectForKey("accounts") as? [ACAccount]
        self.imageToShare = (context!.objectForKey("image") as UIImage)
        self.menu.setNumberOfRows(self.twitterAccounts!.count, withRowType: "AccountRow")
        for var i = 0; i < self.menu.numberOfRows; i++ {
            var row = menu.rowControllerAtIndex(i) as AccountRow
            row.name.setText("@\(self.twitterAccounts![i].username)")
        }
    }
    
    override func table(table: WKInterfaceTable, didSelectRowAtIndex rowIndex: Int) {
        if self.imageToShare != nil {
            let requestURL = NSURL(string: "https://api.twitter.com/1.1/statuses/update_with_media.json")
            
            var postRequest = SLRequest(forServiceType: SLServiceTypeTwitter, requestMethod: SLRequestMethod.POST, URL: requestURL, parameters: nil)
            postRequest.addMultipartData(UIImageJPEGRepresentation(self.imageToShare!, 1.0), withName: "media[]", type: "multipart/form-data", filename: nil)
            postRequest.addMultipartData("".dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false), withName: "status", type: "multipart/form-data", filename: nil)
            
            postRequest.account = self.twitterAccounts![rowIndex]
            postRequest.performRequestWithHandler({ (responseData, urlResponse, error) -> Void in
                if error == nil {
                    NSNotificationCenter.defaultCenter().postNotificationName("FinishedTweet",
                        object: nil,
                        userInfo: nil)
                    self.popToRootController()
                } else {
                    println(error)
                    self.popToRootController()
                }
            })
        }
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
