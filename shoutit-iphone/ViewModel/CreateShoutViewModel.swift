//
//  CreateShoutViewModel.swift
//  shoutit-iphone
//
//  Created by Piotr Bernad on 26.02.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import UIKit
import RxSwift
import FTGooglePlacesAPI

final class CreateShoutViewModel: NSObject {
    
    private let disposeBag = DisposeBag()
    
    var shoutParams : ShoutParams!
    
    // section view models
    private(set) var detailsSectionViewModel: CreateShoutDetailsSectionViewModel!
    private(set) var locationSectionViewModel: CreateShoutLocationSectionViewModel!
    private(set) var sharingSectionViewModel: CreateShoutSocialSharingSectionViewModel!
    var sectionViewModels: [CreateShoutSectionViewModel] { return [detailsSectionViewModel, locationSectionViewModel, sharingSectionViewModel] }
    
    init(type: ShoutType = ShoutType.Request) {
        shoutParams = ShoutParams(type: type, publishToFacebook: Account.sharedInstance.facebookManager.hasPermissions(.PublishActions))
        super.init()
        detailsSectionViewModel = CreateShoutDetailsSectionViewModel(cellViewModels: [.Category], parent: self, hideFilters: true)
        locationSectionViewModel = CreateShoutLocationSectionViewModel(cellViewModels: [.Location], parent: self)
        sharingSectionViewModel = CreateShoutSocialSharingSectionViewModel(cellViewModels: [.Facebook], parent: self)
    }
    
    init(shout: Shout) {
        shoutParams = ShoutParams(type: shout.type()!,
                                  title: shout.title,
                                  text: shout.text,
                                  price: shout.price != nil ? Double(shout.price!/100) : 0.0,
                                  images: shout.imagePaths ?? [],
                                  category: shout.category,
                                  shout: shout,
                                  mobile: shout.mobile)
        super.init()
        detailsSectionViewModel = CreateShoutDetailsSectionViewModel(cellViewModels: [.Category, .Description], parent: self, hideFilters: false)
        locationSectionViewModel = CreateShoutLocationSectionViewModel(cellViewModels: [.Location, .Mobile], parent: self)
        sharingSectionViewModel = CreateShoutSocialSharingSectionViewModel(cellViewModels: [.Facebook], parent: self)
    }
    
    func changeToRequest() {
        if let _ = shoutParams.shout { return }
        shoutParams.type.value = .Request
    }
    
    func changeToShout() {
        if let _ = shoutParams.shout { return }
        shoutParams.type.value = .Offer
    }
}

// Fill Views
extension CreateShoutViewModel {
        
    func fillCategoryCell(cell: CreateShoutSelectCell?) {
        cell?.selectButton.showActivity(detailsSectionViewModel.categories.value.count <= 0)
        
        cell?.selectButton.setImage(nil, forState: .Normal)
        
        if let category = shoutParams.category.value {
            
            cell?.selectButton.setTitle(category.name, forState: .Normal)
            if let imagePath = category.icon, imageURL = NSURL(string: imagePath) {
                cell?.selectButton.showIcon(true)
                cell?.selectButton.iconImageView.kf_setImageWithURL(imageURL, placeholderImage: nil)
            }
        } else {
            cell?.selectButton.showIcon(false)
            cell?.selectButton.iconImageView.image = nil
            cell?.selectButton.setTitle(NSLocalizedString("Category", comment: ""), forState: .Normal)
        }
    }
    
    func fillFilterCell(cell: CreateShoutSelectCell?, withFilter: Filter?) {
        if let filter = withFilter {
            cell?.fillWithFilter(filter, currentValue: shoutParams.filters.value[filter])   
        }
    }
    
    func fillLocationCell(cell: CreateShoutSelectCell?) {
        
        if let location = shoutParams.location.value {
            cell?.selectButton.showIcon(true)
            cell?.selectButton.iconImageView.image = UIImage(named: location.country)
            cell?.selectButton.setTitle(location.address, forState: .Normal)
        } else {
            cell?.selectButton.showIcon(false)
            cell?.selectButton.setTitle(NSLocalizedString("Location", comment: ""), forState: .Normal)
        }
    }
}

