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
    private var isVideoCV = false
    private var offset: CGFloat = 0
    private var tapTagsSelect: UITapGestureRecognizer?
    
    var shout: SHShout?
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
                self.addPickerView(self.viewController.categoriesTextField, array: self.categories, title: NSLocalizedString("Categories", comment: "Categories"), showClear: true)
            }
        } else if indexPath.section == 2 && indexPath.row == 1 {
            // TODO
//            [self selectTags:nil];
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
//            NSMutableArray *currencies = [[NSUserDefaults standardUserDefaults] valueForKey:@"currencies"];
//            NSMutableArray *cur = [NSMutableArray new];
//            for (NSDictionary* dict in currencies)
//            {
//                [cur addObject:dict[@"code"]];
//            }
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
        if let shout = self.shout {
            if (indexPath.section == 0 && indexPath.row == 0) {
                self.viewController.titleTextField.text = shout.title
            } else if (indexPath.section == 0 && indexPath.row == 1) {
                // TODO
//                if([self.shout.type isEqualToString:@"offer"])
//                {
//                    [self setupViewForStandard:YES];
//                    self.segmentControl.selectedSegmentIndex = 0;
//                    
//                }else if([self.shout.type isEqualToString:@"request"])
//                {
//                    [self setupViewForStandard:YES];
//                    self.segmentControl.selectedSegmentIndex = 1;
//                    
//                }else if(self.shout.category)
//                {
//                    if([self.shout.category.name isEqualToString:@"cv-video"])
//                    {
//                        [self setupViewForStandard:NO];
//                        self.segmentControl.selectedSegmentIndex = 2;
//                    }
//                }
//                self.categoriesTextField.text =  self.shout.category.name;
            }
            // TODO
//            if (indexPath.section == 2 && indexPath.row == 0) // categorie
//            {
//                self.categoriesTextField.text = self.shout.category.name;
//            }
//            if (indexPath.section == 3 && indexPath.row == 0) // description
//            {
//                self.descriptionTextView.text = self.shout.text;
//            }
//            if (indexPath.section == 4 && indexPath.row == 0) // Price
//            {
//                self.priceTextField.text = self.shout.price;
//            }
//            if (indexPath.section == 4 && indexPath.row == 1) // Currency
//            {
//                self.currencyTextField.text = self.shout.currency;
//            }
//            if (indexPath.section == 5 && indexPath.row == 0) // location
//            {
//                [self.locationTextView setText:[NSString stringWithFormat:@"%@, %@, %@",self.shout.shoutLocation.city,self.shout.shoutLocation.stateCode,self.shout.shoutLocation.countryCode]];
//            }
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
    private func addPickerView(textField: UITextField, array: NSArray, title: String, showClear: Bool) {
        
    }
    
    private func setUpTagList() {
        self.viewController.tagsList.setTags(self.shout?.getStringTags())
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
    
    private func setupViewForStandard(standard: Bool) {
        if standard {
            // TODO
            // get categories from cache
//            self.categories = [NSMutableArray arrayWithArray: [[NSUserDefaults standardUserDefaults] valueForKey:SH_CATEGORIES_URL]];
            self.viewController.priceTextField.placeholder = NSLocalizedString("Price", comment: "Price")
            self.viewController.titleTextField.placeholder = NSLocalizedString("Title", comment: "Title")
            if self.isEditing {
                self.viewController.categoriesTextField.text = ""
            }
            self.viewController.tagsLabel.text = NSLocalizedString("Price", comment: "Price")
            self.isVideoCV = false
        } else {
            // TODO
//            [self.priceTextField setPlaceholder:NSLocalizedString(@"Salary",@"Salary")];
//            [self.titleTextField setPlaceholder:NSLocalizedString(@"Job Title",@"Job Title")];
//            [self.tagsLabel setText:NSLocalizedString(@"Professions",@"Professions")];
//            [self.categoriesTextField setText:NSLocalizedString(@"Jobs Wanted",@"Jobs Wanted")];
//            
//            self.shout.category = [SHCategory categoryWithName:@"Jobs Wanted"];
//            self.tagsCV = [NSMutableArray arrayWithObjects:
//            [SHTag tagWithName:@"Accounting"],
//            [SHTag tagWithName:@"Airlines & Aviation"],
//            [SHTag tagWithName:@"Architecture & Interior Design"],
//            [SHTag tagWithName:@"Art & Entertainment"],
//            [SHTag tagWithName:@"Automotive"],
//            [SHTag tagWithName: @"Banking & Finance"],
//            [SHTag tagWithName:@"Beauty"],
//            [SHTag tagWithName:@"Business Development"],
//            [SHTag tagWithName:@"Business Supplies & Equipment"],
//            [SHTag tagWithName:@"Construction "],
//            [SHTag tagWithName:@"Consulting"],
//            [SHTag tagWithName:@"Customer Service "],
//            [SHTag tagWithName:@"Education"],
//            [SHTag tagWithName:@"Engineering"],
//            [SHTag tagWithName:@"Environmental Service"],
//            [SHTag tagWithName:@"Event Management"],
//            [SHTag tagWithName: @"Executive"],
//            [SHTag tagWithName:@"Fashion"],
//            [SHTag tagWithName:@"Food & Beverages"],
//            [SHTag tagWithName:@"Government/Administration "],
//            [SHTag tagWithName:@"Graphic Design"],
//            [SHTag tagWithName:@"Hospitality & Restaurants "],
//            [SHTag tagWithName:@"HR & Recruitment"],
//            [SHTag tagWithName:@"Import & Export"],
//            [SHTag tagWithName:@"Industrial & Manufactures"],
//            [SHTag tagWithName:@"Information Technology"],
//            [SHTag tagWithName:@"Insurance"],
//            [SHTag tagWithName:@"Internet"],
//            [SHTag tagWithName:@"Legal Services"],
//            [SHTag tagWithName:@"Logistics & Distribution"],
//            [SHTag tagWithName:@"Marketing & Advertising"],
//            [SHTag tagWithName:@"Media"],
//            [SHTag tagWithName:@"Medical & Healthcare"],
//            [SHTag tagWithName:@"Model"],
//            [SHTag tagWithName:@"Oil, Gas & Energy"],
//            [SHTag tagWithName:@"Online Media"],
//            [SHTag tagWithName:@"Pharmaceuticals"],
//            [SHTag tagWithName:@"Public Relations"],
//            [SHTag tagWithName:@"Real Estate"],
//            [SHTag tagWithName:@"Research & Development"],
//            [SHTag tagWithName:@"Retail & Consumer Goods"],
//            [SHTag tagWithName:@"Safety & Security"],
//            [SHTag tagWithName:@"Sales"],
//            [SHTag tagWithName:@"Secretarial"],
//            [SHTag tagWithName:@"Sports & Fitness"],
//            [SHTag tagWithName:@"Telecommunications "],
//            [SHTag tagWithName:@"Transportation"],
//            [SHTag tagWithName:@"Travel & Tourism"],
//            [SHTag tagWithName: @"Veterinary & Animals"],
//            [SHTag tagWithName:@"Warehousing"],
//            nil];
//            
//            [self.segmentControl setSelectedSegmentIndex:self.segmentControl.numberOfSegments-1];
//            self.timeToRecord = TIME_VIDEO_CV;
//            self.isVideoCV = YES;
        }
    }
}
