//
//  ProfileCollectionSectionViewModel.swift
//  shoutit-iphone
//
//  Created by Łukasz Kasperek on 16.02.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import UIKit

class ProfileCollectionSectionViewModel {
    
    let title: String
    let cells: [ProfileCollectionCellViewModel]
    
    init(title: String, cells: [ProfileCollectionCellViewModel]) {
        self.title = title
        self.cells = cells
    }
}
