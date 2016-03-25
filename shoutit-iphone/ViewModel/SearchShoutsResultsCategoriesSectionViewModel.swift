//
//  SearchShoutsResultsCategoriesSectionViewModel.swift
//  shoutit-iphone
//
//  Created by Łukasz Kasperek on 22.03.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import Foundation
import RxSwift

extension SearchShoutsResultsViewModel {
    
    class CategoriesSection {
        
        unowned var parent: SearchShoutsResultsViewModel
        
        private(set) var state: Variable<PagedViewModelState<SearchShoutsResultsCategoryCellViewModel>> = Variable(.Idle)
        
        init(parent: SearchShoutsResultsViewModel) {
            self.parent = parent
        }
        
        func reloadContent() {
            
        }
    }
}
