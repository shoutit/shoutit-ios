//
//  ShoutDetailViewModel.swift
//  shoutit-iphone
//
//  Created by Łukasz Kasperek on 25.02.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import UIKit
import RxSwift

final class ShoutDetailViewModel {
    
    let disposeBag = DisposeBag()
    
    let reloadObservable: Observable<Void>
    private let reloadSubject: PublishSubject<Void>
    let reloadOtherShoutsSubject: PublishSubject<Void> = PublishSubject()
    let reloadRelatedShoutsSubject: PublishSubject<Void> = PublishSubject()
    
    private(set) var shout: Shout {
        didSet {
            cellModels = ShoutDetailViewModel.cellViewModelsWithShout(shout)
        }
    }
    
    // messages
    private let noImagesMessage = NSLocalizedString("No images are available", comment: "Message for shout with no images")
    private let noShoutsMessage = NSLocalizedString("No shouts are available", comment: "")
    
    // child view models
    private(set) var cellModels: [ShoutDetailTableViewCellViewModel]
    private(set) var otherShoutsCellModels: [ShoutDetailShoutCellViewModel] = [ShoutDetailShoutCellViewModel.Loading]
    private(set) var relatedShoutsCellModels: [ShoutDetailShoutCellViewModel] = [ShoutDetailShoutCellViewModel.Loading]
    private(set) var imagesViewModels: [ShoutDetailShoutImageViewModel] = [ShoutDetailShoutImageViewModel.Loading]
    
    init(shout: Shout) {
        self.shout = shout
        self.cellModels = ShoutDetailViewModel.cellViewModelsWithShout(shout)
        self.reloadSubject = PublishSubject()
        self.reloadObservable = reloadSubject.share()
    }
    
    // MARK: - Actions
    
    func reloadShoutDetails() {
        
        prepareCellViewModelsForLoading()
        fetchShoutDetails()
            .subscribe {[weak self] (event) in
                defer { self?.reloadSubject.onNext() }
                switch event {
                case .Next(let shout):
                    guard let strongSelf = self else { return }
                    self?.shout = shout
                    self?.reloadImages()
                case .Error(let error):
                    if let sSelf = self {
                        sSelf.imagesViewModels = [ShoutDetailShoutImageViewModel.Error(error: error)]
                    }
                case .Completed:
                    break
                }
            }
            .addDisposableTo(disposeBag)
        
        fetchOtherShouts()
            .subscribe {[weak self] (event) in
                defer { self?.reloadOtherShoutsSubject.onNext() }
                switch event {
                case .Next(let otherShouts):
                    if let strongSelf = self {
                        print(otherShouts)
                        strongSelf.otherShoutsCellModels = strongSelf.cellViewModelsWithModels(Array(otherShouts.prefix(4)), withSeeAllCell: false)
                    }
                case .Error(let error):
                    if let strongSelf = self {
                        strongSelf.otherShoutsCellModels = [ShoutDetailShoutCellViewModel.Error(error: error)]
                    }
                case .Completed:
                    break
                }
            }
            .addDisposableTo(disposeBag)
        
        fetchRelatedShouts()
            .subscribe {[weak self] (event) in
                defer { self?.reloadRelatedShoutsSubject.onNext() }
                switch event {
                case .Next(let relatedShouts):
                    if let strongSelf = self {
                        strongSelf.relatedShoutsCellModels = strongSelf.cellViewModelsWithModels(Array(relatedShouts.prefix(6)), withSeeAllCell: true)
                    }
                case .Error(let error):
                    if let strongSelf = self {
                        strongSelf.relatedShoutsCellModels = [ShoutDetailShoutCellViewModel.Error(error: error)]
                    }
                case .Completed:
                    break
                }
            }
            .addDisposableTo(disposeBag)
    }
    
    func reloadImages() {
        guard shout.imagePaths?.count > 0 || shout.videos?.count > 0 else {
            self.imagesViewModels = [ShoutDetailShoutImageViewModel.NoContent(message: self.noImagesMessage)]
            return
        }
        
        var models : [ShoutDetailShoutImageViewModel] = []
        
        if let imagePaths = shout.imagePaths {
            for path in imagePaths {
                if let url = NSURL(string: path) {
                    models.append(ShoutDetailShoutImageViewModel.Image(url: url))
                }
            }
        }
        
        if let videos = shout.videos {
            for video in videos {
                models.append(ShoutDetailShoutImageViewModel.Movie(video: video))
            }
        }
        
        self.imagesViewModels = models
    }
    
    func makeCall() -> Observable<Mobile> {
        return APIShoutsService.retrievePhoneNumberForShoutWithId(shout.id)
    }
    
