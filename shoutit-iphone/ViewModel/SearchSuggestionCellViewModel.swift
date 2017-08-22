//
//  SearchSuggestionCellViewModel.swift
//  shoutit-iphone
//
//  Created by Łukasz Kasperek on 15.03.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import Foundation


enum SearchSuggestionCellViewModel {
    case recentSearch(phrase: String)
    case apiSuggestion(phrase: String)
}
