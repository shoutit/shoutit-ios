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

protocol ProfileCollectionViewControllerFlowDelegate: class, CreateShoutDisplayable, AllShoutsDisplayable, CartDisplayable, SearchDisplayable, ShoutDisplayable, PageDisplayable {
    func performActionForButtonType(type: ProfileCollectionInfoButton) -> Void
}

class ProfileCollectionViewController: UICollectionViewController {
    
    // consts
    private let placeholderCellReuseIdentier = "PlaceholderCollectionViewCellReuseIdentifier"
    
    // view model
    var viewModel: ProfileCollectionViewModelInterface!
    
    // navigation
    weak var flowDelegate: ProfileCollectionViewControllerFlowDelegate?
    
    // rx
    let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let viewModel = self.viewModel else {
            fatalError("Pass view model to \(self.self) instance before presenting it")
        }
        
        if let layout = collectionView?.collectionViewLayout as? ProfileCollectionViewLayout {
            layout.delegate = viewModel
        }
        
        viewModel.reloadSubject
            .throttle(0.5, scheduler: MainScheduler.instance)
            .subscribeNext {[weak self] in
                self?.collectionView?.reloadData()
            }
            .addDisposableTo(disposeBag)
        
        registerReusables()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBarHidden = true
        viewModel.reloadContent()
    }
    
    // MARK: - Setup
    
    private func registerReusables() {
        
        // register cells
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

// MARK: - UICollectionViewDelegate

extension ProfileCollectionViewController {
    
    override func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        
        switch indexPath.section {
        case 0:
            let page = viewModel.pagesSection.cells[indexPath.row].profile
            flowDelegate?.showPage(page)
        case 1:
            let shout = viewModel.shoutsSection.cells[indexPath.row].shout
            flowDelegate?.showShout(shout)
        default:
            assert(false)
        }
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
            let errorMessage = indexPath.section == 0 ? viewModel.pagesSection.errorMessage : viewModel.shoutsSection.errorMessage
            let noContentMessage = indexPath.section == 0 ? viewModel.pagesSection.noContentMessage : viewModel.shoutsSection.noContentMessage
            cell.placeholderTextLabel.text = errorMessage ?? noContentMessage
            return cell
        }
        
        if indexPath.section == ProfileCollectionViewSection.Pages.rawValue {
            let cell = collectionView.dequeueReusableCellWithReuseIdentifier(ProfileCollectionViewSection.Pages.cellReuseIdentifier, forIndexPath: indexPath) as! PagesCollectionViewCell
            let cellViewModel = viewModel.pagesSection.cells[indexPath.row]
            
            cell.nameLabel.text = cellViewModel.profile.name
            cell.listenersCountLabel.text = cellViewModel.listeningCountString()
            cell.thumnailImageView.sh_setImageWithURL(cellViewModel.profile.imagePath?.toURL(), placeholderImage: UIImage(named: "image_placeholder"))
            let listenButtonImage = cellViewModel.profile.listening == true ? UIImage.profileStopListeningIcon() : UIImage.profileListenIcon()
            cell.listenButton.setImage(listenButtonImage, forState: .Normal)
            cell.reuseDisposeBag = DisposeBag()
            cell.listenButton.rx_tap.asDriver().driveNext {
                
            }.addDisposableTo(cell.reuseDisposeBag!)
            
            return cell
        }
            
        else if indexPath.section == ProfileCollectionViewSection.Shouts.rawValue {
            let cell = collectionView.dequeueReusableCellWithReuseIdentifier(ProfileCollectionViewSection.Shouts.cellReuseIdentifier, forIndexPath: indexPath) as! ShoutsCollectionViewCell
            let cellViewModel = viewModel.shoutsSection.cells[indexPath.row]
            
            cell.titleLabel.text = cellViewModel.shout.title
            cell.subtitleLabel.text = cellViewModel.shout.text
            cell.imageView.sh_setImageWithURL(cellViewModel.shout.thumbnailPath?.toURL(), placeholderImage: UIImage.shoutsPlaceholderImage())
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
            
            coverView.cartButton
                .rx_tap
                .subscribeNext{[unowned self] in
                    self.flowDelegate?.showCart()
                }
                .addDisposableTo(disposeBag)
            
            coverView
                .searchButton
                .rx_tap
                .subscribeNext{[unowned self] in
                    self.flowDelegate?.showSearch()
                }
                .addDisposableTo(disposeBag)
            
            
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
            
            infoView.avatarImageView.sh_setImageWithURL(viewModel.avatarURL, placeholderImage: UIImage.squareAvatarPlaceholder())
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
            infoView.locationFlagImageView.image = viewModel.locationFlag
            setButtons(viewModel.infoButtons, inSupplementaryView: infoView)
            
            // adjust constraints for data
            let layout = collectionView.collectionViewLayout as! ProfileCollectionViewLayout
            let descriptionSectionHeight = layout.descriptionViewHeightForText(viewModel.descriptionText)
            infoView.bioSectionHeightConstrait.constant = descriptionSectionHeight
            let texts: [String?] = [viewModel.websiteString, viewModel.dateJoinedString, viewModel.locationString]
            let constraints: [NSLayoutConstraint] = [infoView.websiteSectionHeightConstraint, infoView.dateJoinedSectionHeightConstraint, infoView.locationSectionHeightConstraint]
            for index in 0..<texts.count {
                let text = texts[index]
                let constraint = constraints[index]
                if text == nil || text!.isEmpty {
                    constraint.constant = 0
                }
            }
            
        case .PagesSectionHeader:
            let pagesSectionHeader = supplementeryView as! ProfileCollectionSectionHeaderSupplementaryView
            pagesSectionHeader.titleLabel.text = viewModel.pagesSection.title
        case .CreatePageButtonFooter:
            let createPageButtonFooter = supplementeryView as! ProfileCollectionFooterButtonSupplementeryView
            createPageButtonFooter.type = viewModel.pagesSection.footerButtonStyle
            createPageButtonFooter.button.setTitle(viewModel.pagesSection.footerButtonTitle, forState: .Normal)
            createPageButtonFooter.button
                .rx_tap
                .subscribeNext {[unowned self] in
                    self.flowDelegate?.showCreateShout()
                }
                .addDisposableTo(disposeBag)
        case .ShoutsSectionHeader:
            let shoutsSectionHeader = supplementeryView as! ProfileCollectionSectionHeaderSupplementaryView
            shoutsSectionHeader.titleLabel.text = viewModel.shoutsSection.title
        case .SeeAllShoutsButtonFooter:
            let seeAllShoutsFooter = supplementeryView as! ProfileCollectionFooterButtonSupplementeryView
            seeAllShoutsFooter.type = viewModel.shoutsSection.footerButtonStyle
            seeAllShoutsFooter.button.setTitle(viewModel.shoutsSection.footerButtonTitle, forState: .Normal)
            seeAllShoutsFooter.button
                .rx_tap
                .subscribeNext{[unowned self] in
                    guard let username = self.viewModel.username else {return}
                    self.flowDelegate?.showShoutsForUsername(username)
                }
                .addDisposableTo(disposeBag)
        }
        
        return supplementeryView
    }
}

