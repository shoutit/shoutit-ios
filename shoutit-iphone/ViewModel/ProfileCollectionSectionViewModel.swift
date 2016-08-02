//
//  ProfileCollectionSectionViewModel.swift
//  shoutit-iphone
//
//  Created by Łukasz Kasperek on 16.02.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import UIKit

final class ProfileCollectionSectionViewModel <T: ProfileCollectionCellViewModel> {
    
    let title: String
    let isLoading: Bool
    let errorMessage: String?
    let noContentMessage: String
    let footerButtonTitle: String?
    let footerButtonStyle: ProfileCollectionFooterButtonType?
    var cells: [T]
    
    init(title: String,
         cells: [T],
         isLoading: Bool,
         footerButtonTitle: String? = nil,
         footerButtonStyle: ProfileCollectionFooterButtonType? = nil,
         noContentMessage: String = NSLocalizedString("No content available yet", comment: "No Content placeholder"),
         errorMessage: String? = nil) {
        
        self.title = title
        self.cells = cells
        self.footerButtonTitle = footerButtonTitle
        self.footerButtonStyle = footerButtonStyle
        self.errorMessage = errorMessage
        self.noContentMessage = noContentMessage
        self.isLoading = isLoading
    }
    
    func replaceCell(cell: T, atIndex: Int) {
        self.cells.removeAtIndex(atIndex)
        self.cells.insert(cell, atIndex: atIndex)
    }
}
