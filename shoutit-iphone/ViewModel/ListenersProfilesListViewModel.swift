//
//  ListenersProfilesListViewModel.swift
//  shoutit-iphone
//
//  Created by Łukasz Kasperek on 10.05.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import Foundation
import RxSwift

final class ListenersProfilesListViewModel: ProfilesListViewModel {
    
    let username: String
    
    // RX
    let disposeBag = DisposeBag()
    var requestDisposeBag = DisposeBag()
    let state: Variable<PagedViewModelState<ProfilesListCellViewModel>> = Variable(.Idle)
    
    var showsListenButtons: Bool {
        return false
    }
    
    init(username: String) {
        self.username = username
    }
    
    func fetchProfilesForPage(page: Int) -> Observable<PagedResults<Profile>> {
        let params = PageParams(page: page, pageSize: pageSize)
        return APIProfileService.getListenersProfilesForUsername(username, params: params)
    }
}
