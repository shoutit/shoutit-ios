//
//  CreateShoutViewModel.swift
//  shoutit-iphone
//
//  Created by Piotr Bernad on 26.02.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import UIKit
import RxSwift
import ShoutitKit

final class CreateShoutViewModel: NSObject {
    
    fileprivate let disposeBag = DisposeBag()
    let errorSubject: PublishSubject<Error> = PublishSubject()
    
    var shoutParams : ShoutParams!
    
    // section view models
    fileprivate(set) var detailsSectionViewModel: CreateShoutDetailsSectionViewModel!
    fileprivate(set) var locationSectionViewModel: CreateShoutLocationSectionViewModel!
    fileprivate(set) var sharingSectionViewModel: CreateShoutSocialSharingSectionViewModel!
    var sectionViewModels: [CreateShoutSectionViewModel] { return [detailsSectionViewModel, locationSectionViewModel, sharingSectionViewModel] }
    
    init(type: ShoutType = ShoutType.Request) {
        shoutParams = ShoutParams(type: type, publishToFacebook: Account.sharedInstance.facebookManager.hasPermissions(.PublishActions))
        super.init()
        detailsSectionViewModel = CreateShoutDetailsSectionViewModel(cellViewModels: [.category], parent: self, hideFilters: true)
        locationSectionViewModel = CreateShoutLocationSectionViewModel(cellViewModels: [.location], parent: self)
        sharingSectionViewModel = CreateShoutSocialSharingSectionViewModel(cellViewModels: [.facebook], parent: self)
    }
    
    init(shout: Shout) {
        shoutParams = ShoutParams(type: shout.type()!,
                                  title: shout.title,
                                  text: shout.text,
                                  price: shout.price != nil ? Double(shout.price!/100) : 0.0,
                                  images: shout.imagePaths ?? [],
                                  category: shout.category,
                                  location: shout.location,
                                  shout: shout,
                                  mobile: shout.mobile)
        super.init()
        detailsSectionViewModel = CreateShoutDetailsSectionViewModel(cellViewModels: [.category, .description], parent: self, hideFilters: false)
        locationSectionViewModel = CreateShoutLocationSectionViewModel(cellViewModels: [.location, .mobile], parent: self)
        sharingSectionViewModel = CreateShoutSocialSharingSectionViewModel(cellViewModels: [.facebook], parent: self)
    }
}

// Fill Views
extension CreateShoutViewModel {
        
    func fillCategoryCell(_ cell: CreateShoutSelectCell?) {
        cell?.selectButton.showActivity(detailsSectionViewModel.categories.value.count <= 0)
        
        cell?.selectButton.setImage(nil, for: UIControlState())
        
        if let category = shoutParams.category.value {
            
            cell?.selectButton.setTitle(category.name, for: UIControlState())
            if let imagePath = category.icon, let imageURL = URL(string: imagePath) {
                cell?.selectButton.showIcon(true)
                cell?.selectButton.iconImageView.kf.setImage(with:imageURL, placeholderImage: nil)
            }
        } else {
            cell?.selectButton.showIcon(false)
            cell?.selectButton.iconImageView.image = nil
            cell?.selectButton.setTitle(NSLocalizedString("Category", comment: "Create Shout Button Title"), for: UIControlState())
        }
    }
    
    func fillFilterCell(_ cell: CreateShoutSelectCell?, withFilter: Filter?) {
        if let filter = withFilter {
            cell?.fillWithFilter(filter, currentValue: shoutParams.filters.value[filter])   
        }
    }
    
    func fillLocationCell(_ cell: CreateShoutSelectCell?) {
        
        if let location = shoutParams.location.value {
            cell?.selectButton.showIcon(true)
            cell?.selectButton.iconImageView.image = UIImage(named: location.country)
            cell?.selectButton.setTitle(location.address, for: UIControlState())
        } else {
            cell?.selectButton.showIcon(false)
            cell?.selectButton.setTitle(NSLocalizedString("Location", comment: "Create Shout Button Title"), for: UIControlState())
        }
    }
}

// Present Action Sheets
extension CreateShoutViewModel {
    
    func mediaNotReadyAlertController() -> UIAlertController {
        let actionSheetController = UIAlertController(title: NSLocalizedString("Please make sure that all media are uploaded before continuing", comment: "Create Shout Screen"), message: "",preferredStyle: .actionSheet)
        actionSheetController.addAction(UIAlertAction(title: LocalizedString.ok,style: .cancel, handler: nil))
        
        return actionSheetController
    }
    
    func currenciesActionSheet(_ handler: ((UIAlertAction) -> Void)?) -> UIAlertController {
        let actionSheetController = UIAlertController(title: NSLocalizedString("Please select Currency", comment: "Create Shout Screen"), message: "", preferredStyle: .actionSheet)
        
        detailsSectionViewModel.currencies.value.each { (currency) -> () in
            actionSheetController.addAction(UIAlertAction(title: "\(currency.name) (\(currency.code))", style: .default, handler: { [weak self] (alertAction) in
                
                self?.shoutParams.currency.value = currency
                
                if let completion = handler {
                    completion(alertAction)
                }
            }))
        }
        
        actionSheetController
            .addAction(UIAlertAction(title: NSLocalizedString("Remove Currency", comment: "Create Shout Screen"), style: .destructive) { [weak self] (alertAction) in
                self?.shoutParams.currency.value = nil
                handler?(alertAction)
            })
        
        actionSheetController.addAction(UIAlertAction(title: LocalizedString.cancel, style: .cancel, handler: handler))
        return actionSheetController
    }
    
    func categoriesActionSheet(_ handler: ((UIAlertAction) -> Void)?) -> UIAlertController {
        let actionSheetController = UIAlertController(title: NSLocalizedString("Please select Category", comment: "Create Shout Screen"), message: "", preferredStyle: .actionSheet)
        detailsSectionViewModel.categories.value.each { (category) -> () in
            let action = UIAlertAction(title: "\(category.name)", style: .default) { [weak self] (alertAction) in
                self?.detailsSectionViewModel.setCategory(category)
                handler?(alertAction)
            }
            actionSheetController.addAction(action)
        }
        
        actionSheetController.addAction(UIAlertAction(title: LocalizedString.cancel, style: .cancel, handler: handler))
        return actionSheetController
    }
    
    func filterActionSheet(forFilter filter: Filter, handler: ((UIAlertAction) -> Void)?) -> UIAlertController? {
        
        let title = String.localizedStringWithFormat(NSLocalizedString("Please select %@", comment: "Create Shout: choose filter: Action sheet title"), filter.name ?? "")
        let actionSheetController = UIAlertController(title: title, message: "", preferredStyle: .actionSheet)
        
        filter.values?.each { (value) -> () in
            actionSheetController.addAction(UIAlertAction(title: "\(value.name)", style: .default, handler: { (alertAction) in
                
                self.shoutParams.filters.value[filter] = value
                
                if let completion = handler {
                    completion(alertAction)
                }
            }))
        }
        
        actionSheetController.addAction(UIAlertAction(title: LocalizedString.cancel, style: .cancel, handler: handler))
        actionSheetController.addAction(UIAlertAction(title: NSLocalizedString("Remove", comment: "Create Shout Screen"), style: .destructive, handler: { (alertAction) in
            
            self.shoutParams.filters.value[filter] = nil
            
            if let completion = handler {
                completion(alertAction)
            }
        }))
        
        return actionSheetController
    }
}
