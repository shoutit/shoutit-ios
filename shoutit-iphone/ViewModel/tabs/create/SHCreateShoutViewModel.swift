//
//  SHCreateShoutViewModel.swift
//  shoutit-iphone
//
//  Created by Hitesh Sondhi on 14/11/15.
//  Copyright © 2015 Shoutit. All rights reserved.
//

import UIKit

class SHCreateShoutViewModel: NSObject, TableViewControllerModelProtocol, UICollectionViewDelegateFlowLayout, UICollectionViewDataSource, UITableViewDelegate, UITableViewDataSource {

    private let viewController: SHCreateShoutTableViewController
    
    private var media: [SHMedia] = []
    private var categories: [SHCategory] = []
    private var isVideoCV = false
    private var offset: Float = 0
    
    var isEditing = false
    
    required init(viewController: SHCreateShoutTableViewController) {
        self.viewController = viewController
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
    
    // MARK - CollectionView Delegate
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 0
    }
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        if indexPath.item < 1 {
            return CGSizeMake(190, 190)
        } else {
            // TODO
//            id data = self.media[indexPath.item - 1];
//            if([data isKindOfClass:[UIImage class]])
//            {
//                return CGSizeMake(190, 190);
//            }
//            if([data isKindOfClass:[SHVideo class]])
//            {
//                return CGSizeMake(337, 190);
//            }
        }
        return CGSizeMake(190, 190)
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        return UICollectionViewCell()
    }
    
    // MARK - UITableView Delegate
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath.row == 0 && indexPath.section == 0 {
            self.viewController.titleTextField.becomeFirstResponder()
        } else if indexPath.row == 0 && indexPath.section == 2 && !self.isVideoCV {
            // TODO
//            [self addPickerView:self.categoriesTextField
//                withArray:self.categories
//                andTitle:@"Categories"
//            showClear:YES];
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
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        return self.viewController.tableView(tableView, cellForRowAtIndexPath: indexPath)
    }
}
