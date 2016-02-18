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
    
    // consts
    private let placeholderCellReuseIdentier = "PlaceholderCollectionViewCellReuseIdentifier"
    
    // view model
    var viewModel: ProfileCollectionViewModelInterface!
    
    // rx
    let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let _ = self.viewModel else {
            fatalError("Pass view model to \(self.self) instance before presenting it")
        }
        
        if let layout = collectionView?.collectionViewLayout as? ProfileCollectionViewLayout {
            layout.delegate = viewModel
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
        collectionView?.registerNib(UINib(nibName: "PlaceholderCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: placeholderCellReuseIdentier)
        
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
            return max(1, viewModel.pagesSection.cells.count)
        case 1:
            return max(1, viewModel.shoutsSection.cells.count)
        default:
            assert(false)
            return 0
        }
    }
    
    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        if !viewModel.hasContentToDisplayInSection(indexPath.section) {
            let cell = collectionView.dequeueReusableCellWithReuseIdentifier(placeholderCellReuseIdentier, forIndexPath: indexPath) as! PlcaholderCollectionViewCell
            if indexPath.section == ProfileCollectionViewSection.Pages.rawValue {
                cell.placeholderTextLabel.text = NSLocalizedString("No pages available yet", comment: "")
            } else if indexPath.section == ProfileCollectionViewSection.Shouts.rawValue {
                cell.placeholderTextLabel.text = NSLocalizedString("No shouts available yet", comment: "")
            }
            return cell
        }
        
        if indexPath.section == ProfileCollectionViewSection.Pages.rawValue {
            let cell = collectionView.dequeueReusableCellWithReuseIdentifier(ProfileCollectionViewSection.Pages.cellReuseIdentifier, forIndexPath: indexPath) as! PagesCollectionViewCell
            let cellViewModel = viewModel.pagesSection.cells[indexPath.row] as! ProfileCollectionPageCellViewModel
            
            cell.nameLabel.text = cellViewModel.profile.name
            cell.listenersCountLabel.text = cellViewModel.listeningCountString()
            cell.thumnailImageView.sh_setImageWithURL(cellViewModel.profile.imagePath?.toURL(), placeholderImage: nil)
            let listenButtonImage = cellViewModel.profile.listening == true ? UIImage.profileStopListeningIcon() : UIImage.profileListenIcon()
            cell.listenButton.setImage(listenButtonImage, forState: .Normal)
            
            return cell
        }
            
        else if indexPath.section == ProfileCollectionViewSection.Shouts.rawValue {
            let cell = collectionView.dequeueReusableCellWithReuseIdentifier(ProfileCollectionViewSection.Shouts.cellReuseIdentifier, forIndexPath: indexPath) as! ShoutsCollectionViewCell
            let cellViewModel = viewModel.shoutsSection.cells[indexPath.row] as! ProfileCollectionShoutCellViewModel
            
            cell.titleLabel.text = cellViewModel.shout.title
            cell.subtitleLabel.text = cellViewModel.shout.text
            cell.imageView.sh_setImageWithURL(cellViewModel.shout.image?.toURL(), placeholderImage: nil)
            cell.priceLabel.text = cellViewModel.priceString()
            
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
            
            // set labels
            coverView.titleLabel.text = viewModel.name
            coverView.subtitleLabel.text = viewModel.username
            
        case .Info:
            
            let infoView = supplementeryView as! ProfileCollectionInfoSupplementaryView
            
            infoView.avatarImageView.sh_setImageWithURL(viewModel.avatarURL, placeholderImage: nil)
            infoView.nameLabel.text = viewModel.name
            infoView.usernameLabel.text = viewModel.username
            if let isListening = viewModel.isListeningToYou where isListening {
                infoView.listeningToYouLabel.hidden = false
            } else {
                infoView.listeningToYouLabel.hidden = true
            }
            infoView.bioLabel.text = viewModel.descriptionText
            infoView.websiteLabel.text = viewModel.websiteString
            infoView.dateJoinedLabel.text = viewModel.dateJoinedString
            infoView.locationLabel.text = viewModel.locationString
            infoView.locationFlagImageView.sh_setImageWithURL(viewModel.locationFlagURL, placeholderImage: nil)
            infoView.setButtons(viewModel.infoButtons)
            
        case .PagesSectionHeader:
            let pagesSectionHeader = supplementeryView as! ProfileCollectionSectionHeaderSupplementaryView
            pagesSectionHeader.titleLabel.text = viewModel.pagesSection.title
        case .CreatePageButtonFooter:
            let createPageButtonFooter = supplementeryView as! ProfileCollectionFooterButtonSupplementeryView
            createPageButtonFooter.type = viewModel.pagesSection.footerButtonStyle
            createPageButtonFooter.button.setTitle(viewModel.pagesSection.footerButtonTitle, forState: .Normal)
        case .ShoutsSectionHeader:
            let shoutsSectionHeader = supplementeryView as! ProfileCollectionSectionHeaderSupplementaryView
            shoutsSectionHeader.titleLabel.text = viewModel.shoutsSection.title
        case .SeeAllShoutsButtonFooter:
            let seeAllShoutsFooter = supplementeryView as! ProfileCollectionFooterButtonSupplementeryView
            seeAllShoutsFooter.type = viewModel.shoutsSection.footerButtonStyle
            seeAllShoutsFooter.button.setTitle(viewModel.shoutsSection.footerButtonTitle, forState: .Normal)
        }
        
        return supplementeryView
    }
}
