//
//  AppDelegate.swift
//  CrwdnApplication
//
//  Created by Ebuka Egbunam on 8/22/19.
//  Copyright © 2019 Ebuka Egbunam. All rights reserved.
//

import UIKit
import CoreData
import RadarSDK
import Parse
import Firebase



/*
 
 using parse undertsnading
 
 1.create connection to server
 
 2. create annonymouse user
 - finde user method
 - check if user is conneted and handle all cases
 - write function to leave function properly after function is done
 
 3.fetch information from parse server
 */

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    let GoogleapiKey = "AIzaSyCRQ5K2G8aruotYr00kolzEAmk4HBBwwNY"
//    let parseAPPId  = "f47a0c8c25a5b8cb3687df27d0d7a64ec75246a5"
//    let parseClientKey =  "c56aeffb98dd009e1a5eb8ac8dbaf196ce28cfa1"
//    let ParseServer = "http://18.222.159.195:80/parse"
    let radarPublishisableKey = "prj_test_pk_1ed475572366bc6cf0d865c46430baddc8c244fe"
    
    let parseAPPId  = "hXAYe23pT3tmagsuGXMNQKqHN24JKGOzIiRnP5Z4"
    let parseClientKey =  "N48FV2j9av7dICYEx8SLkrr8TqHmstndVqAeunu0"
    let ParseServer = "https://parseapi.back4app.com/"
    
    
    
    
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        FirebaseApp.configure()
        //MARK:- Rader config
        Radar.initialize(publishableKey: radarPublishisableKey)
        Radar.setDelegate(self)
        
        
        //  MARK:- parse config
        let parseConfig = ParseClientConfiguration {
            $0.applicationId = self.parseAPPId
            $0.clientKey = self.parseClientKey
            $0.server = self.ParseServer
        }
        Parse.initialize(with: parseConfig)
        
        
        
        
        //create user for parse
        
        if PFUser.current() == nil {
            PFAnonymousUtils.logIn { (user, error) in
                if let error = error {
                    print("annonymos login failed and there was an error \(error.localizedDescription)")
                }else{
                    if let user = user {
                        print("annonymos login succesful and there was no error \(user.objectId)")
                    }else{
                        print("user was nil")
                    }
                }
            }
        }
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        return true
    }
    
    /*
     
     func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
     // Override point for customization after application launch.
     //MARK:- Google api config
     //
     //        GMSServices.provideAPIKey(apiKey)
     //        GMSPlacesClient.provideAPIKey(apiKey)
     //
     //
     //MARK:- parse config
     //        let parseConfig = ParseClientConfiguration {
     //            $0.applicationId = "f47a0c8c25a5b8cb3687df27d0d7a64ec75246a5"
     //            $0.clientKey = "c56aeffb98dd009e1a5eb8ac8dbaf196ce28cfa1"
     //            $0.server = "http://18.222.159.195:80/parse"
     //        }
     //        Parse.initialize(with: parseConfig)
     
     
     self.window = UIWindow(frame: UIScreen.main.bounds)
     let sb = UIStoryboard(name: "Main", bundle: nil)
     var vc:UIViewController
     
     if UserDefaults.standard.value(forKey: "buttonPressed") as? String == nil {
     //let popUpSb = UIStoryboard(name: "Main", bundle: nil)
     vc = sb.instantiateViewController(withIdentifier: "locationPopUp")
     // instanate pop up as root view controller
     
     }
     else{
     vc = sb.instantiateInitialViewController()!
     
     // instaniate normalview controller
     }
     
     
     self.window?.rootViewController = vc
     self.window?.makeKeyAndVisible()
     
     return true
     }
     */
    
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        // Saves changes in the application's managed object context before the application terminates.
        self.saveContext()
    }
    
    // MARK: - Core Data stack
    
    lazy var persistentContainer: NSPersistentContainer = {
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
         */
        let container = NSPersistentContainer(name: "CrwdnApplication")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                
                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    
    // MARK: - Core Data Saving support
    
    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
    
}


