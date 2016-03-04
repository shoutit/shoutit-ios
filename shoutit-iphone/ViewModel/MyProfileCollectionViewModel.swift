//
//  MyProfileCollectionViewModel.swift
//  shoutit-iphone
//
//  Created by Łukasz Kasperek on 04.03.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import Foundation
import RxSwift

class MyProfileCollectionViewModel: ProfileCollectionViewModelInterface {
    
    let disposeBag = DisposeBag()
    let reloadSubject: PublishSubject<Void> = PublishSubject()
    
    private var detailedUser: DetailedProfile?
    
    var user: LoggedUser? {
        return Account.sharedInstance.user as? LoggedUser
    }
    
    private(set) var pagesSection: ProfileCollectionSectionViewModel<ProfileCollectionPageCellViewModel>!
    private(set) var shoutsSection: ProfileCollectionSectionViewModel<ProfileCollectionShoutCellViewModel>!
    
    init() {
        shoutsSection = shoutsSectionWithModels([], isLoading: true)
        let pages = (Account.sharedInstance.user as? LoggedUser)?.pages ?? []
        pagesSection = pagesSectionWithModels(pages, isLoading: true)
        Account.sharedInstance.userSubject
            .observeOn(MainScheduler.instance)
            .subscribeNext { (_) in
                self.invalidateUser()
            }
            .addDisposableTo(disposeBag)
    }
    
    func reloadContent() {
        
        reloadPages(currentlyLoading: true)
        
        // reload user
        fetchUser()?
            .subscribe({[weak self] (event) in
                switch event {
                case .Next(let detailedProfile):
                    self?.detailedUser = detailedProfile
                    self?.reloadPages()
                    self?.reloadSubject.onNext(())
                case .Completed:
                    break
                case .Error(let error):
                    self?.reloadPages()
                    self?.reloadSubject.onNext(())
                    print(error)
                }
                })
            .addDisposableTo(disposeBag)
        
        // reload shouts
        fetchShouts()?
            .subscribe {[weak self] (event) in
                switch event {
                case .Next(let value):
                    let shouts = Array(value.prefix(4))
                    self?.shoutsSection = self?.shoutsSectionWithModels(shouts, isLoading: false)
                case .Error(let error as NSError):
                    self?.shoutsSection = self?.shoutsSectionWithModels([], isLoading: false, errorMessage: error.localizedDescription)
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
    
    private func reloadPages(currentlyLoading loading: Bool = false) {
        let pages = user?.pages ?? []
        pagesSection = pagesSectionWithModels(pages, isLoading: loading)
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
        
        var listeningCountString = ""
        var interestsCountString = ""
        
        if let listningMetadata = user.listeningMetadata {
            listeningCountString = NumberFormatters.sharedInstance.numberToShortString(listningMetadata.users)
            interestsCountString = NumberFormatters.sharedInstance.numberToShortString(listningMetadata.tags)
        }
        
        return [.Listeners(countString: listenersCountString), .Listening(countString: listeningCountString), .Interests(countString: interestsCountString), .Notification, .EditProfile]
    }
    
    var descriptionText: String? {
        return user?.bio
    }
    
    var descriptionIcon: UIImage? {
        return UIImage.profileBioIcon()
    }
    
    var websiteString: String? {
        return user?.website
    }
    
    var dateJoinedString: String? {
        guard let epoch = user?.dateJoinedEpoch else {return nil}
        return NSLocalizedString("Joined", comment: "User profile date joined cell") + " " + DateFormatters.sharedInstance.stringFromDateEpoch(epoch)
    }
    
    var locationString: String? {
        return user?.location.city
    }
    
    var locationFlag: UIImage? {
        return UIImage(named: (user?.location.country ?? "country_placeholder"))
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
        return nil
    }
    
    // MARK: - Helpers
    
    private func pagesSectionWithModels(pages: [Profile], isLoading loading: Bool, errorMessage: String? = nil) -> ProfileCollectionSectionViewModel<ProfileCollectionPageCellViewModel> {
        let cells = pages.map{ProfileCollectionPageCellViewModel(profile: $0)}
        let title = NSLocalizedString("My Pages", comment: "")
        let footerTitle = NSLocalizedString("Create Page", comment: "")
        let noContentMessage = NSLocalizedString("No pages available yet", comment: "")
        return ProfileCollectionSectionViewModel(title: title,
                                                 cells: cells,
                                                 isLoading: loading,
                                                 footerButtonTitle: footerTitle,
                                                 footerButtonStyle: .Green,
                                                 noContentMessage: noContentMessage,
                                                 errorMessage: errorMessage)
    }
    
    private func shoutsSectionWithModels(shouts: [Shout], isLoading loading: Bool, errorMessage: String? = nil) -> ProfileCollectionSectionViewModel<ProfileCollectionShoutCellViewModel> {
        let cells = shouts.map{ProfileCollectionShoutCellViewModel(shout: $0)}
        let title = NSLocalizedString("My Shouts", comment: "")
        let footerTitle = NSLocalizedString("See All Shouts", comment: "")
        let noContentMessage = NSLocalizedString("No shouts available yet", comment: "")
        return ProfileCollectionSectionViewModel(title: title, cells: cells, isLoading: loading, footerButtonTitle: footerTitle, footerButtonStyle: .Gray, noContentMessage: noContentMessage, errorMessage: errorMessage)
    }
}