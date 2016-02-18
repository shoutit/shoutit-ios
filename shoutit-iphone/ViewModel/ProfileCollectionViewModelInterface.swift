//
//  ProfileCollectionViewModelInterface.swift
//  shoutit-iphone
//
//  Created by Łukasz Kasperek on 17.02.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import UIKit

enum ProfileCollectionViewConfiguration {
    case MyProfile
    //case Profile
    //case Page
    //case Tag
}

protocol ProfileCollectionViewModelInterface: class, ProfileCollectionViewLayoutDelegate, ProfileCollectionInfoSupplementaryViewDataSource {
    
    var configuration: ProfileCollectionViewConfiguration {get}
    
    // user data
    var name: String? {get}
    var username: String? {get}
    var isListeningToYou: Bool? {get}
    var coverURL: NSURL? {get}
    
    // sections
    var pagesSection: ProfileCollectionSectionViewModel {get}
    var shoutsSection: ProfileCollectionSectionViewModel {get}
}

// MARK: - Default implementations

extension ProfileCollectionViewModelInterface {
    
    func hidesSupplementeryView(view: ProfileCollectionViewSupplementaryView) -> Bool {
        return false
    }
}
