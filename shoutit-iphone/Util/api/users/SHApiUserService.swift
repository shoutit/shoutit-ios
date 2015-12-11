//
//  SHApiUserService.swift
//  shoutit-iphone
//
//  Created by Hitesh Sondhi on 07/11/15.
//  Copyright © 2015 Shoutit. All rights reserved.
//

import UIKit
import Alamofire
import AWSS3
import Bolts

class SHApiUserService: NSObject {
    
    private let USERS_URL_NAME = SHApiManager.sharedInstance.BASE_URL + "/users/%@"
    private let SH_USERS_URL = SHApiManager.sharedInstance.BASE_URL + "/users"
    private let SH_TAGS_URL = SHApiManager.sharedInstance.BASE_URL + "/tags"

    func updateLocation(userName: String, latitude: Float, longitude: Float, completionHandler: Response<SHUser, NSError> -> Void) {
        let params: [String: AnyObject] = [
            "location" : [
                "latitude": latitude,
                "longitude": longitude
            ]
        ]
        SHApiManager.sharedInstance.patch(String(format: USERS_URL_NAME, userName), params: params, completionHandler: completionHandler)
    }
    
    func editUser(username: String, userDict: Dictionary<String, AnyObject>, cacheResponse: SHUser -> Void, completionHandler: Response<SHUser, NSError> -> Void) {
        let urlString = String(format: USERS_URL_NAME, arguments: [username])
        SHApiManager.sharedInstance.patch(urlString, params: userDict, cacheResponse: cacheResponse, completionHandler: completionHandler)
    }
    
    func loadUserDetails(username: String, cacheResponse: SHUser -> Void, completionHandler: Response<SHUser, NSError> -> Void) {
        let urlString = String(format: USERS_URL_NAME, arguments: [username])
        let params = [String: AnyObject]()
        SHApiManager.sharedInstance.get(urlString, params: params, cacheResponse: cacheResponse, completionHandler: completionHandler)
    }
    
    func changeUserImage(username: String, media: SHMedia, completionHandler: Response<SHMedia, NSError> -> Void) {
        var tasks: [AWSTask] = []
        let aws = SHAmazonAWS()
        if let image = media.image, let task = aws.getUserImageTask(image) {
            tasks.append(task)
        }
        
        NetworkActivityManager.addActivity()
        BFTask(forCompletionOfAllTasks: tasks).continueWithBlock { (task) -> AnyObject! in
            NetworkActivityManager.removeActivity()
            let urlString = String(format: self.USERS_URL_NAME, arguments: [username])
            let params = ["image" : aws.images]
            SHApiManager.sharedInstance.patch(urlString, params: params, cacheKey: nil, cacheResponse: nil, completionHandler: completionHandler)
            return nil
        }
    }
    
    func searchUserQuery(query: String, page: Int, param: String, cacheResponse: SHUsersMeta -> Void, completionHandler: Response<SHUsersMeta, NSError> -> Void) {
        var params:[String: AnyObject] = ["page": page, "page_size": Constants.Common.SH_PAGE_SIZE]
        if (!query.isEmpty) {
            params["search"] = query
        }
        SHApiManager.sharedInstance.get(SH_USERS_URL, params: params, cacheResponse: cacheResponse, completionHandler: completionHandler)
    }
    
    func loadUsersFor(username: String, param: String, type: String, page: Int, cacheResponse: SHUsersMeta -> Void, completionHandler: Response<SHUsersMeta, NSError> -> Void) {
        let urlString = String(format: USERS_URL_NAME + "/%@", arguments: [username, param.lowercaseString])
        var params: [String: AnyObject] = ["page": page, "page_size": Constants.Common.SH_PAGE_SIZE]
        if(!type.isEmpty) {
            params["type"] = type
        }
        SHApiManager.sharedInstance.get(urlString, params: params, cacheResponse: cacheResponse, completionHandler: completionHandler)
    }
    
    func loadUserTags(username: String, param: String, type: String, page: Int, cacheResponse: SHTagMeta -> Void, completionHandler: Response<SHTagMeta, NSError> -> Void) {
        let urlString = String(format: USERS_URL_NAME + "/%@", arguments: [username, param.lowercaseString])
        var params: [String: AnyObject] = ["page": page, "page_size": Constants.Common.SH_PAGE_SIZE]
        if(!type.isEmpty) {
            params["type"] = type
        }
        SHApiManager.sharedInstance.get(urlString, params: params, cacheResponse: cacheResponse, completionHandler: completionHandler)
    }
}
