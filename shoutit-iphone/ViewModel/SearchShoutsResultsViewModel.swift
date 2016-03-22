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
    let searchPhrase: String
    
    init(searchPhrase: String, inContext context: SearchContext) {
        self.searchPhrase = searchPhrase
        self.context = context
    }
    
    private func fetchShoutsWithSearchPhrase(phrase: String, context: SearchContext, page: Int) -> Observable<[SearchShoutsResults]> {
        let pageSize = 20
        let params: FilteredShoutsParams
        switch context {
        case .General:
            params = FilteredShoutsParams(searchPhrase: phrase, page: page, pageSize: pageSize)
        case .DiscoverShouts(let item):
            params = FilteredShoutsParams(searchPhrase: phrase, discoverId: item.id, page: page, pageSize: pageSize)
        case .ProfileShouts(let profile):
            params = FilteredShoutsParams(searchPhrase: phrase, username: profile.username, page: page, pageSize: pageSize)
        case .TagShouts(let tag):
            params = FilteredShoutsParams(searchPhrase: phrase, tag: tag.name, page: page, pageSize: pageSize)
        }
        
        return APIShoutsService.searchShoutsWithParams(params)
    }
}
