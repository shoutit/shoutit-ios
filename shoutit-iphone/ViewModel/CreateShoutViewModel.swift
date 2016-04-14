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
    
    private let disposeBag = DisposeBag()
    
    var shoutParams : ShoutParams!
    
    var filters : Variable<[Filter]?> = Variable([])
    var categories : Variable<[Category]> = Variable([])
    var currencies : Variable<[Currency]> = Variable([])
    
    let createShoutCellCategory = "CreateShoutCellCategory"
    let createShoutCellDescription = "CreateShoutCellDescription"
    let createShoutCellOption = "CreateShoutCellOption"
    let createShoutCellLocation = "CreateShoutCellLocation"
    let createShoutCellMobile = "createShoutCellMobile"
    
    var showFilters = false
    var showType = true
    var showMobile = false
    
    init(type: ShoutType = ShoutType.Request) {
        shoutParams = ShoutParams(type: Variable(type), title: Variable(""),
                                text: Variable(nil), price: Variable(nil), currency: Variable(nil),
                                images: Variable([]), videos:  Variable([]), category: Variable(nil),
                                location:  Variable(Account.sharedInstance.loggedUser?.location),
                                publishToFacebook: Variable(false), filters: Variable([:]), shout: nil, mobile: Variable(nil))
    }
    
    init(shout: Shout) {
        
        shoutParams = ShoutParams(type: Variable(shout.type()!), title: Variable(shout.title),
                                  text: Variable(shout.text), price: Variable(shout.price != nil ? Double(shout.price!/100) : 0.0),
            currency: Variable(nil), images: Variable(shout.imagePaths),
                                videos:  Variable([]), category: Variable(shout.category),
                                location:  Variable(Account.sharedInstance.loggedUser?.location),
                                publishToFacebook: Variable(false), filters: Variable([:]), shout: shout, mobile: Variable(shout.mobile))
    }
    
    func changeToRequest() {
        if let _ = self.shoutParams.shout {
            return
        }
        
        self.shoutParams.type.value = .Request
    }
    
    func changeToShout() {
        if let _ = self.shoutParams.shout {
            return
        }
        
        self.shoutParams.type.value = .Offer
    }
    
    // MARK: TableView Data Source
    
    func numberOfSections() -> Int {
        return 2
    }
    
    func numberOfRowsInSection(section: Int) -> Int {
        if section == 1 {
            return 1 + Int(self.showMobile)
        }
        
        if self.showFilters == false {
            return 1
        }
        
        return (self.filters.value?.count ?? 0) + 2
    }
    
    func sectionTitle(section: Int) -> String {
        if section == 0 {
            return NSLocalizedString(" Details", comment: "")
        }
        
        return NSLocalizedString(" Location", comment: "")
    }
    
    func heightForRowAt(indexPath: NSIndexPath) -> CGFloat {
        
        if indexPath.section == 0 && indexPath.row == 1 {
            return 160.0 // description
        }
        
        if indexPath.section == 1 && indexPath.row == 1 {
            return 80.0
        }
        
        return 70.0
    }
    
    func heightForHeaderAt(section: Int) -> CGFloat {
        if section == 0 && self.showFilters == false {
            return 0.0
        }
        
        return 40.0
    }
    
    func cellIdentifierAt(indexPath: NSIndexPath) -> String {
        if indexPath.section == 0 && indexPath.row == 0 {
            return createShoutCellCategory
        }
        
        if indexPath.section == 0 && indexPath.row == 1 {
            return createShoutCellDescription
        }
        
        if indexPath.section == 1 {
            return indexPath.row == 0 ? createShoutCellLocation : createShoutCellMobile
        }
        
        return createShoutCellOption
    }
    
}

// Fetch Data
extension CreateShoutViewModel {
    func fetchCurrencies() {
        APIMiscService.requestCurrencies().subscribe {[weak self] (event) in
            switch event {
            case .Next(let currencies):
                self?.currencies.value = currencies
                self?.fillCurrencyFromShout()
            case .Error(let error):
                print(error)
            default:
                break
            }
        }.addDisposableTo(disposeBag)
    }
    
    func fetchCategories() {
        APIMiscService.requestCategories()
            .subscribe {[weak self] (event) in
                switch event {
                case .Next(let categories):
                    self?.categories.value = categories
                    self?.fillCategoryFromShout()
                case .Error(let error):
                    print(error)
                default:
                    break
                }
            }
            .addDisposableTo(disposeBag)
    }
}
// fill with shout data
extension CreateShoutViewModel {
    
