//
//  DiscoverPreviewCollectionViewController.swift
//  shoutit-iphone
//
//  Created by Piotr Bernad on 12/02/16.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import UIKit
import RxSwift
import Kingfisher

class DiscoverPreviewCollectionViewController: UICollectionViewController {
    
    let viewModel = DiscoverPreviewViewModel()
    
    private let disposeBag = DisposeBag()
        
    override func viewDidLoad() {
        super.viewDidLoad()

        if let collection = self.collectionView {
            
            viewModel.displayable.applyOnLayout(collection.collectionViewLayout as? UICollectionViewFlowLayout)
            
            viewModel.dataSource!.bindTo((collection.rx_itemsWithCellIdentifier(viewModel.cellReuseIdentifier(), cellType: SHShoutItemCell.self))) { (item, element, cell) in
                cell.shoutTitle.text = element.title
                print(element.image)
                cell.shoutImage.kf_setImageWithURL(NSURL(string: element.image)!, placeholderImage: UIImage(named:"auth_screen_bg_pattern"))
            }.addDisposableTo(disposeBag)
        }
        
        
        
    }
    
    // MARK: UICollectionViewDataSource

    override func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }


    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 10
    }

    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(viewModel.cellReuseIdentifier(), forIndexPath: indexPath)
    
        // Configure the cell
    
        return cell
    }

}
