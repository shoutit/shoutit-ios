//
//  PublicChatsPreviewComponent.swift
//  shoutit
//
//  Created by Piotr Bernad on 05.09.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import UIKit
import RxSwift

class PublicChatsPreviewComponent: BasicComponent {
    let viewModel = PublicChatsListViewModel()
    
    private let disposeBag = DisposeBag()
    
    
    lazy var collectionView : UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        
        let collection = AutoInstrictSizeCollectionView(frame: CGRectZero, collectionViewLayout: layout)
        
        layout.scrollDirection = .Vertical
        
        collection.dataSource = self
        collection.backgroundColor = UIColor.whiteColor()
        collection.delegate = self
        collection.scrollEnabled = false
        
        collection.setContentCompressionResistancePriority(1000, forAxis: .Vertical)
        
        collection.register(PublicChatCollectionViewCell)
        
        collection.invalidateIntrinsicContentSize()
        
        return collection
    }()
    
    override init() {
        super.init()
        
        viewModel.pager.state.asDriver().driveNext { (state) in
            print(state)
            self.collectionView.reloadData()
        }.addDisposableTo(disposeBag)
    }
    
    override func loadContent() {
        viewModel.pager.refreshContent()
    }
    
    override func refreshContent() {
        viewModel.pager.refreshContent()
    }
}

extension PublicChatsPreviewComponent : ComponentStackViewRepresentable {
    func stackViewRepresentation() -> [UIView] {
        return [self.collectionView]
    }
}

extension PublicChatsPreviewComponent : UICollectionViewDataSource {
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.viewModel.pager.getCellViewModels()?.count ?? 0
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        let cell : PublicChatCollectionViewCell = collectionView.dequeueReusableCell(forIndexPath: indexPath)
        
        guard let models = viewModel.pager.getCellViewModels() else { preconditionFailure() }
        
        let conversation = models[indexPath.row]
        
        cell.bindWithConversation(conversation)
        
        return cell
    }
}
extension PublicChatsPreviewComponent : UICollectionViewDelegate {
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        let width = collectionView.bounds.width - 2 * 10.0
        
        return CGSizeMake(width, 60.0)
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAtIndex section: Int) -> CGFloat {
        return 0.0
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAtIndex section: Int) -> UIEdgeInsets {
        return UIEdgeInsetsMake(10.0, 10.0, 10.0, 10.0)
    }
}