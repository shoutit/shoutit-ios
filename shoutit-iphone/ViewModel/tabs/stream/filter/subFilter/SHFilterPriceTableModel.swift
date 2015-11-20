//
//  SHFilterPriceTableModel.swift
//  shoutit-iphone
//
//  Created by Vishal Thakur on 20/11/15.
//  Copyright © 2015 Shoutit. All rights reserved.
//

import Foundation

class SHFilterPriceTableModel: NSObject, UITableViewDelegate {
    
    private let viewController: SHFilterPriceTableViewController
    
    required init(viewController: SHFilterPriceTableViewController) {
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
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if (indexPath.section == 0 && indexPath.row == 0) {
            self.viewController.minTextField.becomeFirstResponder()
        }
        if (indexPath.section == 0 && indexPath.row == 1) {
            self.viewController.maxTextField.becomeFirstResponder()
        }
    }
    
    func destroy() {
        
    }
    
}
