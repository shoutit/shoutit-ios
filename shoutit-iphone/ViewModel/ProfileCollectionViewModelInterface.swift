//
//  ProfileCollectionViewModelInterface.swift
//  shoutit-iphone
//
//  Created by Łukasz Kasperek on 17.02.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import UIKit
import RxSwift

protocol ProfileCollectionViewModelInterface: class, ProfileCollectionViewLayoutDelegate, ProfileCollectionInfoSupplementaryViewDataSource {
    
    // user data
    var name: String? {get}
    var username: String? {get}
    var isListeningToYou: Bool? {get}
    var coverURL: NSURL? {get}
    
    // sections
    var pagesSection: ProfileCollectionSectionViewModel<ProfileCollectionPageCellViewModel> {get}
    var shoutsSection: ProfileCollectionSectionViewModel<ProfileCollectionShoutCellViewModel> {get}
    
    // fetchin
    func reloadContent()
    var reloadSubject: PublishSubject<Void> {get}
}

// MARK: - Default implementations

extension ProfileCollectionViewModelInterface {
    
    func hidesSupplementeryView(view: ProfileCollectionViewSupplementaryView) -> Bool {
        return false
    }
}
