//
//  TagsListCellViewModel.swift
//  shoutit-iphone
//
//  Created by Łukasz Kasperek on 23.05.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import Foundation
import RxSwift
import ShoutitKit

final class TagsListCellViewModel: Listenable {
    
    let tag: Tag
    var isListening: Bool
    
    init(tag: Tag) {
        self.tag = tag
        self.isListening = tag.isListening ?? false
    }
    
    func listeningCountString() -> String {
        return String.localizedStringWithFormat(NSLocalizedString("%@ Listeners", comment: ""), NumberFormatters.numberToShortString(tag.listenersCount ?? 0))
    }
    
    func listenRequestObservable() -> Observable<ListenSuccess> {
        return APITagsService.listen(self.isListening, toTagWithSlug: self.tag.slug)
    }
}
