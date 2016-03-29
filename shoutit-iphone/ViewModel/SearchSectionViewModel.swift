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
        case None
        case TitleCentered(title: String)
        case TitleAlignedLeftWithButton(title: String, buttonTitle: String)
    }
    
    case Categories(cells: [SearchCategoryCellViewModel], header: HeaderType)
    case Suggestions(cells: [SearchSuggestionCellViewModel], header: HeaderType)
    case LoadingPlaceholder
    case MessagePlaceholder(message: String?, image: UIImage?)
}
