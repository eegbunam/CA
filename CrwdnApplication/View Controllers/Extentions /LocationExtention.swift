//
//  LocationExtention.swift
//  CrwdnApplication
//
//  Created by Ebuka Egbunam on 10/29/19.
//  Copyright © 2019 Ebuka Egbunam. All rights reserved.
//

import Foundation
import UIKit
import CoreLocation
import RadarSDK

extension ViewController: CLLocationManagerDelegate {
    
    
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        guard let location = locations.last else { return }
        userLattidude =  (locationManager.location?.coordinate.latitude)!
        userLongitude = (locationManager.location?.coordinate.longitude)!
        
        if firstUpdate{
            setUpRader()
            centerViewOnUserLocation()
            populate(currentlattitude: userLattidude, currentLongitude: userLongitude)
            firstUpdate = false
            
        }
        
        Radar.updateLocation(location, completionHandler: { (status: RadarStatus, location: CLLocation?, events: [RadarEvent]?, user: RadarUser?) in
            // do something with status, events, user
            if let events = events{
                for event in events{
                    print(event)
                }

            }

        })
        
        
        
        
        
    }
    
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        checkLocationAuthorization()
    }
    
    
}
