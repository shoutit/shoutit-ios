//
//  HomeShoutsViewModel.swift
//  shoutit-iphone
//
//  Created by Piotr Bernad on 15.02.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import UIKit
import RxSwift

class HomeShoutsViewModel: AnyObject {
    var displayable = ShoutsDisplayable(layout: .VerticalGrid)
    let listReuseIdentifier = "shShoutItemListCell"
    let gridReuseIdentifier = "shShoutItemGridCell"
    
    let homeHeaderReuseIdentifier = "shoutMyFeedHeaderCell"
    
    var dataSource : Observable<[Shout]>
    var dataSubject : PublishSubject<[Shout]>?
    
    func cellReuseIdentifier() -> String {
        if displayable.shoutsLayout == ShoutsLayout.VerticalGrid {
            return gridReuseIdentifier
        }
        
        return listReuseIdentifier
    }
    
    func changeDisplayModel() -> ShoutsLayout {
        if displayable.shoutsLayout == ShoutsLayout.VerticalGrid {
            displayable = ShoutsDisplayable(layout: .VerticalList, offset: displayable.contentOffset.value)
        } else {
            displayable = ShoutsDisplayable(layout: .VerticalGrid, offset: displayable.contentOffset.value)
        }
        
        return displayable.shoutsLayout
    }
    
    required init() {
        
        dataSource = Account.sharedInstance.userSubject.asObservable()
            .flatMap { [unowned self] (user) -> Observable<[Shout]> in
                return self.retriveHomeShouts(user)
            }
    }
    
    func retriveHomeShouts(user: User?) -> Observable<[Shout]>! {
        if let usr = user {
            return APIShoutsService.shouts(forCountry: usr.location.country)
        }
        
        return APIShoutsService.shouts(forCountry: user?.location.country)
    }
}
