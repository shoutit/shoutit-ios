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
    
    let viewModel: ShoutDetailViewModel
    
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
    
    init(viewModel: ShoutDetailViewModel) {
        self.viewModel = viewModel
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
            
        case .KeyValue(let key, let value):
            let keyValueCell = cell as! ShoutDetailKeyValueTableViewCell
            keyValueCell.keyLabel.text = key
            keyValueCell.valueLabel.text = value
            
        case .Regular(let title):
            let regularCell = cell as! ShoutDetailRegularTableViewCell
            regularCell.titleLabel.text = title
            
        case .Button(let title, _):
            let buttonCell = cell as! ShoutDetailButtonTableViewCell
            buttonCell.button.setTitle(title, forState: .Normal)
            
        case .OtherShouts:
            let otherShoutsCell = cell as! ShoutDetailCollectionViewContainerTableViewCell
            otherShoutsCollectionView = otherShoutsCell.collectionView
            otherShoutsCollectionView?.registerNib(UINib(nibName: "ShoutsCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: ShoutDetailOtherShoutsCollectionViewDataSource.cellReuseIdentifier)
            
        case .RelatedShouts:
            let relatedShoutsCell = cell as! ShoutDetailCollectionViewContainerTableViewCell
            relatedShoutsCollectionView = relatedShoutsCell.collectionView
            relatedShoutsCollectionView?.registerNib(UINib(nibName: "ShoutsSmallCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: ShoutDetailRelatedShoutsCollectionViewDataSource.cellReuseIdentifier)
        }
        
        return cell
    }
    
    // MARK: - Helpers
    
    
}

