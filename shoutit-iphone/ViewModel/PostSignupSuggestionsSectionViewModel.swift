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

class PostSignupSuggestionsSectionViewModel<SuggestableType: Suggestable> {
    
    let section: PostSignupSuggestionsSection
    var cells: [PostSignupSuggestionsCellViewModel<SuggestableType>]
    
    init(section: PostSignupSuggestionsSection, models: [SuggestableType]) {
        self.section = section
        let headerCellViewModel = PostSignupSuggestionsCellViewModel<SuggestableType>(sectionTitle: section.title)
        self.cells = [headerCellViewModel] + models.map{PostSignupSuggestionsCellViewModel<SuggestableType>(item: $0)}
    }
}
