//
//  ConversationInfoSectionViewModel.swift
//  shoutit
//
//  Created by Łukasz Kasperek on 20.06.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import Foundation

class ConversationInfoSectionViewModel {
    let sectionTitle: String
    let cellViewModels: [ConversationInfoCellViewModel]
    
    init(title: String, cellViewModels: [ConversationInfoCellViewModel]) {
        self.sectionTitle = title
        self.cellViewModels = cellViewModels
    }
}