//
//  PostSignupSuggestionsSectionViewModel.swift
//  shoutit-iphone
//
//  Created by Łukasz Kasperek on 09.02.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import UIKit

enum PostSignupSuggestionsSection {
    case Users
    case Pages
    
    var title: String {
        switch self {
        case .Users:
            return NSLocalizedString("Suggested Users", comment: "")
        case .Pages:
            return NSLocalizedString("Suggested Pages", comment: "")
        }
    }
}

class PostSignupSuggestionsSectionViewModel {
    
    let section: PostSignupSuggestionsSection
    private(set) var cells: [PostSignupSuggestionsCellViewModel]
    
    init(section: PostSignupSuggestionsSection, models: [Suggestable]) {
        self.section = section
        self.cells = models.map{PostSignupSuggestionsCellViewModel(item: $0)}
    }
    
    func updateCellsWithModels(models: [Suggestable]) {
        self.cells = models.map{PostSignupSuggestionsCellViewModel(item: $0)}
    }
}
