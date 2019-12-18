//
//  RadarDelegate.swift
//  CrwdnApplication
//
//  Created by Ebuka Egbunam on 12/14/19.
//  Copyright © 2019 Ebuka Egbunam. All rights reserved.
//

import RadarSDK
import UIKit
import Parse


extension AppDelegate : RadarDelegate {
    
    func didReceiveEvents(_ events: [RadarEvent], user: RadarUser) {
        print("did recive events ")
        Track(thisuser: user, atthisevents: events)
        
    }
    
    
    
    func didUpdateLocation(_ location: CLLocation, user: RadarUser) {
        // do something with location, user
        print("update events for rader")
        print(user.location.coordinate.latitude)
        print(user.place?.name)
        
        
    }
    
    func didFail(status: RadarStatus) {
        // do something with status
        print("rader status")
        print(status)
        print("rader status")
        
        
    }
    
    
    func Track(thisuser _user : RadarUser , atthisevents _events : [RadarEvent] ){
        
        
        for event in _events {
            let radarEventType = event.type
            
            switch radarEventType {
                //            case .userEnteredGeofence:
            //                print("")
            case .userEnteredPlace:
                
                if PFUser.current() != nil {
                    
                    if let user = PFUser.current(){
                        let data :  [String : Any] = [Constants.CParse.addedCover : false , Constants.CParse.CurrentPlaceID :event.place?.facebookPlaceId , Constants.CParse.RadarName : event.place?.name ]
                        CurrentParseUser.instance.saveUserInformation(user: user, userInformation: data, event: event.place?.name)
                        
                        addOrRemoveUserToServer(withlocation:event.place?.facebookPlaceId ?? "" , andEvents: event , remove: false)
                        
                        
                        
                        
                    }
                    
                    
                    
                }else{
                    print("there was no user hahahaha")
                }
                
                //            case .userExitedGeofence:
            //                print("")
            case .userExitedPlace:
                
                if PFUser.current() != nil {
                    
                    if let user = PFUser.current(){
                        let data :  [String : Any] = [Constants.CParse.addedCover : false , Constants.CParse.CurrentPlaceID :"0", Constants.CParse.RadarName : "0" ]
                        CurrentParseUser.instance.saveUserInformation(user: user, userInformation: data, event: event.place?.name)
                        addOrRemoveUserToServer(withlocation:event.place?.facebookPlaceId ?? "" , andEvents: event , remove: true)
                        
                        
                        
                        
                    }
                    
                    
                    
                }
                
                
            default:
                print("iii")
            }
        }
        
    }
    
    
    
    func addOrRemoveUserToServer(withlocation locationID : String , andEvents event : RadarEvent, remove : Bool){
        if locationID != ""{
            
            
            let query = PFQuery(className: Constants.CParse.Crwds)
            query.whereKey(Constants.CParse.PlaceID, equalTo: locationID)
            query.findObjectsInBackground { (objects, error) in
                
                if let error = error{
                    //unrapping error
                    //there is an error
                    print("there is an error in addor remoive user to server")
                }else{
                    //there is no error
                    
                    if let objects = objects {
                        // unrapping objects
                        if objects.count > 0 {
                            for object in objects{
                                if remove{
                                    let numberOfPeopleInLocation = object.object(forKey: Constants.CParse.People) as! Int
                                    if numberOfPeopleInLocation == 1 || numberOfPeopleInLocation < 1 {
                                        object[Constants.CParse.People] = 0
                                        
                                    }else{
                                        object.incrementKey(Constants.CParse.People, byAmount: -1)
                                    }
                                }else{
                                    object.incrementKey(Constants.CParse.People)
                                }
                                object.saveInBackground { (finished, error) in
                                    if let error = error {
                                        //there was an error
                                        print("object was not saved and there was an error = \(error.localizedDescription)")
                                    }else{
                                        if finished {
                                            //object was saved succesfully
                                            print("saved new user to place")
                                        }else{
                                            //object was not saved
                                            print(" did not save new user to place")
                                            
                                        }
                                    }
                                }
                            }
                            
                        }else{
                            if !remove{
                                self.addLocationToserver(withRaderEvent: event)
                            }
                            
                            
                        }
                        
                    }else{
                        //objects was nil
                        print("object was nil in populate severid function")
                    }
                }
                
                
            }
            
            
        }
        
        
        
    }
    
    
    func addLocationToserver( withRaderEvent _event : RadarEvent ){
        
        
        if let lattitude = _event.place?.location.coordinate.latitude ,
            let longitude =
            _event.place?.location.coordinate.longitude
        {
            let parseGeoPoint = PFGeoPoint(latitude: lattitude, longitude: longitude)
            let newPlace = PFObject(className: Constants.CParse.Crwds)
            
            if let placeid = _event.place?.facebookPlaceId , let raderName = _event.place?.name  {
                newPlace[Constants.CParse.CurrentPlaceID] = placeid
                newPlace[Constants.CParse.RadarName] = raderName
                newPlace[Constants.CParse.Location] = parseGeoPoint
                newPlace[Constants.CParse.People] = 1
                newPlace.saveInBackground { (finished, error) in
                    if let error = error{
                        print("there was an error in ad location to server = \(error.localizedDescription)")
                    }else{
                        if finished{
                            print("new place has now been saved")
                        }else{
                            print("new place has not been saved")
                        }
                    }
                }
                
            }
            
            
        }
            
        else{
            print("rader did not give us the event location in  addlocationtoserver function in radar delegate ")
        }
        
        
        
    }
    
    
    
    
    
    
    
    
    
}
