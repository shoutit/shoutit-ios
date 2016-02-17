//
//  ProfileCollectionViewController.swift
//  shoutit-iphone
//
//  Created by Łukasz Kasperek on 11.02.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import Kingfisher

class ProfileCollectionViewController: UICollectionViewController {
    
    // view model
    var viewModel: ProfileCollectionViewModelInterface!
    
    // rx
    let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let _ = self.viewModel else {
            fatalError("Pass view model to \(self.self) instance before presenting it")
        }
        
        registerReusables()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBarHidden = true
    }
    
    // MARK: - Setup
    
    private func registerReusables() {
        
        // reguster cells
        collectionView?.registerNib(UINib(nibName: "PagesCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: ProfileCollectionViewSection.Pages.cellReuseIdentifier)
        collectionView?.registerNib(UINib(nibName: "ShoutsCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: ProfileCollectionViewSection.Shouts.cellReuseIdentifier)
        
        // register supplementsry views
        collectionView?.registerNib(UINib(nibName: "ProfileCollectionCoverSupplementaryView", bundle: nil), forSupplementaryViewOfKind: ProfileCollectionViewSupplementaryViewKind.Cover.rawValue, withReuseIdentifier: ProfileCollectionViewSupplementaryViewKind.Cover.rawValue)
        collectionView?.registerNib(UINib(nibName: "ProfileCollectionInfoSupplementaryView", bundle: nil), forSupplementaryViewOfKind: ProfileCollectionViewSupplementaryViewKind.Info.rawValue, withReuseIdentifier: ProfileCollectionViewSupplementaryViewKind.Info.rawValue)
        collectionView?.registerNib(UINib(nibName: "ProfileCollectionSectionHeaderSupplementaryView", bundle: nil), forSupplementaryViewOfKind: ProfileCollectionViewSupplementaryViewKind.SectionHeader.rawValue, withReuseIdentifier: ProfileCollectionViewSupplementaryViewKind.SectionHeader.rawValue)
        collectionView?.registerNib(UINib(nibName: "ProfileCollectionFooterButtonSupplementeryView", bundle: nil), forSupplementaryViewOfKind: ProfileCollectionViewSupplementaryViewKind.FooterButton.rawValue, withReuseIdentifier: ProfileCollectionViewSupplementaryViewKind.FooterButton.rawValue)
    }
}

// MARK: - UICollectionViewDataSource

extension ProfileCollectionViewController {
    
    override func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 2
    }
    
    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        switch section {
        case 0:
            return 1//viewModel.pages.count
        case 1:
            return 1//viewModel.shouts.count
        default:
            assert(false)
            return 0
        }
    }
    
    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        if indexPath.section == ProfileCollectionViewSection.Pages.rawValue {
            let cell = collectionView.dequeueReusableCellWithReuseIdentifier(ProfileCollectionViewSection.Pages.cellReuseIdentifier, forIndexPath: indexPath)
            return cell
        }
            
        else if indexPath.section == ProfileCollectionViewSection.Shouts.rawValue {
            let cell = collectionView.dequeueReusableCellWithReuseIdentifier(ProfileCollectionViewSection.Shouts.cellReuseIdentifier, forIndexPath: indexPath)
            return cell
        }
        
        fatalError()
    }
    
    override func collectionView(collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, atIndexPath indexPath: NSIndexPath) -> UICollectionReusableView {
        
        guard let view = ProfileCollectionViewSupplementaryView(indexPath: indexPath) else {
            fatalError("Unexpected supplementery view index path")
        }
        
        let supplementeryView = collectionView.dequeueReusableSupplementaryViewOfKind(kind, withReuseIdentifier: view.kind.rawValue, forIndexPath: indexPath)
        
        switch view {
        case .Cover:
            
            let coverView = supplementeryView as! ProfileCollectionCoverSupplementaryView
            
            // setup navigation bar buttons
            coverView.menuButton
                .rx_tap
                .subscribeNext{[unowned self] in
                    self.toggleMenu()
                }
                .addDisposableTo(disposeBag)
            if let navigationController = navigationController where self === navigationController.viewControllers[0] {
                coverView.setBackButtonHidden(true)
            } else {
                coverView.backButton
                    .rx_tap
                    .subscribeNext{[unowned self] in
                        self.navigationController?.popViewControllerAnimated(true)
                    }
                    .addDisposableTo(disposeBag)
            }
            
            // setup cover image
            
            coverView.imageView.sh_setImageWithURL(viewModel.coverURL, placeholderImage: UIImage.profileCoverPlaceholder(), optionsInfo: nil, completionHandler: {[weak cover = coverView] (image, _, _, _) in
                if let image = image {
                    cover?.blurredImageView.image = image
                } else {
                    cover?.blurredImageView.image = UIImage.profileCoverPlaceholder()
                }
            })
        case .Info:
            let infoView = supplementeryView as! ProfileCollectionInfoSupplementaryView
            infoView.setButtons(viewModel.infoButtons)
        case .PagesSectionHeader:
            break
        case .CreatePageButtonFooter:
            break
        case .ShoutsSectionHeader:
            break
        case .SeeAllShoutsButtonFooter:
            break
            
        }
        
        return supplementeryView
    }
}
