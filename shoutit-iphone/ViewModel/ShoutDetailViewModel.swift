//
//  ShoutDetailViewModel.swift
//  shoutit-iphone
//
//  Created by Łukasz Kasperek on 25.02.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import UIKit
import RxSwift

class ShoutDetailViewModel {
    
    private(set) var shout: Shout {
        didSet {
            cellModels = ShoutDetailViewModel.cellViewModelsWithShout(shout)
        }
    }
    
    private(set) var cellModels: [ShoutDetailTableViewCellViewModel]
    private(set) var otherShoutsCellModels: [ShoutDetailShoutCellViewModel] = []
    private(set) var relatedShoutsCellModels: [ShoutDetailShoutCellViewModel] = []
    
    init(shout: Shout) {
        self.shout = shout
        self.cellModels = ShoutDetailViewModel.cellViewModelsWithShout(shout)
    }
    
    func fetchShoutDetails() -> Observable<Shout> {
        return APIShoutsService.retrieveShoutWithId(self.shout.id)
    }
    
}

// MARK: - Helpers

extension ShoutDetailViewModel {
    
    static func cellViewModelsWithShout(shout: Shout) -> [ShoutDetailTableViewCellViewModel] {
        
        var models: [ShoutDetailTableViewCellViewModel] = []
        
        // description
        models.append(.SectionHeader(title: NSLocalizedString("Description", comment: "Shout details")))
        models.append(.Description(description: shout.text))
        
        // details
        models.append(.SectionHeader(title: NSLocalizedString("Details", comment: "Shout details")))
        models += detailsWithShout(shout).map{ShoutDetailTableViewCellViewModel.KeyValue(key: $0.0, value: $0.1)}
        
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
