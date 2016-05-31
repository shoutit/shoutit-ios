//
//  InterestsTagsListViewModel.swift
//  shoutit-iphone
//
//  Created by Łukasz Kasperek on 23.05.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import Foundation
import RxSwift

final class InterestsTagsListViewModel {
    
    let username: String
    var pager: NumberedPagePager<TagsListCellViewModel, Tag>
    
    var showsListenButtons: Bool
    
    init(username: String, showListenButtons: Bool) {
        self.username = username
        self.showsListenButtons = showListenButtons
        self.pager = NumberedPagePager(
            itemToCellViewModelBlock: {return TagsListCellViewModel(tag: $0)},
            cellViewModelToItemBlock: {return $0.tag},
            fetchItemObservableFactory: {(page) -> Observable<PagedResults<Tag>> in
                let params = PageParams(page: page, pageSize: 20)
                return APIProfileService.getInterestsProfilesForUsername(username, params: params)
            }
        )
    }
}

