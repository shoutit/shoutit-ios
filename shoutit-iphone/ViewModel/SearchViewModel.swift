//
//  SearchViewModel.swift
//  shoutit-iphone
//
//  Created by Łukasz Kasperek on 15.03.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import Foundation
import RxSwift

class SearchViewModel {
    
    let reloadSubject: PublishSubject<Void> = PublishSubject()
    
    let context: SearchContext
    
    init(context: SearchContext) {
        self.context = context
    }
    
    func reloadContent() {
        if case .General = context {
            fetchCategories()
        }
    }
    
    // MARK: - Hydrate models
    
    private func fetchCategories() {
        
    }
}
