//
//  MyProfileCollectionViewModel.swift
//  shoutit-iphone
//
//  Created by Łukasz Kasperek on 04.03.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import Foundation
import RxSwift
import ShoutitKit

final class MyProfileCollectionViewModel: ProfileCollectionViewModelInterface {
    
    let disposeBag = DisposeBag()
    let reloadSubject: PublishSubject<Void> = PublishSubject()
    let successMessageSubject: PublishSubject<String> = PublishSubject()
    
    private var detailedUser: DetailedUserProfile?
    
    var user: DetailedUserProfile? {
        guard case .Some(.Logged(let user)) = Account.sharedInstance.loginState else {
            return nil
        }
        return user
    }
    
    var model: ProfileCollectionViewModelMainModel? {
        guard let user = user else { return nil }
        return .ProfileModel(profile: Profile.profileWithUser(user))
    }
    
    var verified: Bool {
        return false
    }
    
    var placeholderImage: UIImage {
        return UIImage.squareAvatarPlaceholder()
    }
    
    private(set) var listSection: ProfileCollectionSectionViewModel<ProfileCollectionListenableCellViewModel>!
    private(set) var gridSection: ProfileCollectionSectionViewModel<ProfileCollectionShoutCellViewModel>!
    
    init() {
        gridSection = gridSectionWithModels([], isLoading: true)
        listSection = listSectionWithModels([], isLoading: true)
        Account.sharedInstance.loginStateSubject
            .observeOn(MainScheduler.instance)
            .subscribeNext {[weak self] (loginState) in
                if case .Some(.Logged(let user)) = loginState {
                    self?.detailedUser = user
                    self?.reloadSubject.onNext()
                }
            }
            .addDisposableTo(disposeBag)
    }
    
    func reloadContent() {
        
        // reload user
        fetchUser()?
            .subscribe({[weak self] (event) in
                switch event {
                case .Next(let detailedProfile):
                    self?.detailedUser = detailedProfile
                    self?.reloadSubject.onNext(())
                case .Completed:
                    break
                case .Error:
                    self?.reloadSubject.onNext(())
                }
                })
            .addDisposableTo(disposeBag)
        
        // reload shouts
        fetchShouts()?
            .subscribe {[weak self] (event) in
                switch event {
                case .Next(let value):
                    let shouts = Array(value.prefix(4))
                    self?.gridSection = self?.gridSectionWithModels(shouts, isLoading: false)
                    self?.reloadSubject.onNext()
                case .Error(let error):
                    self?.gridSection = self?.gridSectionWithModels([], isLoading: false, errorMessage: error.sh_message)
                    self?.reloadSubject.onNext()
                default:
                    break
                }
            }
            .addDisposableTo(disposeBag)
        
        // fetch pages
        fetchPages()?
            .subscribe{ [weak self] (event) in
                switch event {
                case .Next(let value):
                    self?.listSection = self?.listSectionWithModels(value, isLoading: false)
                    self?.reloadSubject.onNext()
                case .Error(let error):
                    self?.listSection = self?.listSectionWithModels([], isLoading: false, errorMessage: error.sh_message)
                    self?.reloadSubject.onNext()
                default:
                    break
                }
            }
            .addDisposableTo(disposeBag)
    }
    
    // MARK: - ProfileCollectionViewModelInterface
    
    // user data
    
    var name: String? {
        return detailedUser?.name ?? user?.name
    }
    
    var username: String? {
        return detailedUser?.username ?? user?.username
    }
    
    var isListeningToYou: Bool? {
        return false
    }
    
    var reportable: Reportable? {
        return nil
    }
    
    var avatar: ProfileCollectionInfoSupplementeryViewAvatar {
        return .Remote(url: user?.imagePath?.toURL())
    }
    
    var coverURL: NSURL? {
        return (user?.coverPath != nil) ? NSURL(string: user!.coverPath!) : nil
    }
    
    var conversation: MiniConversation? { return nil }
    