// MARK: - Info supplementary view hydration

extension ProfileCollectionViewController {
    
    func setButtons(buttons:[ProfileCollectionInfoButton], inSupplementaryView sView: ProfileCollectionInfoSupplementaryView) {
        
        for button in buttons {
            switch button.defaultPosition {
            case .SmallLeft:
                hydrateButton(sView.notificationButton, withButtonModel: button)
            case .SmallRight:
                hydrateButton(sView.rightmostButton, withButtonModel: button)
            case .BigLeft:
                hydrateButton(sView.buttonSectionLeftButton, withButtonModel: button)
            case .BigCenter:
                hydrateButton(sView.buttonSectionCenterButton, withButtonModel: button)
            case .BigRight:
                hydrateButton(sView.buttonSectionRightButton, withButtonModel: button)
            }
        }
    }
    
    private func hydrateButton(button: UIButton, withButtonModel buttonModel: ProfileCollectionInfoButton) {
        
        if case .HiddenButton = buttonModel {
            button.hidden = true
            return
        }
        
        button
            .rx_tap
            .subscribeNext{[unowned self] in
                self.flowDelegate?.performActionForButtonType(buttonModel)
            }
            .addDisposableTo(disposeBag)
        
        if let button = button as? ProfileInfoHeaderButton {
            button.setTitleText(buttonModel.title)
            button.setImage(buttonModel.image)
            
            if case .Listeners(let countString) = buttonModel {
                button.setCountText(countString)
            } else if case .Listening(let countString) = buttonModel {
                button.setCountText(countString)
            } else if case .Interests(let countString) = buttonModel {
                button.setCountText(countString)
            }
        } else {
            button.setImage(buttonModel.image, forState: .Normal)
        }
    }
}
