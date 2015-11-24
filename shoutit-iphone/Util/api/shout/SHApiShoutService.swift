//
//  SHApiShoutService.swift
//  shoutit-iphone
//
//  Created by Vishal Thakur on 15/11/15.
//  Copyright © 2015 Shoutit. All rights reserved.
//

import UIKit
import Alamofire
import MapKit
import AWSS3
import Bolts
import ObjectMapper

class SHApiShoutService: NSObject {
    
    private let SHOUTS = SHApiManager.sharedInstance.BASE_URL + "/shouts"
    private var currentPage = 0
    private var totalCounts = 0
    var filter: SHFilter?

    func loadShoutStreamForLocation(location: SHAddress, page: Int, var type: ShoutType, query: String?, cacheResponse: SHShoutMeta -> Void, completionHandler: Response<SHShoutMeta, NSError> -> Void) {
        if type == ShoutType.VideoCV {
            type = .Request
        }
        let sendType = type.rawValue
        var params = [String: AnyObject]()
        if let filter = self.filter {
            params = filter.getShoutFilterQuery()
        } else {
            if let location = SHAddress.getUserOrDeviceLocation() {
                params["city"] = location.city
                params["country"] = location.country
            }
            params["shout_type"] = sendType
        }
        params["page_size"] = Constants.Common.SH_PAGE_SIZE
        params["page"] = page
        if let q = query where !q.isEmpty {
            params["search"] = query
        }
        SHApiManager.sharedInstance.get(SHOUTS, params: params, cacheResponse: cacheResponse, completionHandler: completionHandler)
    }
    
    func refreshStreamForLocation(location: SHAddress, type: ShoutType, cacheResponse: SHShoutMeta -> Void, completionHandler: Response<SHShoutMeta, NSError> -> Void) {
        self.currentPage = 1
        self.loadShoutStreamForLocation(location, page: self.currentPage, type: type, query: "", cacheResponse: cacheResponse, completionHandler: completionHandler)
    }
    
    func searchStreamForLocation(location: SHAddress, type: ShoutType, query: String, cacheResponse: SHShoutMeta -> Void, completionHandler: Response<SHShoutMeta, NSError> -> Void) {
        self.currentPage = 1
        self.loadShoutStreamForLocation(location, page: self.currentPage, type: type, query: query, cacheResponse: cacheResponse, completionHandler: completionHandler)
    }
    
    func loadShoutStreamNextPageForLocation(location: SHAddress, type: ShoutType, query: String?, cacheResponse: SHShoutMeta -> Void, completionHandler: Response<SHShoutMeta, NSError> -> Void) {
        self.currentPage++
        self.loadShoutStreamForLocation(location, page: self.currentPage, type: type, query: query, cacheResponse: cacheResponse, completionHandler: completionHandler)
    }
    
    func loadShoutMapWithBottomLeft(down_left: CLLocationCoordinate2D, up_right: CLLocationCoordinate2D, zoom: Double, cacheResponse: SHShoutMeta -> Void, completionHandler: Response<SHShoutMeta, NSError> -> Void) {
        let coordinates = ["down_left_lat": down_left.latitude, "down_left_lng": down_left.longitude, "up_right_lat": up_right.latitude, "up_right_lng": up_right.longitude, "zoom": zoom]
        var params = [String: AnyObject]()
        if let filter = self.filter {
            params = filter.getShoutFilterQuery()
        } else {
            if let location = SHAddress.getUserOrDeviceLocation() {
                params["city"] = location.city
                params["country"] = location.country
            }
        }
        for (key,value) in coordinates {
            params[key] = value
        }
    
        SHApiManager.sharedInstance.get(SHOUTS, params: params, cacheResponse: cacheResponse, completionHandler: completionHandler)
    }
    
    func getCurrentPage() -> Int {
        return currentPage
    }
    
    func resetPage() {
        self.currentPage = 0
        self.totalCounts = 0
    }
    
    func loadShoutDetail(shoutID: String, cacheResponse: SHShout -> Void, completionHandler: Response<SHShout, NSError> -> Void) {
        let urlString = String(format: SHOUTS + "/%@", arguments: [shoutID])
        let params = [String: AnyObject]()
        SHApiManager.sharedInstance.get(urlString, params: params, cacheResponse: cacheResponse, completionHandler: completionHandler)
    }

    func postShout(shout: SHShout, media: [SHMedia], completionHandler: Response<SHShout, NSError> -> Void) {
        var tasks: [AWSTask] = []
        let aws = SHAmazonAWS()
        for shMedia in media {
            if shMedia.isVideo {
                if let url = shMedia.localUrl, let thumbImage = shMedia.localThumbImage {
                    let task = aws.getVideoUploadTasks(url, image: thumbImage)
                    tasks += task
                }
            } else {
                if let image = shMedia.image, let task = aws.getShoutImageTask(image) {
                    tasks.append(task)
                }
            }
        }
        NetworkActivityManager.addActivity()
        BFTask(forCompletionOfAllTasks: tasks).continueWithBlock { (task) -> AnyObject! in
            NetworkActivityManager.removeActivity()
            if aws.images.count + aws.videos.count != media.count {
                log.error("All media wasn't uploaded, occured some error!")
            }
            shout.images = aws.images
            shout.videos = aws.videos
            if shout.type == .VideoCV {
                shout.type = .Request
            }
            let params = Mapper().toJSON(shout)
            SHApiManager.sharedInstance.post(self.SHOUTS, params: params, isCachingEnabled: false, cacheKey: nil, cacheResponse: nil, completionHandler: completionHandler)
            return nil
        }
    }
}
