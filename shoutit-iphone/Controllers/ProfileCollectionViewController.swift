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

protocol ProfileCollectionViewControllerFlowDelegate: class, CreateShoutDisplayable, AllShoutsDisplayable, CartDisplayable, SearchDisplayable, ShoutDisplayable, PageDisplayable, EditProfileDisplayable, ProfileDisplayable, TagDisplayable, NotificationsDisplayable {}

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
        viewModel.reloadContent()
    }
    
    override func prefersNavigationBarHidden() -> Bool {
        return true
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
            if indexPath.row > viewModel.listSection.cells.count - 1 {
                return
            }
            
            switch viewModel.listSection.cells[indexPath.row].model {
            case .TagModel(let tag):
                flowDelegate?.showTag(tag)
            case .ProfileModel(let profile):
                switch profile.type {
                case .Page:
                    flowDelegate?.showPage(profile)
                case .User:
                    flowDelegate?.showProfile(profile)
                }
            }
        case 1:
            if indexPath.row > viewModel.gridSection.cells.count - 1 {
                return
            }
            let shout = viewModel.gridSection.cells[indexPath.row].shout
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
        
        switch viewModel.sectionContentModeForSection(section) {
        case .Default:
            if section == 0 {
                return viewModel.listSection.cells.count
            } else if section == 1 {
                return viewModel.gridSection.cells.count
            } else {
                assert(false)
                return 0
            }
        case .Placeholder:
            return 1
        case .Hidden:
            return 0
        }
    }
    
    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        if case ProfileCollectionSectionContentMode.Placeholder = viewModel.sectionContentModeForSection(indexPath.section) {
            let cell = collectionView.dequeueReusableCellWithReuseIdentifier(placeholderCellReuseIdentier, forIndexPath: indexPath) as! PlcaholderCollectionViewCell
            let isLoading = indexPath.section == 0 ? viewModel.listSection.isLoading : viewModel.gridSection.isLoading
            cell.setupCellForActivityIndicator(isLoading)
            let errorMessage = indexPath.section == 0 ? viewModel.listSection.errorMessage : viewModel.gridSection.errorMessage
            let noContentMessage = indexPath.section == 0 ? viewModel.listSection.noContentMessage : viewModel.gridSection.noContentMessage
            cell.placeholderTextLabel.text = errorMessage ?? noContentMessage
            
            return cell
        }
        
        if indexPath.section == ProfileCollectionViewSection.Pages.rawValue {
            let cell = collectionView.dequeueReusableCellWithReuseIdentifier(ProfileCollectionViewSection.Pages.cellReuseIdentifier, forIndexPath: indexPath) as! PagesCollectionViewCell
            let cellViewModel = viewModel.listSection.cells[indexPath.row]
            
            cell.nameLabel.text = cellViewModel.name()
            cell.listenersCountLabel.text = cellViewModel.listeningCountString()
            cell.thumnailImageView.sh_setImageWithURL(cellViewModel.thumbnailURL(), placeholderImage: UIImage(named: "image_placeholder"))
            let listenButtonImage = cellViewModel.isListening ? UIImage.profileStopListeningIcon() : UIImage.profileListenIcon()
            cell.listenButton.setImage(listenButtonImage, forState: .Normal)
            cell.listenButton.hidden = cellViewModel.hidesListeningButton()
            
            cell.listenButton.rx_tap.asDriver().driveNext {[weak self, weak cellViewModel] in
                cellViewModel?.toggleIsListening().observeOn(MainScheduler.instance).subscribe({[weak cell] (event) in
                    switch event {
                    case .Next(let listening):
                        let listenButtonImage = listening ? UIImage.profileStopListeningIcon() : UIImage.profileListenIcon()
                        cell?.listenButton.setImage(listenButtonImage, forState: .Normal)
                    case .Completed:
                        self?.viewModel.reloadContent()
                    default:
                        break
                    }
                }).addDisposableTo(cell.reuseDisposeBag)
            }.addDisposableTo(cell.reuseDisposeBag)
            
            return cell
        }
            
        else if indexPath.section == ProfileCollectionViewSection.Shouts.rawValue {
            let cell = collectionView.dequeueReusableCellWithReuseIdentifier(ProfileCollectionViewSection.Shouts.cellReuseIdentifier, forIndexPath: indexPath) as! ShoutsCollectionViewCell
            let cellViewModel = viewModel.gridSection.cells[indexPath.row]
            
            cell.titleLabel.text = cellViewModel.shout.title
            cell.subtitleLabel.text = cellViewModel.shout.user.name
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
                .addDisposableTo(coverView.reuseDisposeBag)
            
            if let navigationController = navigationController where self === navigationController.viewControllers[0] {
                coverView.setBackButtonHidden(true)
            } else {
                coverView.backButton
                    .rx_tap
                    .asDriver()
                    .driveNext{[unowned self] in
                        self.navigationController?.popViewControllerAnimated(true)
                    }
                    .addDisposableTo(coverView.reuseDisposeBag)
            }
            
            coverView.cartButton
                .rx_tap
                .subscribeNext{[unowned self] in
                    self.flowDelegate?.showCart()
                }
                .addDisposableTo(coverView.reuseDisposeBag)
            
            coverView
                .searchButton
                .rx_tap
                .subscribeNext{[unowned self] in
                    guard let model = self.viewModel.model else { return }
                    switch model {
                    case .TagModel(let tag):
                        self.flowDelegate?.showSearchInContext(.TagShouts(tag: tag))
                    case .ProfileModel(let profile):
                        self.flowDelegate?.showSearchInContext(.ProfileShouts(profile: profile))
                    }
                }
                .addDisposableTo(coverView.reuseDisposeBag)
            
            
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
            infoView.reuseDisposeBag = DisposeBag()
            
            switch viewModel.avatar {
            case .Local(let image):
                infoView.avatarImageView.contentMode = .Center
                infoView.avatarImageView.image = image
            case .Remote(let url):
                infoView.avatarImageView.contentMode = .ScaleAspectFill
                infoView.avatarImageView.sh_setImageWithURL(url, placeholderImage: UIImage.squareAvatarPlaceholder())
            }
            
            infoView.nameLabel.text = viewModel.name
            infoView.usernameLabel.text = viewModel.username
            if let isListening = viewModel.isListeningToYou where isListening {
                infoView.listeningToYouLabel.hidden = false
            } else {
                infoView.listeningToYouLabel.hidden = true
            }
            infoView.bioLabel.text = viewModel.descriptionText
            infoView.bioIconImageView.image = viewModel.descriptionIcon
            infoView.websiteLabel.text = viewModel.websiteString
            infoView.dateJoinedLabel.text = viewModel.dateJoinedString
            infoView.locationLabel.text = viewModel.locationString
            infoView.locationFlagImageView.image = viewModel.locationFlag
            setButtons(viewModel.infoButtons, inSupplementaryView: infoView, disposeBag: infoView.reuseDisposeBag!)
            
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
                } else {
                    constraint.constant = layout.defaultInfoSupplementaryViewSectionHeight
                }
            }
            
        case .ListSectionHeader:
            let listSectionHeader = supplementeryView as! ProfileCollectionSectionHeaderSupplementaryView
            listSectionHeader.titleLabel.text = viewModel.listSection.title
        case .CreatePageButtonFooter:
            let createPageButtonFooter = supplementeryView as! ProfileCollectionFooterButtonSupplementeryView
            createPageButtonFooter.reuseDisposeBag = DisposeBag()
            createPageButtonFooter.type = viewModel.listSection.footerButtonStyle
            createPageButtonFooter.button.setTitle(viewModel.listSection.footerButtonTitle, forState: .Normal)
            createPageButtonFooter.button
                .rx_tap
                .subscribeNext {[unowned self] in
                    self.flowDelegate?.showCreateShout()
                }
                .addDisposableTo(createPageButtonFooter.reuseDisposeBag!)
        case .GridSectionHeader:
            let gridSectionHeader = supplementeryView as! ProfileCollectionSectionHeaderSupplementaryView
            gridSectionHeader.titleLabel.text = viewModel.gridSection.title
        case .SeeAllShoutsButtonFooter:
            let seeAllShoutsFooter = supplementeryView as! ProfileCollectionFooterButtonSupplementeryView
            seeAllShoutsFooter.reuseDisposeBag = DisposeBag()
            seeAllShoutsFooter.type = viewModel.gridSection.footerButtonStyle
            seeAllShoutsFooter.button.setTitle(viewModel.gridSection.footerButtonTitle, forState: .Normal)
            seeAllShoutsFooter.button
                .rx_tap
                .subscribeNext{[unowned self] in
                    guard let username = self.viewModel.username else {return}
                    self.flowDelegate?.showShoutsForUsername(username)
                }
                .addDisposableTo(seeAllShoutsFooter.reuseDisposeBag!)
        }
        
        return supplementeryView
    }
}