    var hidesVerifyAccountButton: Bool {
        return detailedUser?.isActivated ?? user?.isActivated ?? true
    }
    
    var verifyButtonTitle: String {
        return NSLocalizedString("Verify your account!", comment: "")
    }
    
    var infoButtons: [ProfileCollectionInfoButton] {
        
        guard let user = user else {
            return []
        }
        
        let listenersCount = detailedUser?.listenersCount ?? user.listenersCount
        let listeningMetadata = detailedUser?.listeningMetadata ?? user.listeningMetadata
        
        let listenersCountString = NumberFormatters.numberToShortString(listenersCount)
        
        var listeningCountString = ""
        var interestsCountString = ""
        
        if let listeningMetadata = listeningMetadata {
            listeningCountString = NumberFormatters.numberToShortString(listeningMetadata.users + listeningMetadata.pages)
            interestsCountString = NumberFormatters.numberToShortString(listeningMetadata.tags)
        }
        
        return [.Listeners(countString: listenersCountString), .Listening(countString: listeningCountString), .Interests(countString: interestsCountString), .Notification(position: nil), .EditProfile]
    }
    
    var descriptionText: String? {
        return detailedUser?.bio ?? user?.bio
    }
    
    var descriptionIcon: UIImage? {
        return UIImage.profileBioIcon()
    }
    
    var websiteString: String? {
        return detailedUser?.website ?? user?.website
    }
    
    var dateJoinedString: String? {
        guard let epoch = detailedUser?.dateJoinedEpoch ?? user?.dateJoinedEpoch else {return nil}
        return NSLocalizedString("Joined", comment: "User profile date joined cell") + " " + DateFormatters.sharedInstance.stringFromDateEpoch(epoch)
    }
    
    var locationString: String? {
        return detailedUser?.location.city ?? user?.location.city
    }
    
    var locationFlag: UIImage? {
        return UIImage(named: (user?.location.country ?? "country_placeholder"))
    }
    
    // MARK: - Fetch
    
    private func fetchShouts() -> Observable<[Shout]>? {
        guard let user = user else {return nil}
        let params = FilteredShoutsParams(username: user.username, page: 1, pageSize: 4, currentUserLocation: nil, skipLocation: true)
        return APIShoutsService.listShoutsWithParams(params)
    }
    
    private func fetchPages() -> Observable<[Profile]>? {
        guard let user = user else { return nil }
        let params = PageParams(page: 1, pageSize: 3)
        return APIProfileService.getPagesForUsername(user.username, pageParams: params).map{ $0.results }
    }
    
    private func fetchUser() -> Observable<DetailedUserProfile>? {
        guard let user = user else {return nil}
        return APIProfileService.retrieveProfileWithUsername(user.username)
    }
    
    func listen() -> Observable<Void>? {
        return nil
    }
    
    // MARK: - Helpers
    
    private func listSectionWithModels(pages: [Profile], isLoading loading: Bool, errorMessage: String? = nil) -> ProfileCollectionSectionViewModel<ProfileCollectionListenableCellViewModel> {
        let cells = pages.map{ProfileCollectionListenableCellViewModel(profile: $0)}
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
    
    private func gridSectionWithModels(shouts: [Shout], isLoading loading: Bool, errorMessage: String? = nil) -> ProfileCollectionSectionViewModel<ProfileCollectionShoutCellViewModel> {
        let cells = shouts.map{ProfileCollectionShoutCellViewModel(shout: $0)}
        let title = NSLocalizedString("My Shouts", comment: "")
        let footerTitle = NSLocalizedString("See All Shouts", comment: "")
        let noContentMessage = NSLocalizedString("No shouts available yet", comment: "")
        return ProfileCollectionSectionViewModel(title: title, cells: cells, isLoading: loading, footerButtonTitle: footerTitle, footerButtonStyle: .Gray, noContentMessage: noContentMessage, errorMessage: errorMessage)
    }
}