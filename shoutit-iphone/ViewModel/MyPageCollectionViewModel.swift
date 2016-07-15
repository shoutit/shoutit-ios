//
//  MyPageCollectionViewModel.swift
//  shoutit
//
//  Created by Łukasz Kasperek on 29.06.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import Foundation
import RxSwift
import ShoutitKit

final class MyPageCollectionViewModel: ProfileCollectionViewModelInterface {
    
    let disposeBag = DisposeBag()
    let reloadSubject: PublishSubject<Void> = PublishSubject()
    let successMessageSubject: PublishSubject<String> = PublishSubject()
    
    private(set) var verification: PageVerification?
    
    private var detailedPage: DetailedPageProfile?
    
    var profile: DetailedPageProfile? {
        guard case .Some(.Page(_, let page)) = Account.sharedInstance.loginState else {
            return nil
        }
        return page
    }
    
    var model: ProfileCollectionViewModelMainModel? {
        guard let user = profile else { return nil }
        return .ProfileModel(profile: Profile.profileWithUser(user))
    }
    
    var placeholderImage: UIImage {
        return UIImage.squareAvatarPagePlaceholder()
    }
    
    private(set) var listSection: ProfileCollectionSectionViewModel<ProfileCollectionListenableCellViewModel>!
    private(set) var gridSection: ProfileCollectionSectionViewModel<ProfileCollectionShoutCellViewModel>!
    
    init() {
        gridSection = gridSectionWithModels([], isLoading: true)
        listSection = listSectionWithModels([], isLoading: true)
        Account.sharedInstance.loginStateSubject
            .observeOn(MainScheduler.instance)
            .subscribeNext {[weak self] (loginState) in
                if case .Some(.Page(_, let page)) = loginState {
                    self?.detailedPage = page
                    self?.reloadSubject.onNext()
                }
            }
            .addDisposableTo(disposeBag)
    }
    
