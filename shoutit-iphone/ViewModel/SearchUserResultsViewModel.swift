//
//  SearchUserResultsViewModel.swift
//  shoutit-iphone
//
//  Created by Łukasz Kasperek on 17.03.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import Foundation
import RxSwift

final class SearchUserResultsViewModel: ProfilesListViewModel {
    
    let searchPhrase: String
    var pager: Pager<ProfilesListCellViewModel, Profile>
    
    init(searchPhrase: String) {
        self.searchPhrase = searchPhrase
        self.pager = Pager(
            itemTransformationBlock: {return ProfilesListCellViewModel(profile: $0)},
            fetchItemObservableFactory: {(page) -> Observable<PagedResults<Profile>> in
                let params = SearchParams(phrase: searchPhrase, page: page, pageSize: 20)
                return APIProfileService.searchProfileWithParams(params)
            }
        )
    }
}
