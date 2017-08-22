//
//  SearchShoutsResultsCategoriesSectionViewModel.swift
//  shoutit-iphone
//
//  Created by Łukasz Kasperek on 22.03.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import Foundation
import RxSwift
import ShoutitKit
extension SearchShoutsResultsViewModel {
    
    final class CategoriesSection {
        
        unowned var parent: SearchShoutsResultsViewModel
        
        fileprivate(set) var state: Variable<PagedViewModelState<SearchShoutsResultsCategoryCellViewModel, Int, ShoutitKit.Category>> = Variable(.idle)
        
        init(parent: SearchShoutsResultsViewModel) {
            self.parent = parent
        }
        
        func reloadContent() {
            
        }
    }
}
