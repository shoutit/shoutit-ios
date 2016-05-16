//
//  ConversationInfoViewController.swift
//  shoutit-iphone
//
//  Created by Piotr Bernad on 16/05/16.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import UIKit

protocol ConversationInfoViewControllerFlowDelegate: class, ChatDisplayable, ShoutDisplayable, PageDisplayable, ProfileDisplayable {}

class ConversationInfoViewController: UITableViewController {

    weak var flowDelegate: ConversationInfoViewControllerFlowDelegate?
    
    @IBOutlet weak var headerView: ConversationInfoHeaderView!
    @IBOutlet weak var footerLabel: UILabel!
    
    var conversation: Conversation! {
        didSet {
            viewModel = ConversationInfoViewModel()
            viewModel.conversation = conversation
            self.tableView.reloadData()
        }
    }
    
    var viewModel : ConversationInfoViewModel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return viewModel.numberOfSections()
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.numberOfRows(section)
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(viewModel.cellIdentifierForIndexPath(indexPath), forIndexPath: indexPath)
        
        viewModel.fillCell(cell, indexPath: indexPath)
        
        return cell
        
    }

    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return viewModel.sectionTitleForSection(section)
    }
    
    override func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 2 {
            return 5.0
        }
        
        return 20.0
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        notImplemented()
    }
}