// MARK: - Info supplementary view hydration

extension ProfileCollectionViewController {
    
    func setButtons(buttons:[ProfileCollectionInfoButton], inSupplementaryView sView: ProfileCollectionInfoSupplementaryView, disposeBag: DisposeBag) {
        
        for button in buttons {
            switch button.defaultPosition {
            case .SmallLeft:
                hydrateButton(sView.notificationButton, withButtonModel: button, disposeBag: disposeBag)
            case .SmallRight:
                hydrateButton(sView.rightmostButton, withButtonModel: button, disposeBag: disposeBag)
            case .BigLeft:
                hydrateButton(sView.buttonSectionLeftButton, withButtonModel: button, disposeBag: disposeBag)
            case .BigCenter:
                hydrateButton(sView.buttonSectionCenterButton, withButtonModel: button, disposeBag: disposeBag)
            case .BigRight:
                hydrateButton(sView.buttonSectionRightButton, withButtonModel: button, disposeBag: disposeBag)
            }
        }
    }
    
    private func hydrateButton(button: UIButton, withButtonModel buttonModel: ProfileCollectionInfoButton, disposeBag: DisposeBag) {
        
        if case .HiddenButton = buttonModel {
            button.hidden = true
            return
        }
        
        switch buttonModel {
        case .Listen(let isListening):
            if let observable = viewModel.listen() {
                button.rx_tap.flatMapFirst({[weak button] () -> Observable<Void> in
                    if let button = button as? ProfileInfoHeaderButton {
                        let switchedModel = ProfileCollectionInfoButton.Listen(isListening: !isListening)
                        button.setImage(switchedModel.image, countText: nil)
                        button.setTitleText(switchedModel.title)
                    }
                    return observable
                }).subscribeError({[weak button] (_) in
                    if let button = button as? ProfileInfoHeaderButton {
                        button.setImage(buttonModel.image, countText: nil)
                        button.setTitleText(buttonModel.title)
                    }
                }).addDisposableTo(disposeBag)
            }
        case .EditProfile:
            button.rx_tap.asDriver().driveNext{[weak self] in
                self?.flowDelegate?.showEditProfile()
            }.addDisposableTo(disposeBag)
        case .Notification:
            button.rx_tap.asDriver().driveNext{[weak self] in
                self?.flowDelegate?.showNotifications()
                }.addDisposableTo(disposeBag)
        default:
            break
        }
        
        if let button = button as? ProfileInfoHeaderButton {
            button.setTitleText(buttonModel.title)
            
            if case .Listeners(let countString) = buttonModel {
                button.setImage(buttonModel.image, countText: countString)
            } else if case .Listening(let countString) = buttonModel {
                button.setImage(buttonModel.image, countText: countString)
            } else if case .Interests(let countString) = buttonModel {
                button.setImage(buttonModel.image, countText: countString)
            } else {
                button.setImage(buttonModel.image, countText: nil)
            }
        } else {
            button.setImage(buttonModel.image, forState: .Normal)
        }
    }
}
