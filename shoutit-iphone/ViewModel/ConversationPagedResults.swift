//
//  ConversationPagedResults.swift
//  shoutit-iphone
//
//  Created by Łukasz Kasperek on 12.05.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import Foundation
import ShoutitKit

struct ConversationPagedResults: Equatable {
    let results: PagedResults<MiniConversation>?
}

func ==(lhs: ConversationPagedResults, rhs: ConversationPagedResults) -> Bool {
    return lhs.results?.nextPath == rhs.results?.nextPath && lhs.results?.previousPath == rhs.results?.previousPath
}
