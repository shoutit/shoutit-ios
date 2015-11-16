//
//  SHCreateShoutViewModel.swift
//  shoutit-iphone
//
//  Created by Hitesh Sondhi on 14/11/15.
//  Copyright © 2015 Shoutit. All rights reserved.
//

import UIKit
import DWTagList

class SHCreateShoutViewModel: NSObject, TableViewControllerModelProtocol, UICollectionViewDelegateFlowLayout, UICollectionViewDataSource, UITableViewDelegate, UITableViewDataSource, DWTagListDelegate, SHCreateVideoCollectionViewCellDelegate, SHCameraViewControllerDelegate, SHCreateImageCollectionViewCellDelegate {

    private let viewController: SHCreateShoutTableViewController
    
    private var media: [SHMedia] = []
    private var categories: [SHCategory] = []
    private var categoriesString: [String] = []
    
    private var currencies: [SHCurrency] = []
    private var currenciesString: [String] = []
    private var isVideoCV = false
    private var tagsCV: [SHTag] = []
    private var offset: CGFloat = 0
    private var tapTagsSelect: UITapGestureRecognizer?
    
    var shout: SHShout = SHShout()
    var isEditing = false
    
    required init(viewController: SHCreateShoutTableViewController) {
        self.viewController = viewController
    }
    
