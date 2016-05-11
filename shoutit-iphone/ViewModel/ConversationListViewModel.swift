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

struct ConversationPagedResults: Equatable {
    let results: PagedResults<Conversation>?
}

func ==(lhs: ConversationPagedResults, rhs: ConversationPagedResults) -> Bool {
    return lhs.results?.nextPath == rhs.results?.nextPath && lhs.results?.previousPath == rhs.results?.previousPath
}

class ConversationListViewModel {
    
    let pager: Pager<ConversationPagedResults, Conversation, Conversation>
    
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
    
    func handlePusherEvent(event: PTPusherEvent) {
        
        guard event.eventType() == .NewMessage else { return }
        guard let message : Message = event.object() else { return }
        let result = pager.findItemWithComparisonBlock {$0.id == message.conversationId}
        if let (index, conversation) = result {
            let updatedConversation = conversation.copyWithLastMessage(message)
            do {
                try pager.replaceItemAtIndex(index, withItem: updatedConversation)
            } catch {
                pager.reloadContent()
            }
        } else {
            pager.reloadContent()
        }
    }
}
