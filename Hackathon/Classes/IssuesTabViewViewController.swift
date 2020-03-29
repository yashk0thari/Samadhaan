//
//  IssuesTabViewViewController.swift
//  Hackathon
//
//  Created by Valley on 12/20/18.
//  Copyright © 2018 Samyak Jain. All rights reserved.
//

import UIKit
import FirebaseAuth

class IssuesTabViewViewController: UIViewController {

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
        performSegue(withIdentifier: "goToIssueTableView", sender: self)
    }
    
    @IBAction func pollutionClicked(_ sender: UIButton) {
        category = "Pollution"
        performSegue(withIdentifier: "goToIssueTableView", sender: self)
    }
    
    @IBAction func garbageClicked(_ sender: UIButton) {
        category = "Garbage"
        performSegue(withIdentifier: "goToIssueTableView", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destinationVC = segue.destination as! IssuesViewController
        
        destinationVC.category = category
    }

}
