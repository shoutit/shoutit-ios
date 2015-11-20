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

class SHApiShoutService: NSObject {
    
    private let SHOUTS = SHApiManager.sharedInstance.BASE_URL + "/shouts"
    private var is_last_page_offer: Bool?
    private var is_last_page_request: Bool?
    private var currentPageOffers = 0
    private var currentPageRequests = 0
    private var offerShouts = [SHShout]()
    private var totalCounts = 0
    private var shouts = [SHShout]()
    var filter: SHFilter?
    var requestShouts = []
    
    override init() {
        is_last_page_offer = true
        is_last_page_request = true
    }

    func loadShoutStreamForLocation(location: SHAddress, page: Int, ofType: Int, query: String, cacheResponse: SHShoutMeta -> Void, completionHandler: Response<SHShoutMeta, NSError> -> Void) {
        let sendType = (ofType == 0) ? "offer" : "request"
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
        if(!query.isEmpty) {
            params["search"] = query
        }
       SHApiManager.sharedInstance.get(SHOUTS, params: params, cacheResponse: cacheResponse, completionHandler: completionHandler)
    }
    
    func refreshStreamForLocation(location: SHAddress, ofType: Int, cacheResponse: SHShoutMeta -> Void, completionHandler: Response<SHShoutMeta, NSError> -> Void) {
        if (ofType == 0) {
            self.offerShouts.removeAll()
            self.currentPageOffers = 1
//            self.loadShoutStreamForLocation(location, page: self.currentPageOffers, ofType: ofType, query: "", cacheResponse: { (shShoutMeta) -> Void in
//                // Do nothing
//                }, completionHandler: { (response) -> Void in
//                // Success
//                    if(response.result.isSuccess) {
//                        self.offerShouts = (response.result.value?.results)!
//                        self.is_last_page_offer = response.result.value?.next == "null" ? true : false
//                    } else {
//                        // Do Nothing
//                    }
//                    
//            })
            self.loadShoutStreamForLocation(location, page: self.currentPageOffers, ofType: ofType, query: "", cacheResponse: cacheResponse, completionHandler: completionHandler)
        } else {
            self.requestShouts = []
            self.currentPageRequests = 1
            self.loadShoutStreamForLocation(location, page: self.currentPageRequests, ofType: ofType, query: "", cacheResponse: cacheResponse, completionHandler: completionHandler)
        }
    }
    
    func searchStreamForLocation(location: SHAddress, ofType: Int, query: String, cacheResponse: SHShoutMeta -> Void, completionHandler: Response<SHShoutMeta, NSError> -> Void) {
        if (ofType == 0) {
            self.offerShouts.removeAll()
            self.currentPageOffers = 1
            self.loadShoutStreamForLocation(location, page: self.currentPageOffers, ofType: ofType, query: query, cacheResponse: cacheResponse, completionHandler: completionHandler)
        } else {
            self.requestShouts = []
            self.currentPageRequests = 1
            self.loadShoutStreamForLocation(location, page: self.currentPageRequests, ofType: ofType, query: query, cacheResponse: cacheResponse, completionHandler: completionHandler)
        }
    }
    
    func loadShoutStreamNextPageForLocation(location: SHAddress, ofType: Int, query: String) {
        if (self.isMoreOfType(ofType)) {
            if (ofType == 0) {
                self.currentPageOffers++
                self.loadShoutStreamForLocation(location, page: self.currentPageOffers, ofType: ofType, query: query, cacheResponse: { (shShoutMeta) -> Void in
                    // Do Nothing
                    }, completionHandler: { (response) -> Void in
                        // Success
                })
            }
        } else {
            self.currentPageRequests++
            self.loadShoutStreamForLocation(location, page: self.currentPageRequests, ofType: ofType, query: query, cacheResponse: { (shShoutMeta) -> Void in
                // Do Nothing
                }, completionHandler: { (response) -> Void in
                    // Success
            })
        }
    }
    
    func isMoreOfType(type: Int) -> Bool {
        if(type == 1) {
            if let isLastPageReq = self.is_last_page_request {
                return !isLastPageReq
            }
            
        } else {
            if let isLastPageOffer = self.is_last_page_offer {
                return !isLastPageOffer
            }
        }
        return false
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
    
//    - (void)loadShoutMapWithBottomLeft:(CLLocationCoordinate2D)down_left topRight:(CLLocationCoordinate2D)up_right zoom:(int)zoom
//    {
//    
//    NSDictionary *coordinates = @{@"down_left_lat":@(down_left.latitude),
//    @"down_left_lng":@(down_left.longitude),
//    @"up_right_lat":@(up_right.latitude),
//    @"up_right_lng":@(up_right.longitude),
//    @"zoom":@(zoom)};
//    
//    NSMutableDictionary* params = [NSMutableDictionary new] ;
//    if(self.filter)
//    {
//    params = [self.filter getShoutFilterQuery];
//    }else{
//    [params setObject:[[[[SHLoginModel sharedModel] selfUser] userLocation]city] forKey:@"city"];
//    [params setObject:[[[[SHLoginModel sharedModel] selfUser] userLocation]countryCode] forKey:@"country"];
//    }
//    [params setValuesForKeysWithDictionary:coordinates];
//    
//    [SHRequestManager get:SH_SHOUTS_URL params:params success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult)
//    {
//    [self.shouts removeAllObjects];
//    [self.shouts addObjectsFromArray:mappingResult.dictionary[@"results"]];
//    NSDictionary *response = [NSJSONSerialization JSONObjectWithData:operation.HTTPRequestOperation.responseData options:kNilOptions error:nil];
//    self.totalCount = [response[@"count"] intValue];
//    [self didFinishLoad];
//    
//    }
//    failure:^(RKObjectRequestOperation *operation, NSError *error)
//    {
//    [self didFailLoadWithError:error];
//    }];
//    
//    }
    

}
