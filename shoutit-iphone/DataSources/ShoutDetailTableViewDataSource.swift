//
//  ShoutDetailTableViewDataSource.swift
//  shoutit-iphone
//
//  Created by Łukasz Kasperek on 25.02.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import UIKit
import RxSwift

class ShoutDetailTableViewDataSource: NSObject, UITableViewDataSource {
    
    unowned let controller: ShoutDetailTableViewController
    var viewModel: ShoutDetailViewModel {
        return controller.viewModel
    }
    
    let otherShoutsCollectionViewSetSubject = PublishSubject<IndexedCollectionView>()
    let relatedShoutsCollectionViewSetSubject = PublishSubject<IndexedCollectionView>()
    
    // views
    private(set) var otherShoutsCollectionView: IndexedCollectionView? {
        didSet {
            if let cv = otherShoutsCollectionView {
                otherShoutsCollectionViewSetSubject.onNext(cv)
            }
        }
    }
    private(set) var relatedShoutsCollectionView: IndexedCollectionView? {
        didSet {
            if let cv = relatedShoutsCollectionView {
                relatedShoutsCollectionViewSetSubject.onNext(cv)
            }
        }
    }
    
    init(controller: ShoutDetailTableViewController) {
        self.controller = controller
        super.init()
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.cellModels.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cellModel = viewModel.cellModels[indexPath.row]
        let cell = tableView.dequeueReusableCellWithIdentifier(cellModel.reuseIdentifier, forIndexPath: indexPath)
        
        switch cellModel {
        case .SectionHeader(let title):
            let headerCell = cell as! ShoutDetailSectionHeaderTableViewCell
            headerCell.titleLabel.text = title
            
        case .Description(let description):
            let descriptionCell = cell as! ShoutDetailDescriptionTableViewCell
            descriptionCell.descriptionLabel.text = description
            descriptionCell.setBorders(cellIsFirst: true, cellIsLast: true)
            
        case .KeyValue(let row, let sectionRowsCount, let key, let value):
            let keyValueCell = cell as! ShoutDetailKeyValueTableViewCell
            keyValueCell.setBackgroundForRow(row)
            keyValueCell.keyLabel.text = key
            keyValueCell.valueLabel.text = value
            keyValueCell.setBorders(cellIsFirst: row == 0, cellIsLast: row + 1 == sectionRowsCount)
            
        case .Regular(let row, let sectionRowsCount, let title):
            let regularCell = cell as! ShoutDetailRegularTableViewCell
            regularCell.setBackgroundForRow(row)
            regularCell.titleLabel.text = title
            regularCell.setBorders(cellIsFirst: row == 0, cellIsLast: row + 1 == sectionRowsCount)
            
        case .Button(let title, let type):
            let buttonCell = cell as! ShoutDetailButtonTableViewCell
            buttonCell.button.setTitle(title, forState: .Normal)
            buttonCell.reuseDisposeBag = DisposeBag()
            buttonCell.button
                .rx_tap
                .asDriver()
                .driveNext{[unowned self] in
                    switch type {
                    case .Policies:
                        break
                    case .VisitProfile:
                        self.controller.flowDelegate?.showProfile(self.viewModel.shout.user)
                    }
                }
                .addDisposableTo(buttonCell.reuseDisposeBag!)
            
        case .OtherShouts:
            let otherShoutsCell = cell as! ShoutDetailCollectionViewContainerTableViewCell
            otherShoutsCollectionView = otherShoutsCell.collectionView
            
            otherShoutsCollectionView?.registerNib(UINib(nibName: "ShoutsCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: ShoutDetailShoutCellViewModel.contentCellReuseIdentifier)
            otherShoutsCollectionView?.registerNib(UINib(nibName: "PlaceholderCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: ShoutDetailShoutCellViewModel.placeholderCellReuseIdentifier)
            
        case .RelatedShouts:
            let relatedShoutsCell = cell as! ShoutDetailCollectionViewContainerTableViewCell
            relatedShoutsCollectionView = relatedShoutsCell.collectionView
            
            relatedShoutsCollectionView?.registerNib(UINib(nibName: "ShoutsSmallCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: ShoutDetailShoutCellViewModel.contentCellReuseIdentifier)
            relatedShoutsCollectionView?.registerNib(UINib(nibName: "PlaceholderCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: ShoutDetailShoutCellViewModel.placeholderCellReuseIdentifier)
            relatedShoutsCollectionView?.registerNib(UINib(nibName: "SeeAllCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: ShoutDetailShoutCellViewModel.seeAllCellReuseIdentifier)
        }
        
        return cell
    }
}

