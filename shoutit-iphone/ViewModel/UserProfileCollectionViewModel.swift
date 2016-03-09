//
//  UserProfileCollectionViewModel.swift
//  shoutit-iphone
//
//  Created by Łukasz Kasperek on 04.03.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import Foundation
import RxSwift

class UserProfileCollectionViewModel: ProfileCollectionViewModelInterface {
    
    let disposeBag = DisposeBag()
    let reloadSubject: PublishSubject<Void> = PublishSubject()
    
    private let profile: Profile
    private var detailedUser: DetailedProfile?
    
    private(set) var pagesSection: ProfileCollectionSectionViewModel<ProfileCollectionPageCellViewModel>!
    private(set) var shoutsSection: ProfileCollectionSectionViewModel<ProfileCollectionShoutCellViewModel>!
    
    init(profile: Profile) {
        self.profile = profile
        shoutsSection = shoutsSectionWithModels([], isLoading: true)
        pagesSection = pagesSectionWithModels([], isLoading: true)
    }
    
    func reloadContent() {
        
        reloadPages(currentlyLoading: true)
        
        // reload user
        fetchProfile()?
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
    
    private func reloadPages(currentlyLoading loading: Bool = false) {
        let pages = detailedUser?.pages ?? []
        pagesSection = pagesSectionWithModels(pages, isLoading: loading)
    }
    
    // MARK: - ProfileCollectionViewModelInterface
    
    // user data
    var name: String? {
        return profile.name
    }
    
    var username: String? {
        return profile.username
    }
    
    var isListeningToYou: Bool? {
        return detailedUser?.isListener
    }
    
    var avatarURL: NSURL? {
        return (profile.imagePath != nil) ? NSURL(string: profile.imagePath!) : nil
    }
    
    var coverURL: NSURL? {
        return (profile.coverPath != nil) ? NSURL(string: profile.coverPath!) : nil
    }
    
    var infoButtons: [ProfileCollectionInfoButton] {
        let listenersCountString = NumberFormatters.sharedInstance.numberToShortString(profile.listenersCount)
        return [.Listeners(countString: listenersCountString),
                .Chat,
                .Listen(isListening: detailedUser?.isListening ?? profile.listening ?? false),
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
    
    func hidesSupplementeryView(view: ProfileCollectionViewSupplementaryView) -> Bool {
        if case .CreatePageButtonFooter = view {
            return true
        }
        return false
    }
    
    // MARK: - Fetch
    
    func fetchShouts() -> Observable<[Shout]>? {
        let params = UserShoutsParams(username: profile.username, pageSize: 4, shoutType: nil)
        return APIShoutsService.shoutsForUserWithParams(params)
    }
    
    func fetchProfile() -> Observable<DetailedProfile>? {
        return APIProfileService.retrieveProfileWithUsername(profile.username)
    }
    
    func listenToUser() -> Observable<Void>? {
        guard let listening = profile.listening else {return nil}
        let listen = !(detailedUser?.isListening ?? listening)
        let retrieveUser = fetchProfile()!.map {[weak self] (profile) -> Void in
            self?.detailedUser = profile
            self?.reloadSubject.onNext()
        }
        return APIProfileService.listen(listen, toProfileWithUsername: profile.username).flatMap{() -> Observable<Void> in
            return retrieveUser
        }
    }
    
    // MARK: - Helpers
    
    private func pagesSectionWithModels(pages: [Profile], isLoading loading: Bool, errorMessage: String? = nil) -> ProfileCollectionSectionViewModel<ProfileCollectionPageCellViewModel> {
        let cells = pages.map{ProfileCollectionPageCellViewModel(profile: $0)}
        let title = NSLocalizedString("\(profile.firstName) Pages", comment: "")
        let noContentMessage = NSLocalizedString("No pages available yet", comment: "")
        return ProfileCollectionSectionViewModel(title: title,
                                                 cells: cells,
                                                 isLoading: loading,
                                                 noContentMessage: noContentMessage,
                                                 errorMessage: errorMessage)
    }
    
    private func shoutsSectionWithModels(shouts: [Shout], isLoading loading: Bool, errorMessage: String? = nil) -> ProfileCollectionSectionViewModel<ProfileCollectionShoutCellViewModel> {
        let cells = shouts.map{ProfileCollectionShoutCellViewModel(shout: $0)}
        let title = NSLocalizedString("\(profile.firstName) Shouts", comment: "")
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