    func viewDidLoad() {
        // TODO
        if isEditing {
//            [self setupViewForStandard:YES];
//            [self setCurrentLocation];
        }
        
        // get categories from cache or update from web
        SHApiMiscService().getCategories({ (categories) -> Void in
            self.setCategories(categories)
            }, completionHandler: { (response) -> Void in
                switch(response.result) {
                case .Success(let result):
                    self.setCategories(result)
                case .Failure(let error):
                    log.warning("Error getting categories \(error.localizedDescription)")
                }
        })
        
        // get currencies from cache or update from web
        SHApiMiscService().getCurrencies({ (currencies) -> Void in
            self.setCurrencies(currencies)
            }, completionHandler: { (response) -> Void in
                switch(response.result) {
                case .Success(let result):
                    self.setCurrencies(result)
                case .Failure(let error):
                    log.warning("Error getting categories \(error.localizedDescription)")
                }
        })
        
        self.tapTagsSelect = UITapGestureRecognizer(target: self, action: "selectTags")
        self.offset = self.viewController.tableView.contentOffset.y

        // TODO Setup Currency
//        if(!self.isEditingMode)
//        {
//            NSString* localCur = @"";
//            NSMutableArray *currencies = [[NSUserDefaults standardUserDefaults] valueForKey:@"currencies"];
//            for (NSDictionary* dict in currencies)
//            if([[[[[SHLoginModel sharedModel]selfUser] userLocation]countryCode] isEqualToString:dict[@"country"]])
//            localCur = dict[@"code"];
//            self.currencyTextField.text = localCur;
//        }
        
        self.viewController.tagsList.delegate = self
        self.viewController.tableView.estimatedRowHeight = 120
        self.viewController.tableView.rowHeight = UITableViewAutomaticDimension

        // TODO
//        if(self.isEditingMode)
//        {
//            [self.titleTextField setText:self.shout.title];
//            if([self.shout.type isEqualToString:@"offer"])
//            {
//                [self setupViewForStandard:YES];
//                self.segmentControl.selectedSegmentIndex = 0;
//                
//            }else if([self.shout.type isEqualToString:@"request"])
//            {
//                [self setupViewForStandard:YES];
//                self.segmentControl.selectedSegmentIndex = 1;
//                
//            }else if(self.shout.category)
//            {
//                if([self.shout.category.name isEqualToString:@"cv-video"])
//                {
//                    [self setupViewForStandard:NO];
//                    self.segmentControl.selectedSegmentIndex = 2;
//                }
//            }
//            self.categoriesTextField.text = self.shout.category.name;
//            self.descriptionTextView.text = self.shout.text;
//            self.priceTextField.text = self.shout.price;
//            self.currencyTextField.text = self.shout.currency;
//            [self.locationTextView setText:[NSString stringWithFormat:@"%@, %@, %@",self.shout.shoutLocation.city,self.shout.shoutLocation.stateCode,self.shout.shoutLocation.countryCode]];
//            
//        }
        
        setUpTagList()
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
    
    func segmentAction() {
        if viewController.segmentControl.selectedSegmentIndex == 2 {
            self.shout.type = .VideoCV
            self.setupViewForStandard(false)
            if NSUserDefaults.standardUserDefaults().valueForKey("CVVideoAlert") == nil {
                NSUserDefaults.standardUserDefaults().setValue(1, forKey: "CVVideoAlert")
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    let alert = UIAlertController(title: NSLocalizedString("Recommendation", comment: "Recommendation"), message: NSLocalizedString("Give a brief video summary of yourself", comment: "Give a brief video summary of yourself"), preferredStyle: UIAlertControllerStyle.Alert)
                    alert.addAction(UIAlertAction(title: NSLocalizedString("Ok", comment: "Ok"), style: UIAlertActionStyle.Default, handler: nil))
                    self.viewController.presentViewController(alert, animated: true, completion: nil)
                })
            }
        } else {
            if self.viewController.segmentControl.selectedSegmentIndex == 0 {
                self.shout.type = .Offer
            } else {
                self.shout.type = .Request
            }
            self.setupViewForStandard(true)
        }
    }
    
    func selectTags() {
        if self.shout.category == nil {
            SHProgressHUD.showError(NSLocalizedString("Please, select category first.", comment: "Please, select category first."))
            return
        }
        
    }
    
    // MARK - CollectionView Delegate
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.media.count + 1
    }
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        if indexPath.item >= 1 && self.media[indexPath.item - 1].isVideo {
            return CGSizeMake(337, 190)
        }
        return CGSizeMake(190, 190)
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        if indexPath.item < 1 {
            SHCameraViewController.presentFromViewController(self.viewController, onlyPhoto: false, timeToRecord: Constants.Shout.TIME_VIDEO_SHOUT, isVideoCV: self.isVideoCV, firstVideo: true, delegate: self)
        }
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        if indexPath.item < 1 {
            return collectionView.dequeueReusableCellWithReuseIdentifier(Constants.CollectionViewCell.SHCreatePlusCollectionViewCell, forIndexPath: indexPath)
        } else {
            let data = self.media[indexPath.item - 1]
            if data.isVideo {
                let cell = collectionView.dequeueReusableCellWithReuseIdentifier(Constants.CollectionViewCell.SHCreateVideoCollectionViewCell, forIndexPath: indexPath) as! SHCreateVideoCollectionViewCell
                cell.delegate = self
                cell.media = data
                return cell
            } else {
                let cell = collectionView.dequeueReusableCellWithReuseIdentifier(Constants.CollectionViewCell.SHCreateImageCollectionViewCell, forIndexPath: indexPath) as! SHCreateImageCollectionViewCell
                cell.delegate = self
                if let image = data.image {
                    cell.image = image
                } else {
                    // TODO
//                    cell.imageURL = imageURL
                }
                return cell
            }
        }
    }
    
    // MARK - UITableView Delegate
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath.row == 0 && indexPath.section == 0 {
            self.viewController.titleTextField.becomeFirstResponder()
        } else if indexPath.row == 0 && indexPath.section == 2 && !self.isVideoCV {
            if !self.isVideoCV {
                if self.categories.count > 0 {
                    self.addPickerView(self.viewController.categoriesTextField, stringList: self.categoriesString, title: NSLocalizedString("Categories", comment: "Categories"), showClear: true)
                } else {
                    SHApiMiscService().getCategories({ (categories) -> Void in
                        self.categories = categories
                        }, completionHandler: { (response) -> Void in
                            switch(response.result) {
                            case .Success(let result):
                                self.setCategories(result)
                                self.addPickerView(self.viewController.categoriesTextField, stringList: self.categoriesString, title: NSLocalizedString("Categories", comment: "Categories"), showClear: true)
                            case .Failure(let error):
                                log.warning("Error getting categories \(error.localizedDescription)")
                            }
                    })
                }
            }
        } else if indexPath.section == 2 && indexPath.row == 1 {
            self.selectTags()
        } else if indexPath.section == 3 && indexPath.row == 0 {
            // TODO
//            [SHTextInputViewController presentFromViewController:self withText:self.shout.text completionHandler:^(NSString *text) {
//                [self.descriptionTextView setText:text];
//                self.shout.text = text;
//                }];
        } else if (indexPath.section == 4 && indexPath.row == 0) {
            self.viewController.priceTextField.becomeFirstResponder()
        } else if (indexPath.section == 4 && indexPath.row == 1) {
            // TODO
            // get currencies from cache or update from web
            if self.currencies.count == 0 {
                SHApiMiscService().getCurrencies({ (currencies) -> Void in
                    self.setCurrencies(currencies)
                    }, completionHandler: { (response) -> Void in
                        switch(response.result) {
                        case .Success(let result):
                            self.setCurrencies(result)
                            self.showCurrencyPicker()
                        case .Failure(let error):
                            log.warning("Error getting categories \(error.localizedDescription)")
                        }
                })
            } else {
                self.showCurrencyPicker()
            }
//            [SHSinglePickerTableViewController presentPickerFromViewController:self
//                withStringList:cur
//                andTitle:@"Currencies"
//            allowNoneOption:YES
//            andOnSelectionCallback:^(NSString *selectedItem)
//            {
//                self.shout.currency = selectedItem;
//                self.currencyTextField.text = selectedItem;
//            }];
        } else if (indexPath.section == 5 && indexPath.row == 0) {
            // TODO
//            [self selectLocation];
        }
        self.viewController.tableView.deselectRowAtIndexPath(indexPath, animated: false)
        self.viewController.tableView.reloadData()
        self.viewController.tableView.setContentOffset(CGPointMake(0, self.viewController.tableView.contentOffset.y), animated: false)
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.viewController.tableView(tableView, numberOfRowsInSection: section)
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return self.viewController.numberOfSectionsInTableView(tableView)
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        // Title
        if (indexPath.section == 0 && indexPath.row == 0) {
            self.viewController.titleTextField.text = shout.title
        } else if (indexPath.section == 0 && indexPath.row == 1) {
            // TODO
            if shout.type == .Offer {
                self.setupViewForStandard(true)
                self.viewController.segmentControl.selectedSegmentIndex = 0
            } else if shout.type == .Request {
                self.setupViewForStandard(true)
                self.viewController.segmentControl.selectedSegmentIndex = 1
            } else if let category = shout.category where category.name == "cv-video" {
                self.setupViewForStandard(false)
                self.viewController.segmentControl.selectedSegmentIndex = 2
            }
            self.viewController.categoriesTextField.text = shout.category?.name
        } else if (indexPath.section == 2 && indexPath.row == 0) { // categorie
            self.viewController.categoriesTextField.text = self.shout.category?.name;
        } else if (indexPath.section == 3 && indexPath.row == 0) { // description
            self.viewController.descriptionTextView.text = self.shout.text
        } else if (indexPath.section == 4 && indexPath.row == 0) { // Price
            self.viewController.priceTextField.text = "\(self.shout.price)"
        } else if (indexPath.section == 4 && indexPath.row == 1) { // Currency
            self.viewController.currencyTextField.text = "\(self.shout.currency)"
        } else if (indexPath.section == 5 && indexPath.row == 0) { // location
            if let location = shout.location {
                self.viewController.locationTextView.text = String(format: "%@, %@, %@", location.city, location.state, location.country)
            }
        }
        let cell = self.viewController.tableView(tableView, cellForRowAtIndexPath: indexPath)
        // TODO
