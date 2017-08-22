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
    case profileModel(profile: Profile)
    case tagModel(tag: Tag)
    
    var name: String {
        switch self {
        case .profileModel(let profile): return profile.name
        case .tagModel(let tag): return tag.name
        }
    }
}

protocol ProfileCollectionViewModelInterface: class, ProfileCollectionViewLayoutDelegate, ProfileCollectionInfoSupplementaryViewDataSource {
    
    var model: ProfileCollectionViewModelMainModel? {get}
    // user data
    var name: String? {get}
    var username: String? {get}
    var isListeningToYou: Bool? {get}
    var coverURL: URL? {get}
    var conversation: MiniConversation? {get}
    var reportable: Reportable? {get}
    var placeholderImage: UIImage { get }
    var verifyButtonTitle: String { get }
    var verified: Bool { get }
    // sections
    var listSection: ProfileCollectionSectionViewModel<ProfileCollectionListenableCellViewModel>! {get}
    var gridSection: ProfileCollectionSectionViewModel<ProfileCollectionShoutCellViewModel>! {get}
    
    // fetchin
    func reloadContent()
    var reloadSubject: PublishSubject<Void> {get}
    var successMessageSubject: PublishSubject<String> {get}
    func listen() -> Observable<Void>?
    func reloadWithNewListnersCount(_ newListnersCount: Int?, isListening: Bool)
    
    // more handling
    func moreAlert(_ completion: (_ alertController: UIAlertController) -> Void) -> UIAlertController?
}

// MARK: - Default implementations

extension ProfileCollectionViewModelInterface {
    func replaceShout(_ newShout: Shout) {
        var cells : [ProfileCollectionShoutCellViewModel] = self.gridSection.cells
        let shouts : [Shout] = cells.map{ $0.shout }
        
        if let idx = shouts.index(of: newShout) {
            cells[idx] = ProfileCollectionShoutCellViewModel(shout: newShout)
        }
        
        self.gridSection.cells = cells
    }
}

extension ProfileCollectionViewModelInterface {
    
    var hidesVerifyAccountButton: Bool {
        return true
    }
    
    func sectionContentModeForSection(_ section: Int) -> ProfileCollectionSectionContentMode {
        
        if section == 0 {
            if listSection.isLoading {
                return .placeholder
            }
            return listSection.cells.count > 0 ? .default : .hidden
        }
        if section == 1 {
            if gridSection.isLoading {
                return .placeholder
            }
            return gridSection.cells.count > 0 ? .default : .hidden
        }
        
        assertionFailure()
        return .default
    }
    
    func hidesSupplementeryView(_ view: ProfileCollectionViewSupplementaryView) -> Bool {
        switch view {
        case .createPageButtonFooter:
            return true
        case .listSectionHeader:
            return self.listSection.cells.count == 0 && !listSection.isLoading
        case .gridSectionHeader:
            return self.gridSection.cells.count == 0 && !gridSection.isLoading
        case .seeAllShoutsButtonFooter:
            return self.gridSection.cells.count == 0
        default:
            return false
        }
    }
    
    func moreAlert(_ completion: @escaping (_ alertController: UIAlertController) -> Void) -> UIAlertController? {
        let alertController = UIAlertController(title: NSLocalizedString("More", comment: ""), message: nil, preferredStyle: .actionSheet)
        
        if let reportable = self.reportable {
            alertController.addAction(UIAlertAction(title: reportable.reportTitle(), style: .default, handler: { (action) in
                completion(alertController: alertController)
            }))
        }
        
        alertController.addAction(UIAlertAction(title: LocalizedString.cancel, style: .cancel, handler: { (action) in
            
        }))
        
        return alertController
    }
}
