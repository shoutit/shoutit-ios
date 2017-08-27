//
//  ShoutDetailViewModel.swift
//  shoutit-iphone
//
//  Created by Łukasz Kasperek on 25.02.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import UIKit
import RxSwift
import ShoutitKit
// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}

// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l > r
  default:
    return rhs < lhs
  }
}


final class ShoutDetailViewModel {
    
    let disposeBag = DisposeBag()
    
    let reloadObservable: Observable<Void>
    fileprivate let reloadSubject: PublishSubject<Void>
    let reloadOtherShoutsSubject: PublishSubject<Void> = PublishSubject()
    let reloadRelatedShoutsSubject: PublishSubject<Void> = PublishSubject()
    
    fileprivate(set) var shout: Shout {
        didSet {
            cellModels = cellViewModelsWithShout(shout)
            reloadSubject.onNext()
        }
    }
    
    // messages
    fileprivate let noImagesImage = UIImage.shoutsPlaceholderImage()
    fileprivate let noShoutsMessage = NSLocalizedString("No shouts are available", comment: "")
    
    // child view models
    fileprivate(set) var cellModels: [ShoutDetailTableViewCellViewModel] = []
    fileprivate(set) var otherShoutsCellModels: [ShoutDetailShoutCellViewModel] = [ShoutDetailShoutCellViewModel.loading]
    fileprivate(set) var relatedShoutsCellModels: [ShoutDetailShoutCellViewModel] = [ShoutDetailShoutCellViewModel.loading] {
        didSet {
            cellModels = cellViewModelsWithShout(shout)
            reloadSubject.onNext()
        }
    }
    fileprivate(set) var imagesViewModels: [ShoutDetailShoutImageViewModel] = [ShoutDetailShoutImageViewModel.loading]
    
    init(shout: Shout) {
        self.shout = shout
        self.reloadSubject = PublishSubject()
        self.reloadObservable = reloadSubject.share()
        self.cellModels = cellViewModelsWithShout(shout)
    }
    
    // MARK: - Actions
    
    func reloadShout(_ newShout: Shout) {
        shout = newShout
    }
    
    func reloadShoutDetails() {
        
        prepareCellViewModelsForLoading()
        
        fetchShoutDetails()
            .subscribe {[weak self] (event) in
                defer { self?.reloadSubject.onNext() }
                switch event {
                case .next(let shout):
                    self?.shout = shout
                    self?.reloadImages()
                case .error(let error):
                    self?.imagesViewModels = [ShoutDetailShoutImageViewModel.error(error: error)]
                case .completed:
                    break
                }
            }
            .addDisposableTo(disposeBag)
        
        fetchOtherShouts()
            .subscribe {[weak self] (event) in
                defer { self?.reloadOtherShoutsSubject.onNext() }
                switch event {
                case .next(let otherShouts):
                    if let strongSelf = self {
                        strongSelf.otherShoutsCellModels = strongSelf.cellViewModelsWithModels(Array(otherShouts.prefix(4)), withSeeAllCell: false)
                    }
                case .error(let error):
                    self?.otherShoutsCellModels = [ShoutDetailShoutCellViewModel.error(error: error)]
                case .completed:
                    break
                }
            }
            .addDisposableTo(disposeBag)
        
        fetchRelatedShouts()
            .subscribe {[weak self] (event) in
                defer { self?.reloadRelatedShoutsSubject.onNext() }
                switch event {
                case .next(let relatedShouts):
                    if let strongSelf = self {
                        strongSelf.relatedShoutsCellModels = strongSelf.cellViewModelsWithModels(Array(relatedShouts.prefix(6)), withSeeAllCell: true)
                    }
                case .error(let error):
                    if let strongSelf = self {
                        strongSelf.relatedShoutsCellModels = [ShoutDetailShoutCellViewModel.error(error: error)]
                    }
                case .completed:
                    break
                }
            }
            .addDisposableTo(disposeBag)
    }
    
    func reloadImages() {
        guard shout.imagePaths?.count > 0 || shout.videos?.count > 0 else {
            self.imagesViewModels = [ShoutDetailShoutImageViewModel.noContent(image: self.noImagesImage)]
            return
        }
        
        var models : [ShoutDetailShoutImageViewModel] = []
        
        if let imagePaths = shout.imagePaths {
            for path : String in imagePaths {
                if let url : URL = URL(string: path) {
                    models.append(ShoutDetailShoutImageViewModel.image(url: url))
                }
            }
        }
        
        if let videos = shout.videos {
            for video : Video in videos {
                models.append(ShoutDetailShoutImageViewModel.movie(video: video))
            }
        }
        
        self.imagesViewModels = models
    }
    
    func makeCall() -> Observable<Mobile> {
        return APIShoutsService.retrievePhoneNumberForShoutWithId(shout.id)
    }
    
    // MARK: - To display
    
    func locationString() -> String? {
        if let location = shout.location {
            return "\(location.city), \(location.country)"
        }
        return nil
    }
    
    func priceString() -> String? {
        if let price = shout.price, let currency = shout.currency {
            return NumberFormatters.priceStringWithPrice(price, currency: currency)
        }
        
        return nil
    }
    
    func tabbarButtons() -> [ShoutDetailTabbarButton] {
        if shout.user?.id == Account.sharedInstance.user?.id {
            return [.promote(promoted: shout.isPromoted), .edit, .more]
        }
        
        var buttons: [ShoutDetailTabbarButton] = [.videoCall, .chat, .more]
        if let isMobileSet = shout.isMobileSet, isMobileSet {
            buttons.insert(.call, at: 0)
        }
        
        return buttons
    }
}

