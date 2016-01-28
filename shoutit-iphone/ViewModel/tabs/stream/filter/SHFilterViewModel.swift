//
//  SHFilterViewModel.swift
//  shoutit-iphone
//
//  Created by Vishal Thakur on 16/11/15.
//  Copyright © 2015 Shoutit. All rights reserved.
//

import UIKit
import DWTagList

class SHFilterViewModel: NSObject, ViewControllerModelProtocol, UITableViewDataSource, UITableViewDelegate, DWTagListDelegate {

    private let viewController: SHFilterViewController
    private var tapTagsSelect: UITapGestureRecognizer?
    
    let filters = SHFilterMeta()
    
    required init(viewController: SHFilterViewController) {
        self.viewController = viewController
        super.init()
    }
    
    func viewDidLoad() {
        self.configureFilter()
        
        self.tapTagsSelect = UITapGestureRecognizer(target: self, action: "selectTags:")
    }
    
    func viewWillAppear() {
        
    }
    
    func viewDidAppear() {
        
    }
    
    func viewWillDisappear() {
        
    }
    
    func viewDidDisappear() {
        
    }
    
    func destroy() {
        
    }
    
    // tabelView
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
//        return self.viewController.filters.count + (self.viewController.fetchedResultsController.count > 0 ? 1: 0)
        return 4
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        if(section < 4) {
//            return self.viewController.filters[section].count
//        } else {
//            return self.viewController.fetchedResultsController.count
//        }
        if(section == 0) {
            return 3
        } else {
            return 1
        }
    }
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if(section == 4) {
            return NSLocalizedString("Featured Tags", comment: "Featured Tags")
        } else {
            return ""
        }
        
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if let tags = filters.tags where !tags.kCellType.isEmpty && indexPath.section == 0 && indexPath.row == 2 {
            if let cell = self.viewController.tableView.dequeueReusableCellWithIdentifier(tags.kCellType) as? SHFilterTagsTableViewCell {
                cell.tagList.setTags(tags.KTagsArray)
                cell.tagList.automaticResize = true
                cell.tagList.horizontalPadding = 0
                cell.tagList.userInteractionEnabled = true
                let cellFrameHeight = cell.frame.size.height, cellTaglistContHeight = cell.tagList.contentSize.height, cellTaglistFrameHeight = cell.tagList.frame.size.height
                return fmax(40, cellFrameHeight + cellTaglistContHeight - cellTaglistFrameHeight)
            }
        }
        return 40
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if(indexPath.section == 4) {
            if let cell = tableView.dequeueReusableCellWithIdentifier(Constants.TableViewCell.SHTopTagTableViewCell, forIndexPath: indexPath) as? SHTopTagTableViewCell {
                cell.listenButton.hidden = true
                var frame = cell.frame
                frame.size.height = 40
                cell.frame = frame
                cell.layoutIfNeeded()
                cell.setTagCell(self.viewController.fetchedResultsController[indexPath.row] as! SHTag)
                return cell
            }
        }
        if (indexPath.section == 0 && indexPath.row == 0) {
            if let category = filters.category {
                let cellId = category.kCellType
                if let cell = tableView.dequeueReusableCellWithIdentifier(cellId) as? SHFilterStandardTableViewCell {
                    cell.leftLabel.text = category.kLeftLabel
                    cell.rightLabel.text = category.kRightLabel
                    if(category.kRightLabel != "All") {
                        cell.rightLabel.textColor = UIColor(shoutitColor: .ShoutDarkGreen)
                    } else {
                        cell.rightLabel.textColor = UIColor.lightGrayColor()
                    }
                    return cell
                }
            }
        } else if(indexPath.section == 0 && indexPath.row == 1) {
            if let type = filters.type {
                let cellId = type.kCellType
                if let cell = tableView.dequeueReusableCellWithIdentifier(cellId) as? SHFilterStandardTableViewCell {
                    cell.leftLabel.text = type.kLeftLabel
                    cell.rightLabel.text = type.kRightLabel
                    if(type.kRightLabel != "Offer") {
                        cell.rightLabel.textColor = UIColor(shoutitColor: .ShoutDarkGreen)
                    } else {
                        cell.rightLabel.textColor = UIColor.lightGrayColor()
                    }
                    return cell
                }
            }
        } else if(indexPath.section == 0 && indexPath.row == 2) {
            if let tags = filters.tags {
                let cellId = tags.kCellType
                if let cell = tableView.dequeueReusableCellWithIdentifier(cellId) as? SHFilterTagsTableViewCell {
                    cell.leftLabel.text = self.filters.tags?.kLeftLabel
                    cell.tagList.setTags(self.filters.tags?.KTagsArray)
                    cell.tagList.setTagBackgroundColor(UIColor(shoutitColor: .ShoutDarkGreen))
                    cell.tagList.setTagHighlightColor(UIColor(shoutitColor: .ShoutDarkGreen))
                    cell.tagList.tagDelegate = self
                    cell.tagList.textShadowColor = UIColor.clearColor()
                    cell.tagList.automaticResize = true
                    cell.tagList.horizontalPadding = 0
                    cell.tagList.userInteractionEnabled = true
                    if let tapGesture = self.tapTagsSelect {
                        cell.tagList.addGestureRecognizer(tapGesture)
                    }
                    cell.tagList.scrollEnabled = false
                    return cell
                }
            }
            
        } else if(indexPath.section == 1 && indexPath.row == 0) {
            if let price = filters.price {
                let cellId = price.kCellType
                if let cell = tableView.dequeueReusableCellWithIdentifier(cellId) as? SHFilterStandardTableViewCell {
                    cell.leftLabel.text = price.kLeftLabel
                    cell.rightLabel.text = price.kRightLabel
                    if(price.kRightLabel != "Any") {
                        cell.rightLabel.textColor = UIColor(shoutitColor: .ShoutDarkGreen)
                    } else {
                        cell.rightLabel.textColor = UIColor.lightGrayColor()
                    }
                    return cell
                }
                
            }
        } else if(indexPath.section == 2 && indexPath.row == 0) {
            if let location = filters.location {
                let cellId = location.kCellType
                if let cell = tableView.dequeueReusableCellWithIdentifier(cellId) as? SHFilterStandardTableViewCell {
                    cell.leftLabel.text = location.kLeftLabel
                    if let location = SHAddress.getUserOrDeviceLocation() {
                        cell.rightLabel.text = String(format: "%@, %@, %@", arguments: [location.city, location.state, location.country])
                    }
                    if cell.rightLabel.text! != NSLocalizedString("Current Location", comment: "Current Location") {
                        cell.rightLabel.textColor = UIColor(shoutitColor: .ShoutDarkGreen)
                    } else {
                        cell.rightLabel.textColor = UIColor.lightGrayColor()
                    }
                    return cell
                }
            }
        } else if(indexPath.section == 3 && indexPath.row == 0) {
            if let reset = filters.reset {
                let cellId = reset.kCellType
                if let cell = tableView.dequeueReusableCellWithIdentifier(cellId) as? SHFilterCenterTableViewCell {
                    cell.centerLabel.text = reset.kLeftLabel
                    return cell
                }
            }
        }
        return UITableViewCell()
    }
    
    
    func selectedTag(tagName: String!, tagIndex: Int) {
        let ac = UIAlertController(title: NSLocalizedString("Delete tag?", comment: "Delete tag?"), message: "", preferredStyle: UIAlertControllerStyle.Alert)
        ac.addAction(UIAlertAction(title: "No", style: UIAlertActionStyle.Cancel, handler: nil))
        ac.addAction(UIAlertAction(title: "Yes", style: UIAlertActionStyle.Default, handler: { (alert) -> Void in
            self.filters.tags?.KTagsArray.removeAtIndex(tagIndex)
            self.viewController.tableView.reloadData()
        }))
        self.viewController.presentViewController(ac, animated: true, completion: nil)
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.viewController.tableView.deselectRowAtIndexPath(indexPath, animated: true)
        if (indexPath.section == 4) {
//            if let tagViewController = UIStoryboard.getTag().instantiateViewControllerWithIdentifier(Constants.ViewControllers.SHTAGPROFILE) as? SHTagProfileTableViewController {
//                //[tagViewController requestTag:self.fetchedResultsController[indexPath.row]];
//                self.viewController.navigationController?.pushViewController(tagViewController, animated: true)
//            }
        }
        if (indexPath.section == 0 && indexPath.row == 0) {
            if let category = filters.category?.kSelectorName where self.respondsToSelector(NSSelectorFromString(category)) {
                self.performSelector(NSSelectorFromString(category), withObject: self, afterDelay: 0)
            }
        } else if (indexPath.section == 0 && indexPath.row == 1) {
            if let type = filters.type?.kSelectorName where self.respondsToSelector(NSSelectorFromString(type)){
                self.performSelector(NSSelectorFromString(type), withObject: self, afterDelay: 0)
            }
        } else if (indexPath.section == 0 && indexPath.row == 2) {
            if let tags = filters.tags?.kSelectorName where self.respondsToSelector(NSSelectorFromString(tags)){
                self.performSelector(NSSelectorFromString(tags), withObject: self, afterDelay: 0)
            }
        } else if (indexPath.section == 1 && indexPath.row == 0) {
            if let price = filters.price?.kSelectorName where self.respondsToSelector(NSSelectorFromString(price)){
                self.performSelector(NSSelectorFromString(price), withObject: self, afterDelay: 0)
            }
        } else if (indexPath.section == 2 && indexPath.row == 0) {
            if let location = filters.location?.kSelectorName where self.respondsToSelector(NSSelectorFromString(location)) {
                self.performSelector(NSSelectorFromString(location), withObject: self, afterDelay: 0)
            }
        } else if (indexPath.section == 3 && indexPath.row == 0) {
            if let reset = filters.reset?.kSelectorName where self.respondsToSelector(NSSelectorFromString(reset)) {
                self.performSelector(NSSelectorFromString(reset), withObject: self, afterDelay: 0)
            }
        }
    }
    
    // Selectors
    func selectCategory(sender: AnyObject) {
        let vc = UIStoryboard.getFilter().instantiateViewControllerWithIdentifier(Constants.ViewControllers.SHFILTERCHECKMARK) as! SHFilterCheckmarkTableViewController
        vc.isCategories = true
        if let filter = self.viewController.filter {
            vc.selectedItem = filter.category
            vc.selectedBlock = {(text: String, index: Int) in
                if(filter.category != text) {
                    filter.tags = []
                    if let tags = self.filters.tags {
                        tags.KTagsArray = []
                    }
                }
                filter.category = text
                filter.selectedCategoryIndex = index
                if let category = self.filters.category {
                    category.kRightLabel = text
                    filter.isApplied = true
                }
                self.viewController.tableView.reloadData()
            }
            
        }
        
        vc.title = NSLocalizedString("Category", comment: "Category")
        self.viewController.navigationController?.pushViewController(vc, animated: true)
    }
    
    func selectType(sender: AnyObject) {
        let vc = UIStoryboard.getFilter().instantiateViewControllerWithIdentifier(Constants.ViewControllers.SHFILTERCHECKMARK) as? SHFilterCheckmarkTableViewController
        vc!.isCategories = false
        if let typeList = self.viewController.filter?.typeList(), let selectedTypeIndex = self.viewController.filter?.selectedTypeIndex {
            vc?.setData(typeList, index: selectedTypeIndex)
        }
        vc?.title = NSLocalizedString("Type", comment: "Type")
        vc?.selectedBlock = {(text: String, index: Int) in
            self.viewController.filter?.type = text
            self.viewController.filter?.selectedTypeIndex = index
            if let type = self.filters.type {
                type.kRightLabel = text
            }
            self.viewController.filter?.isApplied = true
            self.viewController.tableView.reloadData()
        }
        self.viewController.navigationController?.pushViewController(vc!, animated: true)
        
    }
    
    func selectTags(sender: AnyObject) {
        let vc = UIStoryboard.getFilter().instantiateViewControllerWithIdentifier(Constants.ViewControllers.SHCATEGORYTAGS) as? SHCategoryTagsViewController
        if let category = self.viewController.filter?.category {
            //vc?.refreshTags(category)
            vc?.category = category
        }
        if let tags = self.viewController.filter?.tags {
            vc?.oldTags = tags
        }
        vc?.selectedBlock = {(tagArray: [SHTag]) in
            if(tagArray.count > 0) {
                self.viewController.filter?.tags = tagArray
                var strArray: [String] = []
                for tag in tagArray {
                    strArray.append(tag.name)
                }
                if let tagsMeta = self.filters.tags {
                    tagsMeta.KTagsArray += strArray
                }
                self.viewController.filter?.isApplied = true
                self.viewController.tableView.reloadData()
            }
        }
        self.viewController.navigationController?.pushViewController(vc!, animated: true)
    }
    
    func tagExist (tag: SHTag) -> Bool {
        if let tags = self.viewController.filter?.tags {
            for shTag in tags {
                if(shTag.name == tag.name) {
                    return true
                }
            }
        }
        return false
    }
    
    func selectPrice(sender: AnyObject) {
        let vc = UIStoryboard.getFilter().instantiateViewControllerWithIdentifier(Constants.ViewControllers.SHFILTERPRICE) as? SHFilterPriceTableViewController
        vc?.min = self.viewController.filter?.minPrice
        vc?.max = self.viewController.filter?.maxPrice
        vc?.selectedBlock = {(min: String, max: String) in
            self.viewController.filter?.minPrice = min
            self.viewController.filter?.maxPrice = max
            var string = String(format: "%@ - %@", arguments: [(min != "" ? min : NSLocalizedString("Any", comment: "Any")), (max != "" ? max : NSLocalizedString("Any", comment: "Any"))])
            self.viewController.filter?.isApplied = true
            //var i = true
            if(min == "" && max == "") {
                string = NSLocalizedString("Any", comment: "Any")
               // i = false
            }
            if let price = self.filters.price {
                price.kRightLabel = string
            }
            self.viewController.tableView.reloadData()
        }
        vc?.title = NSLocalizedString("Select Price", comment: "Select Price")
        self.viewController.navigationController?.pushViewController(vc!, animated: true)
    }
    
    func selectLocation(sender: AnyObject) {
        if let vc = UIStoryboard.getStream().instantiateViewControllerWithIdentifier(Constants.ViewControllers.LOCATION_GETTER) as? SHLocationGetterViewController {
            vc.isUpdateUserLocation = false
            vc.setLocationSelected({ (address) -> () in
                self.viewController.filter?.location = address
                self.viewController.filter?.isApplied = true
                if let location = self.filters.location {
                    location.kLeftLabel = NSLocalizedString("Location", comment: "Location")
                    location.kRightLabel = String(format: "%@, %@, %@", address.city, address.state, address.country)
                }
                self.viewController.tableView.reloadData()
            })
            vc.title = NSLocalizedString("Select Place", comment: "Select Place")
            self.viewController.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    func resetFilter (sender: AnyObject) {
        self.configureFilter()
        self.viewController.filter?.reset()
        self.viewController.tableView.reloadData()
    }
    
    // MARK Private
    private func configureFilter () {
    
        filters.category = SHFilterCategory(kLeftLabel: NSLocalizedString("Category", comment: "Category"), kRightLabel: NSLocalizedString("All", comment: "All"),
            kCellType: Constants.Filter.kStandardCellId,
            kSelectorName: "selectCategory:")
        
        filters.type = SHFilterType(kLeftLabel: NSLocalizedString("Type", comment: "Type"),
            kRightLabel: NSLocalizedString("Offer", comment: "Offer"),
            kCellType: Constants.Filter.kStandardCellId,
            kSelectorName: "selectType:")
        
        filters.tags = SHFilterTags(kLeftLabel: NSLocalizedString("Tags", comment: "Tags"),
            kRightLabel: "",
            KTagsArray: [],
            kCellType: Constants.Filter.kTagsCellId,
            kSelectorName: "selectTags:")
        
        filters.price = SHFilterPrice(kLeftLabel: NSLocalizedString("Price", comment: "Price"),
            kRightLabel: NSLocalizedString("Any", comment: "Any"),
            kCellType: Constants.Filter.kStandardCellId,
            kSelectorName: "selectPrice:")
        
        filters.location = SHFilterLocation(kLeftLabel: NSLocalizedString("Location", comment: "Location"), kRightLabel: NSLocalizedString("Current Location", comment: "Current Location"),
            kCellType: Constants.Filter.kStandardCellId,
            kSelectorName: "selectLocation:")
        
        filters.reset = SHFilterReset(kLeftLabel: NSLocalizedString("Reset", comment: "Reset"),
            kCellType: Constants.Filter.kCenterCellId,
            kSelectorName: "resetFilter:")
    }
    
}

