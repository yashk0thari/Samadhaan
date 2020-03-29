//
//  ViewController.swift
//  Hackathon
//
//  Created by Samyak Jain  on 12/20/18.
//  Copyright © 2018 Samyak Jain. All rights reserved.
//

import UIKit
import FirebaseAuth
import CoreLocation

class ViewController: UIViewController, CLLocationManagerDelegate {
    
    var category = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    @IBAction func logOutButtonAction(_ sender: UIBarButtonItem) {
        let firebaseAuth = Auth.auth()
        do {
            try firebaseAuth.signOut()
            self.dismiss(animated: true, completion: nil)
            
        } catch let signOutError as NSError {
            print ("Error signing out: %@", signOutError)
        }
        
    }
    
    
    @IBAction func constructionClicked(_ sender: UIButton) {
        category = "Construction"
        performSegue(withIdentifier: "goToFileComplaint", sender: self)
    }
    
    @IBAction func pollutionClicked(_ sender: UIButton) {
        category = "Pollution"
        performSegue(withIdentifier: "goToFileComplaint", sender: self)
    }
    
    @IBAction func garbageClicked(_ sender: UIButton) {
        category = "Garbage"
        performSegue(withIdentifier: "goToFileComplaint", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destinationVC = segue.destination as! FileComplaintViewController
        
        destinationVC.category = category
    }
    
}

