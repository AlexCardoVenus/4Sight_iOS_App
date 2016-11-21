//
//  LocationSpeed.swift
//  4Sight
//
//  Created by Simon Rowlands on 18/11/2016.
//  Copyright © 2016 Appitized. All rights reserved.
//

import Foundation

class LocationSpeed: NSObject {
    
    var latitude: Double
    var longitude: Double
    var speed: Double
    var time: Date
    
    init(latitude: Double, longitude: Double, speed: Double, time: Date) {
        
        self.latitude = latitude
        self.longitude = longitude
        self.speed = speed
        self.time = time
        
        super.init()
    }
}
