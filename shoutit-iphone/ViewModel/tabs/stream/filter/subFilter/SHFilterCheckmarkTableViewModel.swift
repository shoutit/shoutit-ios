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
        
//        SHFilterCheckTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SHFilterCheckTableViewCell" forIndexPath:indexPath];
//        cell.leftLabel.text = self.dataArray[indexPath.row];
//        if(indexPath.row == self.selectedRow)
//        {
//            cell.leftLabel.textColor = [UIColor colorWithHex:COLOR_SHOUT_DARK_GREEN];
//            cell.accessoryType = UITableViewCellAccessoryCheckmark;
//        }
//        else{
//            cell.leftLabel.textColor = [UIColor darkTextColor];
//            cell.accessoryType = UITableViewCellAccessoryNone;
//        }
//        return cell;
        return UITableViewCell()
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
//        [tableView deselectRowAtIndexPath:indexPath animated:YES];
//        [tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:self.selectedRow inSection:0]].accessoryType = UITableViewCellAccessoryNone;
//        [[((SHFilterCheckTableViewCell*)[tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:self.selectedRow inSection:0]]) leftLabel]setTextColor:[UIColor darkTextColor]];
//        
//        self.selectedRow = (int)indexPath.row;
//        [tableView cellForRowAtIndexPath:indexPath].accessoryType = UITableViewCellAccessoryCheckmark;
//        [[((SHFilterCheckTableViewCell*)[tableView cellForRowAtIndexPath:indexPath]) leftLabel]setTextColor:[UIColor colorWithHex:COLOR_SHOUT_DARK_GREEN]];
//        
//        if(self.selectedBlock) self.selectedBlock(self.dataArray[self.selectedRow], self.selectedRow);
//        [self.navigationController popViewControllerAnimated:YES];
    }
    
    func tableView(tableView: UITableView, didDeselectRowAtIndexPath indexPath: NSIndexPath) {
//        [[((SHFilterCheckTableViewCell*)[tableView cellForRowAtIndexPath:indexPath]) leftLabel]setTextColor:[UIColor darkTextColor]];
//        
//        [tableView cellForRowAtIndexPath:indexPath].accessoryType = UITableViewCellAccessoryNone;
    }
    
    
}
