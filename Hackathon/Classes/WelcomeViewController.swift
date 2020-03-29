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

class WelcomeViewController: UIViewController, GIDSignInUIDelegate {

    @IBOutlet weak var googleLoginView: GIDSignInButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        SVProgressHUD.dismiss()
        
        //Set self as delegate and initiate views
        GIDSignIn.sharedInstance().uiDelegate = self
        googleLoginView.frame = CGRect(x: 13, y: view.frame.height - 60, width: view.frame.width - 26, height: 50)
        
        if Auth.auth().currentUser != nil {
            
            // User is signed in.
            self.performSegue(withIdentifier: "goToHomePage", sender: self)
        }
        
    }

}
