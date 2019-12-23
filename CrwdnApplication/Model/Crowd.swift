//
//  Crowd.swift
//  CrwdnApplication
//
//  Created by Ebuka Egbunam on 12/21/19.
//  Copyright © 2019 Ebuka Egbunam. All rights reserved.
//

import UIKit
import CoreLocation

class Crowd{
    
    
   
    public var lattitude:  Double
    public var longitude:Double
    public var nameOfPlace:String
    public var distanceFromCurrentLocation : String = ""
    public var imageURL:String = ""
    public var coordinate : CLLocationCoordinate2D?
    public var placeID : String = ""
    
    init(lattitude :Double, longitude : Double , nameOfPlace : String , distanceFromCurrentLocation : String) {
        
        self.lattitude = lattitude
        self.longitude = longitude
        self.nameOfPlace = nameOfPlace
        self.distanceFromCurrentLocation = "\(distanceFromCurrentLocation)m"
    }
    
    func getCooridnate() -> CLLocationCoordinate2D {
        self.coordinate =  CLLocationCoordinate2DMake(self.lattitude, self.longitude)
        let coordinate = CLLocationCoordinate2DMake(self.lattitude, self.longitude)
        return coordinate
        
    }
    
    
    
    
    
}
