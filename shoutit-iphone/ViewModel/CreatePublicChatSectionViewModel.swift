//
//  CreatePublicChatSectionViewModel.swift
//  shoutit-iphone
//
//  Created by Łukasz Kasperek on 16.05.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import Foundation

final class CreatePublicChatSectionViewModel {
    
    let title: String
    var cellViewModels: [CreatePublicChatCellViewModel]
    
    init(title: String, cellViewModels: [CreatePublicChatCellViewModel]) {
        self.title = title
        self.cellViewModels = cellViewModels
    }
    
    func selectCellViewModelAtIndex(index: Int) {
        var cells: [CreatePublicChatCellViewModel] = []
        for (i, cellViewModel) in cellViewModels.enumerate() {
            guard case .Selectable(let option, _) = cellViewModel else {
                cells.append(cellViewModel)
                continue
            }
            cells.append(.Selectable(option: option, selected: i == index))
        }
        cellViewModels = cells
    }
}
