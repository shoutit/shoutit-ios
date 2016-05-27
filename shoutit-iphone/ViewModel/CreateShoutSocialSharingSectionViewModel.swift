//
//  CreateShoutSocialSharingSectionViewModel.swift
//  shoutit-iphone
//
//  Created by Łukasz Kasperek on 27.05.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import Foundation

final class CreateShoutSocialSharingSectionViewModel: CreateShoutSectionViewModel {
    
    var title: String {
        return " " + NSLocalizedString("SHARING", comment: "Sharing section header on create shout")
    }
    private(set) var cellViewModels: [CreateShoutCellViewModel]
    
    init(cellViewModels: [CreateShoutCellViewModel]) {
        self.cellViewModels = cellViewModels
    }
}
