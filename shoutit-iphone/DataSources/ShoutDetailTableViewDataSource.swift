//
//  ShoutDetailTableViewDataSource.swift
//  shoutit-iphone
//
//  Created by Łukasz Kasperek on 25.02.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import UIKit
import RxSwift

final class ShoutDetailTableViewDataSource: NSObject, UITableViewDataSource {
    
    fileprivate(set) var otherShoutsHeight: CGFloat = 130
    unowned let controller: ShoutDetailTableViewController
    var viewModel: ShoutDetailViewModel {
        return controller.viewModel
    }
    
    let otherShoutsCollectionViewSetSubject = PublishSubject<IndexedCollectionView>()
    let relatedShoutsCollectionViewSetSubject = PublishSubject<IndexedCollectionView>()
    
    // views
    fileprivate(set) var otherShoutsCollectionView: IndexedCollectionView? {
        didSet {
            if let cv = otherShoutsCollectionView {
                otherShoutsCollectionViewSetSubject.onNext(cv)
            }
        }
    }
    fileprivate(set) var relatedShoutsCollectionView: IndexedCollectionView? {
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
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.cellModels.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cellModel = viewModel.cellModels[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: cellModel.reuseIdentifier, for: indexPath)
        
        switch cellModel {
        case .sectionHeader(let title):
            let headerCell = cell as! ShoutDetailSectionHeaderTableViewCell
            headerCell.titleLabel.text = title
            
        case .description(let description):
            let descriptionCell = cell as! ShoutDetailDescriptionTableViewCell
            descriptionCell.descriptionLabel.text = description
            descriptionCell.setBorders(cellIsFirst: true, cellIsLast: true)
            
        case .keyValue(let row, let sectionRowsCount, let key, let value, let imageName, _, _):
            let keyValueCell = cell as! ShoutDetailKeyValueTableViewCell
            keyValueCell.setBackgroundForRow(row)
            keyValueCell.keyLabel.text = key
            keyValueCell.valueLabel.text = value
            if let imageName = imageName {
                keyValueCell.iconImageView.image = UIImage(named: imageName)
            } else {
                keyValueCell.iconImageView.image = nil
            }
            keyValueCell.setBorders(cellIsFirst: row == 0, cellIsLast: row + 1 == sectionRowsCount)
            
        case .regular(let row, let sectionRowsCount, let title):
            let regularCell = cell as! ShoutDetailRegularTableViewCell
            regularCell.setBackgroundForRow(row)
            regularCell.titleLabel.text = title
            regularCell.setBorders(cellIsFirst: row == 0, cellIsLast: row + 1 == sectionRowsCount)
            
        case .button(let title, let type):
            let buttonCell = cell as! ShoutDetailButtonTableViewCell
            buttonCell.button.setTitle(title, for: UIControlState())
            buttonCell.reuseDisposeBag = DisposeBag()
            buttonCell.button
                .rx.tap
                .asDriver()
                .drive(onNext: { [unowned self] in
                    switch type {
                    case .policies:
                        break
                    case .visitProfile:
                        guard let profile = self.viewModel.shout.user else { return }
                        self.controller.flowDelegate?.showProfile(profile)
                    }
                })
                .addDisposableTo(buttonCell.reuseDisposeBag!)
            
        case .otherShouts:
            let otherShoutsCell = cell as! ShoutDetailCollectionViewContainerTableViewCell
            otherShoutsCollectionView = otherShoutsCell.collectionView
            
            otherShoutsCollectionView?.register(UINib(nibName: "ShoutsCollectionViewCell", bundle: nil),
                                                   forCellWithReuseIdentifier: ShoutDetailShoutCellViewModel.contentCellReuseIdentifier)
            otherShoutsCollectionView?.register(UINib(nibName: "PlaceholderCollectionViewCell", bundle: nil),
                                                   forCellWithReuseIdentifier: ShoutDetailShoutCellViewModel.placeholderCellReuseIdentifier)
            
            otherShoutsCell.collectionView.contentSizeDidChange = {[weak tableView, weak self] (contentSize) in
                self?.otherShoutsHeight = contentSize.height
                tableView?.beginUpdates()
                tableView?.endUpdates()
            }
            
        case .relatedShouts:
            let relatedShoutsCell = cell as! ShoutDetailCollectionViewContainerTableViewCell
            relatedShoutsCollectionView = relatedShoutsCell.collectionView
            
            relatedShoutsCollectionView?.register(UINib(nibName: "ShoutsSmallCollectionViewCell", bundle: nil),
                                                     forCellWithReuseIdentifier: ShoutDetailShoutCellViewModel.contentCellReuseIdentifier)
            relatedShoutsCollectionView?.register(UINib(nibName: "PlaceholderCollectionViewCell", bundle: nil),
                                                     forCellWithReuseIdentifier: ShoutDetailShoutCellViewModel.placeholderCellReuseIdentifier)
            relatedShoutsCollectionView?.register(UINib(nibName: "SeeAllCollectionViewCell", bundle: nil),
                                                     forCellWithReuseIdentifier: ShoutDetailShoutCellViewModel.seeAllCellReuseIdentifier)
        }
        
        return cell
    }
}

