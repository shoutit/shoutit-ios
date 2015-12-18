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
    private var currentPage = 1
    private var currentLocation: SHAddress?
    var filter: SHFilter?
    
    func loadTagSearchForQueryForPage(page: Int, query: String, cacheResponse: SHTagMeta -> Void, completionHandler: Response<SHTagMeta, NSError> -> Void) {
        var params = [String: AnyObject]()
        if let filter = self.filter {
            params = filter.getTagsFilterQuery()
        }
        params["show_is_listening"] = 1
        params["page_size"] = Constants.Common.SH_PAGE_SIZE
        params["page"] = page
        params["search"] = query
        SHApiManager.sharedInstance.get(TAGS_URL, params: params, cacheResponse: cacheResponse, completionHandler: completionHandler)
    }
    
    func searchTagQuery(query: String) {
        self.loadTagSearchForQueryForPage(currentPage, query: query, cacheResponse: { (shTagMeta) -> Void in
            // Do Nothing
            }) { (response) -> Void in
                // Success
        }
    }
    
    func loadTagSearchNextPageForQuery(query: String) {
//        if(self.isMore()) {
//            self.currentPage++
//            self.loadTagSearchForQueryForPage(self.currentPage, query: query, cacheResponse: { (shTagMeta) -> Void in
//                // Do Nothing
//                }, completionHandler: { (response) -> Void in
//                    // Success
//            })
//        }
    }
    
    func loadTopTagsForLocation(location: SHAddress, forPage: Int, cacheResponse: SHTagMeta -> Void, completionHandler: Response<SHTagMeta, NSError> -> Void) {
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
        params["page_size"] = Constants.Common.SH_PAGE_SIZE
        params["page"] = forPage
        SHApiManager.sharedInstance.get(TAGS_URL, params: params, cacheResponse: cacheResponse, completionHandler: completionHandler)
    }

    func refreshTopTagsForLocation (location: SHAddress) {
//        self.currentLocation = location
//        self.currentPage = 1
//        if let currentLocation = self.currentLocation {
//            self.loadTopTagsForLocation(currentLocation, forPage: self.currentPage, cacheResponse: { (shTagMeta) -> Void in
//                // Do Nothing
//                }, completionHandler: { (response) -> Void in
//                    // Success
//                    if (response.result.isSuccess) {
//                        if(self.currentPage == 1) {
//                            self.tags.removeAll()
//                            if let tags = response.result.value {
//                                self.tags = tags.results
//                                self.is_last_page = tags.next == "" ? true : false
//                            }
//                        }
//                    }
//            })
//        }
        
    }
    
    func loadTopTagsNextPage () {
//        if(self.isMore()) {
//            self.currentPage++
//            if let currentLocation = self.currentLocation {
//                self.loadTopTagsForLocation(currentLocation, forPage: self.currentPage, cacheResponse: { (shTagMeta) -> Void in
//                    // Do Nothing
//                    }, completionHandler: { (response) -> Void in
//                        // Success
//                })
//            }
//        }
    }
    
    func loadProfileForTag(tagName: String) {
        self.currentPage = 1
       // let urlString =
    }
    
//    - (void) loadProfileForTag:(NSString*)tagName;
//    {
//    self.currentPage = 1;
//    NSString *urlString = SH_TAG_URL_WITH_ID([tagName urlencode]);
//    [self didStartLoad];
//    [SHRequestManager get:urlString params:nil success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult)
//    {
//    self.tag = [mappingResult firstObject];
//    [self loadShoutsFor:tagName forPage:self.currentPage];
//    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
//    [self didFailLoadWithError:error];
//    }];
//    }
    func loadTagsForPage(page: Int, query: String, cacheResponse: SHTagMeta -> Void, completionHandler: Response<SHTagMeta, NSError> -> Void) {
        var params = [String: AnyObject]()
        if let filter = self.filter {
            params = filter.getTagsFilterQuery()
        }
        params["page_size"] = Constants.Common.SH_PAGE_SIZE
        params["page"] = page
        if (query != "") {
            params["search"] = query
        }
        SHApiManager.sharedInstance.get(TAGS_URL, params: params, cacheResponse: cacheResponse, completionHandler: completionHandler)
        //    [SHRequestManager get:SH_TAGS_URL params:params success:
        //    ^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult)
        //    {
        //    //NSLog(@"%@", operation.HTTPRequestOperation.responseString);
        //
        //    if(page == 0)    [self.tags removeAllObjects];
        //
        //    [self.tags addObjectsFromArray:mappingResult.dictionary[@"results"]];
        //    NSDictionary *response = [NSJSONSerialization JSONObjectWithData:operation.HTTPRequestOperation.responseData options:kNilOptions error:nil];
        //    self.is_last_page = (response[@"next"] == [NSNull null] ) ?true:false;
        //
        //    [self didFinishLoad];
        //    } failure:^(RKObjectRequestOperation *operation, NSError *error)
        //    {
        //    [self didFailLoadWithError:error];
        //    }];

    }
    
    func refreshTagsWithQuery(query: String, cacheResponse: SHTagMeta -> Void, completionHandler: Response<SHTagMeta, NSError> -> Void) {
        self.currentPage = 1
        self.loadTagsForPage(self.currentPage, query: query,cacheResponse: cacheResponse,completionHandler: completionHandler)
    }
    
    func loadTagsNextPageWithQuery(query: String, cacheResponse: SHTagMeta -> Void, completionHandler: Response<SHTagMeta, NSError> -> Void) {
        self.currentPage++
        self.loadTagsForPage(self.currentPage, query: query, cacheResponse: cacheResponse, completionHandler: completionHandler)
    }
    
    func reset() {
        self.currentPage = 1
    }
    
    func unfollowTag(tagName: String, completionHandler: Response<String, NSError> -> Void ) {
        let urlString = String(format: TAGS_URL + "/%@" + "/listen", arguments: [tagName])
        let params = [String: AnyObject]()
        SHApiManager.sharedInstance.delete(urlString, params: params, completionHandler: completionHandler)
    }
    
    func followTag(tagName: String, completionHandler: Response<SHSuccess, NSError> -> Void) {
        let urlString = String(format: TAGS_URL + "/%@" + "/listen", arguments: [tagName])
        let params = [String: AnyObject]()
        SHApiManager.sharedInstance.post(urlString, params: params, completionHandler: completionHandler)
    }
    
    func loadListenersFor(tag: String, cacheResponse: SHUsersMeta -> Void, completionHandler: Response<SHUsersMeta, NSError> -> Void) {
        let urlString = String(format: TAGS_URL + "/%@" + "/listeners", arguments: [tag])
        let params = [String: AnyObject]()
        SHApiManager.sharedInstance.get(urlString, params: params, cacheResponse: cacheResponse, completionHandler: completionHandler)
    }

}

