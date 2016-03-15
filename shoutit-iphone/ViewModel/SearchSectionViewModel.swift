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
        
    }
    case Categories(cells: [SearchCategoryCellViewModel])
    case Suggestions(cells: [SearchSuggestionCellViewModel])
    
    
}
