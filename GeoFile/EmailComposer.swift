//
//  EmailComposer.swift
//  GeoFile
//
//  Created by knut on 15/06/15.
//  Copyright (c) 2015 knut. All rights reserved.
//

import Foundation
import MessageUI

class EmailComposer: NSObject, MFMailComposeViewControllerDelegate {
    // Did this in order to mitigate needing to import MessageUI in my View Controller
    func canSendMail() -> Bool {
        return MFMailComposeViewController.canSendMail()
    }
    
    func configuredMailComposeViewController() -> MFMailComposeViewController {
        let mailComposerVC = MFMailComposeViewController()
        mailComposerVC.mailComposeDelegate = self
        
        mailComposerVC.setToRecipients(["lambchopnot@hotmail.com"])
        mailComposerVC.setSubject("Skjema sendt fra GeoFile")
        mailComposerVC.setMessageBody("Sending e-mail in-app is not so bad!", isHTML: false)

        //mailComposerVC.addAttachmentData(<#attachment: NSData!#>, mimeType: <#String!#>, fileName: <#String!#>)
        
        return mailComposerVC
    }
    
    // MARK: MFMailComposeViewControllerDelegate Method
    func mailComposeController(controller: MFMailComposeViewController, didFinishWithResult result: MFMailComposeResult, error: NSError?) {
        controller.dismissViewControllerAnimated(true, completion: nil)
    }
}