    func fillCategoryFromShout() {
        guard let shout = self.shoutParams.shout else {
            return
        }
        
        for cat in self.categories.value {
            if shout.category == cat {
                self.setCategory(cat)
                return
            }
        }
    }
    
    func fillCurrencyFromShout() {
        guard let shout = self.shoutParams.shout else {
            return
        }
        
        for currency in self.currencies.value {
            if currency.code == shout.currency {
                self.shoutParams.currency.value = currency
                return
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
        
        cell?.selectButton.setImage(nil, forState: .Normal)
        
        if let category = shoutParams.category.value {
            
            cell?.selectButton.setTitle(category.name, forState: .Normal)
            if let imagePath = category.icon, imageURL = NSURL(string: imagePath) {
                cell?.selectButton.hideIcon = false
                cell?.selectButton.iconImageView.kf_setImageWithURL(imageURL)
            }
        } else {
            cell?.selectButton.hideIcon = true
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
        
        cell?.selectButton.hideIcon = true
        
        if let location = shoutParams.location.value {
            cell?.selectButton.setTitle(location.address, forState: .Normal)
        } else {
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
        let actionSheetController = UIAlertController(title: NSLocalizedString("Please make sure that all media are uploaded before continuing", comment: ""), message: "", preferredStyle: .ActionSheet)
        
        actionSheetController.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: .Cancel, handler: nil))
        
        return actionSheetController
    }
    
    func currenciesActionSheet(handler: ((UIAlertAction) -> Void)?) -> UIAlertController {
        let actionSheetController = UIAlertController(title: NSLocalizedString("Please select Currency", comment: ""), message: "", preferredStyle: .ActionSheet)
        
        self.currencies.value.each { (currency) -> () in
            actionSheetController.addAction(UIAlertAction(title: "\(currency.name) (\(currency.code))", style: .Default, handler: { [weak self] (alertAction) in
                
                self?.shoutParams.currency.value = currency
                
                if let completion = handler {
                    completion(alertAction)
                }
                
            }))
        }
        
        actionSheetController.addAction(UIAlertAction(title: NSLocalizedString("Remove Currency", comment: ""), style: .Destructive, handler: { [weak self] (alertAction) in
            
            self?.shoutParams.currency.value = nil
            
            if let completion = handler {
                completion(alertAction)
            }
            
            }))
        
        actionSheetController.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .Cancel, handler: handler))
        return actionSheetController
    }
    
    func categoriesActionSheet(handler: ((UIAlertAction) -> Void)?) -> UIAlertController {
        let actionSheetController = UIAlertController(title: NSLocalizedString("Please select Category", comment: ""), message: "", preferredStyle: .ActionSheet)
        
        self.categories.value.each { (category) -> () in
            actionSheetController.addAction(UIAlertAction(title: "\(category.name)", style: .Default, handler: { [weak self] (alertAction) in
                
                self?.setCategory(category)
                
                if let completion = handler {
                    completion(alertAction)
                }
                
                }))
        }
        
        actionSheetController.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .Cancel, handler: handler))
        return actionSheetController
    }
    
    func setCategory(category: Category?) {
        
        self.shoutParams.filters.value = [:]
        self.shoutParams.category.value = category
        
        if let filters = category?.filters {
            if let shout = self.shoutParams.shout, shoutFilters = shout.filters {
                for filter in filters {
                    for fl in shoutFilters {
                        if fl == filter {
                            self.shoutParams.filters.value[fl] = fl.value
                        }
                    }
                }
            }
            
            self.filters.value = filters
        } else {
            self.filters.value = []
        }
    }
    
    func filterActionSheet(forIndexPath indexPath: NSIndexPath, handler: ((UIAlertAction) -> Void)?) -> UIAlertController? {
        
        guard let filters = self.filters.value else {
            return nil
        }
        
        if (indexPath.row - 2) < 0 || (indexPath.row - 2 >= filters.count) {
            return nil
        }
        
        let filter = filters[indexPath.row - 2]
        
        let actionSheetController = UIAlertController(title: NSLocalizedString("Please select \(filter.name ?? "")", comment: ""), message: "", preferredStyle: .ActionSheet)
        
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
