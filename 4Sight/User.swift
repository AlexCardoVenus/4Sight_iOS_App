//
//  User.swift
//  4Sight
//
//  Created by Simon Withington on 18/07/2016.
//  Copyright © 2016 Appitized. All rights reserved.
//

import UIKit

class User: NSObject {
    
    let email: String?
    
    var id: String?
    var firstName: String?
    var surname: String?
    var address: String?
    var insurer: String?
    var telephoneNumber: String?
    var vehicleRegistration: String?
    
    var accessToken: String?
    var refreshToken: String?

    init(username: String, accessToken: String, refreshToken: String) {
        
        email = username
        self.accessToken = accessToken
        self.refreshToken = refreshToken
        
        super.init()
    }

    init(json: [String: String]) {
        
        email = json["email"]
        
        id = json["id"]
        firstName = json["first_name"]
        surname = json["surname"]
        vehicleRegistration = json["vehicle_registration"]
        telephoneNumber = json["telephone_number"]
        address = json["address"]
        insurer = json["insurer"]
        
        accessToken = json["access_token"]
        refreshToken = json["refresh_token"]
        
        super.init()
    }
    
    func toJSON() -> [String: String] {
        
        var json : [String: String] = [:]
        
        json["email"] = email
        
        json["id"] = id
        json["first_name"] = firstName
        json["surname"] = surname
        json["vehicle_registration"] = vehicleRegistration
        json["telephone_number"] = telephoneNumber
        json["address"] = address
        json["insurer"] = insurer
        
        json["access_token"] = accessToken
        json["refresh_token"] = refreshToken
        
        return json
    }
}
