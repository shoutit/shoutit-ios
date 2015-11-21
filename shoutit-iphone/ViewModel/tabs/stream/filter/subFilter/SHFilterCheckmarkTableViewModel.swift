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
        getListOfCategories()
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
    
    func getListOfCategories() {
        self.viewController.shApiMisc.getCategories({ (shCategory) -> Void in
            // Do Nothing
            }) { (response) -> Void in
                print(response.result.value?.mainTag)
        }
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.viewController.dataArray.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCellWithIdentifier(Constants.TableViewCell.SHFilterCheckTableViewCell, forIndexPath: indexPath) as? SHFilterCheckTableViewCell {
            cell.leftLabel.text = self.viewController.dataArray[indexPath.row] as? String
            if(indexPath.row == self.viewController.selectedRow) {
                cell.leftLabel.textColor = UIColor(hexString: Constants.Style.COLOR_SHOUT_DARK_GREEN)
                cell.accessoryType = UITableViewCellAccessoryType.Checkmark
            } else {
                cell.leftLabel.textColor = UIColor.darkTextColor()
                cell.accessoryType = UITableViewCellAccessoryType.None
            }
            return cell
        }
        return UITableViewCell()
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        if let selectedRow = self.viewController.selectedRow {
            tableView.cellForRowAtIndexPath(NSIndexPath(forRow: selectedRow, inSection: 0))
            (tableView.cellForRowAtIndexPath(NSIndexPath(forRow: selectedRow, inSection: 0)) as? SHFilterCheckTableViewCell)?.leftLabel.textColor = UIColor.darkTextColor()
            self.viewController.selectedRow = indexPath.row
            tableView.cellForRowAtIndexPath(indexPath)?.accessoryType = UITableViewCellAccessoryType.Checkmark
            (tableView.cellForRowAtIndexPath(indexPath) as? SHFilterCheckTableViewCell)?.leftLabel.textColor = UIColor(hexString: Constants.Style.COLOR_SHOUT_DARK_GREEN)
           // if(self.selectedBlock) self.selectedBlock(self.dataArray[self.selectedRow], self.selectedRow);
            self.viewController.navigationController?.popViewControllerAnimated(true)
        }
    }
    
    func tableView(tableView: UITableView, didDeselectRowAtIndexPath indexPath: NSIndexPath) {
        (tableView.cellForRowAtIndexPath(indexPath) as? SHFilterCheckTableViewCell)?.leftLabel.textColor = UIColor.darkTextColor()
        tableView.cellForRowAtIndexPath(indexPath)?.accessoryType = UITableViewCellAccessoryType.None
    }
    
    
}