// MARK: - Helpers

private extension ShoutDetailViewModel {
    
    func prepareCellViewModelsForLoading() {
        
        let preparationBlock: (([ShoutDetailShoutCellViewModel]) -> [ShoutDetailShoutCellViewModel]) = {models in
            
            if models.count > 1 {
                return models
            }
            
            if models.count == 0 {
                return [ShoutDetailShoutCellViewModel.loading]
            }
            
            if models.count == 1 {
                if case .content = models[0] {
                    return models
                } else {
                    return [ShoutDetailShoutCellViewModel.loading]
                }
            }
            
            assertionFailure()
            return []
        }
        
        otherShoutsCellModels = preparationBlock(otherShoutsCellModels)
        relatedShoutsCellModels = preparationBlock(relatedShoutsCellModels)
    }
    
    func cellViewModelsWithModels(_ models: [Shout]?, withSeeAllCell seeAll: Bool) -> [ShoutDetailShoutCellViewModel] {
        
        guard let models = models else {
            return []
        }
        
        if models.count == 0 {
            let noContentMessage = noShoutsMessage
            return [ShoutDetailShoutCellViewModel.noContent(message: noContentMessage)]
        }
        
        var viewModels = models.map{ShoutDetailShoutCellViewModel.content(shout: $0)}
        
        if seeAll {
            viewModels.append(ShoutDetailShoutCellViewModel.seeAll)
        }
        
        return viewModels
    }
    
    func hasRelatedShouts() -> Bool {
        guard let first = relatedShoutsCellModels.first else { return false }
        guard case .content = first else { return false }
        return true
    }
}

// MARK: - Observables

private extension ShoutDetailViewModel {
    
    func fetchShoutDetails() -> Observable<Shout> {
        return APIShoutsService.retrieveShoutWithId(self.shout.id)
    }
    
    func fetchOtherShouts() -> Observable<[Shout]> {
        let params = FilteredShoutsParams(username: shout.user?.username, page: 1, pageSize: 4, currentUserLocation: nil, skipLocation: true, excludeId: shout.id)
        return APIShoutsService.listShoutsWithParams(params).flatMap({ (result) -> Observable<[Shout]> in
            return Observable.just(result.results)
        })
    }
    
    func fetchRelatedShouts() -> Observable<[Shout]> {
        let params = RelatedShoutsParams(shout: shout, page: 1, pageSize: 6)
        return APIShoutsService.relatedShoutsWithParams(params).map{$0.results}
    }
}

// MARK: - Setup

private extension ShoutDetailViewModel {
    
    func cellViewModelsWithShout(_ shout: Shout) -> [ShoutDetailTableViewCellViewModel] {
        
        var models: [ShoutDetailTableViewCellViewModel] = []
        
        // description
        if let description = shout.text, description.utf16.count > 0 {
            models.append(.sectionHeader(title: NSLocalizedString("Description", comment: "Shout details")))
            models.append(.description(description: description))
        }
        
        // details
        models.append(.sectionHeader(title: NSLocalizedString("Details", comment: "Shout details")))
        let detailsTuples = detailsWithShout(shout)
        var index = 0
        models += detailsTuples.reduce([ShoutDetailTableViewCellViewModel]()) { (array, tuple) -> [ShoutDetailTableViewCellViewModel] in
            defer { index += 1 }
            return array + [ShoutDetailTableViewCellViewModel.keyValue(rowInSection: index, sectionRowsCount:detailsTuples.count, key: tuple.0, value: tuple.1, imageName: tuple.2, filter: tuple.3, tag: tuple.4)]
        }
        
        // other
        let creatorDisplayName: String
        if let firstname = shout.user?.firstName, firstname.utf16.count > 0 {
            creatorDisplayName = firstname
        } else if let name = shout.user?.name, name.utf16.count > 0 {
            creatorDisplayName = name
        } else {
            creatorDisplayName = NSLocalizedString("shouter", comment: "Displayed on shout detail screen if user's firstname would be null")
        }
        models.append(.sectionHeader(title: String.localizedStringWithFormat(NSLocalizedString("More shouts from %@", comment: ""), creatorDisplayName)))
        models.append(.otherShouts)
        models.append(.button(title: String.localizedStringWithFormat(NSLocalizedString("Visit %@'s profile", comment: ""), creatorDisplayName), type: .visitProfile))
        if (hasRelatedShouts()) {
            models.append(.sectionHeader(title: NSLocalizedString("Related shouts", comment: "Shout detail")))
            models.append(.relatedShouts)
        }
        
        return models
    }
    
    func detailsWithShout(_ shout: Shout) -> [(String, String, String?, Filter?, ShoutitKit.Category?)] {
        
        var details: [(String, String, String?, Filter?, ShoutitKit.Category?)] = []
        
        // date
        if let epoch = shout.publishedAtEpoch {
            let key = NSLocalizedString("Date", comment: "Shout details")
            let value = DateFormatters.sharedInstance.stringFromDateEpoch(epoch)
            details.append((key, value, nil, nil, nil))
        }
        
        // category
        details.append((NSLocalizedString("Category", comment: "Shout details"), shout.category.name, nil, nil, shout.category))
        
        // add filters
        shout.filters?.forEach{ (filter) in
            if let key = filter.name, let value = filter.value?.name {
                details.append((key, value, nil, filter, nil))
            }
        }
        
        // location
        if let city = shout.location?.city {
            let key = NSLocalizedString("Location", comment: "Shout detail")
            details.append((key, city, shout.location?.country, nil, nil))
        }
        
        return details
    }
}
