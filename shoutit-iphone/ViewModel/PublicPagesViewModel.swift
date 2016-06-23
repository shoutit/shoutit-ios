//
//  PublicPagesViewModel.swift
//  shoutit
//
//  Created by Łukasz Kasperek on 23.06.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import Foundation
import RxSwift
import ShoutitKit

class PublicPagesViewModel {
    
    var pager: NumberedPagePager<ProfilesListCellViewModel, Profile>
    
    init() {
        pager = NumberedPagePager(itemToCellViewModelBlock: {ProfilesListCellViewModel(profile: $0)},
                                  cellViewModelToItemBlock: {$0.profile},
                                  fetchItemObservableFactory: { APIPageService.getPagesWithParams(FilteredPagesParams(page: $0, pageSize: 20, country: Account.sharedInstance.user?.location.country)) },
                                  pageSize: 20)
    }
}
