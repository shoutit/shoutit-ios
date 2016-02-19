//
//  ProfileCollectionSectionViewModel.swift
//  shoutit-iphone
//
//  Created by Łukasz Kasperek on 16.02.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import UIKit

class ProfileCollectionSectionViewModel <T: ProfileCollectionCellViewModel> {
    
    let title: String
    let errorMessage: String?
    let noContentMessage: String
    let footerButtonTitle: String?
    let footerButtonStyle: ProfileCollectionFooterButtonType?
    let cells: [T]
    
    init(title: String, cells: [T], footerButtonTitle: String? = nil, footerButtonStyle: ProfileCollectionFooterButtonType? = nil, noContentMessage: String = NSLocalizedString("No content available yet", comment: ""), errorMessage: String? = nil) {
        self.title = title
        self.cells = cells
        self.footerButtonTitle = footerButtonTitle
        self.footerButtonStyle = footerButtonStyle
        self.errorMessage = errorMessage
        self.noContentMessage = noContentMessage
    }
}
