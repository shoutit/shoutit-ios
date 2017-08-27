//
//  UserProfileCollectionViewModel.swift
//  shoutit-iphone
//
//  Created by Łukasz Kasperek on 04.03.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import Foundation
import RxSwift
import ShoutitKit

final class UserProfileCollectionViewModel: ProfileCollectionViewModelInterface {
    
    let disposeBag = DisposeBag()
    let reloadSubject: PublishSubject<Void> = PublishSubject()
    let successMessageSubject: PublishSubject<String> = PublishSubject()
    
    let profile: Profile
    fileprivate var detailedUser: DetailedUserProfile?
    var model: ProfileCollectionViewModelMainModel? {
        return .profileModel(profile: profile)
    }
    
    fileprivate(set) var listSection: ProfileCollectionSectionViewModel<ProfileCollectionListenableCellViewModel>!
    fileprivate(set) var gridSection: ProfileCollectionSectionViewModel<ProfileCollectionShoutCellViewModel>!
    
    init(profile: Profile) {
        self.profile = profile
        gridSection = gridSectionWithModels([], isLoading: true)
        listSection = listSectionWithModels([], isLoading: true)
    }
    
    var placeholderImage: UIImage {
        return UIImage.squareAvatarPlaceholder()
    }
    
    func reloadContent() {
        
        // reload user
        fetchProfile()
            .subscribe{[weak self] (event) in
                switch event {
                case .next(let detailedProfile):
                    self?.detailedUser = detailedProfile
                    self?.reloadSubject.onNext()
                case .completed:
                    break
                case .Error:
                    self?.reloadSubject.onNext()
                }
            }
            .addDisposableTo(disposeBag)
        
        // reload shouts
        fetchShouts()
            .subscribe {[weak self] (event) in
                switch event {
                case .next(let value):
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
        
        // reload pages
        fetchPages()
            .subscribe{ [weak self] (event) in
                switch event {
                case .next(let value):
                    self?.listSection = self?.listSectionWithModels(value, isLoading: false)
                    self?.reloadSubject.onNext()
                case .error(let error):
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
        return .remote(url: profile.imagePath?.toURL())
    }
    
    var coverURL: URL? {
        return (profile.coverPath != nil) ? URL(string: profile.coverPath!) : nil
    }
    
    var infoButtons: [ProfileCollectionInfoButton] {
        let listenersCountString = NumberFormatters.numberToShortString(detailedUser?.listenersCount ?? profile.listenersCount)
        return [.listeners(countString: listenersCountString),
                .chat,
                .listen(isListening: detailedUser?.isListening ?? profile.isListening ?? false),
                .hiddenButton(position: .smallLeft),
                .more]

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
    
    var verified: Bool {
        return false
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

    var verifyButtonTitle: String {
        return NSLocalizedString("Verify your account!", comment: "Profile Message")
    }
    
    // MARK: - Fetch
    
    fileprivate func fetchShouts() -> Observable<[Shout]> {
        let params = FilteredShoutsParams(username: profile.username, page: 1, pageSize: 4, skipLocation: true)
        return APIShoutsService.listShoutsWithParams(params).flatMap({ (result) -> Observable<[Shout]> in
            return Observable.just(result.results)
        })
    }
    
    fileprivate func fetchPages() -> Observable<[Profile]> {
        let params = PageParams(page: 1, pageSize:  3)
        return APIProfileService.getPagesForUsername(profile.username, pageParams: params).map{ $0.results }
    }
    
    func fetchProfile() -> Observable<DetailedUserProfile> {
        return APIProfileService.retrieveProfileWithUsername(profile.username)
    }
    
    func reloadWithNewListnersCount(_ newListnersCount: Int?, isListening: Bool) {
        guard let newListnersCount = newListnersCount else {
            return
        }
    
        if let newProfile = self.detailedUser?.updatedProfileWithNewListnersCount(newListnersCount, isListening: isListening) {
            self.detailedUser = newProfile
            self.reloadSubject.onNext()
        }
    }
    
    func listen() -> Observable<Void>? {
        guard let isListening = detailedUser?.isListening ?? profile.isListening else {return nil}
        let listen = !isListening
      
        return APIProfileService.listen(listen, toProfileWithUsername: profile.username).flatMap{ (success) -> Observable<Void> in
            self.successMessageSubject.onNext(success.message)
            self.reloadWithNewListnersCount(success.newListnersCount, isListening: listen)
            return Observable.just(Void())
        
        }
    }
    
    // MARK: - Helpers
    
    fileprivate func listSectionWithModels(_ pages: [Profile], isLoading loading: Bool, errorMessage: String? = nil) -> ProfileCollectionSectionViewModel<ProfileCollectionListenableCellViewModel> {
        let cells = pages.map{ProfileCollectionListenableCellViewModel(profile: $0)}
        let title = String.localizedStringWithFormat(NSLocalizedString("%@ Pages", comment: "Number of pages"), profile.firstName ?? profile.name)
        let noContentMessage = NSLocalizedString("No pages available yet", comment: "User Profile No pages placeholder")
        return ProfileCollectionSectionViewModel(title: title,
                                                 cells: cells,
                                                 isLoading: loading,
                                                 noContentMessage: noContentMessage,
                                                 errorMessage: errorMessage)
    }
    
    fileprivate func gridSectionWithModels(_ shouts: [Shout], isLoading loading: Bool, errorMessage: String? = nil) -> ProfileCollectionSectionViewModel<ProfileCollectionShoutCellViewModel> {
        let cells = shouts.map{ProfileCollectionShoutCellViewModel(shout: $0)}
        let title = String.localizedStringWithFormat(NSLocalizedString("%@ Shouts", comment: "Number of shouts"), profile.firstName ?? profile.name)
        let footerTitle = NSLocalizedString("See All Shouts", comment: "")
        let noContentMessage = NSLocalizedString("No shouts available yet", comment: "User Profile No shouts placeholder")
        return ProfileCollectionSectionViewModel(title: title,
                                                 cells: cells,
                                                 isLoading: loading,
                                                 footerButtonTitle: footerTitle,
                                                 footerButtonStyle: .gray,
                                                 noContentMessage: noContentMessage,
                                                 errorMessage: errorMessage)
    }
}
