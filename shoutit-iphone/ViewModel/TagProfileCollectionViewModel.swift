//
//  TagProfileCollectionViewModel.swift
//  shoutit-iphone
//
//  Created by Łukasz Kasperek on 14.03.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import UIKit
import RxSwift

class TagProfileCollectionViewModel: ProfileCollectionViewModelInterface {
    
    private let disposeBag = DisposeBag()
    let reloadSubject: PublishSubject<Void> = PublishSubject()
    
    let filter: Filter?
    private(set) var tag: Tag?
    
    init(filter: Filter) {
        self.filter = filter
        gridSection = gridSectionWithModels([], isLoading: true)
        listSection = listSectionWithModels([], isLoading: true)
    }
    
    init(tag: Tag) {
        self.filter = nil
        self.tag = tag
        gridSection = gridSectionWithModels([], isLoading: true)
        listSection = listSectionWithModels([], isLoading: true)
    }
    
    private(set) var listSection: ProfileCollectionSectionViewModel<ProfileCollectionListenableCellViewModel>!
    private(set) var gridSection: ProfileCollectionSectionViewModel<ProfileCollectionShoutCellViewModel>!
    
    var nameParameter: String? {
        return tag?.name ?? filter?.slug
    }
    
    // user data
    var name: String? {
        return tag?.name ?? filter?.name
    }
    
    var username: String? { return nil }
    var isListeningToYou: Bool? { return nil }
    var coverURL: NSURL? {return nil}
    
    func reloadContent() {
        
        fetchTag()?.subscribe({ (event) in
            
        }).addDisposableTo(disposeBag)
        
        
        // reload user
        fetchTag()?
            .subscribe({[weak self] (event) in
                switch event {
                case .Next(let tag):
                    self?.tag = tag
                    self?.reloadSubject.onNext(())
                case .Completed:
                    break
                case .Error(let error):
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
            case .Error(let error):
                self?.listSection = self?.listSectionWithModels([], isLoading: false, errorMessage: error.sh_message)
            default:
                break
            }
            self?.reloadSubject.onNext(())
        }.addDisposableTo(disposeBag)
    }
    
    func listen() -> Observable<Void>? {
        guard let listening = tag?.isListening, name = nameParameter else {return nil}
        let listen = !listening
        let reloadTag = fetchTag()!.map {[weak self] (tag) -> Void in
            self?.tag = tag
            self?.reloadSubject.onNext()
        }
        return APITagsService.listen(listen, toTagWithName: name).flatMap{ () -> Observable<Void> in
            return reloadTag
        }
    }
    
    // MARK: - ProfileCollectionViewLayoutDelegate
    
    func hidesSupplementeryView(view: ProfileCollectionViewSupplementaryView) -> Bool {
        switch view {
        case .CreatePageButtonFooter:
            return true
        default:
            return false
        }
    }
    
    // MARK: - ProfileCollectionInfoSupplementaryViewDataSource
    
    var avatar: ProfileCollectionInfoSupplementeryViewAvatar {
        return .Local(image: UIImage.profileTagAvatar())
    }
    var infoButtons: [ProfileCollectionInfoButton] {
        let listenersCountString = NumberFormatters.sharedInstance.numberToShortString(tag?.listenersCount ?? 0)
        return [.Listeners(countString: listenersCountString),
                .Custom(title: "<not implemented>", icon: nil),
                .Listen(isListening: tag?.isListening ?? false),
                .HiddenButton(position: .SmallLeft),
                .More]
    }
    
    var descriptionText: String? {return nil}
    var descriptionIcon: UIImage? {return nil}
    var websiteString: String? {return nil}
    var dateJoinedString: String? {return nil}
    var locationString: String? {return nil}
    var locationFlag: UIImage? {return nil}
    
    // MARK: - Helpers
    
    private func fetchTag() -> Observable<Tag>? {
        guard let name = nameParameter else { return nil }
        return APITagsService.retrieveTagWithName(name)
    }
    
    private func fetchRelatedTags() -> Observable<[Tag]>? {
        guard let name = nameParameter else { return nil }
        let params = RelatedTagsParams(tagName: name, pageSize: 3, page: 0, category: nil, city: nil, state: nil, country: nil)
        return APITagsService.retrieveRelatedTagsForTagWithName(name, params: params)
    }
    
    private func fetchShouts() -> Observable<[Shout]>? {
        guard let name = nameParameter else { return nil }
        let params = FilteredShoutsParams(tag: name, page: 0, pageSize: 4, country: nil, state: nil, city: nil)
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
            title = NSLocalizedString("\(name) Shouts", comment: "")
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
}
