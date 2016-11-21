//
//  MediaService.swift
//  4Sight
//
//  Created by Simon Withington on 17/06/2016.
//  Copyright © 2016 Appitized. All rights reserved.
//

import Foundation
import Alamofire

class MediaService: NSObject {

    static func createVideo(completion:@escaping (NSError?)->()) {
        
        guard let user = UserService.sharedInstance.currentUser, let id = user.id, let token = user.accessToken else {
            completion(NSError(domain: "Trying to create a video but no user found!", code: 0, userInfo: nil))
            return
        }
        
        let timestamp = NSDate().timeIntervalSince1970 // 2016-10-14 by Alex
        
        debugPrint("The SpeedData - \(IncidentService.sharedInstance.currentIncident.speedData)")
        debugPrint("The TimeStamp - \(timestamp)")
        Alamofire.request(String(format: apiURL + videoCreateEndpoint, id), method:.post , parameters: ["lat": IncidentService.sharedInstance.currentIncident.latitude, "long": IncidentService.sharedInstance.currentIncident.longitude, "speed_data": IncidentService.sharedInstance.currentIncident.speedData, "timestamp": timestamp], encoding: JSONEncoding.default, headers: ["Authorization": "Bearer \(token)", "Accept": "application/json"]).responseJSON {
            response in
            
            switch response.result {
                
            case .success(let response):
                print(response)
                let res = response as! NSDictionary
                if let json = res["errors"] as? [[String: AnyObject]],
                    let errors = json[0] as [String: AnyObject]?,
                    let status = errors["status"] as? NSNumber,
                    let messages = errors["messages"] as? [NSObject: AnyObject] {
                    
                    completion(NSError(domain: "MediaService", code: status.intValue, userInfo: messages))
                } else if let json = res["data"] as? [String: AnyObject], let videoID = json["id"] as? String {
                    IncidentService.sharedInstance.currentIncident.videoID = videoID
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

    static func uploadVideo(completion:@escaping (NSError?)->()) {
        
        guard let user = UserService.sharedInstance.currentUser, let token = user.accessToken, let videoData = IncidentService.sharedInstance.currentIncident.videoData else {
            completion(NSError(domain: "Trying to upload a video but user or video missing!", code: 0, userInfo: nil))
            return
        }

        let urlString = String(format:apiURL + videoUploadEndpoint, IncidentService.sharedInstance.currentIncident.videoID)
        
        guard let urlRequest = MediaService.urlRequestWithComponents(urlString: urlString, token: token, parameters: ["Authorization": "Bearer \(token)", "Accept": "application/json"], videoData: videoData, paramName: kVideoParam) else {
            completion(NSError(domain: "Trying to upload a video but something is missing!", code: 0, userInfo: nil))
            return
        }
        
        Alamofire.upload(urlRequest.1, with: urlRequest.0)
//            .progress { (bytesWritten, totalBytesWritten, totalBytesExpectedToWrite) in
//                debugPrint("\(totalBytesWritten) / \(totalBytesExpectedToWrite)")
//            }
            .uploadProgress(closure: { (Progress) in
                debugPrint("\(Progress)")
            })
            .responseJSON { (request) in
                if let response = request.response, response.statusCode == 200 {
                    completion(nil)
                } else {
                    completion(NSError(domain: "MediaService: Video upload failed", code: 0, userInfo: nil))
                }
        }
    }
    
    static func uploadImage(imageData: Data, type:String, index:Int, completion: @escaping (NSError?)->()) {
        
        guard let user = UserService.sharedInstance.currentUser, let token = user.accessToken, let id = IncidentService.sharedInstance.currentIncident.id else {
            completion(NSError(domain: "Trying to upload an image but user missing!", code: 0, userInfo: nil))
            return
        }
        
        let urlString = String(format:apiURL + addImagesEndpoint, id)
        
        guard let urlRequest : (URLRequestConvertible, Data) = MediaService.urlRequestWithComponents(urlString: urlString, token: token, parameters: ["Authorization": "Bearer \(token)", "Accept": "application/json", "type": "\(type)"], photoData: imageData, paramName: kImageParam, index: index) else {
            completion(NSError(domain: "Trying to upload an image but something is missing!", code: 0, userInfo: nil))
            return
        }
        
        //Alamofire.upload(urlRequest.1, with: urlRequest.0)
        Alamofire.upload(urlRequest.1, with: urlRequest.0)
            .uploadProgress(closure: { (Progress) in
                debugPrint("\(Progress)")
            })
            .responseJSON { (request) in
                if let response = request.response, response.statusCode == 200 {
                    completion(nil)
                } else {
                    completion(NSError(domain: "MediaService: Image upload failed", code: 0, userInfo: nil))
                }
        }
    }
        
    private static func urlRequestWithComponents(urlString:String, token: String?, parameters:[String: String], videoData:Data, paramName:String) -> (URLRequestConvertible, Data)? {
        
        var request = URLRequest(url: URL(string: urlString)!)
        request.httpMethod = "POST" //Alamofire.Method.POST.rawValue
        let boundaryConstant = "_4SightBoundary_"
        let contentType = "multipart/form-data;charset=utf-8;boundary="+boundaryConstant
        request.setValue(contentType, forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        if let token = token {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        
        var uploadData = Data()
        uploadData.append("\r\n--\(boundaryConstant)\r\n".data(using: String.Encoding.utf8)!)
        uploadData.append("Content-Disposition: form-data; name=\"\(paramName)\"; filename=\"video.\(uploadVideoFileExtension)\"\r\n".data(using: String.Encoding.utf8)!)
        uploadData.append("Content-Type: video/\(uploadVideoFileExtension)\r\n\r\n".data(using: String.Encoding.utf8)!)
        uploadData.append(videoData)
        
        
        for (key, value) in parameters {
            uploadData.append("\r\n--\(boundaryConstant)\r\n".data(using: String.Encoding.utf8)!)
            uploadData.append("Content-Disposition: form-data; name=\"\(key)\"\r\n\r\n\(value)".data(using: String.Encoding.utf8)!)
        }
        uploadData.append("\r\n--\(boundaryConstant)--\r\n".data(using: String.Encoding.utf8)!)
        
        do {
            let encoded_request = try Alamofire.URLEncoding.default.encode(request, with: nil)
            return (encoded_request, uploadData)
        } catch {
            return nil
        }
    }
    
    private static func urlRequestWithComponents(urlString:String, token: String?, parameters:[String: String], photoData:Data, paramName:String, index:Int) -> (URLRequestConvertible, Data)? {
        
        var request = URLRequest(url: URL(string: urlString)!)
        request.httpMethod = "POST" //Alamofire.Method.POST.rawValue
        let boundaryConstant = "_4SightBoundary_"
        let contentType = "multipart/form-data;charset=utf-8;boundary="+boundaryConstant
        request.setValue(contentType, forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        if let token = token {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        
        var uploadData = Data()
        uploadData.append("\r\n--\(boundaryConstant)\r\n".data(using: String.Encoding.utf8)!)
        uploadData.append("Content-Disposition: form-data; name=\"\(paramName)\"; filename=\"image_\(index).\(uploadImageFileExtension)\"\r\n".data(using: String.Encoding.utf8)!)
        uploadData.append("Content-Type: image/\(uploadImageFileExtension)\r\n\r\n".data(using: String.Encoding.utf8)!)
        uploadData.append(photoData)
        
        
        for (key, value) in parameters {
            uploadData.append("\r\n--\(boundaryConstant)\r\n".data(using: String.Encoding.utf8)!)
            uploadData.append("Content-Disposition: form-data; name=\"\(key)\"\r\n\r\n\(value)".data(using: String.Encoding.utf8)!)
        }
        uploadData.append("\r\n--\(boundaryConstant)--\r\n".data(using: String.Encoding.utf8)!)
        
        //return (Alamofire.ParameterEncoding.url.encode(request, parameters: nil).0, uploadData)
        do {
            let encoded_request = try Alamofire.URLEncoding.default.encode(request, with: nil)
            return (encoded_request, uploadData)
        } catch {
            return nil
        }
    }
}
