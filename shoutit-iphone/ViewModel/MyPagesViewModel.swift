//
//  MyPagesViewModel.swift
//  shoutit
//
//  Created by Łukasz Kasperek on 23.06.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import Foundation
import RxSwift
import ShoutitKit

class MyPagesViewModel {
    
    var pager: NumberedPagePager<ProfilesListCellViewModel, Profile>
    
    init() {
        pager = NumberedPagePager(itemToCellViewModelBlock: {ProfilesListCellViewModel(profile: $0)},
                                  cellViewModelToItemBlock: {$0.profile},
                                  fetchItemObservableFactory: { APIProfileService.getPagesForUsername(Account.sharedInstance.user?.username ?? "me", pageParams: PageParams(page: $0, pageSize: 20))},
                                  pageSize: 20)
    }
}
