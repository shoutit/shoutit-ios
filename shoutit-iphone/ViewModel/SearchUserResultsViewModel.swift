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
    
    // RX
    let disposeBag = DisposeBag()
    var requestDisposeBag = DisposeBag()
    let state: Variable<PagedViewModelState<ProfilesListCellViewModel>> = Variable(.Idle)
    
    init(searchPhrase: String) {
        self.searchPhrase = searchPhrase
    }
    
    func fetchProfilesForPage(page: Int) -> Observable<PagedResults<Profile>> {
        let params = SearchParams(phrase: searchPhrase, page: page, pageSize: pageSize)
        return APIProfileService.searchProfileWithParams(params)
    }
}