// Present Action Sheets
extension CreateShoutViewModel {
    
    func changeTypeActionSheet(handler: ((UIAlertAction) -> Void)?) -> UIAlertController {
        let actionSheetController = UIAlertController(title: NSLocalizedString("Please select Type", comment: ""), message: "", preferredStyle: .ActionSheet)
        actionSheetController.addAction(UIAlertAction(title: NSLocalizedString("Request", comment: ""), style: .Default, handler: handler))
        actionSheetController.addAction(UIAlertAction(title: NSLocalizedString("Offer", comment: ""), style: .Default, handler: handler))
        actionSheetController.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .Cancel, handler: handler))
        return actionSheetController
    }
    
    func mediaNotReadyAlertController() -> UIAlertController {
        let actionSheetController = UIAlertController(title: NSLocalizedString("Please make sure that all media are uploaded before continuing", comment: ""), message: "",preferredStyle: .ActionSheet)
        actionSheetController.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: ""),style: .Cancel, handler: nil))
        
        return actionSheetController
    }
    
    func currenciesActionSheet(handler: ((UIAlertAction) -> Void)?) -> UIAlertController {
        let actionSheetController = UIAlertController(title: NSLocalizedString("Please select Currency", comment: ""), message: "", preferredStyle: .ActionSheet)
        
        detailsSectionViewModel.currencies.value.each { (currency) -> () in
            actionSheetController.addAction(UIAlertAction(title: "\(currency.name) (\(currency.code))", style: .Default, handler: { [weak self] (alertAction) in
                
                self?.shoutParams.currency.value = currency
                
                if let completion = handler {
                    completion(alertAction)
                }
            }))
        }
        
        actionSheetController
            .addAction(UIAlertAction(title: NSLocalizedString("Remove Currency", comment: ""), style: .Destructive) { [weak self] (alertAction) in
                self?.shoutParams.currency.value = nil
                handler?(alertAction)
            })
        
        actionSheetController.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .Cancel, handler: handler))
        return actionSheetController
    }
    
    func categoriesActionSheet(handler: ((UIAlertAction) -> Void)?) -> UIAlertController {
        let actionSheetController = UIAlertController(title: NSLocalizedString("Please select Category", comment: ""), message: "", preferredStyle: .ActionSheet)
        detailsSectionViewModel.categories.value.each { (category) -> () in
            let action = UIAlertAction(title: "\(category.name)", style: .Default) { [weak self] (alertAction) in
                self?.detailsSectionViewModel.setCategory(category)
                handler?(alertAction)
            }
            actionSheetController.addAction(action)
        }
        
        actionSheetController.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .Cancel, handler: handler))
        return actionSheetController
    }
    
    func filterActionSheet(forFilter filter: Filter, handler: ((UIAlertAction) -> Void)?) -> UIAlertController? {
        
        let title = String.localizedStringWithFormat(NSLocalizedString("Please select %@", comment: "Create Shout: choose filter: Action sheet title"), filter.name ?? "")
        let actionSheetController = UIAlertController(title: title, message: "", preferredStyle: .ActionSheet)
        
        filter.values?.each { (value) -> () in
            actionSheetController.addAction(UIAlertAction(title: "\(value.name)", style: .Default, handler: { (alertAction) in
                
                self.shoutParams.filters.value[filter] = value
                
                if let completion = handler {
                    completion(alertAction)
                }
            }))
        }
        
        actionSheetController.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .Cancel, handler: handler))
        actionSheetController.addAction(UIAlertAction(title: NSLocalizedString("Remove", comment: ""), style: .Destructive, handler: { (alertAction) in
            
            self.shoutParams.filters.value[filter] = nil
            
            if let completion = handler {
                completion(alertAction)
            }
        }))
        
        return actionSheetController
    }
}
