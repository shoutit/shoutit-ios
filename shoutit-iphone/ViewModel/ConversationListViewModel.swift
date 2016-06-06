//
//  ConversationListViewModel.swift
//  shoutit-iphone
//
//  Created by Łukasz Kasperek on 11.05.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import Foundation
import RxSwift
import Pusher
import ShoutitKit

class ConversationListViewModel: ChatsListViewModel {
    
    let pager: Pager<ConversationPagedResults, MiniConversation, MiniConversation>
    
    init() {
        self.pager = Pager(
            itemToCellViewModelBlock: {$0},
            cellViewModelToItemBlock: {$0},
            fetchItemObservableFactory: {return APIChatsService.requestConversationsWithParams(ConversationsListParams(pageSize: 20), explicitURL: $0.results?.previousPath)},
            nextPageComputerBlock: { return ConversationPagedResults(results: $0.1) },
            lastPageDidLoadExaminationBlock: {$0.previousPath == nil},
            firstPageIndex: ConversationPagedResults(results: nil)
        )
    }
}
