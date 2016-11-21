//
//  IncidentService.swift
//  4Sight
//
//  Created by Simon Withington on 17/06/2016.
//  Copyright © 2016 Appitized. All rights reserved.
//

import Foundation
import Alamofire

class IncidentService: NSObject {
    
    static let sharedInstance = IncidentService()
    var currentIncident = Incident()
    
    static func reportIncident(completion:@escaping (NSError?)->()) {
        
        guard let user = UserService.sharedInstance.currentUser, let id = user.id, let token = user.accessToken else {
            completion(NSError(domain: "Trying to report an incident but no user found!", code: 0, userInfo: nil))
            return
        }
        
        let params: [String: String] = [
            "video_id": sharedInstance.currentIncident.videoID,
            "lat" : sharedInstance.currentIncident.latitude,
            "long": sharedInstance.currentIncident.longitude,
            "registration_number": sharedInstance.currentIncident.registrationNumber
        ]
        
        Alamofire.request(String(format: apiURL + reportIncidentEndpoint, id), method:.post, parameters:params, encoding: JSONEncoding.default, headers: ["Authorization": "Bearer \(token)", "Accept": "application/json"]).responseJSON {
            (response) in
            
            switch response.result {
                
            case .success(let response):
                print(response)
                let res = response as! NSDictionary
                if let json = res["errors"] as? [[String: AnyObject]],
                    let errors = json[0] as [String: AnyObject]?,
                    let status = errors["status"] as? NSNumber,
                    let messages = errors["messages"] as? [NSObject: AnyObject] {
                    
                    completion(NSError(domain: "IncidentService", code: status.intValue, userInfo: messages))
                    
                } else if let response = response as? [String: [String: String]], let json = response["data"] {
                    sharedInstance.currentIncident.id = json["id"]
                    completion(nil)
                }
                
                break
                
            case .failure(let error):
                print(error)
                completion(error as NSError?)
                break
            }
        }
    }
    
    static func addVehicles(drivers: [[String: String]], completion: @escaping (NSError?)->()) {
        
        guard let user = UserService.sharedInstance.currentUser, let token = user.accessToken, let id = sharedInstance.currentIncident.id else {
            completion(NSError(domain: "Trying to add vehicles to an incident but no user/incident found!", code: 0, userInfo: nil))
            return
        }
        
        let params = ["vehicles": drivers]
        
        Alamofire.request(String(format: apiURL + addVehiclesEndpoint, id), method:.post, parameters:params, encoding: JSONEncoding.default, headers: ["Authorization": "Bearer \(token)", "Accept": "application/json"]).responseJSON {
            (response) in
            
            switch response.result {
                
            case .success(let response):
                print(response)
                let res = response as! NSDictionary
                if let json = res["errors"] as? [[String: AnyObject]],
                    let errors = json[0] as [String: AnyObject]?,
                    let status = errors["status"] as? NSNumber,
                    let messages = errors["messages"] as? [NSObject: AnyObject] {
                    
                    completion(NSError(domain: "IncidentService", code: status.intValue, userInfo: messages))
                    
                } else {
                    completion(nil)
                }
                
                break
                
            case .failure(let error):
                print(error)
                completion(error as NSError)
                break
            }
        }
    }
    
    static func addWitnesses(witnesses: [[String: String]], completion: @escaping (NSError?)->()) {
        
        guard let user = UserService.sharedInstance.currentUser, let token = user.accessToken, let id = sharedInstance.currentIncident.id else {
            completion(NSError(domain: "Trying to add witnesses to an incident but no user/incident found!", code: 0, userInfo: nil))
            return
        }
        
        let params = ["witnesses": witnesses]
        
        Alamofire.request(String(format: apiURL + addWitnessesEndpoint, id), method:.post, parameters:params, encoding: JSONEncoding.default, headers: ["Authorization": "Bearer \(token)", "Accept": "application/json"]).responseJSON {
            (response) in
            
            switch response.result {
                
            case .success(let response):
                print(response)
                let res = response as! NSDictionary
                if let json = res["errors"] as? [[String: AnyObject]],
                    let errors = json[0] as [String: AnyObject]?,
                    let status = errors["status"] as? NSNumber,
                    let messages = errors["messages"] as? [NSObject: AnyObject] {
                    
                    completion(NSError(domain: "IncidentService", code: status.intValue, userInfo: messages))
                    
                } else {
                    completion(nil)
                }
                
                break
                
            case .failure(let error):
                print(error)
                completion(error as NSError)
                break
            }
        }
    }
}
