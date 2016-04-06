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
import Curry
import Ogra

struct ShoutParams {
    let type: Variable<ShoutType>
    var title: Variable<String?>
    var text:  Variable<String?>
    var price:  Variable<Double?>

    var currency:  Variable<Currency?>
    
    var images:  Variable<[String]?>
    var videos:  Variable<[Video]?>
    
    var category:  Variable<Category?>
    
    var location:  Variable<Address?>
    var publishToFacebook:  Variable<Bool>
    var filters:  Variable<[Filter: FilterValue]>
    
    var shout: Shout?
    
}

extension ShoutParams: Encodable {
    func encode() -> JSON {
        
        var values : [String: JSON] = [:]
        
        values["type"] = self.type.value.rawValue.encode()
        values["title"] = self.title.value.encode()
        values["text"] = self.text.value.encode()
        
        if self.price.value > 0 {
            values["price"] = (self.price.value! * 100).encode()
            if let currency = self.currency.value?.code {
                values["currency"] = currency.encode()
            }
        } else if self.price.value == 0 {
            values["price"] = JSON.Number(0)
            if let currency = self.currency.value?.code {
                values["currency"] = currency.encode()
            }
        } else {
            values["price"] = JSON.Null
            values["currency"] = JSON.Null
        }
                
        values["images"] = self.images.value.encode()
        values["videos"] = self.videos.value.encode()
        
        if let category = self.category.value {
            values["category"] = category.encode()
        } else {
           values["category"] = JSON.Null
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

        return JSON.Object(values)
    }
}