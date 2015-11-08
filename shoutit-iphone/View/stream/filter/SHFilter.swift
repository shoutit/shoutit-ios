//
//  SHFilter.swift
//  shoutit-iphone
//
//  Created by Vishal Thakur on 08/11/15.
//  Copyright © 2015 Shoutit. All rights reserved.
//

import Foundation

class SHFilter: NSObject {
    
    private var before: NSDate?
    private var after: NSDate?
    private var type: String?
    private var selectedTypeIndex: Int?
    private var location: SHAddress?
    private var minPrice: String?
    private var maxPrice: String?
    private var category: String?
    private var selectedCategoryIndex: Int?
    private var tags = []
    
}
