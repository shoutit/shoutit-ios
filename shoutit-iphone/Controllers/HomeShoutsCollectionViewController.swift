//
//  HomeShoutsCollectionViewController.swift
//  shoutit-iphone
//
//  Created by Piotr Bernad on 15.02.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import UIKit
import RxSwift

class HomeShoutsCollectionViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout {

    let viewModel = HomeShoutsViewModel()
    let scrollOffset = Variable(CGPointZero)
    let disposeBag = DisposeBag()
    var retry = Variable(true)
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupDisplayable()
        setupDataSource()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        reloadData()
    }
    
    func reloadData() {
        retry.value = false
    }
    
    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(viewModel.cellReuseIdentifier(), forIndexPath: indexPath)
    
        // Configure the cell
    
        return cell
    }
    
    
    // MARK: Actions
    
    func changeCollectionViewDisplayMode(sender: UIButton) {
        sender.selected = viewModel.changeDisplayModel() == ShoutsLayout.VerticalList
        
        setupDisplayable()
    }
    
    func setupDisplayable() {
        viewModel.displayable.applyOnLayout(self.collectionView?.collectionViewLayout as? UICollectionViewFlowLayout)
        
        viewModel.displayable.contentOffset.asObservable().subscribeNext { (offset) -> Void in
            self.scrollOffset.value = offset
        }.addDisposableTo(disposeBag)
    }
    
    func setupDataSource() {
        if let collection = self.collectionView {
            
            viewModel.displayable.applyOnLayout(collection.collectionViewLayout as? UICollectionViewFlowLayout)
            
            retry.asObservable()
                .filter({ (reload) -> Bool in
                    return reload
                })
                .flatMap({ reload in
                    return self.viewModel.dataSource
                })
                .bindTo((collection.rx_itemsWithCellIdentifier(viewModel.cellReuseIdentifier(), cellType: SHShoutItemCell.self))) { (item, element, cell) in
                    cell.shoutTitle.text = element.title
                    cell.name.text = element.text
                    cell.shoutPrice.text = "\(element.price) $"
                
                    if let thumbPath = element.thumbnailPath, thumbURL = NSURL(string: thumbPath) {
                        cell.shoutImage.kf_setImageWithURL(thumbURL, placeholderImage: UIImage(named:"auth_screen_bg_pattern"))
                    }
                
                }.addDisposableTo(disposeBag)
            
        }
    }
}
