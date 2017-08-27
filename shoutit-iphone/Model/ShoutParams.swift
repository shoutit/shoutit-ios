//
//  ShoutParams.swift
//  shoutit-iphone
//
//  Created by Piotr Bernad on 02.03.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import UIKit
import RxSwift
import JSONCodable
import ShoutitKit
// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}

// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l > r
  default:
    return rhs < lhs
  }
}


public struct ShoutParams {
    let type: Variable<ShoutType>
    var title: Variable<String?>
    var text:  Variable<String?>
    var price:  Variable<Double?>

    var currency:  Variable<Currency?>
    
    var images:  Variable<[String]?>
    var videos:  Variable<[Video]?>
    
    var category:  Variable<ShoutitKit.Category?>
    
    var location:  Variable<Address?>
    var publishToFacebook:  Variable<Bool>
    var filters:  Variable<[Filter: FilterValue]>
    
    var shout: Shout?
    var mobile:  Variable<String?>
    
    public init(type: ShoutType,
         title: String? = "",
         text: String? = nil,
         price: Double? = nil,
         currency: Currency? = nil,
         images:[String] = [],
         videos: [Video] = [],
         category: ShoutitKit.Category? = nil,
         location: Address? = Account.sharedInstance.user?.location,
         publishToFacebook: Bool = false,
         filters: [Filter : FilterValue] = [:],
         shout: Shout? = nil,
         mobile: String? = nil) {
        
        self.type = Variable(type)
        self.title = Variable(title)
        self.text = Variable(text)
        self.price = Variable(price)
        self.currency = Variable(currency)
        self.images = Variable(images)
        self.videos = Variable(videos)
        self.category = Variable(category)
        self.location = Variable(location)
        self.publishToFacebook = Variable(publishToFacebook)
        self.filters = Variable(filters)
        self.shout = shout
        self.mobile = Variable(mobile)
    }
}

extension ShoutParams: JSONEncodable {
    
    public func toJSON() throws -> Any {
        return try JSONEncoder.create({ (encoder) -> Void in
            try encoder.encode(type.value, key: "type")
            try encoder.encode(title.value, key: "title")
            try encoder.encode(text.value, key: "text")
            try encoder.encode(mobile.value, key: "mobile")
            
            if self.price.value > 0 {
                try encoder.encode((Int(self.price.value! * 100)), key: "price")
                
                if let currency = self.currency.value?.code {
                    try encoder.encode(currency, key: "currency")
                }
            } else if self.price.value == 0 {
                try encoder.encode(0, key: "price")
                
                if let currency = self.currency.value?.code {
                    try encoder.encode(currency, key: "currency")
                }
            } else {
                try encoder.encode(nil, key: "price")
                try encoder.encode(nil, key: "currency")
                
            }
            
            try encoder.encode(images.value, key: "images")
            try encoder.encode(videos.value, key: "videos")
            
            if let category = self.category.value {
               try encoder.encode(category, key: "category")
            } else {
               try encoder.encode(nil, key: "category")
            }
            
            try encoder.encode(location.value, key: "location")
            try encoder.encode(publishToFacebook.value, key: "publish_to_facebook")
            
            
            try encoder.encode(filters.value, key: "filters")
        })
    }

    
//    public func encode() -> JSON {
//        
//        var values : [String: JSON] = [:]
//        
//        values["images"] = self.images.value.encode()
//        values["videos"] = self.videos.value.encode()
//        
//        if let category = self.category.value {
//            values["category"] = category.encode()
//        } else {
//           values["category"] = JSON.null
//        }
//        
//        values["location"] = self.location.value.encode()
//        
//        values["publish_to_facebook"] = self.publishToFacebook.value.encode()
//        
//        var shoutFilters : [JSON] = []
//        
//        for (filter, filterValue) in self.filters.value {
//            shoutFilters.append(FilterResult(filter: filter, value: filterValue).encode())
//        }
//        
//        if shoutFilters.count > 0 {
//            values["filters"] = shoutFilters.encode()
//        }
//
//        return JSON.object(values)
//    }
}
