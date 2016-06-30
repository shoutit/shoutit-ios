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
    func shoutForIndexPath(indexPath: NSIndexPath) -> Shout?
    func indexPathForShout(shout: Shout?) -> NSIndexPath?
    func replaceShoutAndReload(shout: Shout)
}

protocol Bookmarking : ShoutProvider {
    var bookmarksDisposeBag : DisposeBag! { get }
    func switchShoutBookmarkShout(sender: UIButton)
}

class BookmarkManager {
    static func addShoutToBookmarks(shout: Shout) -> Observable<Success> {
        return APIShoutsService.bookmarkShout(shout)
    }
    
    static func removeFromBookmarks(shout: Shout) -> Observable<Success> {
        return APIShoutsService.removeFromBookmarksShout(shout)
    }
}

extension Bookmarking where Self : UICollectionViewController {
    func switchShoutBookmarkShout(sender: UIButton) {
        let item = sender.tag
        let indexPath = NSIndexPath(forItem: item, inSection: 0)
        
        guard let shout = self.shoutForIndexPath(indexPath) else {
            return
        }
        
        let wShout = shout
        
        if shout.isBookmarked {
            APIShoutsService.removeFromBookmarksShout(shout).subscribe({ [weak self] (event) in
                switch event {
                case .Next(let success):
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
                case .Next(let success):
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
    
    func switchToBookmarked(shout: Shout?) {
        guard let shout = shout else {
            return
        }
        
        if let newShout = shout.copyWithBookmark(true) {
            replaceShoutAndReload(newShout)
        }
    }
    
    func switchToNonBookmarked(shout: Shout?) {
        guard let shout = shout else {
            return
        }
        
        if let newShout = shout.copyWithBookmark(false) {
            replaceShoutAndReload(newShout)
        }
    }
}