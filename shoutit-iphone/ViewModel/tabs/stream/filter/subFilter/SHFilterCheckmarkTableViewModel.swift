//
//  SHFilterCheckmarkTableViewModel.swift
//  shoutit-iphone
//
//  Created by Vishal Thakur on 20/11/15.
//  Copyright © 2015 Shoutit. All rights reserved.
//

import Foundation

class SHFilterCheckmarkTableViewModel: NSObject, ViewControllerModelProtocol, UITableViewDelegate, UITableViewDataSource {

    private let viewController: SHFilterCheckmarkTableViewController
    
    required init(viewController: SHFilterCheckmarkTableViewController) {
        self.viewController = viewController
    }
    
    func viewDidLoad() {
        if(self.viewController.isCategories) {
            getListOfCategories()
        }
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
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.viewController.dataArray.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(Constants.TableViewCell.SHFilterCheckTableViewCell, forIndexPath: indexPath) as! SHFilterCheckTableViewCell
        cell.leftLabel.text = self.viewController.dataArray[indexPath.row]
        if(indexPath.row == self.viewController.selectedRow) {
            cell.leftLabel.textColor = UIColor(shoutitColor: .ShoutDarkGreen)
            cell.accessoryType = UITableViewCellAccessoryType.Checkmark
        } else {
            cell.leftLabel.textColor = UIColor.darkTextColor()
            cell.accessoryType = UITableViewCellAccessoryType.None
        }
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
//        if let selectedRow = self.viewController.selectedRow {
            tableView.cellForRowAtIndexPath(NSIndexPath(forRow: indexPath.row, inSection: 0))
            (tableView.cellForRowAtIndexPath(NSIndexPath(forRow: indexPath.row, inSection: 0)) as? SHFilterCheckTableViewCell)?.leftLabel.textColor = UIColor.darkTextColor()
            self.viewController.selectedRow = indexPath.row
            tableView.cellForRowAtIndexPath(indexPath)?.accessoryType = UITableViewCellAccessoryType.Checkmark
            (tableView.cellForRowAtIndexPath(indexPath) as? SHFilterCheckTableViewCell)?.leftLabel.textColor = UIColor(shoutitColor: .ShoutDarkGreen)
            if let block = self.viewController.selectedBlock {
                block(selectedTitle: self.viewController.dataArray[indexPath.row], index: indexPath.row)
            }
           // if(self.selectedBlock) self.selectedBlock(self.dataArray[self.selectedRow], self.selectedRow);
            self.viewController.navigationController?.popViewControllerAnimated(true)
       // }
    }
    
    func tableView(tableView: UITableView, didDeselectRowAtIndexPath indexPath: NSIndexPath) {
        (tableView.cellForRowAtIndexPath(indexPath) as? SHFilterCheckTableViewCell)?.leftLabel.textColor = UIColor.darkTextColor()
        tableView.cellForRowAtIndexPath(indexPath)?.accessoryType = UITableViewCellAccessoryType.None
    }
    
    // Private 
    private func getListOfCategories() {
        self.viewController.shApiMisc.getCategories({ (shCategory) -> Void in
            self.setCategories(shCategory)
            }) { (response) -> Void in
                if let result = response.result.value {
                    self.setCategories(result)
                }
                self.viewController.tableView.reloadData()
        }
    }
    
    private func setCategories(category: [SHCategory]) {
        self.viewController.dataArray += category.map({ (category) -> String in
            category.name
        })
        if !self.viewController.dataArray.contains("All") {
            self.viewController.dataArray.insert("All", atIndex: 0)
        }
        if let selectedItem = self.viewController.selectedItem {
            self.viewController.selectedRow = self.viewController.dataArray.indexOf(selectedItem)
        }
    }
}
