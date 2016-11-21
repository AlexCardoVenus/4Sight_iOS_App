//
//  AppDelegate.swift
//  4Sight
//
//  Created by Simon Withington on 25/04/2016.
//  Copyright © 2016 Appitized. All rights reserved.
//

import UIKit
import CoreLocation
import UserNotifications

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, CLLocationManagerDelegate {

    var window: UIWindow?
    let locationManager = CLLocationManager()
    let locationsToKeep = Int(VideoManager.sharedInstance.recordingDuration.seconds)
    var locationData: [LocationSpeed] = []
    var initialBrightness: CGFloat = 0.0
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        initialBrightness = UIScreen.main.brightness
        
        locationManager.delegate = self
        
        checkAuthAndStart()
        
        VideoManager.sharedInstance.checkAudioAuthStatus()
        VideoManager.sharedInstance.checkVideoAuthStatus()
        
        if #available(iOS 10.0, *) {
            UNUserNotificationCenter.current().requestAuthorization(
                options: [.alert,.sound,.badge],
                completionHandler: { (granted,error) in
                    Shared.shared.isGrantedNotificationAccess = granted
                }
            )
        } else {
            // Fallback on earlier versions
            UIApplication.shared.registerUserNotificationSettings(UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil))
        }
        
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
        UIScreen.main.brightness = initialBrightness

        locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
        
        UIScreen.main.brightness = initialBrightness
        locationManager.stopUpdatingLocation()
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
        
        checkAuthAndStart()
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        
        UIScreen.main.brightness = initialBrightness
    }
}

typealias LocationManagement = AppDelegate
extension AppDelegate {

    func checkAuthAndStart() {
        if CLLocationManager.authorizationStatus() != .authorizedWhenInUse {
            locationManager.requestWhenInUseAuthorization()
        } else {
            locationManager.startUpdatingLocation()
        }
        
    }
    
    func locationManager(manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedWhenInUse {
            locationManager.startUpdatingLocation()
        } else {
            debugPrint("Can't update locations - unauthorized")
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        // ignore if was quicker than the last second?
        
        if let newLocation = locations.last {
            if locationData.count >= locationsToKeep {
                locationData.remove(at: 0)
            }
            
            let locationSpeed = LocationSpeed(latitude: newLocation.coordinate.latitude, longitude: newLocation.coordinate.longitude, speed: newLocation.speed, time: newLocation.timestamp)
            
            locationData.append (locationSpeed)
            debugPrint("The location speed - \(locationSpeed)")
        } else {
            debugPrint("Error - nil location")
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        debugPrint("Failed to find location: \(error.localizedDescription)")
    }
}

