//
//  SuggestedUsersViewModel.swift
//  shoutit-iphone
//
//  Created by Piotr Bernad on 31/05/16.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import UIKit
import RxSwift
import ShoutitKit

class SuggestedUsersViewModel: ProfilesListViewModel {
    var pager: NumberedPagePager<ProfilesListCellViewModel, Profile>
    
    var showsListenButtons: Bool
    var sectionTitle : String?
    
    init(showListenButtons: Bool) {
        self.showsListenButtons = showListenButtons
        self.pager = NumberedPagePager(
            itemToCellViewModelBlock: {return ProfilesListCellViewModel(profile: $0)},
            cellViewModelToItemBlock: {return $0.profile},
            fetchItemObservableFactory: {(page) -> Observable<PagedResults<Profile>> in
                let params = SuggestionsParams(address: Account.sharedInstance.user!.location, pageSize: 20, type: [.Users, .Pages], page: page)
                return APIMiscService.requestSuggestedUsersWithParams(params)
            }
        )
    }
}

class SuggestedPagesViewModel: ProfilesListViewModel {
    var pager: NumberedPagePager<ProfilesListCellViewModel, Profile>
    
    var showsListenButtons: Bool
    var sectionTitle : String?
    
    init(showListenButtons: Bool) {
        self.showsListenButtons = showListenButtons
        self.pager = NumberedPagePager(
            itemToCellViewModelBlock: {return ProfilesListCellViewModel(profile: $0)},
            cellViewModelToItemBlock: {return $0.profile},
            fetchItemObservableFactory: {(page) -> Observable<PagedResults<Profile>> in
                let params = SuggestionsParams(address: Account.sharedInstance.user!.location, pageSize: 20, type: [.Users, .Pages], page: page)
                return APIMiscService.requestSuggestedPagesWithParams(params)
            }
        )
    }
}
