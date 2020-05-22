//
//  WelcomeViewController.swift
//  Hackathon
//
//  Created by Aashrit Garg on 12/20/18.
//  Copyright © 2018 Samyak Jain. All rights reserved.
//

import UIKit
import Firebase
import GoogleSignIn
import FirebaseAuth
import SVProgressHUD

class WelcomeViewController: UIViewController, GIDSignInDelegate {
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        weak var googleLoginView: GIDSignInButton!
        
        func viewDidLoad() {
            super.viewDidLoad()

            SVProgressHUD.dismiss()
            
            //Set self as delegate and initiate views
            GIDSignIn.sharedInstance().presentingViewController = self
            googleLoginView.frame = CGRect(x: 13, y: view.frame.height - 60, width: view.frame.width - 26, height: 50)
            
            if Auth.auth().currentUser != nil {
                
                // User is signed in.
                self.performSegue(withIdentifier: "goToHomePage", sender: self)
            }
            
        }
    }
    



}
