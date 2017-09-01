//
//  PageProfileCollectionViewModel.swift
//  shoutit-iphone
//
//  Created by Łukasz Kasperek on 04.03.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import Foundation
import RxSwift
import ShoutitKit

final class PageProfileCollectionViewModel: ProfileCollectionViewModelInterface {
    
    let disposeBag = DisposeBag()
    let reloadSubject: PublishSubject<Void> = PublishSubject()
    let successMessageSubject: PublishSubject<String> = PublishSubject()
    
    fileprivate let profile: Profile
    fileprivate var detailedProfile: DetailedPageProfile?
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
        return UIImage.squareAvatarPagePlaceholder()
    }
    
    func reloadContent() {
        
        // reload user
        fetchProfile()
            .subscribe({[weak self] (event) in
                switch event {
                case .next(let detailedProfile):
                    self?.detailedProfile = detailedProfile
                    self?.reloadSubject.onNext(())
                case .completed:
                    break
                case .error:
                    self?.reloadSubject.onNext(())
                }
                })
            .addDisposableTo(disposeBag)
        
        // reload shouts
        fetchShouts()
            .subscribe {[weak self] (event) in
                switch event {
                case .next(let value):
                    let shouts = Array(value.prefix(4))
                    self?.gridSection = self?.gridSectionWithModels(shouts, isLoading: false)
                    self?.reloadSubject.onNext()
                case .error(let error as NSError):
                    self?.gridSection = self?.gridSectionWithModels([], isLoading: false, errorMessage: error.localizedDescription)
                    self?.reloadSubject.onNext()
                default:
                    break
                }
            }
            .addDisposableTo(disposeBag)
        
        // reload admins
        fetchAdmins()
            .subscribe { [weak self] (event) in
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
    
    var name: String? {
        return profile.name
    }
    
    var username: String? {
        return profile.username
    }
    
    var reportable: Reportable? {
        return nil
    }
    
    var conversation: MiniConversation? {
        return nil // profile.conversation
    }
    
    var isListeningToYou: Bool? {
        // TODO
        return false
    }
    
    var avatar: ProfileCollectionInfoSupplementeryViewAvatar {
        if let imgpath = profile.imagePath {
            return .remote(url: imgpath.toURL())
        } else {
            return .local(image:UIImage.squareAvatarPagePlaceholder())
        }
    }
    
    var coverURL: URL? {
        return (profile.coverPath != nil) ? URL(string: profile.coverPath!) : nil
    }
    
    var infoButtons: [ProfileCollectionInfoButton] {
        let listenersCountString = NumberFormatters.numberToShortString(detailedProfile?.listenersCount ?? profile.listenersCount)
        return [.listeners(countString: listenersCountString),
                .chat,
                .listen(isListening: detailedProfile?.isListening ?? profile.isListening ?? false),
                .hiddenButton(position: .smallLeft),
                .more]
    }
    
    var descriptionText: String? {
        return detailedProfile?.about
    }
    
    var descriptionIcon: UIImage? {
        return UIImage.profileAboutIcon()
    }
    
    var websiteString: String? {
        return detailedProfile?.website
    }
    
    var verified: Bool {
        return detailedProfile?.isVerified ?? false
    }
    
    var dateJoinedString: String? {
        guard let epoch = detailedProfile?.dateJoinedEpoch else {return nil}
        return NSLocalizedString("Joined", comment: "User profile date foined cell") + " " + DateFormatters.sharedInstance.stringFromDateEpoch(epoch)
    }
    
    var locationString: String? {
        return detailedProfile?.location.city
    }
    
    var locationFlag: UIImage? {
        return UIImage(named: (detailedProfile?.location.country ?? "country_placeholder"))
    }
    
    var verifyButtonTitle: String {
        return NSLocalizedString("Verify your account!", comment: "Profile message")
    }
    
    // MARK: - Fetch
    
    fileprivate func fetchShouts() -> Observable<[Shout]> {
        let params = FilteredShoutsParams(username: profile.username, page: 1, pageSize: 4, currentUserLocation: nil, skipLocation: true)
        return APIShoutsService.listShoutsWithParams(params).flatMap({ (result) -> Observable<[Shout]> in
            return Observable.just(result.results)
        })
    }
    
    fileprivate func fetchAdmins() -> Observable<[Profile]> {
        let params = PageParams(page: 1, pageSize: 3)
        return APIPageService.getAdminsForPageWithUsername(profile.username, pageParams: params).map{ $0.results }
    }
    
    fileprivate func fetchProfile() -> Observable<DetailedPageProfile> {
        return APIProfileService.retrievePageProfileWithUsername(profile.username)
    }
    
    func listen() -> Observable<Void>? {
        guard let isListening = detailedProfile?.isListening ?? profile.isListening else {return nil}
        let listen = !isListening
        
        return APIProfileService.listen(listen, toProfileWithUsername: profile.username).flatMap{ (success) -> Observable<Void> in
            self.successMessageSubject.onNext(success.message)
            
            self.reloadWithNewListnersCount(success.newListnersCount, isListening: listen)
            return Observable.just(Void())
        }
    }
    
    func reloadWithNewListnersCount(_ newListnersCount: Int?, isListening: Bool) {
        guard let newListnersCount = newListnersCount else {
            return
        }
        
        if let newProfile = self.detailedProfile?.updatedProfileWithNewListnersCount(newListnersCount, isListening: isListening) {
            self.detailedProfile = newProfile
            self.reloadSubject.onNext()
        }
    }
    
    // MARK: - Helpers
    
    fileprivate func listSectionWithModels(_ pages: [Profile], isLoading loading: Bool, errorMessage: String? = nil) -> ProfileCollectionSectionViewModel<ProfileCollectionListenableCellViewModel> {
        let cells = pages.map{ProfileCollectionListenableCellViewModel(profile: $0)}
        let title = String.localizedStringWithFormat(NSLocalizedString("%@ Admins", comment: "Admins Section Title"), profile.name)
        let noContentMessage = NSLocalizedString("No pages available yet", comment: "Profile Placeholder")
        return ProfileCollectionSectionViewModel(title: title,
                                                 cells: cells,
                                                 isLoading: loading,
                                                 noContentMessage: noContentMessage,
                                                 errorMessage: errorMessage)
    }
    
    fileprivate func gridSectionWithModels(_ shouts: [Shout], isLoading loading: Bool, errorMessage: String? = nil) -> ProfileCollectionSectionViewModel<ProfileCollectionShoutCellViewModel> {
        let cells = shouts.map{ProfileCollectionShoutCellViewModel(shout: $0)}
        let title = String.localizedStringWithFormat(NSLocalizedString("%@ Shouts", comment: "Number of Shouts"), profile.name)
        let footerTitle = NSLocalizedString("See All Shouts", comment: "Profile Footer section")
        let noContentMessage = NSLocalizedString("No shouts available yet", comment: "Profile shouts placeholder")
        return ProfileCollectionSectionViewModel(title: title,
                                                 cells: cells,
                                                 isLoading: loading,
                                                 footerButtonTitle: footerTitle,
                                                 footerButtonStyle: .gray,
                                                 noContentMessage: noContentMessage,
                                                 errorMessage: errorMessage)
    }
}
