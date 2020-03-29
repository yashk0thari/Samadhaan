//
//  IssuesViewController.swift
//  Hackathon
//
//  Created by Aashrit Garg on 12/20/18.
//  Copyright © 2018 Samyak Jain. All rights reserved.
//

import UIKit
import Firebase
import Alamofire
import AlamofireImage
import SVProgressHUD
import FirebaseFirestore
import FirebaseAuth
import FBSDKLoginKit
import CoreLocation
import MobileCoreServices

class IssuesViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
//    var setImage:UIImage? = nil
    var category: String?

    @IBOutlet var issuesTableView: UITableView!
    
    var issues = [Issue]()
    let db = Firestore.firestore()
    var index : Int?
    var docID = [String]()
    
    let locationManager = CLLocationManager()
    var globalLat = 0.0
    var globalLon = 0.0
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return issues.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "issueCell", for: indexPath) as! IssueTableViewCell
        if issues.count != 0 {
            let issue : Issue = issues[indexPath.row]
            cell.nameLabel.text = issue.name
            
            Alamofire.request(issue.mediaURL!).responseImage { response in
                debugPrint(response)
                
                if let image = response.result.value {
                    
                    if self.issues[indexPath.row].media_type == "Image" {

//                        print("LOLOLOLOLOL")
                        cell.issueImageView.image = image
                        cell.issueImageView.layer.cornerRadius = 10
                        cell.issueImageView.layer.masksToBounds = true
                        SVProgressHUD.dismiss()
                    }
                }
            }
            
            if self.issues[indexPath.row].media_type == "Movie" {
                
//                print("CALLED!!")
                cell.issueImageView.image = UIImage(named: "video")
                SVProgressHUD.dismiss()
            }
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        index = indexPath.row
        SVProgressHUD.dismiss()
        
        self.performSegue(withIdentifier: "goToIssueDetail", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destinationVC = segue.destination as! DetailViewController
        destinationVC.issue = issues[index!]
        destinationVC.docID = docID[index!]
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        SVProgressHUD.show()
        
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestAlwaysAuthorization()
        locationManager.startUpdatingLocation()

        issuesTableView.delegate = self
        issuesTableView.dataSource = self
        issuesTableView.rowHeight = 240
        // Do any additional setup after loading the view.
        
        db.collection("Issues").whereField("category", isEqualTo: category!).addSnapshotListener { documentSnapshot, error in
            guard let documents = documentSnapshot?.documents else {
                print("Error fetching document changes: \(error!)")
                return
            }
            for i in 0 ..< documents.count {
                let documentID = documents[i].documentID
                self.getIssueFromDoc(documentID: documentID)
            }
        }
    }
    
    func getIssueFromDoc(documentID : String) {
        
        let docRef = db.collection("Issues").document(documentID)
        
        docRef.getDocument { (document, error) in
            
            if let document = document, document.exists {
                let dataDescription = document.data()
                
                let issue : Issue = Issue(
                    name: dataDescription!["name"] as? String ?? "",
                    latitude: dataDescription!["latitude"] as? Double ?? 1.0,
                    longitude: dataDescription!["longitude"] as? Double ?? 1.0,
                    mediaURL: dataDescription!["mediaURL"] as? String ?? "",
                    description: dataDescription!["description"] as? String ?? "",
                    category: dataDescription!["category"] as? String ?? "",
                    mostViewed: true,
                    concerns: dataDescription!["concerns"] as? Int ?? 1,
                    email: dataDescription!["email"] as? String ?? "",
                    media_type: dataDescription!["mediaType"] as? String ?? "")
                self.issues.append(issue)
                self.docID.append(documentID)
                
//                print("----------> \(issue.media_type ?? "Not Found")")
                
                self.issuesTableView.reloadData()
                
            } else {
                print("Document does not exist")
            }
        }
    }
    
    @IBAction func customizeButtonPressed(_ sender: UIBarButtonItem) {
        
        let issues2 = issues
        issues = [Issue]()
        
        for issue in issues2 {
            let coordinate1 = CLLocation(latitude: Double(issue.latitude!), longitude: Double(issue.longitude!))
            let coordinate2 = CLLocation(latitude: globalLat, longitude: globalLon)
            
            let distance = coordinate1.distance(from: coordinate2)
            print(distance)
            
            if distance < 100 {
                
                issues.append(issue)
            }
        }
        print(issues.count)
        
        issuesTableView.reloadData()
    }
    

}

extension IssuesViewController: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        let location = locations[locations.count - 1]
        
        let longitude = location.coordinate.longitude
        let latitude = location.coordinate.latitude
        
        globalLon = longitude
        globalLat = latitude
        
        print("Longitude: \(globalLon)")
        print("Latitude: \(globalLat)")
        
        locationManager.stopUpdatingLocation()
    }
}

