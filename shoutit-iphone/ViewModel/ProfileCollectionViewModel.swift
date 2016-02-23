//
//  ProfileCollectionViewModel.swift
//  shoutit-iphone
//
//  Created by Łukasz Kasperek on 11.02.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class ProfileCollectionViewModel: ProfileCollectionViewModelInterface {
    
    let disposeBag = DisposeBag()
    let reloadSubject: PublishSubject<Void> = PublishSubject()
    
    init() {
        shoutsSection = ProfileCollectionViewModel.shoutsSectionWithModels([])
        let pages = (Account.sharedInstance.user as? LoggedUser)?.pages ?? []
        pagesSection = ProfileCollectionViewModel.pagesSectionWithModels(pages)
    }
    
    func reloadContent() {
        fetchShouts()
            .subscribe {[weak self] (event) in
                switch event {
                case .Next(let value):
                    let shouts = Array(value.prefix(4))
                    self?.shoutsSection = ProfileCollectionViewModel.shoutsSectionWithModels(shouts)
                case .Error(let error as NSError):
                    self?.shoutsSection = ProfileCollectionViewModel.shoutsSectionWithModels([], errorMessage: error.localizedDescription)
                default:
                    break
                }
                self?.reloadSubject.onNext(())
            }
            .addDisposableTo(disposeBag)
    }
    
    var user: LoggedUser {
        return Account.sharedInstance.user as! LoggedUser
    }
    
    private(set) var pagesSection: ProfileCollectionSectionViewModel<ProfileCollectionPageCellViewModel>
    private(set) var shoutsSection: ProfileCollectionSectionViewModel<ProfileCollectionShoutCellViewModel>
    
    // MARK: - ProfileCollectionViewModelInterface
    var configuration: ProfileCollectionViewConfiguration {
        return .MyProfile
    }
    
    // user data
    var name: String? {
        return user.name
    }
    
    var username: String? {
        return user.username
    }
    
    var isListeningToYou: Bool? {
        return false
    }
    
    var avatarURL: NSURL? {
        return (user.imagePath != nil) ? NSURL(string: user.imagePath!) : nil
    }
    
    var coverURL: NSURL? {
        return (user.coverPath != nil) ? NSURL(string: user.coverPath!) : nil
    }
    
    var infoButtons: [ProfileCollectionInfoButton] {
    
        guard user.isGuest == false else {
            assert(false)
            return []
        }

        let listenersCountString = NumberFormatters.sharedInstance.numberToShortString(user.listenersCount!)
        
        var listeningCountString = ""
        var interestsCountString = ""
        
        if let listningMetadata = user.listeningMetadata {
            listeningCountString = NumberFormatters.sharedInstance.numberToShortString(listningMetadata.users)
            interestsCountString = NumberFormatters.sharedInstance.numberToShortString(listningMetadata.tags)
        }
        
        return [.Listeners(countString: listenersCountString), .Listening(countString: listeningCountString), .Interests(countString: interestsCountString), .Notification, .EditProfile]
    }
    
    var descriptionText: String? {
        return user.bio
    }
    
    var websiteString: String? {
        return user.website
    }
    
    var dateJoinedString: String? {
        return NSLocalizedString("Joined", comment: "User profile date foined cell") + " " + DateFormatters.sharedInstance.stringFromDateEpoch(user.dateJoinedEpoch)
    }
    
    var locationString: String? {
        return user.location.city
    }
    
    var locationFlag: UIImage? {
        return UIImage(named: (user.location.country ?? "country_placeholder"))
    }
    
    func hasContentToDisplayInSection(section: Int) -> Bool {
        if section == 0 {
            return pagesSection.cells.count > 0
        }
        if section == 1 {
            return shoutsSection.cells.count > 1
        }
        return false
    }
    
    // MARK: - Fetch
    
    func fetchShouts() -> Observable<[Shout]> {
        let params = UserShoutsParams(username: "me", pageSize: 4, shoutType: nil)
        return APIShoutsService.shoutsForUserWithParams(params)
    }
    
    // MARK: - Helpers
    
    private static func pagesSectionWithModels(pages: [Profile], errorMessage: String? = nil) -> ProfileCollectionSectionViewModel<ProfileCollectionPageCellViewModel> {
        let cells = pages.map{ProfileCollectionPageCellViewModel(profile: $0)}
        let title = NSLocalizedString("My Pages", comment: "")
        let footerTitle = NSLocalizedString("Create Page", comment: "")
        let noContentMessage = NSLocalizedString("No pages available yet", comment: "")
        return ProfileCollectionSectionViewModel(title: title, cells: cells, footerButtonTitle: footerTitle, footerButtonStyle: .Green, noContentMessage: noContentMessage, errorMessage: errorMessage)
    }
    
    private static func shoutsSectionWithModels(shouts: [Shout], errorMessage: String? = nil) -> ProfileCollectionSectionViewModel<ProfileCollectionShoutCellViewModel> {
        let cells = shouts.map{ProfileCollectionShoutCellViewModel(shout: $0)}
        let title = NSLocalizedString("My Shouts", comment: "")
        let footerTitle = NSLocalizedString("See All Shouts", comment: "")
        let noContentMessage = NSLocalizedString("No shouts available yet", comment: "")
        return ProfileCollectionSectionViewModel(title: title, cells: cells, footerButtonTitle: footerTitle, footerButtonStyle: .Gray, noContentMessage: noContentMessage, errorMessage: errorMessage)
    }
}
