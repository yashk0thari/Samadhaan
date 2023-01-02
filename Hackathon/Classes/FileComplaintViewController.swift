//
//  FileComplaintViewController.swift
//  Hackathon
//
//  Created by Valley on 12/20/18.
//  Copyright © 2018 Samyak Jain. All rights reserved.
//

import UIKit
import CoreLocation
import MobileCoreServices
import FirebaseStorage
import SVProgressHUD
import FirebaseAuth
import FirebaseFirestore
import ChameleonFramework
import AVKit

class FileComplaintViewController: UIViewController {

    let imagePicker = UIImagePickerController() // for Camera Usage
    let locationManager = CLLocationManager()   // for Location Usage
    
    var globalLat = 0.0
    var globalLon = 0.0
    
    var mediaURL : String?
    var media_type : String?
    var category : String?
    let db = Firestore.firestore()
    
    //    var issueArray : [Issue] = [Issue]()        // for Issue Class Usage
    
    @IBOutlet weak var CameraImageView: UIImageView!
    @IBOutlet weak var AddIssueView: UIButton!
    @IBOutlet weak var SubjectTextField: UITextView!
    @IBOutlet weak var DescriptionTextField: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // For Camera
        imagePicker.delegate = self
        imagePicker.sourceType = .camera //This need to be changed to ".camera" from ".photoLibrary"
        
        imagePicker.mediaTypes = [kUTTypeImage as String, kUTTypeMovie as String]
        // Optimize for video also then do this [kUTTypeImage as String, kUTTypeMovie as String]
        
        imagePicker.allowsEditing = false // for now
        
        AddIssueView.layer.cornerRadius = 10
        
        // For Location
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestAlwaysAuthorization()
        locationManager.startUpdatingLocation()
        
        // Initialising Input Outlet Design
        SubjectTextField.text = "Subject: "
        SubjectTextField.textColor = UIColor.white
        
        DescriptionTextField.text = "Description: This issue is really important! Please help solve this. Download the App for more information <//link to app>"
        DescriptionTextField.textColor = UIColor.white
        
