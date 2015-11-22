//
//  SHFilterMeta.swift
//  shoutit-iphone
//
//  Created by Vishal Thakur on 21/11/15.
//  Copyright © 2015 Shoutit. All rights reserved.
//

import UIKit

class SHFilterMeta: NSObject {
    
    var category: SHFilterCategory?
    var type: SHFilterType?
    var tags: SHFilterTags?
    var price: SHFilterPrice?
    var location: SHFilterLocation?
    var reset: SHFilterReset?
}

class SHFilterCategory: NSObject {
    var kLeftLabel: String
    var kRightLabel: String
    let kCellType: String
    let kSelectorName: String
    
    init(kLeftLabel: String, kRightLabel: String, kCellType: String, kSelectorName: String) {
        self.kLeftLabel = kLeftLabel
        self.kRightLabel = kRightLabel
        self.kCellType = kCellType
        self.kSelectorName = kSelectorName
    }
}

class SHFilterType: NSObject {
    var kLeftLabel: String
    var kRightLabel: String
    let kCellType: String
    let kSelectorName: String
    
    init(kLeftLabel: String, kRightLabel: String, kCellType: String, kSelectorName: String) {
        self.kLeftLabel = kLeftLabel
        self.kRightLabel = kRightLabel
        self.kCellType = kCellType
        self.kSelectorName = kSelectorName
    }
}

class SHFilterTags: NSObject {
    var kLeftLabel: String
    var kRightLabel: String
    var KTagsArray: [String]
    let kCellType: String
    let kSelectorName: String
    
    init(kLeftLabel: String, kRightLabel: String, KTagsArray: [String], kCellType: String, kSelectorName: String) {
        self.kLeftLabel = kLeftLabel
        self.kRightLabel = kRightLabel
        self.KTagsArray = KTagsArray
        self.kCellType = kCellType
        self.kSelectorName = kSelectorName
    }
}

class SHFilterPrice: NSObject {
    var kLeftLabel: String
    var kRightLabel: String
    let kCellType: String
    let kSelectorName: String
    
    init(kLeftLabel: String, kRightLabel: String, kCellType: String, kSelectorName: String) {
        self.kLeftLabel = kLeftLabel
        self.kRightLabel = kRightLabel
        self.kCellType = kCellType
        self.kSelectorName = kSelectorName
    }
}

class SHFilterLocation: NSObject {
    var kLeftLabel: String
    var kRightLabel: String
    let kCellType: String
    let kSelectorName: String
    
    init(kLeftLabel: String, kRightLabel: String, kCellType: String, kSelectorName: String) {
        self.kLeftLabel = kLeftLabel
        self.kRightLabel = kRightLabel
        self.kCellType = kCellType
        self.kSelectorName = kSelectorName
    }
}

class SHFilterReset: NSObject {
    var kLeftLabel: String
    let kCellType: String
    let kSelectorName: String
    
    init(kLeftLabel: String, kCellType: String, kSelectorName: String) {
        self.kLeftLabel = kLeftLabel
        self.kCellType = kCellType
        self.kSelectorName = kSelectorName
    }
}
