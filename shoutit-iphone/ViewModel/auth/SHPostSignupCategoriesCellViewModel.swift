//
//  SHPostSignupCategoriesCellViewModel.swift
//  shoutit-iphone
//
//  Created by Vishal Thakur on 1/12/16.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import UIKit

class SHPostSignupCategoriesCellViewModel: NSObject {
    
    private let cell: SHPostSignupCategoriesCell
    private var discoverItem: SHDiscoverItem?
    
    init(cell: SHPostSignupCategoriesCell) {
        self.cell = cell
    }
    
    func setUp (category: String) {
        cell.categoryTitle.text = category
    }

}
