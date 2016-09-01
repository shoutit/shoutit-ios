//
//  HomeShoutsComponent.swift
//  shoutit
//
//  Created by Piotr Bernad on 30/08/16.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import Foundation
import RxSwift

class HomeShoutsComponent : BasicComponent {
    
    private let disposeBag = DisposeBag()
    
    lazy var sectionHeader : HomeSectionHeader = {
        let header = HomeSectionHeader.instanceFromNib()
        
        header.backgroundColor = UIColor.whiteColor()
        
        return header
    }()
    
    lazy var collectionView : UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        
        let collection = AutoInstrictSizeCollectionView(frame: CGRectZero, collectionViewLayout: layout)
        
        layout.scrollDirection = .Vertical
        
        collection.dataSource = self
        collection.backgroundColor = UIColor.whiteColor()
        collection.delegate = self
        collection.scrollEnabled = false
        
        collection.setContentCompressionResistancePriority(1000, forAxis: .Vertical)
        
        collection.register(ShoutCardCollectionViewCell)
        
        collection.invalidateIntrinsicContentSize()
        
        return collection
    }()
    
    lazy var viewModel : ShoutsCollectionViewModel = {
        let vm = ShoutsCollectionViewModel(context: .HomeShouts)
        
        vm.pager.state
            .asDriver()
            .driveNext {[weak self] (state) in
                print("STATE CHANGED: \(state)")
                self?.collectionView.reloadData()
                self?.collectionView.invalidateIntrinsicContentSize()
                switch state {
                case .Idle:
                    self?.isLoaded = false
                    self?.isLoading = false
                case .Loading:
                    self?.isLoaded = false
                    self?.isLoading = true
                case .Refreshing:
                    self?.isLoaded = false
                    self?.isLoading = true
                case .Loaded:
                    self?.isLoaded = true
                    self?.isLoading = false
                case .NoContent:
                    self?.isLoaded = true
                    self?.isLoading = false
                case .Error:
                    self?.isLoaded = true
                    self?.isLoading = false
                case .LoadingMore:
                    self?.isLoaded = true
                    self?.isLoading = true
                case .LoadedAllContent:
                    self?.isLoaded = true
                    self?.isLoading = false
                }
            }
            .addDisposableTo(self.disposeBag)
        
        return vm
    }()
    
    override func loadContent() {
        self.viewModel.reloadContent()
    }
    
    override func refreshContent() {
        self.viewModel.reloadContent()
    }
}

extension HomeShoutsComponent : ComponentStackViewRepresentable {
    func stackViewRepresentation() -> [UIView] {
        return [self.sectionHeader, self.collectionView]
    }
}

extension HomeShoutsComponent : UICollectionViewDataSource {
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch viewModel.pager.state.value {
        case .Idle:
            return 0
        case .Error, .NoContent, .Loading:
            return 0
        default:
            return self.viewModel.pager.shoutCellViewModels().count
        }
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell : ShoutCardCollectionViewCell = collectionView.dequeueReusableCell(forIndexPath: indexPath)
        
        return cell
    }
}

extension HomeShoutsComponent : UICollectionViewDelegateFlowLayout {
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        let width = (collectionView.bounds.width - 3 * 10.0) * 0.5
        
        return CGSizeMake(width, width * 1.5)
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAtIndex section: Int) -> CGFloat {
        return 10.0
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAtIndex section: Int) -> CGFloat {
        return 10.0
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAtIndex section: Int) -> UIEdgeInsets {
        return UIEdgeInsetsMake(10.0, 10.0, 10.0, 10.0)
    }
}