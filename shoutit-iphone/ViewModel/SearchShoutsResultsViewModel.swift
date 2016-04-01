//
//  SearchShoutsResultsViewModel.swift
//  shoutit-iphone
//
//  Created by Łukasz Kasperek on 21.03.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import Foundation
import RxSwift

final class SearchShoutsResultsViewModel {
    
    let context: SearchContext
    let searchPhrase: String?
    
    private(set) var shoutsSection: ShoutsSection!
    private(set) var categoriesSection: CategoriesSection!
    
    init(searchPhrase: String?, inContext context: SearchContext) {
        self.searchPhrase = searchPhrase
        self.context = context
        self.shoutsSection = ShoutsSection(parent: self)
        self.categoriesSection = CategoriesSection(parent: self)
    }
    
    func reloadContent() {
        shoutsSection.reloadContent()
        categoriesSection.reloadContent()
    }
}
