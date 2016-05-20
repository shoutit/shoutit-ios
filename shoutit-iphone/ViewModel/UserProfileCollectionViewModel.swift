//
//  UserProfileCollectionViewModel.swift
//  shoutit-iphone
//
//  Created by Łukasz Kasperek on 04.03.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import Foundation
import RxSwift

final class UserProfileCollectionViewModel: ProfileCollectionViewModelInterface {
    
    let disposeBag = DisposeBag()
    let reloadSubject: PublishSubject<Void> = PublishSubject()
    let successMessageSubject: PublishSubject<String> = PublishSubject()
    
    let profile: Profile
    private var detailedUser: DetailedProfile?
    var model: ProfileCollectionViewModelMainModel? {
        return .ProfileModel(profile: profile)
    }
    
    private(set) var listSection: ProfileCollectionSectionViewModel<ProfileCollectionListenableCellViewModel>!
    private(set) var gridSection: ProfileCollectionSectionViewModel<ProfileCollectionShoutCellViewModel>!
    
    init(profile: Profile) {
        self.profile = profile
        gridSection = gridSectionWithModels([], isLoading: true)
        listSection = listSectionWithModels([], isLoading: true)
    }
    
    func reloadContent() {
        
        // reload user
        fetchProfile()
            .subscribe({[weak self] (event) in
                switch event {
                case .Next(let detailedProfile):
                    self?.detailedUser = detailedProfile
                    self?.reloadPages()
                    self?.reloadSubject.onNext(())
                case .Completed:
                    break
                case .Error:
                    self?.reloadPages()
                    self?.reloadSubject.onNext(())
                }
                })
            .addDisposableTo(disposeBag)
        
        // reload shouts
        fetchShouts()
            .subscribe {[weak self] (event) in
                switch event {
                case .Next(let value):
                    let shouts = Array(value.prefix(4))
                    self?.gridSection = self?.gridSectionWithModels(shouts, isLoading: false)
                case .Error(let error as NSError):
                    self?.gridSection = self?.gridSectionWithModels([], isLoading: false, errorMessage: error.localizedDescription)
                default:
                    break
                }
                self?.reloadSubject.onNext(())
            }
            .addDisposableTo(disposeBag)
    }
    
    // MARK: - ProfileCollectionViewModelInterface
    
    // user data
    
    var name: String? {
        return profile.name
    }
    
    var username: String? {
        return profile.username
    }
    
    var reportable: Reportable? {
        return profile
    }
    
    var conversation: MiniConversation? {
        return detailedUser?.conversation
    }
    
    var isListeningToYou: Bool? {
        return detailedUser?.isListener
    }
    
    var avatar: ProfileCollectionInfoSupplementeryViewAvatar {
        return .Remote(url: profile.imagePath?.toURL())
    }
    
    var coverURL: NSURL? {
        return (profile.coverPath != nil) ? NSURL(string: profile.coverPath!) : nil
    }
    
    var infoButtons: [ProfileCollectionInfoButton] {
        let listenersCountString = NumberFormatters.numberToShortString(detailedUser?.listenersCount ?? profile.listenersCount)
        return [.Listeners(countString: listenersCountString),
                .Chat,
                .Listen(isListening: detailedUser?.isListening ?? profile.isListening ?? false),
                .HiddenButton(position: .SmallLeft),
                .More]

    }
    
    var descriptionText: String? {
        return detailedUser?.bio
    }
    
    var descriptionIcon: UIImage? {
        return UIImage.profileBioIcon()
    }
    
    var websiteString: String? {
        return detailedUser?.website
    }
    
    var dateJoinedString: String? {
        guard let epoch = detailedUser?.dateJoinedEpoch else {return nil}
        return NSLocalizedString("Joined", comment: "User profile date foined cell") + " " + DateFormatters.sharedInstance.stringFromDateEpoch(epoch)
    }
    
    var locationString: String? {
        return detailedUser?.location.city
    }
    
    var locationFlag: UIImage? {
        return UIImage(named: (detailedUser?.location.country ?? "country_placeholder"))
    }

    // MARK: - Fetch
    
    func fetchShouts() -> Observable<[Shout]> {
        let params = FilteredShoutsParams(username: profile.username, page: 1, pageSize: 4)
        return APIShoutsService.listShoutsWithParams(params)
    }
    
    func fetchProfile() -> Observable<DetailedProfile> {
        return APIProfileService.retrieveProfileWithUsername(profile.username)
    }
    
    func listen() -> Observable<Void>? {
        guard let listening = profile.isListening else {return nil}
        let listen = !(detailedUser?.isListening ?? listening)
        let retrieveUser = fetchProfile().map {[weak self] (profile) -> Void in
            self?.detailedUser = profile
            self?.reloadSubject.onNext()
            let message = listen ? UserMessages.startedListeningMessageWithName(profile.name) : UserMessages.stoppedListeningMessageWithName(profile.name)
            self?.successMessageSubject.onNext(message)
        }
        return APIProfileService.listen(listen, toProfileWithUsername: profile.username).flatMap{() -> Observable<Void> in
            return retrieveUser
        }
    }
    
    // MARK: - Helpers
    
    private func reloadPages(currentlyLoading loading: Bool = false) {
        let pages = detailedUser?.pages ?? []
        listSection = listSectionWithModels(pages, isLoading: loading)
    }
    
    private func listSectionWithModels(pages: [Profile], isLoading loading: Bool, errorMessage: String? = nil) -> ProfileCollectionSectionViewModel<ProfileCollectionListenableCellViewModel> {
        let cells = pages.map{ProfileCollectionListenableCellViewModel(profile: $0)}
        let title = String.localizedStringWithFormat(NSLocalizedString("%@ Pages", comment: ""), profile.firstName ?? profile.name)
        let noContentMessage = NSLocalizedString("No pages available yet", comment: "")
        return ProfileCollectionSectionViewModel(title: title,
                                                 cells: cells,
                                                 isLoading: loading,
                                                 noContentMessage: noContentMessage,
                                                 errorMessage: errorMessage)
    }
    
    private func gridSectionWithModels(shouts: [Shout], isLoading loading: Bool, errorMessage: String? = nil) -> ProfileCollectionSectionViewModel<ProfileCollectionShoutCellViewModel> {
        let cells = shouts.map{ProfileCollectionShoutCellViewModel(shout: $0)}
        let title = String.localizedStringWithFormat(NSLocalizedString("%@ Shouts", comment: ""), profile.firstName ?? profile.name)
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
