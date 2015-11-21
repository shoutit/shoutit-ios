//
//  SHFilter.swift
//  shoutit-iphone
//
//  Created by Vishal Thakur on 15/11/15.
//  Copyright © 2015 Shoutit. All rights reserved.
//

import UIKit

class SHFilter: NSObject {

    private var before: NSDate?
    private var after: NSDate?
    var selectedTypeIndex: Int?
    var selectedCategoryIndex: Int?
    var tags = []
    var isApplied = false
    var location: SHAddress?
    var minPrice: String?
    var maxPrice: String?
    var type: String?
    var category: String?
    
    override init () {
        selectedCategoryIndex = 0
        selectedTypeIndex = 0
        before = nil
        after = nil
        minPrice = nil
        maxPrice = nil
        type = "Offer"
        category = NSLocalizedString("All", comment: "All")
    }
    
    func getTagsFilterQuery () -> [String: AnyObject] {
        if(!self.isApplied) {
            return [:]
        }
        if(self.type == NSLocalizedString("Tag", comment: "Tag")) {
            var params = [String: AnyObject]()
            if let location = SHAddress.getUserOrDeviceLocation() {
                params["country"] = location.country
                params["city"] = location.city
            }
            if(self.category != NSLocalizedString("All", comment: "All")) {
                params["category"] = self.category
            }
            return params
        } else {
            return [:]
        }
    }
    
    func getShoutFilterQuery () -> [String: AnyObject] {
        if(!self.isApplied) {
            return [:]
        }
        if (self.type == NSLocalizedString("Tag", comment: "Tag")) {
            return [:]
        } else {
            var params = [String: AnyObject]()
            if((self.before) != nil) {
                params["before"] = self.before?.timeIntervalSince1970
                params["after"] = self.before?.timeIntervalSince1970
            }
            params["shout_type"] = self.type?.lowercaseString
            if let location = SHAddress.getUserOrDeviceLocation() {
                params["country"] = location.country
                params["city"] = location.city
            }
            if let minPrice = self.minPrice where self.minPrice != "" {
                params["min_price"] = minPrice
            }
            if let maxPrice = self.maxPrice where self.maxPrice != "" {
                params["max_price"] = maxPrice
            }
            if (self.category != NSLocalizedString("All", comment: "All")) {
                params["category"] = self.category
            }
            var tagArr = [String]()
            for tag in self.tags {
                tagArr.append(tag.name)
            }
            let tagStr = tagArr.joinWithSeparator(",")
            if (tagStr != ""){
                params["tags"] = tagStr
            }
            return params
        }
    }
    
    func prepareTag(tag: String) -> String {
        var result = tag.stringByReplacingOccurrencesOfString(" & ", withString: "-")
        result = result.stringByReplacingOccurrencesOfString(", ", withString: "-")
        result = result.stringByReplacingOccurrencesOfString("/", withString: "-")
        result = result.stringByReplacingOccurrencesOfString(" ", withString: "-")
        return result.lowercaseString
    }

    func reset () {
        self.isApplied = false
        self.selectedCategoryIndex = 0
        self.selectedTypeIndex = 0
        self.before = nil
        self.after = nil
        self.minPrice = nil
        self.maxPrice = nil
        self.type = "Offer"
        self.category = NSLocalizedString("All", comment: "All")
        self.tags = []
        
    }
    
    func typeList () -> [String] {
        return ["Offer", "Request"]
    }
    
   
}
