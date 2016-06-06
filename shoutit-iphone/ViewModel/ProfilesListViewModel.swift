//
//  ProfilesListViewModel.swift
//  shoutit-iphone
//
//  Created by Łukasz Kasperek on 09.05.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import Foundation
import RxSwift
import ShoutitKit

protocol ProfilesListViewModel: class {
    var pager: NumberedPagePager<ProfilesListCellViewModel, Profile> { get }
    var showsListenButtons: Bool {get}
    var sectionTitle : String? {get set}
}

extension ProfilesListViewModel {
    var showsListenButtons: Bool {return true}
}
