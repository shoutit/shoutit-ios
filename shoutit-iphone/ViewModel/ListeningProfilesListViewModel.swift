//
//  ListeningProfilesListViewModel.swift
//  shoutit-iphone
//
//  Created by Łukasz Kasperek on 10.05.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import Foundation
import RxSwift

final class ListeningProfilesListViewModel: ProfilesListViewModel {
    
    let username: String
    var pager: Pager<ProfilesListCellViewModel, Profile>
    
    var showsListenButtons: Bool
    
    init(username: String, showListenButtons: Bool) {
        self.username = username
        self.showsListenButtons = showListenButtons
        self.pager = Pager(
            itemTransformationBlock: {return ProfilesListCellViewModel(profile: $0)},
            fetchItemObservableFactory: {(page) -> Observable<PagedResults<Profile>> in
                let params = PageParams(page: page, pageSize: 20)
                return APIProfileService.getListeningProfilesForUsername(username, params: params)
            }
        )
    }
}
