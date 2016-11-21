//
//  IncidentDetector.swift
//  4Sight
//
//  Created by Simon Withington on 04/05/2016.
//  Copyright © 2016 Appitized. All rights reserved.
//

import UIKit
import CoreMotion

struct DetectionProfile {
    var updateInterval: Double
    var acceleration: Double
    
    static func defaultProfile() -> DetectionProfile {
        return DetectionProfile.init(updateInterval: 0.01, acceleration: 3.0)
    }
}

class IncidentDetector: NSObject {

    static let sharedInstance = IncidentDetector()
    
    let motionManager = CMMotionManager()
    
    var profile: DetectionProfile
    var incidentClosure: (() -> ())?
    
    override init() {
        profile = DetectionProfile.defaultProfile()
        super.init()
    }
    
    func start() {
        if motionManager.isDeviceMotionAvailable {
            motionManager.deviceMotionUpdateInterval = profile.updateInterval
            motionManager.startDeviceMotionUpdates(to: OperationQueue.main, withHandler: {
                [weak self] (data: CMDeviceMotion?, error: Error?) in
                
                if let error = error {
                    debugPrint(error.localizedDescription)
                } else if let weakSelf = self, let data = data {
                    weakSelf.evaluateMotionData(data)
                }
                })
        }
    }
    
    func stop() {
        motionManager.stopDeviceMotionUpdates()
    }
    
    func evaluateMotionData(_ data: CMDeviceMotion) {
        
        if data.userAcceleration.magnitude > profile.acceleration {
            incidentClosure?()
        }
    }
}

extension CMAcceleration {
    
    var magnitude: Double {
        get {
            return sqrt((sqrt(x*x + y*y) + z*z))
        }
    }
}