    func moreAlert(completion: (alertController: UIAlertController) -> Void) -> UIAlertController {
        let alertController = UIAlertController(title: NSLocalizedString("More", comment: ""), message: nil, preferredStyle: .ActionSheet)
        
        if self.shout.user.id != Account.sharedInstance.user?.id {
            alertController.addAction(UIAlertAction(title: NSLocalizedString("Report Shout", comment: ""), style: .Default, handler: { (action) in
                completion(alertController: alertController)
            }))
        }
        
        alertController.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .Cancel, handler: { (action) in
            
        }))
        
        return alertController
    }
    
    func deleteAlert(completion: () -> Void) -> UIAlertController {
        let alertController = UIAlertController(title: NSLocalizedString("Are you sure?", comment: ""), message: NSLocalizedString("Do you want to delete this shout?", comment: ""), preferredStyle: .ActionSheet)
        
        alertController.addAction(UIAlertAction(title: NSLocalizedString("Yes, Delete Shout", comment: ""), style: .Destructive, handler: { (action) in
            completion()
        }))
        
        alertController.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .Cancel, handler: { (action) in
            
        }))
        
        return alertController
    }
    
    // MARK: - To display
    
    func locationString() -> String? {
        if let location = shout.location {
            return NSLocalizedString("\(location.city), \(location.country)", comment: "Shout detail location string")
        }
        return nil
    }
    
    func priceString() -> String? {
        if let price = shout.price, currency = shout.currency {
            return NumberFormatters.priceStringWithPrice(price, currency: currency)
        }
        
        return nil
    }
    
    func tabbarButtons() -> [ShoutDetailTabbarButton] {
        if shout.user.id == Account.sharedInstance.user?.id {
            return [.Edit, .Delete, .Chats, .More]
        }
        
        var buttons: [ShoutDetailTabbarButton] = [.VideoCall, .Chat, .More]
        if let isMobileSet = shout.isMobileSet where isMobileSet {
            buttons.insert(.Call, atIndex: 0)
        }
        
        return buttons
    }
    
    // MARK: - Helpers
    
    private func prepareCellViewModelsForLoading() {
        
        let preparationBlock: ([ShoutDetailShoutCellViewModel] -> [ShoutDetailShoutCellViewModel]) = {models in
            
            if models.count > 1 {
                return models
            }
            
            if models.count == 0 {
                return [ShoutDetailShoutCellViewModel.Loading]
            }
            
            if models.count == 1 {
                if case .Content = models[0] {
                    return models
                } else {
                    return [ShoutDetailShoutCellViewModel.Loading]
                }
            }
            
            assertionFailure()
            return []
        }
        
        otherShoutsCellModels = preparationBlock(otherShoutsCellModels)
        relatedShoutsCellModels = preparationBlock(relatedShoutsCellModels)
    }
    
    private func cellViewModelsWithModels(models: [Shout]?, withSeeAllCell seeAll: Bool) -> [ShoutDetailShoutCellViewModel] {
        
        guard let models = models else {
            return []
        }
        
        if models.count == 0 {
            let noContentMessage = noShoutsMessage
            return [ShoutDetailShoutCellViewModel.NoContent(message: noContentMessage)]
        }
        
        var viewModels = models.map{ShoutDetailShoutCellViewModel.Content(shout: $0)}
        
        if seeAll {
            viewModels.append(ShoutDetailShoutCellViewModel.SeeAll)
        }
        
        return viewModels
    }
    
    private func fetchShoutDetails() -> Observable<Shout> {
        return APIShoutsService.retrieveShoutWithId(self.shout.id)
    }
    
    private func fetchOtherShouts() -> Observable<[Shout]> {
        let params = FilteredShoutsParams(username: shout.user.username, page: 1, pageSize: 4)
        return APIShoutsService.listShoutsWithParams(params)
    }
    
    private func fetchRelatedShouts() -> Observable<[Shout]> {
        let params = RelatedShoutsParams(shout: shout, page: 1, pageSize: 6, type: nil)
        return APIShoutsService.relatedShoutsWithParams(params).map{$0.results}
    }
}

// MARK: - Setup

extension ShoutDetailViewModel {
    
    static func cellViewModelsWithShout(shout: Shout) -> [ShoutDetailTableViewCellViewModel] {
        
        var models: [ShoutDetailTableViewCellViewModel] = []
        
        // description
        if let description = shout.text where description.utf16.count > 0 {
            models.append(.SectionHeader(title: NSLocalizedString("Description", comment: "Shout details")))
            models.append(.Description(description: description))
        }
        
        // details
        models.append(.SectionHeader(title: NSLocalizedString("Details", comment: "Shout details")))
        let detailsTuples = detailsWithShout(shout)
        var index = 0
        models += detailsTuples.reduce([ShoutDetailTableViewCellViewModel]()) { (array, tuple) -> [ShoutDetailTableViewCellViewModel] in
            defer { index += 1 }
            return array + [ShoutDetailTableViewCellViewModel.KeyValue(rowInSection: index, sectionRowsCount:detailsTuples.count, key: tuple.0, value: tuple.1, imageName: tuple.2, filter: tuple.3, tag: tuple.4)]
        }
        
        // other
        let firstname = shout.user.firstName ?? NSLocalizedString("shouter", comment: "Displayed on shout detail screen if user's firstname would be null")
        //models.append(.Button(title: NSLocalizedString("Policies", comment: "Shout Detail"), type: .Policies))
        models.append(.SectionHeader(title: NSLocalizedString("More shouts from \(firstname)", comment: "Shout detail")))
        models.append(.OtherShouts)
        models.append(.Button(title: NSLocalizedString("Visit \(firstname)'s profile", comment: "Shout Detail"), type: .VisitProfile))
        models.append(.SectionHeader(title: NSLocalizedString("Related shouts", comment: "Shout detail")))
        models.append(.RelatedShouts)
        
        return models
    }
    
    static func detailsWithShout(shout: Shout) -> [(String, String, String?, Filter?, Category?)] {
        
        var details: [(String, String, String?, Filter?, Category?)] = []
        
        // date
        if let epoch = shout.publishedAtEpoch {
            let key = NSLocalizedString("Date", comment: "Shout details")
            let value = DateFormatters.sharedInstance.stringFromDateEpoch(epoch)
            details.append((key, value, nil, nil, nil))
        }
        
        // category
        details.append((NSLocalizedString("Categorie", comment: "Shout details"), shout.category.name, nil, nil, shout.category))
        
        // add filters
        shout.filters?.forEach{ (filter) in
            if let key = filter.name, value = filter.value?.name {
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
