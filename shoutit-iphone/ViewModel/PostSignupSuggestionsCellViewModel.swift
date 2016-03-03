//
//  PostSignupSuggestionsCellViewModel.swift
//  shoutit-iphone
//
//  Created by Łukasz Kasperek on 09.02.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import UIKit

enum PostSignupSuggestionsCellType<SuggestableType: Suggestable> {
    case Header(title: String)
    case Normal(item: SuggestableType)
    
    var reuseIdentifier: String {
        switch self {
        case .Header(title: _):
            return "PostSignupSuggestionsHeaderTableViewCell"
        case .Normal(item: _):
            return "PostSignupSuggestionsTableViewCell"
        }
    }
}

class PostSignupSuggestionsCellViewModel<SuggestableType: Suggestable> {
    
    let cellType: PostSignupSuggestionsCellType<SuggestableType>
    var item: SuggestableType? {
        if case PostSignupSuggestionsCellType.Normal(let item) = self.cellType {
            return item
        }
        return nil
    }
    var selected: Bool = false
    
    init(item: SuggestableType) {
        self.cellType = .Normal(item: item)
    }
    
    init(sectionTitle: String) {
        self.cellType = .Header(title: sectionTitle)
    }
}
