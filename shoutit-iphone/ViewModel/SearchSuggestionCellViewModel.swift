//
//  SearchSuggestionCellViewModel.swift
//  shoutit-iphone
//
//  Created by Łukasz Kasperek on 15.03.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import Foundation

struct SearchSuggestionCellViewModel {
    
    enum SuggestionType {
        case RecentSearch
        case API
        case Typing
    }
    
    let type: SuggestionType
}
