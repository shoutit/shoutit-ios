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
    var listSection: ProfileCollectionSectionViewModel<ProfileCollectionListenableCellViewModel>! {get}
    var gridSection: ProfileCollectionSectionViewModel<ProfileCollectionShoutCellViewModel>! {get}
    
    // fetchin
    func reloadContent()
    var reloadSubject: PublishSubject<Void> {get}
    func listen() -> Observable<Void>?
}

// MARK: - Default implementations

extension ProfileCollectionViewModelInterface {
    
    func sectionContentModeForSection(section: Int) -> ProfileCollectionSectionContentMode {
        if section == 0 {
            return listSection.cells.count > 0 ? .Default : .Placeholder
        }
        if section == 1 {
            return gridSection.cells.count > 1 ? .Default : .Placeholder
        }
        
        assertionFailure()
        return .Default
    }
}
