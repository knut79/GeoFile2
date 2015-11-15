//
//  LoginViewController.swift
//  GeoFile
//
//  Created by knut on 13/11/15.
//  Copyright © 2015 knut. All rights reserved.
//

import Foundation

import UIKit
import UIKit
import FBSDKLoginKit

class LoginViewController: UIViewController,FBSDKLoginButtonDelegate
{

    
    var userName:String!
    var userId:String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if (FBSDKAccessToken.currentAccessToken() != nil)
        {
            // User is already logged in, do work such as go to next view controller.
            //self.performSegueWithIdentifier("segueFromLoginToPlay", sender: nil)
            
            initUserData({() -> Void in
                self.performSegueWithIdentifier("SequeFromLoginToMap", sender: nil)
            })
            
        }
        else
        {
            let loginButton: FBSDKLoginButton = FBSDKLoginButton()
            // Optional: Place the button in the center of your view.
            loginButton.center = self.view.center
            loginButton.delegate = self
            loginButton.readPermissions = ["public_profile", "user_friends"]
            self.view.addSubview(loginButton)
        }
    }
    
    func loginButton(loginButton: FBSDKLoginButton!, didCompleteWithResult result: FBSDKLoginManagerLoginResult!, error: NSError!) {
        if ((error) != nil)
        {
            // Process error
        }
        else if result.isCancelled {
            // Handle cancellations
        }
        else {
            initUserData({() -> Void in
                self.performSegueWithIdentifier("SequeFromLoginToMap", sender: nil)
            })

        }
    }
    
    func initUserData(completion: (() -> (Void)))
    {
        let graphRequest : FBSDKGraphRequest = FBSDKGraphRequest(graphPath: "me", parameters: ["fields": "email, friends"])
        graphRequest.startWithCompletionHandler({ (connection, result, error) -> Void in
            
            if ((error) != nil)
            {
                // Process error
                print("Error: \(error)")
                completion()
            }
            else
            {
                print("fetched user: \(result)")
                let userName : String = result.valueForKey("name") as! String
                print("User Name is: \(userName)")
                self.userName = userName
                let userId2 = result.valueForKey("id") as! String
                print("UserId2 is: \(userId2)")
                self.userId = userId2
                //self.userId = "1492605914370841"
                //self.userId = "10155943015600858"
                
                result
                
                completion()
                /*
                self.updateUser({() -> Void in
                    completion()
                })
                */
            }
        })
    }
    
    
    func loginButtonDidLogOut(loginButton: FBSDKLoginButton!) {
        
        
    }


}