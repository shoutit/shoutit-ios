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
    let reloadSubject: PublishSubject<Void> = PublishSubject()
    
    private(set) var shout: Shout {
        didSet {
            cellModels = ShoutDetailViewModel.cellViewModelsWithShout(shout)
        }
    }
    
    // messages
    private let noImagesMessage = NSLocalizedString("No images are avialable", comment: "Message for shout with no images")
    private let noShoutsMessage = NSLocalizedString("No shouts are available", comment: "")
    
    private(set) var cellModels: [ShoutDetailTableViewCellViewModel]
    private(set) var otherShoutsCellModels: [ShoutDetailShoutCellViewModel] = [ShoutDetailShoutCellViewModel.Loading]
    private(set) var relatedShoutsCellModels: [ShoutDetailShoutCellViewModel] = [ShoutDetailShoutCellViewModel.Loading]
    private(set) var imagesViewModels: [ShoutDetailShoutImageViewModel] = [ShoutDetailShoutImageViewModel.Loading]
    
    init(shout: Shout) {
        self.shout = shout
        self.cellModels = ShoutDetailViewModel.cellViewModelsWithShout(shout)
    }
    
    func reloadShoutDetails() {
        
        prepareCellViewModelsForLoading()
        fetchShoutDetails()
            .subscribe {[weak self] (event) in
                defer { self?.reloadSubject.onNext() }
                switch event {
                case .Next(let shout):
                    self?.shout = shout
                    guard let strongSelf = self, let imagePaths = shout.imagePaths else { return }
                    if imagePaths.count == 0 {
                        strongSelf.imagesViewModels = [ShoutDetailShoutImageViewModel.NoContent(message: strongSelf.noImagesMessage)]
                    } else {
                        strongSelf.imagesViewModels = imagePaths.flatMap{path in
                            if let url = path.toURL() {
                                return ShoutDetailShoutImageViewModel.Image(url: url)
                            } else {
                                return nil
                            }
                        }
                    }
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
                defer { self?.reloadSubject.onNext() }
                switch event {
                case .Next(let otherShouts):
                    if let strongSelf = self {
                        strongSelf.otherShoutsCellModels = strongSelf.cellViewModelsWithModels(otherShouts, withSeeAllCell: false)
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
                defer { self?.reloadSubject.onNext() }
                switch event {
                case .Next(let relatedShouts):
                    if let strongSelf = self {
                        strongSelf.relatedShoutsCellModels = strongSelf.cellViewModelsWithModels(relatedShouts, withSeeAllCell: false)
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
    
    private func fetchShoutDetails() -> Observable<Shout> {
        return APIShoutsService.retrieveShoutWithId(self.shout.id)
    }
    
    private func fetchOtherShouts() -> Observable<[Shout]> {
        let params = UserShoutsParams(username: shout.user.username, pageSize: 4, shoutType: nil)
        return APIShoutsService.shoutsForUserWithParams(params)
    }
    
    private func fetchRelatedShouts() -> Observable<[Shout]> {
        let params = RelatedShoutsParams(shout: shout, page: 0, pageSize: 6, type: nil)
        return APIShoutsService.relatedShoutsWithParams(params)
    }
    
    // MARK: - To display
    
    func locationString() -> String? {
        if let location = shout.location {
            return NSLocalizedString("\(location.city), \(location.country)", comment: "Shout detail location string")
        }
        return nil
    }
    
    func priceString() -> String? {
        return NumberFormatters.priceStringWithPrice(shout.price, currency: shout.currency)
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
            
            assert(false)
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
}

// MARK: - Setup

extension ShoutDetailViewModel {
    
    static func cellViewModelsWithShout(shout: Shout) -> [ShoutDetailTableViewCellViewModel] {
        
        var models: [ShoutDetailTableViewCellViewModel] = []
        
        // description
        models.append(.SectionHeader(title: NSLocalizedString("Description", comment: "Shout details")))
        models.append(.Description(description: shout.text))
        
        // details
        models.append(.SectionHeader(title: NSLocalizedString("Details", comment: "Shout details")))
        var index = 0
        models += detailsWithShout(shout).reduce([ShoutDetailTableViewCellViewModel]()) { (array, tuple) -> [ShoutDetailTableViewCellViewModel] in
            defer { index += 1 }
            return array + [ShoutDetailTableViewCellViewModel.KeyValue(rowInSection: index, key: tuple.0, value: tuple.1)]
        }
        
        // other
        models.append(.Button(title: NSLocalizedString("Policies", comment: "Shout Detail"), type: .Policies))
        models.append(.SectionHeader(title: NSLocalizedString("More shouts from \(shout.user.firstName)", comment: "Shout detail")))
        models.append(.OtherShouts)
        models.append(.Button(title: NSLocalizedString("Visit \(shout.user.firstName)'s profile", comment: "Shout Detail"), type: .Policies))
        models.append(.SectionHeader(title: NSLocalizedString("Related shouts", comment: "Shout detail")))
        models.append(.RelatedShouts)
        
        return models
    }
    
    static func detailsWithShout(shout: Shout) -> [(String, String)] {
        
        var details: [(String, String)] = []
        
        // date
        if let epoch = shout.publishedAtEpoch {
            let key = NSLocalizedString("Date", comment: "Shout details")
            let value = DateFormatters.sharedInstance.stringFromDateEpoch(epoch)
            details.append((key, value))
        }
        
        // category
        details.append((NSLocalizedString("Categorie", comment: "Shout details"), shout.category.name))
        
        // location
        if let city = shout.location?.city {
            let key = NSLocalizedString("Location", comment: "Shout detail")
            details.append((key, city))
        }
        
        return details
    }
}
