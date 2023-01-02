//
//  DetailViewController.swift
//  Hackathon
//
//  Created by Samyak Jain  on 12/20/18.
//  Copyright © 2018 Samyak Jain. All rights reserved.
//

import UIKit
import Alamofire
import SVProgressHUD
import MapKit
import CoreLocation
import FirebaseFirestore
import FirebaseAuth
import AVKit
//import MessageUI

// Class to Add 'PIN'
class customPin: NSObject, MKAnnotation {
    
    var coordinate: CLLocationCoordinate2D
    var string: String
    
    init(location: CLLocationCoordinate2D, problemString: String) {
        
        self.coordinate = location
        self.string = problemString
    }
}

class DetailViewController: UIViewController {

    var issue : Issue?
    var docID : String?
    let db = Firestore.firestore()
    
    @IBOutlet weak var issueImage: UIImageView!
    @IBOutlet weak var concernsNumber: UILabel!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var issueDescription: UITextView!
    @IBOutlet weak var MapKitView: MKMapView!
    @IBOutlet weak var videoButtonView: UIButton!
    @IBOutlet weak var concernsView: UIView!
    
    let attrs = [NSAttributedString.Key.font : UIFont.boldSystemFont(ofSize: 19)]
    let attrs1 = [NSAttributedString.Key.font : UIFont(name: "Helvetica", size: 19.0)!]
    
    var videoURL = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        SVProgressHUD.show()
        name.font = UIFont.boldSystemFont(ofSize: name.font.pointSize)
        name.textAlignment = NSTextAlignment.center;
        issueImage.layer.cornerRadius = 10
        issueImage.clipsToBounds = true
//        let attributedString = NSMutableAttributedString(string: "Issue: ", attributes:attrs)
        let normalString = NSMutableAttributedString(string: (issue?.description!)!,attributes:attrs1)
//        attributedString.append(normalString)
        name.text = (issue?.name!)!
        issueDescription.attributedText = normalString
        issueDescription.textColor = UIColor.white
        concernsNumber.text = String(issue!.concerns!)
        concernsNumber.textColor = UIColor.white
        
        videoButtonView.isHidden = true
        print("Media Type: \(issue?.media_type ?? "Not Found")")
        print("Media URL: \(issue?.mediaURL ?? "Not Found")")
        videoURL = issue!.mediaURL!
        
        name.layer.cornerRadius = 10
        name.layer.masksToBounds = true
        issueDescription.layer.cornerRadius = 10
        concernsView.layer.cornerRadius = 10
        MapKitView.layer.cornerRadius = 10
        
        if issue?.media_type == "Image" {
            
            Alamofire.request(issue!.mediaURL!).responseImage { response in
                debugPrint(response)
                
                if let image = response.result.value {
                    self.issueImage.image = image
                    SVProgressHUD.dismiss()
                }
            }
        } else if issue?.media_type == "Movie" {
        
            videoButtonView.isHidden = false
        }
        
        // Location Pin Handling for MapKitView
        let location = CLLocationCoordinate2D(latitude: self.issue?.latitude ?? 0.0, longitude: self.issue?.longitude ?? 0.0)
        let region = MKCoordinateRegion(center: location, span: MKCoordinateSpan(latitudeDelta: 0.005, longitudeDelta: 0.005))
        self.MapKitView.setRegion(region, animated: true)
        
