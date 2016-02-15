//
//  ProfileCollectionViewController.swift
//  shoutit-iphone
//
//  Created by Łukasz Kasperek on 11.02.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import UIKit

class ProfileCollectionViewController: UICollectionViewController {
    
    private var dataSource: ProfileCollectionViewControllerDataSource! {
        didSet {
            self.collectionView?.dataSource = dataSource
        }
    }
    var viewModel: ProfileCollectionViewModel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let viewModel = self.viewModel else {
            fatalError("Pass view model to \(self.self) instance before presenting it")
        }
        
        navigationController?.navigationBarHidden = true
        
        dataSource = ProfileCollectionViewControllerDataSource(viewModel: viewModel)
        registerReusables()
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
