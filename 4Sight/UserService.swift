//
//  UserService.swift
//  4Sight
//
//  Created by Simon Withington on 16/06/2016.
//  Copyright © 2016 Appitized. All rights reserved.
//

import Alamofire

class UserService: NSObject {
    
    static let sharedInstance = UserService()
    var currentUser: User?
    
    static func registerUser(_ userDict: [String: String], completion: @escaping (NSError?)->()) {
        
        Alamofire.request(apiURL + registerEndpoint, method:.post, parameters: userDict, encoding: JSONEncoding.default, headers: ["Accept": "application/json"])
            .responseJSON {
            (response) in
                
                switch response.result {
                    
                case .success(let response):
                    print(response)
                    let res = response as! NSDictionary
                    let errors = res["errors"]
                    print(errors)
                    if let json = res["errors"] as? [[String: AnyObject]],
                        let errors = json[0] as [String: AnyObject]?,
                        let status = errors["status"] as? NSNumber,
                        let messages = errors["messages"] as? [String: AnyObject], messages.first != nil {
                        
                        completion(NSError(domain: "UserService", code: status.intValue, userInfo: messages))
                    } else {
                        
                        UserService.signIn(userDict["email"]!, password: userDict["password"]!, completion: {
                            (error) in
                            
                            if let error = error {
                                completion(error)
                                return
                            }
                            
                            completion(nil)
                        })
                    }
                    break
                    
                case .failure(let error):
                    print(error)
                    completion(error as NSError?)
                    break
                }
        }
    }
    
    static func signIn(_ username: String, password:String, completion: @escaping (NSError?)->()) {
        
        let params: [String: String] = [
            "grant_type": "password",
            "client_id": clientID,
            "client_secret": clientSecret,
            "username": username,
            "password": password
        ]
        debugPrint(params)
        Alamofire.request(oauthURL, method:.post, parameters:params, encoding: JSONEncoding.default, headers: ["Accept": "application/json"])
            .responseJSON {
            (response) in
            
            switch response.result {
                
            case .success(let response):
                print(response)
                let res = response as! NSDictionary
                if let message = res["message"] as? String {
                    var error_message: Dictionary<String, String> = [:]
                    error_message["message"] = message
                    completion(NSError(domain: "UserService", code: 101, userInfo:error_message))
                }
                else if let json = response as? [String: AnyObject],
                    let accessToken = json["access_token"] as? String,
                    let refreshToken = json["refresh_token"] as? String {
                    
                    sharedInstance.currentUser = User(username: username, accessToken: accessToken, refreshToken: refreshToken)
                    
                    UserService.getUserDetails({
                        (error) in
                        
                        if let error = error {
                            completion(error)
                        } else {
                            saveCurrentUser()
                            completion(nil)
                        }
                    })
                
                } else {
                    
                    if let responseDict = response as? [String: String] {
                        completion(NSError(domain: "UserService", code: 0, userInfo: responseDict))
                    } else {
                        completion(NSError(domain: "UserService", code: 0, userInfo: nil))
                    }
                }
                
                break
                
            case .failure(let error):
                print(error)
                completion(error as NSError?)
                break
            }
        }
    }
    
    static func getUserDetails(_ completion: @escaping (NSError?)->()) {
        
        guard let token = UserService.sharedInstance.currentUser?.accessToken else {
            debugPrint("User has no token!")
            return
        }
        
        Alamofire.request(apiURL + userEndpoint, method:.get, headers: ["Authorization": "Bearer \(token)", "Accept": "application/json"])
            .responseJSON { (response) in
            
            switch response.result {
                
            case .success(let response):
                print(response)
                let res = response as! NSDictionary
                if let json = res["errors"] as? [[String: AnyObject]],
                    let errors = json[0] as [String: AnyObject]?,
                    let status = errors["status"] as? NSNumber,
                    let messages = errors["messages"] as? [NSObject: AnyObject] {
                    
                    completion(NSError(domain: "UserService", code: status.intValue, userInfo: messages))
                    
                } else if let json = res["data"] as? [String: AnyObject], let profile = json["profile"] as? [String: String] {
                    
                    var details = profile
                    details["id"] = json["id"] as? String
                    details["type"] = json["type"] as? String
                    
                    getDetails(details as [String : AnyObject])
                    
                    completion(nil)
                    
                } else {
                    completion(NSError(domain: "JSON FORMAT", code: 0, userInfo: nil))
                }
                break
            case .failure(let error):
                print(error)
                completion(error as NSError?)
                break
            }
        }
    }
    
