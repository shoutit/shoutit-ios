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

class CreateShoutViewModel: NSObject {
    
    var currentType = Variable(ShoutType.Request)
    
    var currencies : Variable<[Currency]> = Variable([])
    var selectedCurrency : Variable<Currency?> = Variable(nil)
    
    var selectedLocation : FTGooglePlacesAPISearchResultItem?
    
    var filters : Variable<[Filter]?> = Variable([])
    var selectedFilters : [Filter: FilterValue] = [:]
    
    var categories : Variable<[Category]> = Variable([])
    var selectedCategory : Variable<Category?> = Variable(nil)
    
    let createShoutCellCategory = "CreateShoutCellCategory"
    let createShoutCellDescription = "CreateShoutCellDescription"
    let createShoutCellOption = "CreateShoutCellOption"
    let createShoutCellLocation = "CreateShoutCellLocation"
    
    func changeToRequest() {
        self.currentType.value = .Request
    }
    
    func changeToShout() {
        self.currentType.value = .Offer
    }
    
    // MARK: TableView Data Source
    
    func numberOfSections() -> Int {
        return 2
    }
    
    func numberOfRowsInSection(section: Int) -> Int {
        if section == 1 {
            return 1
        }
        
        return (self.filters.value?.count ?? 0) + 2
    }
    
    func sectionTitle(section: Int) -> String {
        if section == 0 {
            return NSLocalizedString("Details", comment: "")
        }
        
        return NSLocalizedString("Location", comment: "")
    }
    
    func heightForRowAt(indexPath: NSIndexPath) -> CGFloat {
        if indexPath.section == 0 && indexPath.row == 1 {
            return 80.0
        }
        
        return 70.0
    }
    
    func cellIdentifierAt(indexPath: NSIndexPath) -> String {
        if indexPath.section == 0 && indexPath.row == 0 {
            return createShoutCellCategory
        }
        
        if indexPath.section == 0 && indexPath.row == 1 {
            return createShoutCellDescription
        }
        
        if indexPath.section == 1 {
            return createShoutCellLocation
        }
        
        return createShoutCellOption
    }
    
}

// Fetch Data
extension CreateShoutViewModel {
    func fetchCurrencies() {
        APIMiscService.requestCurrenciesWithCompletionHandler { (result) -> Void in
            switch result {
            case .Success(let currencies):
                self.currencies.value = currencies
            case .Failure(let error):
                print(error)
            }
        }
    }
    
    func fetchCategories() {
        APIMiscService.requestCategoriesWithCompletionHandler { (result) -> Void in
            switch result {
            case .Success(let categories):
                self.categories.value = categories
            case .Failure(let error):
                print(error)
            }
        }
    }
}

// Fill Views
extension CreateShoutViewModel {
    func fillCell(cell: UITableViewCell, forIndexPath indexPath:NSIndexPath) {
        if indexPath.section == 0 && indexPath.row == 0 {
            fillCategoryCell(cell as? CreateShoutSelectCell)
        } else if indexPath.section == 0 {
            if let filters = self.filters.value {
                if (indexPath.row - 2) >= 0 && (indexPath.row - 2 <= filters.count) {
                    let filter = filters[indexPath.row - 2]
                    fillFilterCell(cell as? CreateShoutSelectCell, withFilter: filter)
                }
            }
        } else if indexPath.section == 1 {
            fillLocationCell(cell as? CreateShoutSelectCell)
        }
    }
    
    func fillCategoryCell(cell: CreateShoutSelectCell?) {
        cell?.selectButton.optionsLoaded = self.categories.value.count > 0
        
        if let category = self.selectedCategory.value {
            cell?.selectButton.setTitle(category.name, forState: .Normal)
        } else {
            cell?.selectButton.setTitle(NSLocalizedString("Category", comment: ""), forState: .Normal)
        }
    }
    
    func fillFilterCell(cell: CreateShoutSelectCell?, withFilter: Filter?) {
        if let filter = withFilter {
            cell?.fillWithFilter(filter, currentValue: self.selectedFilters[filter])
        }
    }
    
    func fillLocationCell(cell: CreateShoutSelectCell?) {
        if self.selectedLocation != nil {
            cell?.selectButton.setTitle(self.selectedLocation?.addressString, forState: .Normal)
        } else {
            cell?.selectButton.setTitle(Account.sharedInstance.locationString(), forState: .Normal)
        }
    }
}

// Present Action Sheets
extension CreateShoutViewModel {
    func changeTypeActionSheet(handler: ((UIAlertAction) -> Void)?) -> UIAlertController {
        let actionSheetController = UIAlertController(title: NSLocalizedString("Please select Type", comment: ""), message: "", preferredStyle: .ActionSheet)
        
        actionSheetController.addAction(UIAlertAction(title: NSLocalizedString("Request", comment: ""), style: .Default, handler: handler))
        actionSheetController.addAction(UIAlertAction(title: NSLocalizedString("Shout", comment: ""), style: .Default, handler: handler))
        actionSheetController.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .Cancel, handler: handler))
        
        return actionSheetController
    }
    
    func currenciesActionSheet(handler: ((UIAlertAction) -> Void)?) -> UIAlertController {
        let actionSheetController = UIAlertController(title: NSLocalizedString("Please select Currency", comment: ""), message: "", preferredStyle: .ActionSheet)
        
        self.currencies.value.each { (currency) -> () in
            actionSheetController.addAction(UIAlertAction(title: "\(currency.name) (\(currency.code))", style: .Default, handler: { [weak self] (alertAction) in
                
                self?.selectedCurrency.value = currency
                
                if let completion = handler {
                    completion(alertAction)
                }
                
                }))
        }
        
        actionSheetController.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .Cancel, handler: handler))
        return actionSheetController
    }
    
    func categoriesActionSheet(handler: ((UIAlertAction) -> Void)?) -> UIAlertController {
        let actionSheetController = UIAlertController(title: NSLocalizedString("Please select Category", comment: ""), message: "", preferredStyle: .ActionSheet)
        
        self.categories.value.each { (category) -> () in
            actionSheetController.addAction(UIAlertAction(title: "\(category.name)", style: .Default, handler: { [weak self] (alertAction) in
                
                self?.selectedCategory.value = category
                
                if let filters = category.filters {
                    self?.filters.value = filters
                }
                
                if let completion = handler {
                    completion(alertAction)
                }
                
                }))
        }
        
        actionSheetController.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .Cancel, handler: handler))
        return actionSheetController
    }
    
    func filterActionSheet(forIndexPath indexPath: NSIndexPath, handler: ((UIAlertAction) -> Void)?) -> UIAlertController? {
        
        guard let filters = self.filters.value else {
            return nil
        }
        
        if (indexPath.row - 2) < 0 || (indexPath.row - 2 >= filters.count) {
            return nil
        }
        
        let filter = filters[indexPath.row - 2]
        
        let actionSheetController = UIAlertController(title: NSLocalizedString("Please select \(filter.name)", comment: ""), message: "", preferredStyle: .ActionSheet)
        
        filter.values?.each { (value) -> () in
            actionSheetController.addAction(UIAlertAction(title: "\(value.name)", style: .Default, handler: { (alertAction) in
                
                self.selectedFilters[filter] = value
                
                if let completion = handler {
                    completion(alertAction)
                }
                
            }))
        }
        
        actionSheetController.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .Cancel, handler: handler))
        
        return actionSheetController
    }
}
