//
//  SHApiShoutService.swift
//  shoutit-iphone
//
//  Created by Vishal Thakur on 15/11/15.
//  Copyright © 2015 Shoutit. All rights reserved.
//

import UIKit

class SHApiShoutService: NSObject {
    
    func loadShoutStreamForLocation(location: SHAddress, page: Int, ofType: Int, query: String) {
        let sendType = ofType == 0 ? "offer" : "request"
        let params = []
        
    }
    
//    - (void)loadShoutStreamForLocation:(SHAddress*)location  page:(int)page ofType:(int)type query:(NSString*)query
//    {
//    NSString* sendType = (type == 0)?@"offer":@"request";
//    NSMutableDictionary* params = [NSMutableDictionary new] ;
//    if(self.filter)
//    {
//    params = [self.filter getShoutFilterQuery];
//    }else{
//    [params setObject:location.city forKey:@"city"];
//    [params setObject:location.countryCode forKey:@"country"];
//    [params setObject:sendType forKey:@"shout_type"];
//    }
//    if(!params)
//    params = [NSMutableDictionary new];
//    [params setObject:SH_PAGE_SIZE forKey:@"page_size"];
//    [params setObject:@(page) forKey:@"page"];
//    //NSString *cityParam = [NSString stringWithFormat:@"city=%@&",[city  urlencode]];
//    //NSString *urlString =  [SH_SHOUT_GET_STREAM_URL stringByAppendingFormat:@"?page=%d&%@shout_types=%d", page, ([city isEqual: @""] || city == nil)?@"":cityParam ,sendType];
//    
//    
//    if (query)
//    {
//    [params setObject:query forKey:@"search"];
//    }
//    [SHRequestManager get:SH_SHOUTS_URL params:params success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult)
//    {
//    //NSLog(@"%@", operation.HTTPRequestOperation.responseString);
//    if (type == 0)
//    {
//    //if(beforeTimestamp == 0)    [self.offerShouts removeAllObjects];
//    
//    [self.offerShouts addObjectsFromArray:mappingResult.dictionary[@"results"]];
//    NSDictionary *response = [NSJSONSerialization JSONObjectWithData:operation.HTTPRequestOperation.responseData options:kNilOptions error:nil];
//    self.is_last_page_offer = (response[@"next"] == [NSNull null] ) ?true:false;
//    }else{
//    //if(beforeTimestamp == 0)    [self.requestShouts removeAllObjects];
//    [self.requestShouts addObjectsFromArray:mappingResult.dictionary[@"results"]];
//    NSDictionary *response = [NSJSONSerialization JSONObjectWithData:operation.HTTPRequestOperation.responseData options:kNilOptions error:nil];
//    self.is_last_page_request = (response[@"next"] == [NSNull null] ) ?true:false;
//    }
//    [self didFinishLoad];
//    } failure:^(RKObjectRequestOperation *operation, NSError *error)
//    {
//    [self didFailLoadWithError:error];
//    }];
//    }


}
