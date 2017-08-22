//
//  PageCategoriesCollectionViewController.swift
//  shoutit
//
//  Created by Piotr Bernad on 27/06/16.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import UIKit
import ShoutitKit
import RxSwift

class PageCategoriesCollectionViewController: UICollectionViewController {

    fileprivate let  disposeBag = DisposeBag()
    fileprivate var categories : [PageCategory]?
    
    let selectedCategory : PublishSubject<PageCategory> = PublishSubject()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        fetchCategories()
    }
    
    func fetchCategories() {
        APIPageService.getPageCategories().subscribeNext { [weak self] (categories) in
            self?.categories = categories
            self?.collectionView?.reloadData()
        }.addDisposableTo(disposeBag)
        
    }
    
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return (self.categories != nil) ? self.categories!.count : 0
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell : PageCategoryCell = collectionView.dequeueReusableCell(withReuseIdentifier: "PageCategoryCell", for: indexPath) as! PageCategoryCell
        
        guard let category = categories?[indexPath.item] else {
            return cell
        }
        
        cell.bindWithCategory(category)
        
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let category = categories?[indexPath.item] else {
            return
        }
        
        selectedCategory.onNext(category)
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: IndexPath) -> CGSize {
        let width = (collectionView.frame.width - 3 * 20.0)/2.0
        return CGSize(width: width, height: width)
    }
    
}
