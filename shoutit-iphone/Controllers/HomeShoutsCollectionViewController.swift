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
    var items : [Shout] = []
    
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
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(viewModel.cellReuseIdentifier(), forIndexPath: indexPath) as! SHShoutItemCell
    
        let element = items[indexPath.item]
        
        cell.shoutTitle.text = element.title
        cell.name.text = element.text
        cell.shoutPrice.text = "$\(element.price)"
        cell.shoutCountryImage.image = UIImage(named:  element.location.country)
        
        if let categoryIcon = element.category.icon {
            cell.shoutCategoryImage.sh_setImageWithURL(NSURL(string: categoryIcon), placeholderImage: nil)
        }
        
        if let thumbPath = element.image, thumbURL = NSURL(string: thumbPath) {
            cell.shoutImage.sh_setImageWithURL(thumbURL, placeholderImage: UIImage(named:"auth_screen_bg_pattern"))
        }
    
        return cell
    }
    
    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.items.count
    }
    
    override func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
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
                .flatMap({ [weak self] (reload) -> Observable<[Shout]> in
                    return (self?.viewModel.dataSource!)!
                }).subscribeNext({ [weak self] (shouts) -> Void in
                    self?.items = shouts
                    self?.collectionView?.reloadData()
                }).addDisposableTo(disposeBag)
        }
    }
}
