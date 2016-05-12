//
//  PublicChatsListViewModel.swift
//  shoutit-iphone
//
//  Created by Łukasz Kasperek on 12.05.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import Foundation
import Pusher

class PublicChatsListViewModel: ChatsListViewModel {
    
    let pager: Pager<ConversationPagedResults, Conversation, Conversation>
    
    init() {
        self.pager = Pager(
            itemToCellViewModelBlock: {$0},
            cellViewModelToItemBlock: {$0},
            fetchItemObservableFactory: {return APIPublicChatsService.requestPublicChatsWithParams(ConversationsListParams(pageSize: 20), explicitURL: $0.results?.previousPath)},
            nextPageComputerBlock: { return ConversationPagedResults(results: $0.1) },
            lastPageDidLoadExaminationBlock: {$0.previousPath == nil},
            firstPageIndex: ConversationPagedResults(results: nil)
        )
    }
}
