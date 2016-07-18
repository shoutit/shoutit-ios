//
//  ConversationSelectShoutController.swift
//  shoutit-iphone
//
//  Created by Piotr Bernad on 25/03/16.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import UIKit
import RxSwift
import ShoutitKit

final class ConversationSelectShoutController: UITableViewController {
    
    private var shouts : [Shout] = []
    private let disposeBag = DisposeBag()
    private let cellIdentifier = "ConversationSelectShoutCellIdentifier"
    
    let shoutPublishSubject : PublishSubject<Shout> = PublishSubject()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = NSLocalizedString("Select Shout", comment: "")
        
        let params = FilteredShoutsParams(username: Account.sharedInstance.user!.username, page: 1, pageSize: 30, skipLocation: true)
        
        APIShoutsService.listShoutsWithParams(params).asDriver(onErrorJustReturn: []).driveNext { [weak self] (shouts) in
            self?.shouts = shouts
            self?.tableView.reloadData()
        }.addDisposableTo(disposeBag)
        
        tableView.tableFooterView = UIView()
    }
    
    override func dismiss() {
        self.navigationController?.dismissViewControllerAnimated(true, completion: nil)
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return shouts.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier, forIndexPath: indexPath) as! ConversationSelectShoutTableViewCell
        cell.bindWith(self.shouts[indexPath.row])
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.navigationController?.popViewControllerAnimated(true)
        self.shoutPublishSubject.onNext(self.shouts[indexPath.row])
    }
    
    override func prefersTabbarHidden() -> Bool {
        return true
    }
}
