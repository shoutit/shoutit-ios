//
//  ConversationBlockedListModel.swift
//  shoutit-iphone
//
//  Created by Piotr Bernad on 17/05/16.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import UIKit
import RxSwift
import ShoutitKit

final class ConversationBlockedListModel: ProfilesListViewModel {
    let conversation : Conversation
    
    var pager: NumberedPagePager<ProfilesListCellViewModel, Profile>
    var sectionTitle : String?
    
    init(conversation: Conversation) {
        self.conversation = conversation
        
        let pager =  NumberedPagePager(itemToCellViewModelBlock: {return ProfilesListCellViewModel(profile: $0)},
                                       cellViewModelToItemBlock: {return $0.profile},
                                       fetchItemObservableFactory:{(page) -> Observable<PagedResults<Profile>> in
                                            let params = PageParams(page: page, pageSize: 20)
                                            return APIChatsService.getBlockedProfilesForConversation(conversation.id, params: params)
                                       })
        
        self.pager = pager
    }
}
