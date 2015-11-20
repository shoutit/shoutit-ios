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
            if let tagViewController = Constants.ViewControllers.SHTAGPROFILE as? SHTagProfileTableViewController {
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
        
    }
    
    func selectType(sender: AnyObject) {
//        SHFilterCheckmarkTableViewController * vc = [SHNavigator viewControllerFromStoryboard:@"FilterStoryboard" withViewControllerId:@"SHFilterCheckmarkTableViewController"];
//        [vc setData:[SHFilter typeList] withSelectedItem:self.filter.selectedTypeIndex];
//        
//        vc.title = NSLocalizedString(@"Type", @"Type");
//        [vc setSelectedBlock:^(NSString * text, int index)
//        {
//        
//        self.filter.type = text;
//        self.filter.selectedTypeIndex = index;
//        [self.filters[0][1] setObject:text forKey:kRightLablel];
//        [self.filters[0][1] setObject:@1 forKey:kIsApply];
//        self.filter.isApplyed = YES;
//        [self.filters[0][1] setObject:@(index==0?NO:YES) forKey:kIsApply];
//        [self.tableView reloadData];
//        NSLog(@"Selected Category: %@",text);
//        }];
//        [self.navigationController pushViewController:vc animated:YES];
        
    }
    
    func selectTag(sender: AnyObject) {
        
    }
    
    func tagExist (tag: SHTag) -> Bool {
        return true
    }
    
    func selectPrice(sender: AnyObject) {
//        if let vc = Constants.ViewControllers.SHFILTERPRICE as? SHFilterPriceTableViewController {
//            if let filter = self.viewController.filter {
//                vc.min = filter.minPrice == nil ? "0" : filter.minPrice
//                vc.max = filter.maxPrice == nil ? "0" : filter.maxPrice
//                var string = String(format: "%@ - %@", arguments: [(filter.minPrice != nil && filter.minPrice != "") ? filter.minPrice!: NSLocalizedString("Any", comment: "Any"), (filter.maxPrice != nil && filter.maxPrice != "") ? filter.maxPrice! : NSLocalizedString("Any", comment: "Any")])
//                self.viewController.filter?.isApplied = true
//                var i = true
//                if((filter.minPrice == nil && filter.maxPrice == nil) || (filter.minPrice == "" && filter.maxPrice == "")) {
//                string = NSLocalizedString("Any", comment: "Any")
//                i = false
//                }
////                [self.filters[1][0] setObject:string forKey:kRightLablel];
////                [self.filters[1][0] setObject:@(i) forKey:kIsApply];
////                
////                [self.tableView reloadData];
//            }
//            vc.title = NSLocalizedString("Select Place", comment: "Select Place")
//            self.viewController.navigationController?.pushViewController(vc, animated: true)
//        }
    }
    
    func selectDates(sender: AnyObject) {
        
    }
    
    func selectLocation(sender: AnyObject) {
        let vc = Constants.ViewControllers.LOCATION_GETTER
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
        
        let tags = [Constants.Filter.kLeftLable: NSLocalizedString("Tags", comment: "Tags"),
            Constants.Filter.kRightLable: "",
            Constants.Filter.KTagsArray: [],
            Constants.Filter.kCellType: Constants.Filter.kStandardCellId,
            Constants.Filter.kSelectorName: "selectTags:"]
        
        firstSection = [category, type, tags as! [String: AnyObject]]
        
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
