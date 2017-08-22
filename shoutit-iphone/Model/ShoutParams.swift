//
//  ShoutParams.swift
//  shoutit-iphone
//
//  Created by Piotr Bernad on 02.03.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import UIKit
import RxSwift
import Argo

import Ogra
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

extension ShoutParams: Encodable {
    
    public func encode() -> JSON {
        
        var values : [String: JSON] = [:]
        
        values["type"] = self.type.value.rawValue.encode()
        values["title"] = self.title.value.encode()
        values["text"] = self.text.value.encode()
        values["mobile"] = self.mobile.value.encode()
        
        if self.price.value > 0 {
            values["price"] = (Int(self.price.value! * 100)).encode()
            if let currency = self.currency.value?.code {
                values["currency"] = currency.encode()
            }
        } else if self.price.value == 0 {
            values["price"] = JSON.number(0)
            if let currency = self.currency.value?.code {
                values["currency"] = currency.encode()
            }
        } else {
            values["price"] = JSON.null
            values["currency"] = JSON.null
        }
                
        values["images"] = self.images.value.encode()
        values["videos"] = self.videos.value.encode()
        
        if let category = self.category.value {
            values["category"] = category.encode()
        } else {
           values["category"] = JSON.null
        }
        
        values["location"] = self.location.value.encode()
        
        values["publish_to_facebook"] = self.publishToFacebook.value.encode()
        
        var shoutFilters : [JSON] = []
        
        for (filter, filterValue) in self.filters.value {
            shoutFilters.append(FilterResult(filter: filter, value: filterValue).encode())
        }
        
        if shoutFilters.count > 0 {
            values["filters"] = shoutFilters.encode()
        }

        return JSON.object(values)
    }
}
