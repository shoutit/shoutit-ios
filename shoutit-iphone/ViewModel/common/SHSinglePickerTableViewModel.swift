//
//  SHSinglePickerTableViewModel.swift
//  shoutit-iphone
//
//  Created by Hitesh Sondhi on 16/11/15.
//  Copyright © 2015 Shoutit. All rights reserved.
//

import UIKit

class SHSinglePickerTableViewModel: NSObject, ViewControllerModelProtocol, UITableViewDelegate, UITableViewDataSource {

    private let viewController: SHSinglePickerTableViewController
    var allowNoneOption: Bool = true
    var stringList: [String] = []
    var onSelection: ((String) -> ())?
    
    required init(viewController: SHSinglePickerTableViewController) {
        self.viewController = viewController
    }
    
    func viewDidLoad() {
        if self.allowNoneOption {
            stringList = ["None"] + stringList
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
    
    // MARK - UITableViewDelegate
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.stringList.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .Value1, reuseIdentifier: "UITableViewCellStyleValue1")
        cell.textLabel?.text = self.stringList[indexPath.row]
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if self.allowNoneOption {
            if indexPath.row == 0 {
                onSelection?("")
            } else {
                onSelection?(self.stringList[indexPath.row])
            }
        } else {
            self.onSelection?(self.stringList[indexPath.row])
        }
        self.viewController.navigationController?.popViewControllerAnimated(true)
    }
}
