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
    
    fileprivate var shouts : [Shout] = []
    fileprivate let disposeBag = DisposeBag()
    fileprivate let cellIdentifier = "ConversationSelectShoutCellIdentifier"
    
    let shoutPublishSubject : PublishSubject<Shout> = PublishSubject()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = NSLocalizedString("Select Shout", comment: "Select Shout to send title")
        
        let params = FilteredShoutsParams(username: Account.sharedInstance.user!.username, page: 1, pageSize: 30, skipLocation: true)
        
        APIShoutsService.listShoutsWithParams(params).flatMap({ (result) -> Observable<[Shout]> in
            return Observable.just(result.results)
        })
        .asDriver(onErrorJustReturn: []).drive(onNext: { [weak self] (shouts) in
            self?.shouts = shouts
            self?.tableView.reloadData()
        }).addDisposableTo(disposeBag)
        
        tableView.tableFooterView = UIView()
    }
    
    override func dismiss() {
        self.navigationController?.dismiss(animated: true, completion: nil)
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return shouts.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! ConversationSelectShoutTableViewCell
        cell.bindWith(self.shouts[indexPath.row])
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.navigationController?.popViewController(animated: true)
        self.shoutPublishSubject.onNext(self.shouts[indexPath.row])
    }
    
    override func prefersTabbarHidden() -> Bool {
        return true
    }
}
