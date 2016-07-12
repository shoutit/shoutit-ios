//
//  ProfileCollectionViewModelInterface.swift
//  shoutit-iphone
//
//  Created by Łukasz Kasperek on 17.02.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import UIKit
import RxSwift
import ShoutitKit

enum ProfileCollectionViewModelMainModel {
    case ProfileModel(profile: Profile)
    case TagModel(tag: Tag)
    
    var name: String {
        switch self {
        case .ProfileModel(let profile): return profile.name
        case .TagModel(let tag): return tag.name
        }
    }
}

protocol ProfileCollectionViewModelInterface: class, ProfileCollectionViewLayoutDelegate, ProfileCollectionInfoSupplementaryViewDataSource {
    
    var model: ProfileCollectionViewModelMainModel? {get}
    // user data
    var name: String? {get}
    var username: String? {get}
    var isListeningToYou: Bool? {get}
    var coverURL: NSURL? {get}
    var conversation: MiniConversation? {get}
    var reportable: Reportable? {get}
    
    var verifyButtonTitle: String { get }
    
    // sections
    var listSection: ProfileCollectionSectionViewModel<ProfileCollectionListenableCellViewModel>! {get}
    var gridSection: ProfileCollectionSectionViewModel<ProfileCollectionShoutCellViewModel>! {get}
    
    // fetchin
    func reloadContent()
    var reloadSubject: PublishSubject<Void> {get}
    var successMessageSubject: PublishSubject<String> {get}
    func listen() -> Observable<Void>?
    
    // more handling
    func moreAlert(completion: (alertController: UIAlertController) -> Void) -> UIAlertController?
}

// MARK: - Default implementations

extension ProfileCollectionViewModelInterface {
    func replaceShout(newShout: Shout) {
        var cells : [ProfileCollectionShoutCellViewModel] = self.gridSection.cells
        let shouts : [Shout] = cells.map{ $0.shout }
        
        if let idx = shouts.indexOf(newShout) {
            cells[idx] = ProfileCollectionShoutCellViewModel(shout: newShout)
        }
        
        self.gridSection.cells = cells
    }
}

extension ProfileCollectionViewModelInterface {
    
    var hidesVerifyAccountButton: Bool {
        return true
    }
    
    func sectionContentModeForSection(section: Int) -> ProfileCollectionSectionContentMode {
        
        if section == 0 {
            if listSection.isLoading {
                return .Placeholder
            }
            return listSection.cells.count > 0 ? .Default : .Hidden
        }
        if section == 1 {
            if gridSection.isLoading {
                return .Placeholder
            }
            return gridSection.cells.count > 0 ? .Default : .Hidden
        }
        
        assertionFailure()
        return .Default
    }
    
    func hidesSupplementeryView(view: ProfileCollectionViewSupplementaryView) -> Bool {
        switch view {
        case .CreatePageButtonFooter:
            return true
        case .ListSectionHeader:
            return self.listSection.cells.count == 0 && !listSection.isLoading
        case .GridSectionHeader:
            return self.gridSection.cells.count == 0 && !gridSection.isLoading
        case .SeeAllShoutsButtonFooter:
            return self.gridSection.cells.count == 0
        default:
            return false
        }
    }
    
    func moreAlert(completion: (alertController: UIAlertController) -> Void) -> UIAlertController? {
        let alertController = UIAlertController(title: NSLocalizedString("More", comment: ""), message: nil, preferredStyle: .ActionSheet)
        
        if let reportable = self.reportable {
            alertController.addAction(UIAlertAction(title: reportable.reportTitle(), style: .Default, handler: { (action) in
                completion(alertController: alertController)
            }))
        }
        
        alertController.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .Cancel, handler: { (action) in
            
        }))
        
        return alertController
    }
}
