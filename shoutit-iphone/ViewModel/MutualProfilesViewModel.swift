//
//  MutualProfilesViewModel.swift
//  shoutit-iphone
//
//  Created by Piotr Bernad on 30/05/16.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import UIKit
import RxSwift
import ShoutitKit

class MutualProfilesViewModel: ProfilesListViewModel {
    var pager: NumberedPagePager<ProfilesListCellViewModel, Profile>
    
    var showsListenButtons: Bool
    var sectionTitle : String?
    
    init(showListenButtons: Bool) {
        self.showsListenButtons = showListenButtons
        self.pager = NumberedPagePager(
            itemToCellViewModelBlock: {return ProfilesListCellViewModel(profile: $0)},
            cellViewModelToItemBlock: {return $0.profile},
            fetchItemObservableFactory: {(page) -> Observable<PagedResults<Profile>> in
                let params = PageParams(page: page, pageSize: 20)
                return APIProfileService.getMutualProfiles(params)
            }
        )
    }
}

class MutualContactsViewModel: ProfilesListViewModel {
    var pager: NumberedPagePager<ProfilesListCellViewModel, Profile>
    
    var showsListenButtons: Bool
    var sectionTitle : String?
    
    init(showListenButtons: Bool) {
        self.showsListenButtons = showListenButtons
        self.pager = NumberedPagePager(
            itemToCellViewModelBlock: {return ProfilesListCellViewModel(profile: $0)},
            cellViewModelToItemBlock: {return $0.profile},
            fetchItemObservableFactory: {(page) -> Observable<PagedResults<Profile>> in
                let params = PageParams(page: page, pageSize: 20)
                return APIProfileService.getMutualContacts(params)
            }
        )
    }
}
