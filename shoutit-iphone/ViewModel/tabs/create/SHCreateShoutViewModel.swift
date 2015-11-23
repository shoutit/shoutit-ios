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
        
        if let tagsVC = UIStoryboard.getFilter().instantiateViewControllerWithIdentifier(Constants.ViewControllers.SHCATEGORYTAGS) as? SHCategoryTagsViewController {
            tagsVC.category = self.shout.category?.name
            tagsVC.selectedBlock = {(tags: [SHTag]) in
                if tags.count > 0 {
                    let tagName = tags[0].name
                    if self.tagExist(tagName) {
                        return;
                    }
                    var stringTags: [String] = []
                    for tag in tags {
                        stringTags += [tag.name]
                    }
                    if self.shout.tags == nil {
                        self.shout.tags = tags
                        self.shout.stringTags = stringTags
                    } else {
                        self.shout.tags! += tags
                        self.shout.stringTags += stringTags
                    }
                    
                    if (self.viewController.segmentControl.selectedSegmentIndex == 2) {
                        if NSUserDefaults.standardUserDefaults().valueForKey(Constants.SharedUserDefaults.SelectLocationAlert) == nil {
                            NSUserDefaults.standardUserDefaults().setValue(1, forKey: Constants.SharedUserDefaults.SelectLocationAlert)
                            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                                let alert = UIAlertController(title: NSLocalizedString("Recommendation", comment: "Recommendation"), message: NSLocalizedString("Now choose the city you would like to work in", comment: "Now choose the city you would like to work in"), preferredStyle: UIAlertControllerStyle.Alert)
                                
                                alert.addAction(UIAlertAction(title: NSLocalizedString("Skip", comment: "Skip"), style: UIAlertActionStyle.Cancel, handler: nil))
                                alert.addAction(UIAlertAction(title: NSLocalizedString("Choose the city", comment: "Choose the city"), style: .Default, handler: { (action) -> Void in
                                    self.selectLocation()
                                }))
                                self.viewController.presentViewController(alert, animated: true, completion: nil)
                            })
                        }
                    }
                }
                let verticalContentOffset = self.viewController.tableView.contentOffset.y
                self.viewController.tableView.reloadData()
                self.viewController.tableView.contentOffset = CGPointMake(0, verticalContentOffset)
            }
            
            self.viewController.navigationController?.pushViewController(tagsVC, animated: true)
        }
        
    }
    
    func cleanForms() {}
    
    func postShout() {
        if !self.validFields() {
            return;
        }
        self.shout
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
            SHTextInputViewController.presentFromViewController(self.viewController, text: self.shout.text, completionHandler: { (text) -> () in
                self.viewController.descriptionTextView.text = text
                self.shout.text = text
            })
        } else if (indexPath.section == 4 && indexPath.row == 0) {
            self.viewController.priceTextField.becomeFirstResponder()
        } else if (indexPath.section == 4 && indexPath.row == 1) {
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
        } else if (indexPath.section == 5 && indexPath.row == 0) {
            self.selectLocation()
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
            if self.shout.price != 0 {
                self.viewController.priceTextField.text = "\(self.shout.price)"
            } else {
                self.viewController.priceTextField.text = ""
            }
        } else if (indexPath.section == 4 && indexPath.row == 1) { // Currency
            self.viewController.currencyTextField.text = "\(self.shout.currency)"
        } else if (indexPath.section == 5 && indexPath.row == 0) { // location
            if let location = shout.location {
                self.viewController.locationTextView.text = String(format: "%@, %@, %@", location.city, location.state, location.country)
            }
        }
        let cell = self.viewController.tableView(tableView, cellForRowAtIndexPath: indexPath)
        if (indexPath.section == 2 && indexPath.row == 1) {
            self.viewController.tagsList.setTags(self.shout.stringTags)
            for (_, constraint) in self.viewController.tagsList.constraints.enumerate() {
                if constraint.firstAttribute == NSLayoutAttribute.Height {
                    constraint.constant =  fmax(24.0, self.viewController.tagsList.contentSize.height)
                    break
                }
            }
            cell.layoutIfNeeded()
        }
        return cell
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if indexPath.section == 2 && indexPath.row == 1 {
            return fmax(24.0, self.viewController.tagsList.contentSize.height) + 20
        }
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
    
    // MARK - DWTagListDelegate
    func selectedTag(tagName: String!, tagIndex: Int) {
        let ac = UIAlertController(title: NSLocalizedString("Delete tag?", comment: "Delete tag?"), message: "", preferredStyle: UIAlertControllerStyle.Alert)
        ac.addAction(UIAlertAction(title: "No", style: UIAlertActionStyle.Cancel, handler: nil))
        ac.addAction(UIAlertAction(title: "Yes", style: UIAlertActionStyle.Default, handler: { (alert) -> Void in
            self.shout.tags?.removeAtIndex(tagIndex)
            self.shout.stringTags.removeAtIndex(tagIndex)
            self.viewController.tagsList.setTags(self.shout.stringTags)
        }))
        self.viewController.presentViewController(ac, animated: true, completion: nil)
    }
    
    // MARK - Private
    private func showCurrencyPicker() {
        SHSinglePickerTableViewController.presentPickerFromViewController(self.viewController, stringList: self.currenciesString, title: "Currencies", allowNoneOption: true) { (selectedItem) -> () in
            self.shout.currency = selectedItem
            self.viewController.currencyTextField.text = selectedItem
        }
    }
    
    private func validFields() -> Bool {
        if self.viewController.titleTextField.text!.isEmpty {
            self.showErrorAlert(NSLocalizedString("Title not set", comment: "Title not set"), message: NSLocalizedString("Please enter the title.", comment: "Please enter the title."))
            return false
        }
        if self.viewController.titleTextField.text!.characters.count < 6 {
            self.showErrorAlert(NSLocalizedString("Title minimum length", comment: "Title minimum length"), message: NSLocalizedString("Title should be at least 6 characters.", comment: "Title should be at least 6 characters."))
            return false
        }
        if self.viewController.categoriesTextField.text!.isEmpty {
            self.showErrorAlert(NSLocalizedString("Categorie not set", comment: "Categorie not set"), message: NSLocalizedString("Please select the categorie.", comment: "Please select the categorie."))
            return false
        }
        if self.viewController.tagsList.textArray.count < 1 {
            self.showErrorAlert(NSLocalizedString("Tags not set", comment: "Tags not set"), message: NSLocalizedString("Please select tags.", comment: "Please select tags."))
            return false
        }
        if self.viewController.descriptionTextView.text!.isEmpty {
            self.showErrorAlert(NSLocalizedString("Description not set", comment: "Description not set"), message: NSLocalizedString("Please enter the description.", comment: "Please enter the description."))
            return false
        }
        if self.viewController.descriptionTextView.text!.characters.count < 10 {
            self.showErrorAlert(NSLocalizedString("Description minimum length", comment: "Description minimum length"), message: NSLocalizedString("Description should be at least 10 characters.", comment: "Description should be at least 10 characters."))
            return false
        }
        if self.viewController.priceTextField.text!.isEmpty {
            self.showErrorAlert(NSLocalizedString("Price not set", comment: "Price not set"), message: NSLocalizedString("Please enter the price.", comment: "Please enter the price."))
            return false
        }
        if self.viewController.currencyTextField.text!.isEmpty {
            self.showErrorAlert(NSLocalizedString("Currency not set", comment: "Currency not set"), message: NSLocalizedString("Please select the currency", comment: "Please select the currency"))
            return false
        }
        if self.media.count < 1 {
            self.showErrorAlert(NSLocalizedString("Media is empty", comment: "Media is empty"), message: NSLocalizedString("Please take at least one image or video.", comment: "Please take at least one image or video."))
            return false
        }
        if self.viewController.locationTextView.text!.isEmpty {
            self.showErrorAlert(NSLocalizedString("Location not set", comment: "Location not set"), message: NSLocalizedString("Please select the location", comment: "Please select the location"))
            return false
        }
        if !SHApiManager.sharedInstance.isNetworkReachable() {
            self.showErrorAlert(NSLocalizedString("No network connection", comment: "No network connection"), message: NSLocalizedString("You must be connected to the internet to post the shout.", comment: "You must be connected to the internet to post the shout."))
            return false
        }
        return true
    }
    
    private func showErrorAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: NSLocalizedString("Ok", comment: "Ok"), style: UIAlertActionStyle.Cancel, handler: nil))
        self.viewController.presentViewController(alert, animated: true, completion: nil)
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
    
    private func selectLocation() {
        if let locationVC = UIStoryboard.getStream().instantiateViewControllerWithIdentifier(Constants.ViewControllers.LOCATION_GETTER) as? SHLocationGetterViewController {
            locationVC.title = NSLocalizedString("Select Place", comment: "Select Place")
            locationVC.isUpdateUserLocation = false
            locationVC.setLocationSelected({ (address) -> () in
                self.shout.location = address
                if let location = self.shout.location {
                    self.viewController.locationTextView.text = String(format: "%@, %@, %@", location.city, location.state, location.country)
                    let verticalContentOffset = self.viewController.tableView.contentOffset.y
                    self.viewController.tableView.reloadData()
                    self.viewController.tableView.contentOffset = CGPointMake(0, verticalContentOffset)
                    for currency in self.currencies {
                        if address.country == currency.country {
                            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                                self.viewController.currencyTextField.text = currency.code
                            })
                            break
                        }
                    }
                }
            })
            self.viewController.navigationController?.pushViewController(locationVC, animated: true)
        }
    }
    
    private func setUpTagList() {
        self.viewController.tagsList.setTags(self.shout.getStringTags())
        self.viewController.tagsList.setTagBackgroundColor(UIColor(hexString: Constants.Style.COLOR_SHOUT_GREEN))
        self.viewController.tagsList.setTagHighlightColor(UIColor(hexString: Constants.Style.COLOR_SHOUT_DARK_GREEN))
        self.viewController.tagsList.textShadowColor = UIColor.clearColor()
        self.viewController.tagsList.automaticResize = true
        self.viewController.tagsList.userInteractionEnabled = true
        self.viewController.tagsList.tagDelegate = self
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
        let location = SHAddress.getUserOrDeviceLocation()
        self.currenciesString = self.currencies.map({ (currency) -> String in
            if let loc = location where loc.country == currency.country {
                self.viewController.currencyTextField.text = currency.code
            }
            return currency.code
        })
    }
    
    
    private func tagExist(tagName: String) -> Bool{
        if let tags = self.shout.tags {
            for tag in tags {
                if tag.name == tagName {
                    return true
                }
            }
        }
        return false
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
