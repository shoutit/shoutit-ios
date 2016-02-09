//
//  PostSignupSuggestionsCellViewModel.swift
//  shoutit-iphone
//
//  Created by Łukasz Kasperek on 09.02.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import UIKit

enum PostSignupSuggestionsCellType {
    case Header(title: String)
    case Normal(item: Suggestable)
    
    var reuseIdentifier: String {
        switch self {
        case .Header(title: _):
            return "PostSignupSuggestionsHeaderCell"
        case .Normal(item: _):
            return "PostSignupSuggestionsCell"
        }
    }
}

class PostSignupSuggestionsCellViewModel {
    
    let cellType: PostSignupSuggestionsCellType
    let item: Suggestable?
    var selected: Bool = false
    
    init(item: Suggestable) {
        self.cellType = .Normal(item: item)
    }
    
    init(sectionTitle: String) {
        self.cellType = .Header(title: sectionTitle)
    }
}
