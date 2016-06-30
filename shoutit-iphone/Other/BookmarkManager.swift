//
//  BookmarkManager.swift
//  shoutit
//
//  Created by Piotr Bernad on 30/06/16.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import Foundation
import ShoutitKit
import RxSwift

class BookmarkManager {
    static func addShoutToBookmarks(shout: Shout) -> Observable<Success> {
        return APIShoutsService.bookmarkShout(shout)
    }
    
    static func removeFromBookmarks(shout: Shout) -> Observable<Success> {
        return APIShoutsService.removeFromBookmarksShout(shout)
    }
}