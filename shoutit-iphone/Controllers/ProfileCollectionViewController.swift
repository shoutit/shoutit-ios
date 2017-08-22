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
import MBProgressHUD
import ShoutitKit

final class ProfileCollectionViewController: UICollectionViewController {
    
    // consts
    fileprivate let placeholderCellReuseIdentier = "PlaceholderCollectionViewCellReuseIdentifier"
    
    // view model
    var viewModel: ProfileCollectionViewModelInterface!
    
    // navigation
    weak var flowDelegate: FlowController?
    
    // rx
    let disposeBag = DisposeBag()
    
    var bookmarksDisposeBag : DisposeBag?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        bookmarksDisposeBag = DisposeBag()
        
        guard let viewModel = self.viewModel else {
            preconditionFailure("Pass view model to \(self.self) instance before presenting it")
        }
        
        if let layout = collectionView?.collectionViewLayout as? ProfileCollectionViewLayout {
            layout.delegate = viewModel
        }
        
        viewModel.reloadSubject
            .debounce(0.5, scheduler: MainScheduler.instance)
            .subscribeNext {[weak self] in
                self?.collectionView?.reloadData()
            }
            .addDisposableTo(disposeBag)
        
        viewModel.successMessageSubject
            .observeOn(MainScheduler.instance)
            .subscribeNext{[weak self] (message) in
                self?.showSuccessMessage(message)
            }
            .addDisposableTo(disposeBag)
        
