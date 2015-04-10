//
//  PresentationViewController.swift
//  InfiniTweet
//
//  Created by Ruben on 2/7/15.
//  Copyright (c) 2015 Ruben. All rights reserved.
//

import WatchKit
import Social
import Accounts

class PresentationViewController: WKInterfaceController {
    var imageToShare : UIImage?
    @IBOutlet weak var wkImage: WKInterfaceImage!
    
    override func awakeWithContext(context: AnyObject?) {
        super.awakeWithContext(context)
        
        // Configure interface objects here.
        if context != nil && context!.objectForKey("image") != nil {
            self.imageToShare = (context!.objectForKey("image") as! UIImage)
            self.wkImage.setImage(self.imageToShare)
        }
    }
    
    @IBAction func share() {
        let accountStore = ACAccountStore()
        let accountType = accountStore.accountTypeWithAccountTypeIdentifier(ACAccountTypeIdentifierTwitter)
        
        // Prompt the user for permission to their twitter account stored in the phone's settings
        accountStore.requestAccessToAccountsWithType(accountType, options: nil) {
            granted, error in
            
            if granted {
                let twitterAccounts = accountStore.accountsWithAccountType(accountType)
                
                if twitterAccounts.count == 0 {
                    println("No Twitter Accounts")
                }
                else { //success!
                    var defaults = NSUserDefaults.standardUserDefaults()
                    defaults.setBool(true, forKey: "permissionsGranted")
                    defaults.synchronize()
                    
                    if twitterAccounts.count > 1 {
                        self.pushControllerWithName("AccountSelection", context: ["accounts": twitterAccounts, "image" : self.imageToShare!])
                    } else {
                        self.postImageToTwitterAccount(twitterAccounts.first as! ACAccount)
                    }
                }
            }
            else {
                println("Access Not Granted")
            }
        }
    }
    
    func postImageToTwitterAccount(account : ACAccount) {
        if self.imageToShare != nil {
            let requestURL = NSURL(string: "https://api.twitter.com/1.1/statuses/update_with_media.json")
            
            var postRequest = SLRequest(forServiceType: SLServiceTypeTwitter, requestMethod: SLRequestMethod.POST, URL: requestURL, parameters: nil)
            postRequest.addMultipartData(UIImageJPEGRepresentation(self.imageToShare!, 1.0), withName: "media[]", type: "multipart/form-data", filename: nil)
            postRequest.addMultipartData("".dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false), withName: "status", type: "multipart/form-data", filename: nil)
            
            postRequest.account = account
            postRequest.performRequestWithHandler({ (responseData, urlResponse, error) -> Void in
                if error == nil {
                    println(NSJSONSerialization.JSONObjectWithData(responseData, options: nil, error: nil))
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
}
