//
//  ShoutsComponent.swift
//  shoutit
//
//  Created by Piotr Bernad on 01.09.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import UIKit
import RxSwift

class ShoutsComponent : BasicComponent {
    
    private let disposeBag = DisposeBag()
    
    let context : ShoutsContext
    
    init(context: ShoutsContext) {
        self.context = context
    }
    
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
        let vm = ShoutsCollectionViewModel(context: self.context)
        
        vm.pager.state
            .asDriver()
            .driveNext {[weak self] (state) in
                print("STATE CHANGED: \(state)")
                
                self?.sectionHeader.leftLabel.text = vm.sectionTitle()
                
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

extension ShoutsComponent : ComponentStackViewRepresentable {
    func stackViewRepresentation() -> [UIView] {
        return [self.sectionHeader, self.collectionView]
    }
}

extension ShoutsComponent : UICollectionViewDataSource {
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
        
        
        switch viewModel.pager.state.value {
        case .Idle:
            fatalError()
        case .Error(let error):
            return cell
        //            return placeholderCellWithMessage(message: error.sh_message, activityIndicator: false)
        case .NoContent:
            return cell
        //            return placeholderCellWithMessage(message: self.viewModel.noContentMessage(), activityIndicator: false)
        case .Loading:
            return cell
        //            return placeholderCellWithMessage(message: nil, activityIndicator: true)
        default:
            let cellViewModel = self.viewModel.pager.shoutCellViewModels()[indexPath.row]
            
            if let shout = cellViewModel.shout {
                cell.bindWithShout(shout)
            } else if let ad = cellViewModel.ad {
                cell.bindWithAd(ad)
            }
            
            return cell
        }
        
    }
}

extension ShoutsComponent : UICollectionViewDelegateFlowLayout {
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