        registerReusables()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel.reloadContent()
    }
    
    override func prefersNavigationBarHidden() -> Bool {
        return true
    }
    
    override func hasFakeNavigationBar() -> Bool {
        return true
    }
    
    // MARK: - Setup
    
    fileprivate func registerReusables() {
        
        // register cells
        collectionView?.register(UINib(nibName: "PagesCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: ProfileCollectionViewSection.pages.cellReuseIdentifier)
        collectionView?.register(UINib(nibName: "ShoutsCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: ProfileCollectionViewSection.shouts.cellReuseIdentifier)
        collectionView?.register(UINib(nibName: "PlaceholderCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: placeholderCellReuseIdentier)
        
        // register supplementsry views
        collectionView?.register(UINib(nibName: "ProfileCollectionCoverSupplementaryView", bundle: nil), forSupplementaryViewOfKind: ProfileCollectionViewSupplementaryViewKind.Cover.rawValue, withReuseIdentifier: ProfileCollectionViewSupplementaryViewKind.Cover.rawValue)
        collectionView?.register(UINib(nibName: "ProfileCollectionInfoSupplementaryView", bundle: nil), forSupplementaryViewOfKind: ProfileCollectionViewSupplementaryViewKind.Info.rawValue, withReuseIdentifier: ProfileCollectionViewSupplementaryViewKind.Info.rawValue)
        collectionView?.register(UINib(nibName: "ProfileCollectionSectionHeaderSupplementaryView", bundle: nil), forSupplementaryViewOfKind: ProfileCollectionViewSupplementaryViewKind.SectionHeader.rawValue, withReuseIdentifier: ProfileCollectionViewSupplementaryViewKind.SectionHeader.rawValue)
        collectionView?.register(UINib(nibName: "ProfileCollectionFooterButtonSupplementeryView", bundle: nil), forSupplementaryViewOfKind: ProfileCollectionViewSupplementaryViewKind.FooterButton.rawValue, withReuseIdentifier: ProfileCollectionViewSupplementaryViewKind.FooterButton.rawValue)
    }
}

// MARK: - UICollectionViewDelegate

extension ProfileCollectionViewController {
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        switch indexPath.section {
        case 0:
            if indexPath.row > viewModel.listSection.cells.count - 1 {
                return
            }
            
            switch viewModel.listSection.cells[indexPath.row].model {
            case .tagModel(let tag):
                flowDelegate?.showTag(tag)
            case .profileModel(let profile):
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
    
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 2
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        switch viewModel.sectionContentModeForSection(section) {
        case .default:
            if section == 0 {
                return viewModel.listSection.cells.count
            } else if section == 1 {
                return viewModel.gridSection.cells.count
            } else {
                assert(false)
                return 0
            }
        case .placeholder:
            return 1
        case .hidden:
            return 0
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if case ProfileCollectionSectionContentMode.placeholder = viewModel.sectionContentModeForSection(indexPath.section) {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: placeholderCellReuseIdentier, for: indexPath) as! PlcaholderCollectionViewCell
            let isLoading = indexPath.section == 0 ? viewModel.listSection.isLoading : viewModel.gridSection.isLoading
            cell.setupCellForActivityIndicator(isLoading)
            let errorMessage = indexPath.section == 0 ? viewModel.listSection.errorMessage : viewModel.gridSection.errorMessage
            let noContentMessage = indexPath.section == 0 ? viewModel.listSection.noContentMessage : viewModel.gridSection.noContentMessage
            cell.placeholderTextLabel.text = errorMessage ?? noContentMessage
            
            return cell
        }
        
        if indexPath.section == ProfileCollectionViewSection.pages.rawValue {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ProfileCollectionViewSection.pages.cellReuseIdentifier, for: indexPath) as! PagesCollectionViewCell
            let cellViewModel = viewModel.listSection.cells[indexPath.row]
            
            cell.nameLabel.text = cellViewModel.name()
            cell.listenersCountLabel.text = cellViewModel.listeningCountString()
            cell.thumnailImageView.sh_setImageWithURL(cellViewModel.thumbnailURL(), placeholderImage: UIImage.squareAvatarPagePlaceholder())
            let listenButtonImage = cellViewModel.isListening ? UIImage.profileStopListeningIcon() : UIImage.profileListenIcon()
            cell.listenButton.setImage(listenButtonImage, for: UIControlState())
            cell.listenButton.isHidden = cellViewModel.hidesListeningButton()
            
            cell.listenButton.rx_tap.asDriver().driveNext {[weak self, weak cellViewModel] in
                guard self != nil && self!.checkIfUserIsLoggedInAndDisplayAlertIfNot() else { return }
                cellViewModel?.toggleIsListening().observeOn(MainScheduler.instance).subscribe({[weak cell] (event) in
                    switch event {
                    case .next(let (listening, successMessage, newListnersCount, error)):
                        let listenButtonImage = listening ? UIImage.profileStopListeningIcon() : UIImage.profileListenIcon()
                        cell?.listenButton.setImage(listenButtonImage, for: UIControlState())

                        if let message = successMessage {
                            self?.showSuccessMessage(message)
                            
                            guard let newListnersCount = newListnersCount, let cellViewModel = cellViewModel else {
                                return
                            }
                            
                            cellViewModel.updateListnersCount(newListnersCount, isListening: listening)
                            cell?.listenersCountLabel.text = cellViewModel.listeningCountString()
                            
                        } else if let error =  error {
                            self?.showError(error)
                        }
                    default:
                        break
                    }
                }).addDisposableTo(cell.reuseDisposeBag)
            }.addDisposableTo(cell.reuseDisposeBag)
            
            return cell
        }
            
        else if indexPath.section == ProfileCollectionViewSection.shouts.rawValue {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ProfileCollectionViewSection.shouts.cellReuseIdentifier, for: indexPath) as! ShoutsCollectionViewCell
            let cellViewModel = viewModel.gridSection.cells[indexPath.row]
            cell.bindWith(Shout: cellViewModel.shout)
            cell.bookmarkButton?.tag = indexPath.row
            cell.bookmarkButton?.addTarget(self, action: #selector(switchBookmarkState), for: .touchUpInside)
            return cell
        }
        
        fatalError()
    }
    
    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        
        guard let view = ProfileCollectionViewSupplementaryView(indexPath: indexPath) else {
            fatalError("Unexpected supplementery view index path")
        }
        
        let supplementeryView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: view.kind.rawValue, for: indexPath)
        
        switch view {
        case .cover:
            
            let coverView = supplementeryView as! ProfileCollectionCoverSupplementaryView
            
            // setup navigation bar buttons
            coverView.menuButton
                .rx_tap
                .subscribeNext{[unowned self] in
                    self.toggleMenu()
                }
                .addDisposableTo(coverView.reuseDisposeBag)
            
            if let navigationController = navigationController, self === navigationController.viewControllers[0] {
                coverView.setBackButtonHidden(true)
            } else {
                coverView.backButton
                    .rx_tap
                    .asDriver()
                    .driveNext{[unowned self] in
                        self.navigationController?.popViewController(animated: true)
                    }
                    .addDisposableTo(coverView.reuseDisposeBag)
            }
            /*
            coverView.cartButton
                .rx_tap
                .subscribeNext{[unowned self] in
                    self.flowDelegate?.showCart()
                }
                .addDisposableTo(coverView.reuseDisposeBag)
             */
            
            coverView
                .searchButton
                .rx_tap
                .subscribeNext{[unowned self] in
                    guard let model = self.viewModel.model else { return }
                    switch model {
                    case .tagModel(let tag):
                        self.flowDelegate?.showSearchInContext(.tagShouts(tag: tag))
                    case .profileModel(let profile):
                        self.flowDelegate?.showSearchInContext(.profileShouts(profile: profile))
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
            
        case .info:
            
            let infoView = supplementeryView as! ProfileCollectionInfoSupplementaryView
            
            switch viewModel.avatar {
            case .Local(let image):
                infoView.avatarImageView.contentMode = .center
                infoView.avatarImageView.image = image
            case .remote(let url):
                infoView.avatarImageView.contentMode = .scaleAspectFill
                infoView.avatarImageView.sh_setImageWithURL(url, placeholderImage: viewModel.placeholderImage)
            }
            
            infoView.nameLabel.text = viewModel.name
            infoView.usernameLabel.text = viewModel.username
            if let isListening = viewModel.isListeningToYou, isListening {
                infoView.listeningToYouLabel.isHidden = false
            } else {
                infoView.listeningToYouLabel.isHidden = true
            }
            infoView.bioLabel.text = viewModel.descriptionText
            infoView.verifiedIcon.isHidden = !viewModel.verified
            infoView.bioIconImageView.image = viewModel.descriptionIcon
            infoView.websiteLabel.text = viewModel.websiteString
            infoView.dateJoinedLabel.text = viewModel.dateJoinedString
            infoView.locationLabel.text = viewModel.locationString
            infoView.locationFlagImageView.image = viewModel.locationFlag
            infoView.verifyAccountButton.setTitle(viewModel.verifyButtonTitle, for: UIControlState())
            setButtons(viewModel.infoButtons, inSupplementaryView: infoView, disposeBag: infoView.reuseDisposeBag)
            infoView.verifyAccountButton
                .rx_tap.asDriver()
                .driveNext{ [weak self] in
                    guard let loginState = Account.sharedInstance.loginState else {
                        return
                    }
                    
                    if case .page(_, let page) = loginState {
                        if page.isActivated == false {
                            self?.showActivateAccountAlert()
                            return
                        }
                        
                        if page.isVerified == false {
                            self?.flowDelegate?.showVerifyBussiness(page)
                            return
                        }
                        
                        return
                    }
                    
                    guard case .logged(let user) = loginState else { assertionFailure(); return; }
                    self?.flowDelegate?.showVerifyEmailView(user, successBlock: { (message) in
                        self?.showSuccessMessage(message)
                    })
                }
                .addDisposableTo(infoView.reuseDisposeBag)
            
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
            infoView.verifyAccountButtonHeightConstraint.constant = viewModel.hidesVerifyAccountButton ? 0 : layout.defaultVerifyButtonHeight
            
            
        case .listSectionHeader:
            let listSectionHeader = supplementeryView as! ProfileCollectionSectionHeaderSupplementaryView
            listSectionHeader.titleLabel.text = viewModel.listSection.title
        case .createPageButtonFooter:
            let createPageButtonFooter = supplementeryView as! ProfileCollectionFooterButtonSupplementeryView
            createPageButtonFooter.reuseDisposeBag = DisposeBag()
            createPageButtonFooter.type = viewModel.listSection.footerButtonStyle
            createPageButtonFooter.button.setTitle(viewModel.listSection.footerButtonTitle, for: UIControlState())
            createPageButtonFooter.button
                .rx_tap
                .subscribeNext {[unowned self] in
                    self.flowDelegate?.showCreateShout()
                }
                .addDisposableTo(createPageButtonFooter.reuseDisposeBag!)
        case .gridSectionHeader:
            let gridSectionHeader = supplementeryView as! ProfileCollectionSectionHeaderSupplementaryView
            gridSectionHeader.titleLabel.text = viewModel.gridSection.title
        case .seeAllShoutsButtonFooter:
            let seeAllShoutsFooter = supplementeryView as! ProfileCollectionFooterButtonSupplementeryView
            seeAllShoutsFooter.reuseDisposeBag = DisposeBag()
            seeAllShoutsFooter.type = viewModel.gridSection.footerButtonStyle
            seeAllShoutsFooter.button.setTitle(viewModel.gridSection.footerButtonTitle, for: UIControlState())
            seeAllShoutsFooter.button
                .rx_tap
                .subscribeNext{[unowned self] in
                    guard let model = self.viewModel.model else { return }
                    switch model {
                    case .profileModel(let profile):
                        self.flowDelegate?.showShoutsForProfile(profile)
                    case .tagModel(let tag):
                        self.flowDelegate?.showShoutsForTag(tag)
                        
                    }
                }
                .addDisposableTo(seeAllShoutsFooter.reuseDisposeBag!)
        }
        
        return supplementeryView
    }
}

// MARK: - Info supplementary view hydration

extension ProfileCollectionViewController {
    
    func setButtons(_ buttons:[ProfileCollectionInfoButton], inSupplementaryView sView: ProfileCollectionInfoSupplementaryView, disposeBag: DisposeBag) {
        
        for button in buttons {
            switch button.position {
            case .smallLeft:
                hydrateButton(sView.notificationButton, withButtonModel: button, disposeBag: disposeBag)
            case .smallRight:
                hydrateButton(sView.rightmostButton, withButtonModel: button, disposeBag: disposeBag)
            case .bigLeft:
                hydrateButton(sView.buttonSectionLeftButton, withButtonModel: button, disposeBag: disposeBag)
            case .bigCenter:
                hydrateButton(sView.buttonSectionCenterButton, withButtonModel: button, disposeBag: disposeBag)
            case .bigRight:
                hydrateButton(sView.buttonSectionRightButton, withButtonModel: button, disposeBag: disposeBag)
            }
        }
        sView.layoutButtons()
    }
    
    fileprivate func hydrateButton(_ button: UIButton, withButtonModel buttonModel: ProfileCollectionInfoButton, disposeBag: DisposeBag) {
        
        if case .hiddenButton = buttonModel {
            button.isHidden = true
            return
        }
        
        switch buttonModel {
        case .listen(let isListening):
            
            guard let listenObservable = viewModel.listen() else { return }
            
            button.rx_tap
                .filter{[unowned self] () -> Bool in
                    let isGuest = Account.sharedInstance.user?.isGuest ?? true
                    if isGuest {
                        self.displayUserMustBeLoggedInAlert()
                    }
                    return !isGuest
                }
                .flatMapFirst{[weak button] () -> Observable<Void> in
                    if let button = button as? ProfileInfoHeaderButton {
                        let switchedModel = ProfileCollectionInfoButton.listen(isListening: !isListening)
                        button.setImage(switchedModel.image, countText: nil)
                        button.setTitleText(switchedModel.title)
                    }
                    return listenObservable
                }
                .subscribeError{[weak button] (_) in
                    if let button = button as? ProfileInfoHeaderButton {
                        button.setImage(buttonModel.image, countText: nil)
                        button.setTitleText(buttonModel.title)
                    }
                }
                .addDisposableTo(disposeBag)
        case .listening:
            button.rx_tap
                .asDriver()
                .driveNext{[weak self] in
                    guard let model = self?.viewModel.model else { return }
                    guard case .profileModel(let profile) = model else { return }
                    guard profile.username == Account.sharedInstance.user?.username else { return }
                    self?.flowDelegate?.showListeningForUsername(profile.username)
                }
                .addDisposableTo(disposeBag)
        case .listeners:
            button.rx_tap
                .asDriver()
                .driveNext{[weak self] in
                    guard let model = self?.viewModel.model else { return }
                    guard case .profileModel(let profile) = model else { return }
                    guard profile.username == Account.sharedInstance.user?.username else { return }
                    self?.flowDelegate?.showListenersForUsername(profile.username)
                }
                .addDisposableTo(disposeBag)
        case .interests:
            button.rx_tap
                .asDriver()
                .driveNext{[weak self] in
                    guard let model = self?.viewModel.model else { return }
                    guard case .profileModel(let profile) = model else { return }
                    guard profile.username == Account.sharedInstance.user?.username else { return }
                    self?.flowDelegate?.showInterestsForUsername(profile.username)
                }
                .addDisposableTo(disposeBag)
        case .more:
            button.rx_tap.asDriver().driveNext({ [weak self] in
                self?.moreAction()
            }).addDisposableTo(disposeBag)
        case .editProfile:
            if let btn = button as? BadgeButton {
                var shouldShowFillProfileBadge = false
                
                if let profile = Account.sharedInstance.user as? DetailedUserProfile {
                    if profile.hasAllRequiredFieldsFilled() == false {
                        shouldShowFillProfileBadge = true
                    }
                }
                
                btn.setBadgeNumber(shouldShowFillProfileBadge ? 1 : 0)
            }
            button.rx_tap.asDriver().driveNext{[weak self] in
                self?.flowDelegate?.showEditProfile()
            }.addDisposableTo(disposeBag)
        case .chat:
            button.rx_tap.asDriver().driveNext({ [weak self] in
                self?.startChat()
            }).addDisposableTo(disposeBag)
        case .notification:
            Account.sharedInstance.statsSubject.subscribeNext{ (stats) in
                if let btn = button as? BadgeButton {
                    btn.setBadgeNumber(stats?.unreadNotificationsCount ?? 0)
                }
            }.addDisposableTo(disposeBag)
                
            button.rx_tap.asDriver().driveNext{[weak self] in
                self?.flowDelegate?.showNotifications()
                }.addDisposableTo(disposeBag)
        default:
            break
        }
        
        if let button = button as? ProfileInfoHeaderButton {
            button.setTitleText(buttonModel.title)
            
            if case .listeners(let countString) = buttonModel {
                button.setImage(buttonModel.image, countText: countString)
            } else if case .listening(let countString) = buttonModel {
                button.setImage(buttonModel.image, countText: countString)
            } else if case .interests(let countString) = buttonModel {
                button.setImage(buttonModel.image, countText: countString)
            } else {
                button.setImage(buttonModel.image, countText: nil)
            }
        } else {
            button.setImage(buttonModel.image, for: .Normal)
        }
    }
    
    func reportAction() {
        
        guard let reportable = viewModel.reportable else {
            return
        }
        
        let alert = reportable.reportAlert { (report) in
            MBProgressHUD.showAdded(to: self.view, animated: true)
            
            APIMiscService.makeReport(report).subscribe({ [weak self] (event) in
                MBProgressHUD.hide(for: self?.view, animated: true)
                
                switch event {
                case .next:
                    self?.showSuccessMessage(NSLocalizedString("Profile Reported Successfully", comment: "Reported Message"))
                case .Error(let error):
                    self?.showError(error)
                default:
                    break
                }
                
            }).addDisposableTo(self.disposeBag)
        }
        
        self.navigationController?.present(alert, animated: true, completion: nil)
    }
    
    func moreAction() {
        let alt = viewModel.moreAlert { (alertController) in
            self.reportAction()
        }
        
        guard let alert = alt else {
            return
        }
        
        self.navigationController?.present(alert, animated: true, completion: nil)
    }
    
    func startChat() {
        
        guard checkIfUserIsLoggedInAndDisplayAlertIfNot() else {
            return
        }
        
        if viewModel.isListeningToYou != true {
            let error = LightError(userMessage: NSLocalizedString("You can only start a chat with your listeners", comment: ""))
            showError(error)
            return
        }
        
        if let conversation = viewModel.conversation {
            flowDelegate?.showConversation(.created(conversation: conversation))
            return
        }
        
        guard let model = viewModel.model, case .profileModel(let profile) = model else {
            debugPrint("Could not create conversation without profile")
            return
        }
        
        if profile.id == Account.sharedInstance.user?.id {
            let error = LightError(userMessage: NSLocalizedString("You can't chat with yourself", comment: ""))
            showError(error)
            return
        }
        
        flowDelegate?.showConversation(.notCreated(type: .Chat, user: profile, aboutShout: nil))
    }
}

extension ProfileCollectionViewController : Bookmarking {
    
    func shoutForIndexPath(_ indexPath: IndexPath) -> Shout? {
        let cellViewModel = viewModel.gridSection.cells[indexPath.row]
        return cellViewModel.shout
    }
    
    func indexPathForShout(_ shout: Shout?) -> IndexPath? {
        guard let shout = shout else {
            return nil
        }
        
        let shouts = viewModel.gridSection.cells.map{$0.shout}
    
        if let idx = shouts.index(of: shout) {
            return IndexPath(item: idx, section: 1)
        }
        
        return nil
    }
    
    func replaceShoutAndReload(_ shout: Shout) {
        self.viewModel?.replaceShout(shout)
        self.viewModel?.reloadSubject.onNext()
    }
    
    @objc func switchBookmarkState(_ sender: UIButton) {
        switchShoutBookmarkShout(sender)
    }
}

extension ProfileCollectionViewController {
    func showActivateAccountAlert() {
        let alert = UIAlertController(title: NSLocalizedString("Activate your page", comment: ""), message: NSLocalizedString("To activate your page, your personal account should be verified first. Click the activation link in the email you have received when you signed up.", comment: ""), preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: LocalizedString.ok, style: .default, handler: nil))
        
        self.navigationController?.present(alert, animated: true, completion: nil)
    }
}
