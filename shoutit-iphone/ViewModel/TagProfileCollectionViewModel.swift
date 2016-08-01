//
//  TagProfileCollectionViewModel.swift
//  shoutit-iphone
//
//  Created by Łukasz Kasperek on 14.03.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import UIKit
import RxSwift
import ShoutitKit

final class TagProfileCollectionViewModel: ProfileCollectionViewModelInterface {
    
    private let disposeBag = DisposeBag()
    let reloadSubject: PublishSubject<Void> = PublishSubject()
    let successMessageSubject: PublishSubject<String> = PublishSubject()
    
    let filter: Filter?
    let category: ShoutitKit.Category?
    private(set) var tag: Tag?
    
    var placeholderImage: UIImage {
        return UIImage.squareAvatarTagPlaceholder()
    }

    var model: ProfileCollectionViewModelMainModel? {
        guard let tag = tag else { return nil }
        return .TagModel(tag: tag)
    }
    
    var reportable: Reportable? {
        return nil
    }
    
    init(filter: Filter) {
        self.filter = filter
        self.category = nil
        gridSection = gridSectionWithModels([], isLoading: true)
        listSection = listSectionWithModels([], isLoading: true)
    }
    
    init(tag: Tag) {
        self.filter = nil
        self.category = nil
        self.tag = tag
        gridSection = gridSectionWithModels([], isLoading: true)
        listSection = listSectionWithModels([], isLoading: true)
    }
    
    init(category: ShoutitKit.Category) {
        self.filter = nil
        self.tag = nil
        self.category = category
        gridSection = gridSectionWithModels([], isLoading: true)
        listSection = listSectionWithModels([], isLoading: true)
    }
    
    private(set) var listSection: ProfileCollectionSectionViewModel<ProfileCollectionListenableCellViewModel>!
    private(set) var gridSection: ProfileCollectionSectionViewModel<ProfileCollectionShoutCellViewModel>!
    
    var slugParameter: String? {
        return tag?.slug ?? filter?.value?.slug ?? category?.slug
    }
    
    // user data
    var name: String? {
        let val =  tag?.name ?? filter?.value?.name ?? category?.name
        
        return val
    }
    
    var verified: Bool {
        return false
    }
    
    var username: String? { return nil }
    var isListeningToYou: Bool? { return nil }
    var coverURL: NSURL? {return nil}
    
    func reloadContent() {
        
        // reload user
        fetchTag()?
            .subscribe({[weak self] (event) in
                switch event {
                case .Next(let tag):
                    self?.tag = tag
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
                case .Error(let error):
                    self?.gridSection = self?.gridSectionWithModels([], isLoading: false, errorMessage: error.sh_message)
                default:
                    break
                }
                self?.reloadSubject.onNext(())
            }
            .addDisposableTo(disposeBag)
        
        fetchRelatedTags()?.subscribe{[weak self] (event) in
            switch event {
            case .Next(let tags):
                self?.listSection = self?.listSectionWithModels(tags, isLoading: false)
                self?.reloadSubject.onNext(())
            case .Error(let error):
                self?.listSection = self?.listSectionWithModels([], isLoading: false, errorMessage: error.sh_message)
                self?.reloadSubject.onNext(())
            default:
                break
            }
        }.addDisposableTo(disposeBag)
    }
    
    func listen() -> Observable<Void>? {
        guard let listening = tag?.isListening, slug = slugParameter else {return nil}
        let listen = !listening
        
        return APITagsService.listen(listen, toTagWithSlug: slug).flatMap{ (success) -> Observable<Void> in
            self.successMessageSubject.onNext(success.message)
        
            self.reloadWithNewListnersCount(success.newListnersCount, isListening: listen)
            return Observable.just(Void())
        }
    }
    
    // MARK: - ProfileCollectionInfoSupplementaryViewDataSource
    
    var avatar: ProfileCollectionInfoSupplementeryViewAvatar {
        return .Local(image: UIImage.profileTagAvatar())
    }
    var infoButtons: [ProfileCollectionInfoButton] {
        let listenersCountString = NumberFormatters.numberToShortString(tag?.listenersCount ?? 0)
        return [.Listeners(countString: listenersCountString),
                .HiddenButton(position: .BigCenter),
                .Listen(isListening: tag?.isListening ?? false),
                .HiddenButton(position: .SmallLeft),
                .HiddenButton(position: .SmallRight)]
    }
    
    var descriptionText: String? {return nil}
    var descriptionIcon: UIImage? {return nil}
    var websiteString: String? {return nil}
    var dateJoinedString: String? {return nil}
    var locationString: String? {return nil}
    var locationFlag: UIImage? {return nil}
    var conversation: MiniConversation? {return nil}
    var verifyButtonTitle: String {
        return NSLocalizedString("Verify your account!", comment: "")
    }
    // MARK: - Helpers
    
    private func fetchTag() -> Observable<Tag>? {
        guard let slug = slugParameter else { return nil }
        return APITagsService.retrieveTagWithSlug(slug)
    }
    
    private func fetchRelatedTags() -> Observable<[Tag]>? {
        guard let slug = slugParameter else { return nil }
        let params = RelatedTagsParams(tagSlug: slug, pageSize: 3, page: 1, category: nil, country: nil)
        return APITagsService.retrieveRelatedTagsForTagWithSlug(slug, params: params)
    }
    
    private func fetchShouts() -> Observable<[Shout]>? {
        guard let slug = slugParameter else { return nil }
        let params = FilteredShoutsParams(tag: slug, page: 1, pageSize: 4, currentUserLocation: Account.sharedInstance.user?.location, skipLocation: false, passCountryOnly: true)
        return APIShoutsService.listShoutsWithParams(params)
    }
    
    private func listSectionWithModels(tags: [Tag], isLoading loading: Bool, errorMessage: String? = nil) -> ProfileCollectionSectionViewModel<ProfileCollectionListenableCellViewModel> {
        let cells = tags.map{ProfileCollectionListenableCellViewModel(tag: $0)}
        let title = NSLocalizedString("Related Interests", comment: "")
        let noContentMessage = NSLocalizedString("No pages available yet", comment: "")
        return ProfileCollectionSectionViewModel(title: title,
                                                 cells: cells,
                                                 isLoading: loading,
                                                 noContentMessage: noContentMessage,
                                                 errorMessage: errorMessage)
    }
    
    private func gridSectionWithModels(shouts: [Shout], isLoading loading: Bool, errorMessage: String? = nil) -> ProfileCollectionSectionViewModel<ProfileCollectionShoutCellViewModel> {
        let cells = shouts.map{ProfileCollectionShoutCellViewModel(shout: $0)}
        let title: String
        if let name = tag?.name {
            title = String.localizedStringWithFormat(NSLocalizedString("%@ Shouts", comment: ""), name)
        } else {
            title = NSLocalizedString("Shouts", comment: "")
        }
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
    
    func reloadWithNewListnersCount(newListnersCount: Int?, isListening: Bool) {
        guard let newListnersCount = newListnersCount else {
            return
        }
        
        if let newTag = self.tag?.copyWithListnersCount(newListnersCount, isListening: isListening) {
            self.tag = newTag
            self.reloadSubject.onNext()
        }
    }
}
