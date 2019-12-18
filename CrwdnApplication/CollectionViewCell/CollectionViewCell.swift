//
//  CollectionViewCell.swift
//  SlideCollection
//
//  Created by Ebuka Egbunam on 10/21/19.
//  Copyright © 2019 Ebuka Egbunam. All rights reserved.
//

import UIKit
import  CoreLocation
import MapKit

class CollectionViewCell: UICollectionViewCell {
    
  
    
   
    override func awakeFromNib() {
        super.awakeFromNib()
         behindView.layer.cornerRadius = 12
        
        
        
        
        
    }
    
    
    @IBOutlet weak var snapButtonOutlet: UIButton!
    @IBOutlet weak var nameOfPlace: UILabel!
    @IBOutlet weak var coverFee: UILabel!
    @IBOutlet weak var views: UILabel!
    @IBOutlet weak var behindView: UIView!
    @IBOutlet weak var snapImage: UIImageView!
    @IBOutlet weak var distanceInMiles: UILabel!

    @IBOutlet weak var tapView: UIView!
    
    
    
    
    
   
    
    
    
    
    
    
    
}



