//
//  SHApiTagsService.swift
//  shoutit-iphone
//
//  Created by Vishal Thakur on 15/11/15.
//  Copyright © 2015 Shoutit. All rights reserved.
//

import UIKit
import Alamofire

class SHApiTagsService: NSObject {
    
    private let TAGS_URL = SHApiManager.sharedInstance.BASE_URL + "/tags"
    private var filter: SHFilter?
    private var is_last_page = true
    private var currentPage = 1
    private var tags: [String]?
    private var currentLocation: SHAddress?
    
    override init() {
        // Custom initialization
        currentPage = 1
        tags = [String]()
    }
    
    func isMore() -> Bool {
        return !self.is_last_page
    }
    
    func loadTagSearchForQueryForPage(page: Int, query: String, cacheResponse: SHTag -> Void, completionHandler: Response<SHTag, NSError> -> Void) {
        var params = [String: AnyObject]()
        if let filter = self.filter {
            params = filter.getTagsFilterQuery()
        }
        params["show_is_listening"] = 1
        params["page_size"] = Constants.Shout.SH_PAGE_SIZE
        params["page"] = page
        params["search"] = query
        SHApiManager.sharedInstance.get(TAGS_URL, params: params, cacheResponse: cacheResponse, completionHandler: completionHandler)
    }
    
    func searchTagQuery(query: String) {
        self.loadTagSearchForQueryForPage(currentPage, query: query, cacheResponse: { (shTag) -> Void in
            // Do Nothing
            }) { (response) -> Void in
                // Success
        }
    }
    
    func loadTagSearchNextPageForQuery(query: String) {
        if(self.isMore()) {
            self.currentPage++
            self.loadTagSearchForQueryForPage(self.currentPage, query: query, cacheResponse: { (shTag) -> Void in
                // Do Nothing
                }, completionHandler: { (response) -> Void in
                    // Success
            })
        }
    }
    
    func loadTopTagsForLocation(location: SHAddress, forPage: Int, cacheResponse: SHTag -> Void, completionHandler: Response<SHTag, NSError> -> Void) {
        var params = [String: AnyObject]()
        if let filter = self.filter {
            params = filter.getTagsFilterQuery()
        } else {
            if let location = SHAddress.getUserOrDeviceLocation() {
                params["city"] = location.city
                params["country"] = location.country
            }
        }
        params["type"] = "featured"
        params["page_size"] = Constants.Shout.SH_PAGE_SIZE
        params["page"] = forPage
        SHApiManager.sharedInstance.get(TAGS_URL, params: params, cacheResponse: cacheResponse, completionHandler: completionHandler)
    }

    func refreshTopTagsForLocation (location: SHAddress) {
        self.currentLocation = location
        self.currentPage = 1
        if let currentLocation = self.currentLocation {
            self.loadTopTagsForLocation(currentLocation, forPage: self.currentPage, cacheResponse: { (shTag) -> Void in
                // Do Nothing
                }, completionHandler: { (response) -> Void in
                    // Success
            })
        }
        
    }
    
    func loadTopTagsNextPage () {
        if(self.isMore()) {
            self.currentPage++
            if let currentLocation = self.currentLocation {
                self.loadTopTagsForLocation(currentLocation, forPage: self.currentPage, cacheResponse: { (shTag) -> Void in
                    // Do Nothing
                    }, completionHandler: { (response) -> Void in
                        // Success
                })
            }
        }
    }

}

