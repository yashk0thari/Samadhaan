//
//  ViewController.swift
//  Hackathon
//
//  Created by Samyak Jain  on 12/13/18.
//  Copyright © 2018 Samyak Jain. All rights reserved.
//

import UIKit
import CoreLocation

class HomePageViewController: UIViewController, CLLocationManagerDelegate {
    
    let locationManager = CLLocationManager()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        locationManager.requestAlwaysAuthorization()
        locationManager.startUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        let location = locations[locations.count - 1]
        if location.horizontalAccuracy > 0 {
            
            locationManager.stopUpdatingLocation()
            locationManager.delegate = nil
            
            print("Longitude: \(location.coordinate.longitude)")
            print("Latitude: \(location.coordinate.latitude)")
        }
    }
    
    @IBAction func Location(_ sender: UIButton) {
        
        
    }
}

