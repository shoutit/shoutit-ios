//
//  ConversationSelectShoutController.swift
//  shoutit-iphone
//
//  Created by Piotr Bernad on 25/03/16.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import UIKit
import RxSwift

class ConversationSelectShoutController: UITableViewController {
    
    private var shouts : [Shout] = []
    private let disposeBag = DisposeBag()
    private let cellIdentifier = "ConversationSelectShoutCellIdentifier"
    
    let shoutPublishSubject : PublishSubject<Shout> = PublishSubject()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = NSLocalizedString("Select Shout", comment: "")
//        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Cancel, target: self, action: #selector(ConversationSelectShoutController.dismiss))
        
        let params = FilteredShoutsParams(username: Account.sharedInstance.user!.username, page: 1, pageSize: 30)
        
        APIShoutsService.listShoutsWithParams(params).asDriver(onErrorJustReturn: []).driveNext { [weak self] (shouts) in
            self?.shouts = shouts
            self?.tableView.reloadData()
        }.addDisposableTo(disposeBag)
        
        tableView.tableFooterView = UIView()
        
    }
    
    func dismiss() {
        self.navigationController?.dismissViewControllerAnimated(true, completion: nil)
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return shouts.count
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
        self.shoutPublishSubject.onNext(self.shouts[indexPath.row])
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    override func prefersTabbarHidden() -> Bool {
        return true
    }

}