//        if (indexPath.section == 2 && indexPath.row == 1)
//        {
//            [self.tagList setTags:self.shout.stringTags];
//            
//            [self.tagList.constraints enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
//                NSLayoutConstraint* constraint = obj;
//                if (constraint.firstAttribute == NSLayoutAttributeHeight)
//                {
//                constraint.constant =  fmax(24.0, self.tagList.contentSize.height);
//                *stop = YES;
//                }
//                }];
//            
//            [cell layoutIfNeeded];
//        }
        return cell
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
//        if indexPath.section == 2 && indexPath.row == 1 {
//            // TODO
////            return fmax(24.0, self.tagList.contentSize.height) + 20
//        }
        return self.viewController.tableView(tableView, heightForRowAtIndexPath: indexPath)
    }
    
    // MARK - SHCreateImageCollectionViewCellDelegate
    func removeImage(image: UIImage) {
        if let index = self.media.indexOf({
            if let image1 = $0.image {
                return image.isEqual(image1)
            }
            return false
        }) {
            self.media.removeAtIndex(index)
            self.viewController.collectionView.performBatchUpdates({ () -> Void in
                self.viewController.collectionView.deleteItemsAtIndexPaths([NSIndexPath(forItem: index + 1, inSection: 0)])
                }, completion: nil)
        }
    }
    
    func removeImageURL(imageURL: String) {
        if let index = self.media.indexOf({
            return imageURL == $0.localUrl || $0.url == imageURL
        }) {
            self.media.removeAtIndex(index)
            self.viewController.collectionView.performBatchUpdates({ () -> Void in
                self.viewController.collectionView.deleteItemsAtIndexPaths([NSIndexPath(forItem: index + 1, inSection: 0)])
                }, completion: nil)
        }
    }
    
    // MARK - SHCreateVideoCollectionViewCellDelegate
    func removeVideo(media: SHMedia) {
        if let index = self.media.indexOf({
            if let image1 = $0.image, image2 = media.image {
                return image2.isEqual(image1)
            }
            return $0.localUrl == media.localUrl || ($0.idOnProvider == media.idOnProvider && $0.url == media.url)
        }) {
            self.media.removeAtIndex(index)
            self.viewController.collectionView.performBatchUpdates({ () -> Void in
                self.viewController.collectionView.deleteItemsAtIndexPaths([NSIndexPath(forItem: index + 1, inSection: 0)])
                }, completion: nil)
        }
    }
    
    // MARK - SHCameraViewControllerDelegate
    func didCameraFinish(image: UIImage) {
        let media = SHMedia()
        media.isVideo = false
        media.image = image
        self.media.insert(media, atIndex: 0)
        self.viewController.collectionView.reloadData()
    }
    
    func didCameraFinish(tempVideoFileURL: NSURL, thumbnailImage: UIImage) {
        let media = SHMedia()
        media.isVideo = true
        media.upload = true
        media.localUrl = tempVideoFileURL
        media.localThumbImage = thumbnailImage
        self.media.append(media)
        self.viewController.collectionView.reloadData()
    }
    
    // MARK - Private
    private func showCurrencyPicker() {
        SHSinglePickerTableViewController.presentPickerFromViewController(self.viewController, stringList: self.currenciesString, title: "Currencies", allowNoneOption: true) { (selectedItem) -> () in
            self.shout.currency = selectedItem
            self.viewController.currencyTextField.text = selectedItem
        }
    }
    
    private func addPickerView(textField: UITextField, stringList: [String], title: String, showClear: Bool) {
        SHSinglePickerTableViewController.presentPickerFromViewController(self.viewController, stringList: stringList, title: title, allowNoneOption: showClear) { (selectedItem) -> () in
            textField.text = selectedItem
            if title == NSLocalizedString("Categories", comment: "Categories") {
                self.shout.category = SHCategory.categoryFromName(selectedItem)
                if selectedItem == "Jobs Wanted" {
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        let alert = UIAlertController(title: NSLocalizedString("Recommendation", comment: "Recommendation"), message: NSLocalizedString("CreateCVMessage", comment: "Create a video cv to increase your chances of impressing potential employers!"), preferredStyle: UIAlertControllerStyle.Alert)
                        alert.addAction(UIAlertAction(title: NSLocalizedString("Skip", comment: "Skip"), style: UIAlertActionStyle.Cancel, handler: nil))
                        alert.addAction(UIAlertAction(title: NSLocalizedString("SwitchVideoCV", comment: "Switch to Video CV"), style: .Default, handler: { (action) -> Void in
                            self.viewController.segmentControl.selectedSegmentIndex = 2
                            self.segmentAction()
                        }))
                        self.viewController.presentViewController(alert, animated: true, completion: nil)
                    })
                }
            }
        }
    }
    
    private func setUpTagList() {
        self.viewController.tagsList.setTags(self.shout.getStringTags())
        self.viewController.tagsList.setTagBackgroundColor(UIColor(hexString: Constants.Style.COLOR_SHOUT_GREEN))
        self.viewController.tagsList.setTagHighlightColor(UIColor(hexString: Constants.Style.COLOR_SHOUT_DARK_GREEN))
        self.viewController.tagsList.textShadowColor = UIColor.clearColor()
        self.viewController.tagsList.automaticResize = true
        self.viewController.tagsList.userInteractionEnabled = true
        if let tapGesture = self.tapTagsSelect {
            self.viewController.tagsList.addGestureRecognizer(tapGesture)
        }
        self.viewController.tagsList.scrollEnabled = false
    }
    
    private func setCategories(categories: [SHCategory]) {
        self.categories = categories
        self.categoriesString = categories.map({ (category) -> String in
            category.name
        })
    }
    
    private func setCurrencies(currencies: [SHCurrency]) {
        self.currencies = currencies
        self.currenciesString = self.currencies.map({ (currency) -> String in
            currency.code
        })
    }
    
    private func setupViewForStandard(standard: Bool) {
        if standard {
            // get categories from cache
            if self.categories.count == 0 {
                SHApiMiscService().getCategories({ (categories) -> Void in
                    self.setCategories(categories)
                    }, completionHandler: { (response) -> Void in
                        switch(response.result) {
                        case .Success(let result):
                            self.setCategories(result)
                        case .Failure(let error):
                            log.warning("Error getting categories \(error.localizedDescription)")
                        }
                })
            }
            self.viewController.priceTextField.placeholder = NSLocalizedString("Price", comment: "Price")
            self.viewController.titleTextField.placeholder = NSLocalizedString("Title", comment: "Title")
            if self.isEditing {
                self.viewController.categoriesTextField.text = ""
            }
            self.viewController.tagsLabel.text = NSLocalizedString("Price", comment: "Price")
            self.isVideoCV = false
        } else {
            // TODO
            self.viewController.priceTextField.placeholder = NSLocalizedString("Salary", comment: "Salary")
            self.viewController.titleTextField.placeholder = NSLocalizedString("Job Title", comment: "Job Title")
            self.viewController.tagsLabel.text = NSLocalizedString("Professions", comment: "Professions")
            self.viewController.categoriesTextField.text = NSLocalizedString("Jobs Wanted", comment: "Jobs Wanted")

            self.shout.category = SHCategory.categoryFromName("Jobs Wanted")
            self.tagsCV = [
                SHTag.tagWithName("Accounting"),
                SHTag.tagWithName("Airlines & Aviation"),
                SHTag.tagWithName("Architecture & Interior Design"),
                SHTag.tagWithName("Art & Entertainment"),
                SHTag.tagWithName("Automotive"),
                SHTag.tagWithName("Banking & Finance"),
                SHTag.tagWithName("Beauty"),
                SHTag.tagWithName("Business Development"),
                SHTag.tagWithName("Business Supplies & Equipment"),
                SHTag.tagWithName("Construction "),
                SHTag.tagWithName("Consulting"),
                SHTag.tagWithName("Customer Service "),
                SHTag.tagWithName("Education"),
                SHTag.tagWithName("Engineering"),
                SHTag.tagWithName("Environmental Service"),
                SHTag.tagWithName("Event Management"),
                SHTag.tagWithName("Executive"),
                SHTag.tagWithName("Fashion"),
                SHTag.tagWithName("Food & Beverages"),
                SHTag.tagWithName("Government/Administration "),
                SHTag.tagWithName("Graphic Design"),
                SHTag.tagWithName("Hospitality & Restaurants "),
                SHTag.tagWithName("HR & Recruitment"),
                SHTag.tagWithName("Import & Export"),
                SHTag.tagWithName("Industrial & Manufactures"),
                SHTag.tagWithName("Information Technology"),
                SHTag.tagWithName("Insurance"),
                SHTag.tagWithName("Internet"),
                SHTag.tagWithName("Legal Services"),
                SHTag.tagWithName("Logistics & Distribution"),
                SHTag.tagWithName("Marketing & Advertising"),
                SHTag.tagWithName("Media"),
                SHTag.tagWithName("Medical & Healthcare"),
                SHTag.tagWithName("Model"),
                SHTag.tagWithName("Oil, Gas & Energy"),
                SHTag.tagWithName("Online Media"),
                SHTag.tagWithName("Pharmaceuticals"),
                SHTag.tagWithName("Public Relations"),
                SHTag.tagWithName("Real Estate"),
                SHTag.tagWithName("Research & Development"),
                SHTag.tagWithName("Retail & Consumer Goods"),
                SHTag.tagWithName("Safety & Security"),
                SHTag.tagWithName("Sales"),
                SHTag.tagWithName("Secretarial"),
                SHTag.tagWithName("Sports & Fitness"),
                SHTag.tagWithName("Telecommunications "),
                SHTag.tagWithName("Transportation"),
                SHTag.tagWithName("Travel & Tourism"),
                SHTag.tagWithName("Veterinary & Animals"),
                SHTag.tagWithName("Warehousing")
            ]
            
            self.viewController.segmentControl.selectedSegmentIndex = self.viewController.segmentControl.numberOfSegments - 1
            self.isVideoCV = true
        }
    }
}
