//
//  CurrentParseUser.swift
//  CrwdnApplication
//
//  Created by Ebuka Egbunam on 12/14/19.
//  Copyright © 2019 Ebuka Egbunam. All rights reserved.
//

import UIKit
import Parse



class CurrentParseUser {
    
    
    static let instance = CurrentParseUser()
    
    private var CURRENT_USER_ : PFUser? = PFUser.current()
    
    var REF_CURRENT_USER : PFUser? {
        return CURRENT_USER_
    }
    
    func saveUserInformation(user : PFUser , userInformation : [String:Any] , event : String?){
            user[Constants.CParse.addedCover] = Constants.CParse.addedCover 
            user[Constants.CParse.addedCover] = false
            user[Constants.CParse.RadarName] = event
        user.saveInBackground { (finished, error) in
            if let error = error {
                // there was an error
                print("there was an error \(error.localizedDescription)")
            }else{
                if finished{
                    //user was saved
                    print("user was saved ")
                }else{
                    print("user was  not saved ")
                }
            }
        }
    
            
        
    }
    
    
}
