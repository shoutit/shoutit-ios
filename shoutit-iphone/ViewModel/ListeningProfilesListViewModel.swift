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
    
    // RX
    let disposeBag = DisposeBag()
    var requestDisposeBag = DisposeBag()
    let state: Variable<PagedViewModelState<ProfilesListCellViewModel>> = Variable(.Idle)
    
    var showsListenButtons: Bool
    
    init(username: String, showListenButtons: Bool) {
        self.username = username
        self.showsListenButtons = showListenButtons
    }
    
    func fetchProfilesForPage(page: Int) -> Observable<PagedResults<Profile>> {
        let params = PageParams(page: page, pageSize: pageSize)
        return APIProfileService.getListeningProfilesForUsername(username, params: params)
    }
}
