//
//  Incident.swift
//  4Sight
//
//  Created by Simon Withington on 17/06/2016.
//  Copyright © 2016 Appitized. All rights reserved.
//

import UIKit
import Foundation
import CoreLocation

class Incident: NSObject {

    var videoID = ""
    var videoData: Data? {
        didSet {
            recordSpeedAndLocationData()
        }
    }
    
    // TODO: Capture location data
    var latitude = "0.0"
    var longitude = "0.0"
    
    // TODO: Capture speed data
    var speedData = [[String: String]]()
    
    var registrationNumber = ""
    
    var id: String?
    
    var vehicles: [[String: String]] = []
    var witnesses: [[String: String]] = []
    
    func recordSpeedAndLocationData() {
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        
        let data = appDelegate.locationData
        
        guard data.count > 0 else {
            debugPrint("No location data available")
            return
        }
        
//        let lastKnownLocation = data.last!.coordinate
        latitude = /*"53.3910"*/"\(data.last!.latitude)"
        longitude = /*"2.5970"*/"\(data.last!.longitude)"
        debugPrint("Location: \(latitude) x \(longitude)")
        
        speedData = [[String:String]]()
        
        let calendar = NSCalendar.current
        
        data.reversed().forEach { (speedLocation) in
            let speedTime = speedLocation.time
            
            
            debugPrint("Speedlocation time - \(speedLocation.time)")
            debugPrint("Crash detected - \(DashboardViewController.crashDetectedTimestamp)")
            
            
            if let nanoSecondsDifference = calendar.dateComponents([Calendar.Component.nanosecond], from: speedTime, to:DashboardViewController.crashDetectedTimestamp).nanosecond {
                let milliSecondsDifference = nanoSecondsDifference / 1000000
                let secondsDifference = nanoSecondsDifference / 1000000000
//                debugPrint("secondsDifference - \(secondsDifference)")
//                debugPrint("milliseconds to secondsDifference- \(secondsDifference / 1000)")
                debugPrint("secondsDifference - \(secondsDifference)")
                
                if secondsDifference >= -15 && secondsDifference <= 5 {
                    
                    var speed = speedLocation.speed
                    
                    if speed < 0 {
                        // Invalid speed
                        speed = -1
                    }
                    
                    debugPrint("speed - \(speed)")
                    debugPrint("crashDetectedAt - \(DashboardViewController.crashDetectedTimestamp)")
                    speedData.append(["speed":"\(speed)", "time": "\(milliSecondsDifference + 15000)"])
                }
            }
        }
        
//        speedData.reverse()
        
        speedData.forEach{ (speedDict) in
            debugPrint(speedDict)
        }
    }
    
    func convertSpeedToMPH(speed: CLLocationSpeed) -> CLLocationSpeed {
    
        let scaleFactor = (60*60) / 1609.34
        return speed * scaleFactor
    }
}
