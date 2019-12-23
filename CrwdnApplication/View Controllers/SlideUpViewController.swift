//
//  SlideUpViewController.swift
//  CrwdnApplication
//
//  Created by Ebuka Egbunam on 12/19/19.
//  Copyright © 2019 Ebuka Egbunam. All rights reserved.
//

import UIKit
import CoreLocation
import Parse


protocol SlideUpViewControllerDelelegate {
    func willUpdateMapViewWithCoordinate(coordinate : CLLocationCoordinate2D)
    func willAddAnnotationwithcrowdItem(CrowdItem : [Crowd])
}

class SlideUpViewController: UIViewController {
    
    
    //MARK:- iboutlets
    @IBOutlet weak var handleAreaView: UIView!
    
    @IBOutlet weak var PlacesCollectionView: UICollectionView!
    
    //MARK:- variables
    var currentCoordinate : CLLocationCoordinate2D?
    var crowdList = [Crowd]()
    let displayLimit = 20
    var delegate : SlideUpViewControllerDelelegate?
    let  cellIdentifier = "realCell"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        setupCollectionVew()
        handleAreaView.layer.cornerRadius = 12
        view.layer.cornerRadius = 12
        
       
        
        
    }
    
    func setupCollectionVew(){
        
        
        PlacesCollectionView.backgroundColor = .white
        PlacesCollectionView.delegate = self
        PlacesCollectionView.dataSource  = self
        self.PlacesCollectionView.register(UINib(nibName:"CollectionViewCell", bundle: nil), forCellWithReuseIdentifier: cellIdentifier)
        
    }
    
    
    func populatewithLocation(currentlattitude : Double , currentLongitude : Double){
        let parseGeoPoint = PFGeoPoint(latitude: currentlattitude, longitude: currentLongitude)
        let query = PFQuery(className: Constants.CParse.Crwds)
        query.whereKey("location", nearGeoPoint: parseGeoPoint)
        query.limit = displayLimit
        query.findObjectsInBackground { [weak self](objects, error) in
            if let error = error{
                self?.handleError(with : "There was an error querying for data :  \(error.localizedDescription)")
            }else if objects != nil{
                if objects!.count > 0 {
                    for object in objects!{
                        let objectLocation = object.object(forKey: Constants.CParse.Location) as! PFGeoPoint
                        
                        let objectLattiude = objectLocation.latitude
                        let objectLongitude = objectLocation.longitude
                        let objectLoctaionInCllocation = CLLocation(latitude: objectLattiude, longitude: objectLongitude)
                        let userLocationInCllocation = CLLocation(latitude: (self?.currentCoordinate!.latitude)!, longitude: (self?.currentCoordinate!.longitude)!)
                        
                        let distanceFromLocationInMiles = "\(Int(((userLocationInCllocation.distance(from: objectLoctaionInCllocation)) / 1609.344)))"
                        let objectNameOfPlace = object.object(forKey: Constants.CParse.RadarName) as! String
                        let recentPic = object.object(forKey: Constants.CParse.RecentPic) as? String
                        let placeID = object.object(forKey: Constants.CParse.PlaceID) as? String
                        
                        let singleCrowdEvent = Crowd(lattitude: objectLattiude, longitude: objectLongitude, nameOfPlace: objectNameOfPlace , distanceFromCurrentLocation : distanceFromLocationInMiles)
                        singleCrowdEvent.imageURL = recentPic ?? ""
                        singleCrowdEvent.placeID = placeID ?? ""
                        self?.crowdList.append(singleCrowdEvent)
                        self?.PlacesCollectionView.reloadData()
                        
                        
                        
                    }
                    //add anotaions
                    self!.delegate?.willAddAnnotationwithcrowdItem(CrowdItem: self!.crowdList)
                    
                    
                }else{
                    //object count is less that zero ; show loading screen
                }
                
                
            }else{
                //somehow the object was nill
            }
        }
        
        
        
        
    }
    
    func handleError(with message : String){
        
    }
    
    
    
    
    
}

extension SlideUpViewController: UICollectionViewDelegate , UICollectionViewDataSource{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if crowdList.count > 0 {
            return crowdList.count
        }else{
            return 5
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellIdentifier, for: indexPath) as!
        CollectionViewCell
        
        if crowdList.count > 0{
            cell.nameOfPlace.text = crowdList[indexPath.row].nameOfPlace
            cell.distanceInMiles.text = crowdList[indexPath.row].distanceFromCurrentLocation
        
        }
        
        return cell
        
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let coordinate = crowdList[indexPath.row].getCooridnate()
        delegate?.willUpdateMapViewWithCoordinate(coordinate: coordinate)
    }
    
    
    
    
    
    
}

extension SlideUpViewController : UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width:( PlacesCollectionView.frame.width / 3) * 1.25 , height:  (PlacesCollectionView.frame.width / 3) )
    }
    
    
    
    
    
    
    
}

extension SlideUpViewController : ViewControllerDelegate {
    func didGetCurrentLocation(currentLocation: CLLocationCoordinate2D) {
        currentCoordinate = currentLocation
        // call populate function
        populatewithLocation(currentlattitude: currentCoordinate!.latitude, currentLongitude: currentCoordinate!.longitude)
        
        
    }
    
    
}

