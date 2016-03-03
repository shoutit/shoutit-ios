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
    
    private let profile: Profile?
    private var detailedUser: DetailedProfile?
    
    var user: ProfileCollectionUser? {
        return detailedUser ?? profile ?? Account.sharedInstance.user as? LoggedUser
    }
    
    private(set) var pagesSection: ProfileCollectionSectionViewModel<ProfileCollectionPageCellViewModel>!
    private(set) var shoutsSection: ProfileCollectionSectionViewModel<ProfileCollectionShoutCellViewModel>!
    
    init(profile: Profile? = nil) {
        if let profile = profile, let user = Account.sharedInstance.user as? LoggedUser where profile.id == user.id {
            self.profile = nil
        } else {
            self.profile = profile
        }
        shoutsSection = shoutsSectionWithModels([])
        if let _ = self.profile {
            pagesSection = pagesSectionWithModels([])
        } else {
            let pages = (Account.sharedInstance.user as? LoggedUser)?.pages ?? []
            pagesSection = pagesSectionWithModels(pages)
            Account.sharedInstance.userSubject
                .observeOn(MainScheduler.instance)
                .subscribeNext { (_) in
                    self.invalidateUser()
                }
                .addDisposableTo(disposeBag)
        }
    }
    
    func reloadContent() {
        
        reloadPages()
        
        // reload user
        fetchUser()?
            .subscribeNext {[weak self] (detailedProfile) in
                self?.detailedUser = detailedProfile
                self?.reloadPages()
                self?.reloadSubject.onNext(())
            }
            .addDisposableTo(disposeBag)
        
        // reload shouts
        fetchShouts()?
            .subscribe {[weak self] (event) in
                switch event {
                case .Next(let value):
                    let shouts = Array(value.prefix(4))
                    self?.shoutsSection = self?.shoutsSectionWithModels(shouts)
                case .Error(let error as NSError):
                    self?.shoutsSection = self?.shoutsSectionWithModels([], errorMessage: error.localizedDescription)
                default:
                    break
                }
                self?.reloadSubject.onNext(())
            }
            .addDisposableTo(disposeBag)
    }
    
    private func invalidateUser() {
        detailedUser = nil
        reloadContent()
    }
    
    private func reloadPages() {
        let pages = user?.pages ?? []
        pagesSection = pagesSectionWithModels(pages)
    }
    
    // MARK: - ProfileCollectionViewModelInterface
    
    // user data
    var name: String? {
        return user?.name
    }
    
    var username: String? {
        return user?.username
    }
    
    var isListeningToYou: Bool? {
        return false
    }
    
    var avatarURL: NSURL? {
        return (user?.imagePath != nil) ? NSURL(string: user!.imagePath!) : nil
    }
    
    var coverURL: NSURL? {
        return (user?.coverPath != nil) ? NSURL(string: user!.coverPath!) : nil
    }
    
    var infoButtons: [ProfileCollectionInfoButton] {
    
        guard let user = user else {
            return []
        }
        
        let listenersCountString = NumberFormatters.sharedInstance.numberToShortString(user.listenersCount)
        
        if let profile = profile {
            return [.Listeners(countString: listenersCountString), .Chat, .Listen(isListening: detailedUser?.isListening ?? profile.listening ?? false), .HiddenButton(position: .SmallLeft), .More]
        } else {
            
            var listeningCountString = ""
            var interestsCountString = ""
            
            if let listningMetadata = user.listeningMetadata {
                listeningCountString = NumberFormatters.sharedInstance.numberToShortString(listningMetadata.users)
                interestsCountString = NumberFormatters.sharedInstance.numberToShortString(listningMetadata.tags)
            }
            
            return [.Listeners(countString: listenersCountString), .Listening(countString: listeningCountString), .Interests(countString: interestsCountString), .Notification, .EditProfile]
        }
    }
    
    var descriptionText: String? {
        return user?.bio
    }
    
    var websiteString: String? {
        return user?.website
    }
    
    var dateJoinedString: String? {
        guard let user = user, let epoch = user.dateJoinedEpoch_optional else {return nil}
        return NSLocalizedString("Joined", comment: "User profile date foined cell") + " " + DateFormatters.sharedInstance.stringFromDateEpoch(epoch)
    }
    
    var locationString: String? {
        return user?.location_optional?.city
    }
    
    var locationFlag: UIImage? {
        return UIImage(named: (user?.location_optional?.country ?? "country_placeholder"))
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
    
    func hidesSupplementeryView(view: ProfileCollectionViewSupplementaryView) -> Bool {
        if case .CreatePageButtonFooter = view {
            return true
        }
        return false
    }
    
    // MARK: - Fetch
    
    func fetchShouts() -> Observable<[Shout]>? {
        guard let user = user else {return nil}
        let params = UserShoutsParams(username: user.username, pageSize: 4, shoutType: nil)
        return APIShoutsService.shoutsForUserWithParams(params)
    }
    
    func fetchUser() -> Observable<DetailedProfile>? {
        guard let user = user else {return nil}
        return APIUsersService.retrieveUserWithUsername(user.username)
    }
    
    func listenToUser() -> Observable<Void>? {
        guard let profile = profile, let listening = profile.listening else {return nil}
        let listen = !(detailedUser?.isListening ?? listening)
        let retrieveUser = APIUsersService.retrieveUserWithUsername(profile.username).map {[weak self] (profile) -> Void in
            self?.detailedUser = profile
            self?.reloadSubject.onNext()
        }
        return APIUsersService.listen(listen, toUserWithUsername: profile.username).flatMap{() -> Observable<Void> in
            return retrieveUser
        }
    }
    
    // MARK: - Helpers
    
    private func pagesSectionWithModels(pages: [Profile], errorMessage: String? = nil) -> ProfileCollectionSectionViewModel<ProfileCollectionPageCellViewModel> {
        let cells = pages.map{ProfileCollectionPageCellViewModel(profile: $0)}
        let title: String
        if let profile = profile {
            title = NSLocalizedString("\(profile.firstName) Pages", comment: "")
        } else {
            title = NSLocalizedString("My Pages", comment: "")
        }
        let footerTitle = NSLocalizedString("Create Page", comment: "")
        let noContentMessage = NSLocalizedString("No pages available yet", comment: "")
        return ProfileCollectionSectionViewModel(title: title, cells: cells, footerButtonTitle: footerTitle, footerButtonStyle: .Green, noContentMessage: noContentMessage, errorMessage: errorMessage)
    }
    
    private func shoutsSectionWithModels(shouts: [Shout], errorMessage: String? = nil) -> ProfileCollectionSectionViewModel<ProfileCollectionShoutCellViewModel> {
        let cells = shouts.map{ProfileCollectionShoutCellViewModel(shout: $0)}
        let title: String
        if let profile = profile {
            title = NSLocalizedString("\(profile.firstName) Shouts", comment: "")
        } else {
            title = NSLocalizedString("My Shouts", comment: "")
        }
        let footerTitle = NSLocalizedString("See All Shouts", comment: "")
        let noContentMessage = NSLocalizedString("No shouts available yet", comment: "")
        return ProfileCollectionSectionViewModel(title: title, cells: cells, footerButtonTitle: footerTitle, footerButtonStyle: .Gray, noContentMessage: noContentMessage, errorMessage: errorMessage)
    }
}