        CameraImageView.layer.cornerRadius = 10
    }
    
    

    @IBAction func CameraButton(_ sender: Any) {
        
        present(imagePicker, animated: true, completion: nil)
    }
    
    
    @IBAction func ShareMeButtonAction(_ sender: UIButton) {
        
        let activityController = UIActivityViewController(activityItems: [CameraImageView.image!, SubjectTextField.text!, DescriptionTextField.text!], applicationActivities: nil)
        
        present(activityController, animated: true, completion: nil)
    }
    
    @IBAction func AddIssueButtonAction(_ sender: UIButton) {
        
        SVProgressHUD.show()
        
        // Error Checking Methods
        if (mediaURL == "" || (SubjectTextField.text == "Subject: ")) {
            
            AddIssueView.backgroundColor = UIColor.flatWatermelon()
        } else {
            
            let currentUser = Auth.auth().currentUser
            let email = currentUser?.email
            
            var ref: DocumentReference? = nil
            
            let data = [
                "name" : SubjectTextField.text ?? "",
                "description" : DescriptionTextField.text ?? "",
                "latitude" : globalLat ,
                "longitude" : globalLon,
                "mediaURL" : mediaURL,
                "mostViewed" : true,
                "concerns" : 0,
                "email" : email,
                "category" : category,
                "mediaType": media_type
                ] as [String : Any]
            
            ref = db.collection("Issues").addDocument(data: data) { err in
                if let err = err {
                    print("Error adding document: \(err)")
                } else {
                    print("Document added with ID: \(ref!.documentID)")
                    
                    var ref2: DocumentReference? = nil
                    let data2 = ["affected" : true]
                    ref2 = self.db.collection("Issues").document(ref!.documentID).collection("Concerned").document(Auth.auth().currentUser!.uid)
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
            
//            AddIssueView.backgroundColor = UIColor.lightGray
            AddIssueView.isEnabled = false // To restrain multiple entries
            AddIssueView.backgroundColor = UIColor.flatGreen()
        }
        
        SVProgressHUD.dismiss()
    }
    
    @IBAction func TapGestureAction(_ sender: UITapGestureRecognizer) {
        
        SubjectTextField.endEditing(true)
        DescriptionTextField.endEditing(true)
    }
    
    
    func uploadImageToFirebaseStorage(data: NSData) {
        print("Image was selected")
        
        let today = getTodayString()
        let finalString = "issuePics/" + Auth.auth().currentUser!.uid + today + ".jpg"
        
        let storageRef = Storage.storage().reference(withPath: finalString)
        
        let uploadMetadata = StorageMetadata()
        uploadMetadata.contentType = "image.jpeg"
        let uploadTask = storageRef.putData(data as Data, metadata: uploadMetadata) { (metadata, error) in
            
            if (error != nil) {
                print("I recieved an error", error?.localizedDescription)
            } else {
                print("Upload complete.")
            }
            
            // You can also access to download URL after upload.
            storageRef.downloadURL { (url, error) in
                guard let downloadURL = url else {
                    // Uh-oh, an error occurred!
                    return
                }
                self.mediaURL = "\(downloadURL)"
                print("Download URL \(downloadURL)")
            }
            
            SVProgressHUD.dismiss()
        }
    }
    
    func uploadMovieToFirebaseStorage(url: NSURL) {
        print("Movie was selected")
        
        let today = getTodayString()
        let finalString = "issueVids/" + Auth.auth().currentUser!.uid + today + ".mov"
        
        let storageRef = Storage.storage().reference(withPath: finalString)
        
        let uploadMetadata = StorageMetadata()
        uploadMetadata.contentType = "image/quicktime"
        let uploadTask = storageRef.putFile(from: url as URL, metadata: uploadMetadata) { (metadata, error) in
            
            if (error != nil) {
                print("I recieved an error", error?.localizedDescription)
            } else {
                print("Upload complete.")
            }
            
            // You can also access to download URL after upload.
            storageRef.downloadURL { (url, error) in
                guard let downloadURL = url else {
                    // Uh-oh, an error occurred!
                    return
                }
                self.mediaURL = "\(downloadURL)"
                print("Download URL \(downloadURL)")
            }
            
            SVProgressHUD.dismiss()
        }
    }
    
    func getTodayString() -> String{
        
        let date = Date()
        let calender = Calendar.current
        let components = calender.dateComponents([.year,.month,.day,.hour,.minute,.second], from: date)
        
        let year = components.year
        let month = components.month
        let day = components.day
        let hour = components.hour
        let minute = components.minute
        let second = components.second
        
        let today_string = String(year!) + "-" + String(month!) + "-" + String(day!) + " " + String(hour!)  + ":" + String(minute!) + ":" +  String(second!)
        
        return today_string
        
    }

}

extension FileComplaintViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
// Local variable inserted by Swift 4.2 migrator.
let info = convertFromUIImagePickerControllerInfoKeyDictionary(info)

        
        SVProgressHUD.show()
        
        guard let mediaType: String = info[convertFromUIImagePickerControllerInfoKey(UIImagePickerController.InfoKey.mediaType)] as? String else {
            picker.dismiss(animated: true, completion: nil)
            return
        }
        
        if mediaType == (kUTTypeImage as String) {
            
            media_type = "Image"
            //User has selected an image
            if let originalImage = info[convertFromUIImagePickerControllerInfoKey(UIImagePickerController.InfoKey.originalImage)] as? UIImage {
                let imageData = originalImage.jpegData(compressionQuality: 0.5)
                uploadImageToFirebaseStorage(data: imageData as! NSData)
            }
            
            guard let image = info[convertFromUIImagePickerControllerInfoKey(UIImagePickerController.InfoKey.originalImage)] as? UIImage else {
                return
            }
            CameraImageView.image = image
            
        } else if mediaType == (kUTTypeMovie as String) {
            
            media_type = "Movie"
            //User has selected an image
            if let movieURL = info[convertFromUIImagePickerControllerInfoKey(UIImagePickerController.InfoKey.mediaURL)] as? NSURL {
                uploadMovieToFirebaseStorage(url: movieURL)
            }
        }
        
        
        picker.dismiss(animated: true, completion: nil)
    }
    
}

extension FileComplaintViewController: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        let location = locations[locations.count - 1]
        
        let longitude = location.coordinate.longitude
        let latitude = location.coordinate.latitude
        
        globalLon = longitude
        globalLat = latitude
        
//        globalLon = Double(round(globalLon))
//        globalLat = Double(round(globalLat))
        
        print("Longitude: \(globalLon)")
        print("Latitude: \(globalLat)")
        
        locationManager.stopUpdatingLocation()
    }
}

extension FileComplaintViewController: UITextViewDelegate {
    
//    func textViewDidBeginEditing(_ textView: UITextView) {
//
//        if SubjectTextField.textColor == UIColor.lightGray {
//            SubjectTextField.text = "lol"
//            SubjectTextField.textColor = UIColor.white
//        } else {
//
//            SubjectTextField.textColor = UIColor.red
//        }
//    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        
        if textView.text.isEmpty {
            
            AddIssueView.isEnabled = false
            AddIssueView.backgroundColor = UIColor.lightGray
        }
    }
}


// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromUIImagePickerControllerInfoKeyDictionary(_ input: [UIImagePickerController.InfoKey: Any]) -> [String: Any] {
	return Dictionary(uniqueKeysWithValues: input.map {key, value in (key.rawValue, value)})
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromUIImagePickerControllerInfoKey(_ input: UIImagePickerController.InfoKey) -> String {
	return input.rawValue
}