        let pin = customPin(location: location, problemString: "Location of Problem")
        self.MapKitView.addAnnotation(pin)
    }
    
    @IBAction func videoButtonAction(_ sender: UIButton) {
        
        let video = AVPlayer(url: URL(string: videoURL)!)
        let videoPlayer = AVPlayerViewController()
        videoPlayer.player = video
        
        present(videoPlayer, animated: true, completion: {
            
            video.play()
        })
    }
    
    @IBAction func ShareMeButtonAction(_ sender: UIBarButtonItem) {
        
        let activityController = UIActivityViewController(activityItems: [name.text!, issueDescription.text!, issueImage.image!], applicationActivities: nil)
        
        present(activityController, animated: true, completion: nil)
    }
    
    @IBAction func concernButtonPressed(_ sender: UIButton) {
        
        SVProgressHUD.show()
        
        var found: Bool = false
        
        let query1 = self.db.collection("Issues").document(docID!).collection("Concerned").whereField("affected", isEqualTo: true)
        query1.addSnapshotListener { documentSnapshot, error in
            guard let documents = documentSnapshot?.documents else {
                print("Error fetching document changes: \(error!)")
                return
            }
            
            if documents.count != 0 {
                
                for i in 0 ..< documents.count {
                    
                    
                    let documentID1 = documents[i].documentID
                    if documentID1 == Auth.auth().currentUser!.uid {
                        found = true
                        
                    }
                }
            }
        }
        
        if found == false {
            var ref: DocumentReference? = nil
            let data = ["affected" : true]
            ref = self.db.collection("Issues").document(self.docID!).collection("Concerned").document(Auth.auth().currentUser!.uid)
            ref?.setData(data) { err in
                if let err = err {
                    SVProgressHUD.dismiss()
                    print("Error adding document: \(err)")
                } else {
                    SVProgressHUD.dismiss()
                    let alert = UIAlertController(title: "Concern noted!", message: "Your concern has been noted. If you wish to further contribute, file a complaint on pgportal.gov.in or share it on social media.", preferredStyle: .alert)
                    let action = UIAlertAction(title: "Continue", style: .default) { (action) in
                        
                    }
                    
                    alert.addAction(action)
                    self.present(alert, animated: true, completion: nil)
                    print("Document added with ID: \(ref!.documentID)")
                }
            }
            
            db.collection("Issues").document(self.docID!).updateData([
                "concerns": Int(issue!.concerns! + 1),
                ]) { err in
                    if let err = err {
                        print("Error updating document: \(err)")
                    } else {
                        print("Document successfully updated")
                    }
            }
            
            concernsNumber.text = String(issue!.concerns! + 1)
            
            if ((issue!.concerns! + 1) == 150) {
                
                var ref: DocumentReference? = nil
                
                let data = [
                    "name" : self.issue!.name!,
                    "description" : self.issue!.description!,
                    "latitude" : self.issue!.latitude!,
                    "longitude" : self.issue!.longitude!,
                    "mediaURL" : self.issue!.mediaURL!,
                    "mostViewed" : self.issue!.mostViewed!,
                    "concerns" : self.issue!.concerns!,
                    "email" : self.issue!.email!,
                    "category" : self.issue!.category!
                    ] as [String : Any]
                
                ref = db.collection("Parvaah").addDocument(data: data) { err in
                    if let err = err {
                        print("Error adding document: \(err)")
                    } else {
                        print("Document added with ID: \(ref!.documentID)")
                        
                        var ref2: DocumentReference? = nil
                        let data2 = ["affected" : true]
                        ref2 = self.db.collection("Parvaah").document(ref!.documentID).collection("Concerned").document(Auth.auth().currentUser!.uid)
                        ref2?.setData(data2) { err in
                            if let err = err {
                                SVProgressHUD.dismiss()
                                print("Error adding document: \(err)")
                            } else {
                                SVProgressHUD.dismiss()
                                let alert = UIAlertController(title: "Success!", message: "Your concern has been noted. If you wish to further contribute, file a complaint on pgportal.gov.in or share it on social media.", preferredStyle: .alert)
                                let action = UIAlertAction(title: "Continue", style: .default) { (action) in
                                    
                                }
                                
                                alert.addAction(action)
                                self.present(alert, animated: true, completion: nil)
                                print("Document added with ID: \(ref2!.documentID)")
                            }
                        }
                    }
                    
                }
                
                concernsNumber.textColor = UIColor.flatGreen()
                
            } else { concernsNumber.textColor = UIColor.flatWatermelon() }
        }
    }
}

//extension DetailViewController: MFMailComposeViewControllerDelegate {
//
//    func configureMailController() -> MFMailComposeViewController {
//
//        let MailComposerVC = MFMailComposeViewController()
//        MailComposerVC.mailComposeDelegate = self
//
//        MailComposerVC.setToRecipients(["yashkothari1000@gmail.com"])
//        MailComposerVC.setSubject(name.text!)
//        MailComposerVC.setMessageBody(issueDescription.text!, isHTML: false)
//
//        return MailComposerVC
//    }
//
//    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
//
//        controller.dismiss(animated: true, completion: nil)
//    }
//}
