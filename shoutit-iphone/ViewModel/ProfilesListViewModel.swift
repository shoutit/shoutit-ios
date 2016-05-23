//
//  ProfilesListViewModel.swift
//  shoutit-iphone
//
//  Created by Łukasz Kasperek on 09.05.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import Foundation
import RxSwift

protocol ProfilesListViewModel: class {
    var pager: NumberedPagePager<ProfilesListCellViewModel, Profile> { get }
    var showsListenButtons: Bool {get}
}

extension ProfilesListViewModel {
    var showsListenButtons: Bool {return true}
}
