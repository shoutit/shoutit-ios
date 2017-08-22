//
//  PagedShoutsViewModel.swift
//  shoutit-iphone
//
//  Created by Łukasz Kasperek on 18.04.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import Foundation
import RxSwift
import ShoutitKit

protocol PagedShoutsViewModel: class {
    
    var filtersState: FiltersState? {get}
    var pager: NumberedPagePager<ShoutCellViewModel, Shout>! { get }
    
    func reloadContent() -> Void
    func fetchShoutsAtPage(_ page: Int) -> Observable<PagedResults<Shout>>
}

extension PagedShoutsViewModel {
    
    var pageSize: Int {
        return 20
    }
    
    var numberOfResults: Int? {
        return pager.numberOfResults
    }
    
    func reloadContent() {
        pager.loadContent()
    }
    
    func fetchNextPage() {
        pager.fetchNextPage()
    }
    
    func applyParamsToFilterParamsIfAny(_ params: inout FilteredShoutsParams) {
        if let filtersState = filtersState {
            let filterParams = filtersState.composeParams()
            params = filterParams.paramsByReplacingEmptyFieldsWithFieldsFrom(params)
        }
    }
}
