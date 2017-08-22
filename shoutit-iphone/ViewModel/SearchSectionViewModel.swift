//
//  SearchSectionViewModel.swift
//  shoutit-iphone
//
//  Created by Łukasz Kasperek on 15.03.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import Foundation

enum SearchSectionViewModel {
    
    enum HeaderType {
        case none
        case titleCentered(title: String)
        case titleAlignedLeftWithButton(title: String, buttonTitle: String)
    }
    
    case categories(cells: [SearchCategoryCellViewModel], header: HeaderType)
    case suggestions(cells: [SearchSuggestionCellViewModel], header: HeaderType)
    case loadingPlaceholder
    case messagePlaceholder(message: String?, image: UIImage?)
}
