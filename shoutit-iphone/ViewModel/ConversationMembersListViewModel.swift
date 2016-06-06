//
//  ConversationMembersListViewModel.swift
//  shoutit-iphone
//
//  Created by Piotr Bernad on 17/05/16.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import UIKit
import RxSwift
import ShoutitKit

final class ConversationMembersListViewModel: ProfilesListViewModel {
    let conversation : Conversation

    var pager: NumberedPagePager<ProfilesListCellViewModel, Profile>
    var sectionTitle : String?
    
    init(conversation: Conversation) {
        self.conversation = conversation
        
        self.pager = NumberedPagePager(
            itemToCellViewModelBlock: {return ProfilesListCellViewModel(profile: $0)},
            cellViewModelToItemBlock: {return $0.profile},
            fetchItemObservableFactory: {(page) -> Observable<PagedResults<Profile>> in
                let profiles : [Profile] = conversation.users!.map{$0.value}
                let result : PagedResults<Profile> = PagedResults(count: nil, previousPath: nil, nextPath: nil, results: profiles)
                return Observable.just(result)
            }
        )
    }
}
