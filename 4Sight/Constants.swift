//
//  Constants.swift
//  4Sight
//
//  Created by Simon Withington on 17/06/2016.
//  Copyright © 2016 Appitized. All rights reserved.
//

let kSavedUser = "savedUser"
let kVideoParam = "video_data"
let kImageParam = "image"

let uploadVideoFileExtension = "mp4"
let uploadImageFileExtension = "jpeg"

let apiURL = "https://4sightplus.co.uk/api/"//"http://surefleet.appitized-dev.com/api/"
let oauthURL = "https://4sightplus.co.uk/oauth/token"//"http://surefleet.appitized-dev.com/oauth/access_token"
let clientSecret = "KyELvu1j626AatvAO0vRqiJOBpCBivqwa0Vq0clv"
let clientID = "2"

let registerEndpoint = "register"
let userEndpoint = "user"
let updateUserEndpoint = "users/%@" //2016-10-6 by Alex
let changePasswordEndpoint = "users/%@/password" //2016-10-7 by Alex
let resetPasswordEndpoint = "password/forgot" //2016-10-12 by Alex

let reportIncidentEndpoint = "users/%@/accident"

let videoCreateEndpoint = "users/%@/videos"
let videoUploadEndpoint = "videos/%@"

let addVehiclesEndpoint = "accidents/%@/vehicles"
let addImagesEndpoint = "accidents/%@/photo"
let addWitnessesEndpoint = "accidents/%@/witnesses"

final class Shared {
    static let shared = Shared() //lazy init, and it only runs once
    
    var appRunning : Bool!
    
    var isGrantedNotificationAccess:Bool = false
}