    /* 2016-10-6 by Alex */
    static func updateUserDetails(_ userDict: [String: String], completion: @escaping (NSError?)->()) {
        
        guard let user = UserService.sharedInstance.currentUser, let id = user.id, let token = user.accessToken else {
            completion(NSError(domain: "Trying to update user details but no user found!", code: 0, userInfo: nil))
            return
        }
        debugPrint(id)
        debugPrint(userDict)
        Alamofire.request(String(format: apiURL + updateUserEndpoint, id), method:.put, parameters: userDict, encoding: JSONEncoding.default, headers: ["Authorization": "Bearer \(token)"])
            .responseJSON {
            (response) in
            
            switch response.result {
                
            case .success(let response):
                print(response)
                let res = response as! NSDictionary
                let errors = res["errors"]
                print(errors)
                if let json = res["errors"] as? [[String: AnyObject]],
                    let errors = json[0] as [String: AnyObject]?,
                    let status = errors["status"] as? NSNumber,
                    let messages = errors["messages"] as? [String: AnyObject], messages.first != nil {
                    
                    completion(NSError(domain: "UserService", code: status.intValue, userInfo: messages))
                } else {
                    
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
    
    /* 2016-10-7 by Alex */
    static func changePassword(_ userDict: [String: String], completion: @escaping (NSError?)->()) {
        
        guard let user = UserService.sharedInstance.currentUser, let id = user.id, let token = user.accessToken else {
            completion(NSError(domain: "Trying to update user details but no user found!", code: 0, userInfo: nil))
            return
        }
        
        Alamofire.request(String(format: apiURL + changePasswordEndpoint, id), method:.post, parameters: userDict, encoding: JSONEncoding.default, headers: ["Authorization": "Bearer \(token)"])
            .responseJSON {
            (response) in
            
            let statusCode = response.response?.statusCode
                    
            if statusCode == 403 {
                completion(NSError(domain: "UserService", code: 403, userInfo: nil))
                return
            }
                
            switch response.result {
            
            case .success(let response):
                print(response)                
                
                let res = response as! NSDictionary

                if let json = res["errors"] as? [[String: AnyObject]],
                    let errors = json[0] as [String: AnyObject]?,
                    let status = errors["status"] as? NSNumber,
                    let messages = errors["messages"] as? [String: AnyObject],
                        messages.first != nil {
                    
                    completion(NSError(domain: "UserService", code: status.intValue, userInfo: messages))
                } else {
                    
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
    
    /* 2016-10-12 by Alex */
    static func resetPassword(_ email: String, completion: @escaping (NSError?)->()) {
        
        Alamofire.request(apiURL + resetPasswordEndpoint, method:.post, parameters: [
            "email": email], encoding: JSONEncoding.default, headers: ["Accept": "application/json"])
            .responseJSON {
                (response) in
                
                switch response.result {
                    
                case .success(let response):
                    print(response)
                    
                    let res = response as! NSDictionary
                    
                    if let json = res["error"] as? [[String: AnyObject]],
                        let errors = json[0] as [String: AnyObject]?,
                        let status = errors["status"] as? NSNumber,
                        let messages = errors["messages"] as? [String: AnyObject],
                        messages.first != nil {
                        
                        completion(NSError(domain: "UserService", code: status.intValue, userInfo: messages))
                    } else {
                        
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
    
    private static func getDetails(_ json: [String: AnyObject]) {
        
        sharedInstance.currentUser?.id = json["id"] as? String
        sharedInstance.currentUser?.firstName = json["first_name"] as? String
        sharedInstance.currentUser?.surname = json["surname"] as? String
        sharedInstance.currentUser?.address = json["address"] as? String
        sharedInstance.currentUser?.insurer = json["insurer"] as? String
        sharedInstance.currentUser?.telephoneNumber = json["telephone_number"] as? String
        sharedInstance.currentUser?.vehicleRegistration = json["vehicle_registration"] as? String

    }
}

extension UserService {
    
    static func saveCurrentUser() {
    
        UserDefaults.standard.setValue(UserService.sharedInstance.currentUser?.toJSON(), forKey: kSavedUser)
    }
    
    static func loadCurrentUser() {
        
        if let json = UserDefaults.standard.value(forKey: kSavedUser) as? [String: String] {
            UserService.sharedInstance.currentUser = User(json: json)
        }
    }
    
    static func logOut() {
        
        UserService.sharedInstance.currentUser = nil
        saveCurrentUser()
    }
}
