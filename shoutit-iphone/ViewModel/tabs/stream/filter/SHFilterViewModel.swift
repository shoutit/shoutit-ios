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
    
    required init(viewController: SHFilterViewController) {
        self.viewController = viewController
        super.init()
        self.configureFilter()
    }
    
    func viewDidLoad() {
        
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
        return self.viewController.filters.count + (self.viewController.fetchedResultsController.count > 0 ? 1: 0)
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if(section < 4) {
            return self.viewController.filters[section].count
        } else {
            return self.viewController.fetchedResultsController.count
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
        if(indexPath.section < 4)
        {
            let dict = self.viewController.filters[indexPath.section][indexPath.row]
            if(String(dict["kCellType"]) == Constants.Filter.kTagsCellId) {
                let cell = tableView.dequeueReusableCellWithIdentifier(String(dict["kCellType"]), forIndexPath: indexPath) as? SHFilterTagsTableViewCell
                cell?.tagList.setTags(dict["KTagsArray"] as! [AnyObject])
                cell?.tagList.automaticResize = true
                cell?.tagList.horizontalPadding = 0
                cell?.tagList.userInteractionEnabled = true
                if let cellFrameHeight = cell?.frame.size.height, cellTaglistContHeight = cell?.tagList.contentSize.height, cellTaglistFrameHeight = cell?.tagList.frame.size.height {
                    return fmax(40, cellFrameHeight + cellTaglistContHeight - cellTaglistFrameHeight)
                } else {
                    return 40
                }
                
            } else {
                return 40
            }
        } else {
            return 40
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if (indexPath.row >= self.viewController.fetchedResultsController.count - Constants.Common.SH_PAGE_SIZE / 3) {
           // self.triggerLoadMore()
        }
        
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
        if let dict = self.viewController.filters[indexPath.section][indexPath.row] {
            if let cellId = dict[Constants.Filter.kCellType] as? String where cellId == Constants.Filter.kStandardCellId {
                if let cell = tableView.dequeueReusableCellWithIdentifier(cellId) as? SHFilterStandardTableViewCell {
                    cell.leftLabel.text = dict[Constants.Filter.kLeftLable] as? String
                    cell.rightLabel.text = dict[Constants.Filter.kRightLable] as? String
                    if let kIsApply = (dict[Constants.Filter.kIsApply]) as? Bool {
                        if(kIsApply) {
                            cell.rightLabel.textColor = UIColor(hexString: Constants.Style.COLOR_SHOUT_DARK_GREEN)
                        } else {
                            cell.rightLabel.textColor = UIColor.lightGrayColor()
                        }
                    }
                    return cell
                }
            } else if let cellId = dict[Constants.Filter.kCellType] as? String where cellId == Constants.Filter.kTagsCellId {
                if let cell = tableView.dequeueReusableCellWithIdentifier(cellId) as? SHFilterTagsTableViewCell {
                    cell.leftLabel.text = String(dict[Constants.Filter.kLeftLable])
                    cell.tagList.setTags(dict[Constants.Filter.KTagsArray] as? [AnyObject])
                    cell.tagList.setTagBackgroundColor(UIColor(hexString: Constants.Style.COLOR_SHOUT_GREEN))
                    cell.tagList.setTagHighlightColor(UIColor(hexString: Constants.Style.COLOR_SHOUT_DARK_GREEN))
                    cell.tagList.tagDelegate = self
                    cell.tagList.textShadowColor = UIColor.clearColor()
                    cell.tagList.automaticResize = true
                    cell.tagList.horizontalPadding = 0
                    cell.tagList.userInteractionEnabled = true
                    if let tapTagsSelect = self.viewController.tapTagsSelect {
                        cell.tagList.addGestureRecognizer(tapTagsSelect)
                    }
                    cell.tagList.scrollEnabled = false
                    return cell
                }
            } else {
                if let cell = tableView.dequeueReusableCellWithIdentifier(Constants.Filter.kCenterCellId) as? SHFilterCenterTableViewCell {
                    if let leftLabel = dict[Constants.Filter.kLeftLable] {
                        cell.centerLabel.text = leftLabel as? String
                    }
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
            if var tags = self.viewController.filters[0][2][Constants.Filter.KTagsArray] as? [AnyObject], let filter = self.viewController.filter {
                if(tags.count > tagIndex && filter.tags.count > tagIndex) {
                    tags.removeAtIndex(tagIndex)
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        self.viewController.tableView.reloadData()
                    })
                    
                }
            }
        }))
        self.viewController.presentViewController(ac, animated: true, completion: nil)
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.viewController.tableView.deselectRowAtIndexPath(indexPath, animated: true)
        if (indexPath.section == 4) {
            if let tagViewController = UIStoryboard.getTag().instantiateViewControllerWithIdentifier(Constants.ViewControllers.SHTAGPROFILE) as? SHTagProfileTableViewController {
                //[tagViewController requestTag:self.fetchedResultsController[indexPath.row]];
                self.viewController.navigationController?.pushViewController(tagViewController, animated: true)
            }
        } else {
            if let dict = self.viewController.filters[indexPath.section][indexPath.row] {
                if let selector = dict[Constants.Filter.kSelectorName] as? String {
                    if(self.respondsToSelector(NSSelectorFromString(selector))) {
                    self.performSelector(NSSelectorFromString(selector), withObject: self, afterDelay: 0)
                    }
                }
            }
        }
    }
    
    // Selectors
    func selectCategory(sender: AnyObject) {
        let vc = UIStoryboard.getFilter().instantiateViewControllerWithIdentifier(Constants.ViewControllers.SHFILTERCHECKMARK) as? SHFilterCheckmarkTableViewController
        if let filter = self.viewController.filter {
            if let selectedTypeIndex = self.viewController.filter?.selectedTypeIndex, let selectedCategoryIndex = self.viewController.filter?.selectedCategoryIndex {
                vc?.setData([(selectedTypeIndex)], index: selectedCategoryIndex)
            }
            vc!.selectedBlock = {(text: String, index: Int) in
                if(filter.category != text) {
                    filter.tags = []
                    (self.viewController.filters[0][2] as? NSDictionary)!.setValue([], forKey: Constants.Filter.KTagsArray)
                }
                filter.category = text
                filter.selectedCategoryIndex = index
                (self.viewController.filters[0][0] as? NSDictionary)?.setValue(text, forKey: Constants.Filter.kRightLable)
                filter.isApplied = true
                (self.viewController.filters[0][0] as? NSDictionary)?.setValue(index == 0 ? false : true, forKey: Constants.Filter.kIsApply)
                self.viewController.tableView.reloadData()
            }
            
        }
        
        vc?.title = NSLocalizedString("Category", comment: "Category")
        self.viewController.navigationController?.pushViewController(vc!, animated: true)
        
    }
    
    func selectType(sender: AnyObject) {
        let vc = UIStoryboard.getFilter().instantiateViewControllerWithIdentifier(Constants.ViewControllers.SHFILTERCHECKMARK) as? SHFilterCheckmarkTableViewController
        if let typeList = self.viewController.filter?.typeList(), let selectedTypeIndex = self.viewController.filter?.selectedTypeIndex {
            vc?.setData(typeList, index: selectedTypeIndex)
        }
        vc?.title = NSLocalizedString("Type", comment: "Type")
        vc?.selectedBlock = {(text: String, index: Int) in
            self.viewController.filter?.type = text
            self.viewController.filter?.selectedTypeIndex = index
            (self.viewController.filters[0][1] as? NSDictionary)?.setValue(text, forKey: Constants.Filter.kRightLable)
            (self.viewController.filters[0][1] as? NSDictionary)?.setValue(1, forKey: Constants.Filter.kIsApply)
            self.viewController.tableView.reloadData()
        }
        self.viewController.navigationController?.pushViewController(vc!, animated: true)
        
    }
    
    func selectTagst(sender: AnyObject) {
        let vc = UIStoryboard.getFilter().instantiateViewControllerWithIdentifier(Constants.ViewControllers.SHCATEGORYTAGS) as? SHCategoryTagsViewController
        if let category = self.viewController.filter?.category {
            vc?.refreshTags(category)
        }
        if let tags = self.viewController.filter?.tags {
            vc?.oldTags = tags
        }
        vc?.selectedBlock = {(tagArray: [SHTag]) in
            if(tagArray.count > 0) {
                if(self.tagExist(tagArray[0])) {
                    return
                }
                if(self.viewController.filter?.tags.count == 0) {
                    self.viewController.filter?.tags = tagArray
                } else {
                    self.viewController.filter?.tags = tagArray
                }
                var strArray = [String]()
                if let tags = self.viewController.filter?.tags {
                    for tag in tags {
                        strArray.append(tag.name)
                    }
                }
                (self.viewController.filters[0][2] as? NSDictionary)?.setValue(1, forKey: Constants.Filter.kIsApply)
                (self.viewController.filters[0][2] as? NSDictionary)?.setValue(strArray, forKey: Constants.Filter.KTagsArray)
                self.viewController.filter?.isApplied = true
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
            var i = true
            if(min == "" && max == "") {
                string = NSLocalizedString("Any", comment: "Any")
                i = false
            }
            (self.viewController.filters[1][0] as? NSDictionary)?.setValue(string, forKey: Constants.Filter.kRightLable)
            (self.viewController.filters[1][0] as? NSDictionary)?.setValue(i, forKey: Constants.Filter.kIsApply)
            self.viewController.tableView.reloadData()
        }
        vc?.title = NSLocalizedString("Select Price", comment: "Select Price")
        self.viewController.navigationController?.pushViewController(vc!, animated: true)
    }
    
//    func selectDates(sender: AnyObject) {
//        
//    }
    
    func selectLocation(sender: AnyObject) {
        let vc = UIStoryboard.getStream().instantiateViewControllerWithIdentifier(Constants.ViewControllers.LOCATION_GETTER)
        vc.title = NSLocalizedString("Select Place", comment: "Select Place")
        self.viewController.navigationController?.pushViewController(vc, animated: true)
    }
    
    func resetFilter () {
        
    }
    
    
    // MARK Private
    private func configureFilter () {
        var firstSection = [[String: AnyObject]]()
        var secondSection = [[String: AnyObject]]()
        var thirdSection = [[String: AnyObject]]()
        var fourthSection = [[String: AnyObject]]()
        
        let category = [Constants.Filter.kLeftLable: NSLocalizedString("Category", comment: "Category"), Constants.Filter.kRightLable: NSLocalizedString("All", comment: "All"),
            Constants.Filter.kCellType: Constants.Filter.kStandardCellId,
            Constants.Filter.kSelectorName: "selectCategory:"]
        
        let type = [Constants.Filter.kLeftLable: NSLocalizedString("Type", comment: "Type"),
            Constants.Filter.kRightLable: NSLocalizedString("Offer", comment: "Offer"),
            Constants.Filter.kCellType: Constants.Filter.kStandardCellId,
            Constants.Filter.kSelectorName: "selectType:"]
        
        let tags: [String: AnyObject] = [Constants.Filter.kLeftLable: NSLocalizedString("Tags", comment: "Tags"),
            Constants.Filter.kRightLable: "",
            Constants.Filter.KTagsArray: [],
            Constants.Filter.kCellType: Constants.Filter.kStandardCellId,
            Constants.Filter.kSelectorName: "selectTags:"]
        
        firstSection = [category, type, tags]
        
        let price = [Constants.Filter.kLeftLable: NSLocalizedString("Price", comment: "Price"),
            Constants.Filter.kRightLable: NSLocalizedString("Any", comment: "Any"),
            Constants.Filter.kCellType: Constants.Filter.kStandardCellId,
            Constants.Filter.kSelectorName: "selectPrice:"]
        
        secondSection = [price]
        
        var location = [Constants.Filter.kLeftLable: NSLocalizedString("Location", comment: "Location"), Constants.Filter.kRightLable: NSLocalizedString("Current Location", comment: "Current Location"),
            Constants.Filter.kCellType: Constants.Filter.kStandardCellId,
            Constants.Filter.kSelectorName: "selectLocation:"]
        if let loc = SHAddress.getUserOrDeviceLocation(), let filter = self.viewController.filter{
            self.viewController.filter?.location = loc
            let string = String(format: "%@, %@, %@", arguments: [loc.city, loc.state, loc.country])
            location[Constants.Filter.kRightLable] = string
            location[Constants.Filter.kIsApply] = "1"
            filter.isApplied = true
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                self.viewController.tableView.reloadData()
            })
        }
        
        thirdSection = [location]
        
        let reset = [Constants.Filter.kLeftLable: NSLocalizedString("Reset", comment: "Reset"),
            Constants.Filter.kCellType: Constants.Filter.kCenterCellId,
            Constants.Filter.kSelectorName: "resetFilter"]
        
        fourthSection = [reset]
        
        self.viewController.filters = [firstSection, secondSection, thirdSection, fourthSection]
        
    }
}
