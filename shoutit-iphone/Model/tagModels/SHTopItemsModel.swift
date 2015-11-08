//
//  SHTopTagsModel.swift
//  shoutit-iphone
//
//  Created by Vishal Thakur on 08/11/15.
//  Copyright © 2015 Shoutit. All rights reserved.
//

import Foundation

class SHTopItemsModel: NSObject {
    
    private var filter: SHFilter?
    private var is_last_page = true
    private var currentPage = 1
    private var tags = NSMutableOrderedSet()
    private var currentLocation: SHAddress?
    
    func isMore () -> Bool {
        return !self.is_last_page
    }
    
    func loadTopItemsForLocation (location: SHAddress, forPage: Int) {
        
    }
}
