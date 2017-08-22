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

protocol ShoutProvider {
    func shoutForIndexPath(_ indexPath: IndexPath) -> Shout?
    func indexPathForShout(_ shout: Shout?) -> IndexPath?
    func replaceShoutAndReload(_ shout: Shout)
}

protocol Bookmarking : ShoutProvider {
    var bookmarksDisposeBag : DisposeBag? { get set }
    func switchShoutBookmarkShout(_ sender: UIButton)
}

class BookmarkManager {
    static func addShoutToBookmarks(_ shout: Shout) -> Observable<Success> {
        return APIShoutsService.bookmarkShout(shout)
    }
    
    static func removeFromBookmarks(_ shout: Shout) -> Observable<Success> {
        return APIShoutsService.removeFromBookmarksShout(shout)
    }
}

extension Bookmarking where Self : UICollectionViewController {
    func switchShoutBookmarkShout(_ sender: UIButton) {
        let item = sender.tag
        let indexPath = IndexPath(item: item, section: 0)
        
        guard let shout = self.shoutForIndexPath(indexPath) else {
            return
        }
        
        let wShout = shout
        
        guard let bookmarksDisposeBag = bookmarksDisposeBag else {
            return
        }
        
        if shout.isBookmarked ?? false {
            APIShoutsService.removeFromBookmarksShout(shout).subscribe({ [weak self] (event) in
                switch event {
                case .next(let success):
                    self?.showSuccessMessage(success.message)
                    self?.switchToNonBookmarked(wShout)
                case .Error(let error):
                    self?.showError(error)
                    self?.switchToBookmarked(wShout)
                default: break
                }
            }).addDisposableTo(bookmarksDisposeBag)
        } else {
            
            APIShoutsService.bookmarkShout(shout).subscribe({ [weak self] (event) in
                switch event {
                case .next(let success):
                    self?.showSuccessMessage(success.message)
                    self?.switchToBookmarked(wShout)
                case .Error(let error):
                    self?.showError(error)
                    self?.switchToNonBookmarked(wShout)
                default: break
                }
            }).addDisposableTo(bookmarksDisposeBag)
        }
        
    }
    
    func switchToBookmarked(_ shout: Shout?) {
        guard let shout = shout else {
            return
        }
        
        if let newShout = shout.copyWithBookmark(true) {
            replaceShoutAndReload(newShout)
        }
    }
    
    func switchToNonBookmarked(_ shout: Shout?) {
        guard let shout = shout else {
            return
        }
        
        if let newShout = shout.copyWithBookmark(false) {
            replaceShoutAndReload(newShout)
        }
    }
}