    func reloadContent() {
        
        // reload user
        fetchPageProfile()?
            .subscribe({[weak self] (event) in
                switch event {
                case .Next(let detailedProfile):
                    self?.detailedPage = detailedProfile
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
                case .Error(let error as NSError):
                    self?.gridSection = self?.gridSectionWithModels([], isLoading: false, errorMessage: error.localizedDescription)
                    self?.reloadSubject.onNext()
                default:
                    break
                }
            }
            .addDisposableTo(disposeBag)
        
        // reload admins
        fetchAdmins()?
            .subscribe { [weak self] (event) in
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
        
        fetchVerification()?
            .subscribe { [weak self] (event) in
                switch event {
                case .Next(let value):
                    self?.verification = value
                    self?.reloadSubject.onNext()
                case .Error(_):
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
        return detailedPage?.name ?? profile?.name
    }
    
    var username: String? {
        return detailedPage?.username ?? profile?.username
    }
    
    var isListeningToYou: Bool? {
        return false
    }
    
    var reportable: Reportable? {
        return nil
    }
    
    var verified: Bool {
        return self.detailedPage?.isVerified ?? false
    }
    
    var avatar: ProfileCollectionInfoSupplementeryViewAvatar {
        return .Remote(url: profile?.imagePath?.toURL())
    }
    
    var coverURL: NSURL? {
        return (profile?.coverPath != nil) ? NSURL(string: profile!.coverPath!) : nil
    }
    
    var conversation: MiniConversation? { return nil }
    
    var hidesVerifyAccountButton: Bool {
        if let activated = detailedPage?.isActivated {
            if activated == false {
                return false
            }
            
            if let verified = detailedPage?.isVerified {
                return verified
            }
        }
        return true
    }
    
    var verifyButtonTitle: String {
        if let activated = detailedPage?.isActivated {
            if activated == false {
                return NSLocalizedString("Activate your Page!", comment: "")
            }
        }
            
        return NSLocalizedString("Verify your business!", comment: "")
    }
    
    var infoButtons: [ProfileCollectionInfoButton] {
        
        guard let user = profile else {
            return []
        }
        
        let listenersCount = detailedPage?.listenersCount ?? user.listenersCount
        let listeningMetadata = detailedPage?.listeningMetadata ?? user.listeningMetadata
        
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
        return detailedPage?.about ?? profile?.about
    }
    
    var descriptionIcon: UIImage? {
        return UIImage.profileBioIcon()
    }
    
    var websiteString: String? {
        return detailedPage?.website ?? profile?.website
    }
    
    var dateJoinedString: String? {
        guard let epoch = detailedPage?.dateJoinedEpoch ?? profile?.dateJoinedEpoch else {return nil}
        return NSLocalizedString("Joined", comment: "User profile date joined cell") + " " + DateFormatters.sharedInstance.stringFromDateEpoch(epoch)
    }
    
    var locationString: String? {
        return detailedPage?.location.city ?? profile?.location.city
    }
    
    var locationFlag: UIImage? {
        return UIImage(named: (profile?.location.country ?? "country_placeholder"))
    }
    
    // MARK: - Fetch
    
    private func fetchShouts() -> Observable<[Shout]>? {
        guard let page = profile else {return nil}
        let params = FilteredShoutsParams(username: page.username, page: 1, pageSize: 4, currentUserLocation: nil, skipLocation: true)
        return APIShoutsService.listShoutsWithParams(params)
    }
    
    private func fetchAdmins() -> Observable<[Profile]>? {
        guard let page = profile else {return nil}
        let params = PageParams(page: 1, pageSize: 3)
        return APIPageService.getAdminsForPageWithUsername(page.username, pageParams: params).map{ $0.results }
    }
    
    private func fetchPageProfile() -> Observable<DetailedPageProfile>? {
        guard let page = profile else {return nil}
        return APIProfileService.retrievePageProfileWithUsername(page.username)
    }
    
    private func fetchVerification() -> Observable<PageVerification>? {
        guard let page = profile else {return nil}
        return APIPageService.getPageVerificationStatus(page.username)
    }

    
    func listen() -> Observable<Void>? {
        return nil
    }
    
    // MARK: - Helpers
    
    private func listSectionWithModels(pages: [Profile], isLoading loading: Bool, errorMessage: String? = nil) -> ProfileCollectionSectionViewModel<ProfileCollectionListenableCellViewModel> {
        let cells = pages.map{ProfileCollectionListenableCellViewModel(profile: $0)}
        let title = profile == nil ? NSLocalizedString("Admins", comment: "") : String.localizedStringWithFormat(NSLocalizedString("%@ Admins", comment: ""), profile!.name)
        let noContentMessage = NSLocalizedString("No pages available yet", comment: "")
        return ProfileCollectionSectionViewModel(title: title,
                                                 cells: cells,
                                                 isLoading: loading,
                                                 noContentMessage: noContentMessage,
                                                 errorMessage: errorMessage)
    }
    
    private func gridSectionWithModels(shouts: [Shout], isLoading loading: Bool, errorMessage: String? = nil) -> ProfileCollectionSectionViewModel<ProfileCollectionShoutCellViewModel> {
        let cells = shouts.map{ProfileCollectionShoutCellViewModel(shout: $0)}
        let title = profile == nil ? NSLocalizedString("Shouts", comment: "") : String.localizedStringWithFormat(NSLocalizedString("%@ Shouts", comment: ""), profile!.name)
        let footerTitle = NSLocalizedString("See All Shouts", comment: "")
        let noContentMessage = NSLocalizedString("No shouts available yet", comment: "")
        return ProfileCollectionSectionViewModel(title: title,
                                                 cells: cells,
                                                 isLoading: loading,
                                                 footerButtonTitle: footerTitle,
                                                 footerButtonStyle: .Gray,
                                                 noContentMessage: noContentMessage,
                                                 errorMessage: errorMessage)
    }
}
