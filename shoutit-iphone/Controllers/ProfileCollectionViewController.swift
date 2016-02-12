//
//  ProfileCollectionViewController.swift
//  shoutit-iphone
//
//  Created by Łukasz Kasperek on 11.02.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import UIKit

class ProfileCollectionViewController: UICollectionViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        registerReusables()
    }
    
    // MARK: - Setup
    
    private func registerReusables() {
        
        // reguster cells
        collectionView?.registerNib(UINib(nibName: NSStringFromClass(PagesCollectionViewCell.self), bundle: nil), forCellWithReuseIdentifier: ProfileCollectionViewCellKind.Pages.rawValue)
        collectionView?.registerNib(UINib(nibName: NSStringFromClass(ShoutsCollectionViewCell.self), bundle: nil), forCellWithReuseIdentifier: ProfileCollectionViewCellKind.Shouts.rawValue)
        
        // register supplementsry views
        collectionView?.registerNib(UINib(nibName: NSStringFromClass(ProfileCollectionCoverSupplementaryView.self), bundle: nil), forSupplementaryViewOfKind: ProfileCollectionViewSupplementaryViewKind.Cover.rawValue, withReuseIdentifier: ProfileCollectionViewSupplementaryViewKind.Cover.rawValue)
        collectionView?.registerNib(UINib(nibName: NSStringFromClass(ProfileCollectionInfoSupplementaryView.self), bundle: nil), forSupplementaryViewOfKind: ProfileCollectionViewSupplementaryViewKind.Info.rawValue, withReuseIdentifier: ProfileCollectionViewSupplementaryViewKind.Info.rawValue)
        collectionView?.registerNib(UINib(nibName: NSStringFromClass(ProfileCollectionSectionHeaderSupplementaryView.self), bundle: nil), forSupplementaryViewOfKind: ProfileCollectionViewSupplementaryViewKind.SectionHeader.rawValue, withReuseIdentifier: ProfileCollectionViewSupplementaryViewKind.SectionHeader.rawValue)
    }
}
