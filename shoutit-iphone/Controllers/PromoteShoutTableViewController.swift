//
//  PromoteShoutTableViewController.swift
//  shoutit
//
//  Created by Łukasz Kasperek on 16.06.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import UIKit
import RxSwift
import ShoutitKit

final class PromoteShoutTableViewController: UITableViewController {
    
    var viewModel: PromoteShoutViewModel!
    weak var flowDelegate : FlowController?
    private let disposeBag = DisposeBag()
    
    @IBOutlet weak var headerView : PromotionLabelsViews?
    
    private var options : [PromotionOption]? = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        precondition(viewModel != nil)
        setupRx()
        
        self.headerView?.fillWithShout(self.viewModel.shout)
    }
    
    func setupRx() {
        self.viewModel.getPromotionLabels().subscribeNext { [weak self] (labels) in
            self?.headerView?.presentPromotionLabels(labels)
        }.addDisposableTo(disposeBag)
        
        self.viewModel.getPromotionOptions().subscribeNext { [weak self] (labels) in
            self?.options = labels
            self?.tableView.reloadData()
        }.addDisposableTo(disposeBag)
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let options = options else {
            return 1
        }
        return options.count > 0 ? options.count : 1
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        if options?.count == 0 {
            return tableView.dequeueReusableCellWithIdentifier("PromotionsLoadingPlaceholder", forIndexPath: indexPath)
        }
        
        // PromotionsOptionCell
        let cell = tableView.dequeueReusableCellWithIdentifier("PromotionsOptionCell", forIndexPath: indexPath) as! PromotionOptionTableViewCell
        
        guard let option = options?[indexPath.row] else {
            return cell
        }

        cell.bindWithOption(option)
        
        return cell
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 60.0
    }
}
