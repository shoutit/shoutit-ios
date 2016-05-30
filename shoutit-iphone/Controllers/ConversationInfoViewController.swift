//
//  ConversationInfoViewController.swift
//  shoutit-iphone
//
//  Created by Piotr Bernad on 16/05/16.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import UIKit
import RxSwift
import MBProgressHUD

class ConversationInfoViewController: UITableViewController {

    private let disposeBag = DisposeBag()
    private var socketsBag : DisposeBag?
    
    // navigation
    weak var flowDelegate: FlowController?
    
    // outlets
    @IBOutlet weak var headerView: CreatePublicChatHeaderView!
    @IBOutlet weak var footerLabel: UILabel!
    
    // children
    lazy var mediaPickerController: MediaPickerController = {[unowned self] in
        var pickerSettings = MediaPickerSettings()
        pickerSettings.allowsVideos = false
        let controller = MediaPickerController(delegate: self, settings: pickerSettings)
        
        controller.presentingSubject
            .observeOn(MainScheduler.instance)
            .subscribeNext {[weak self] controller in
                guard let controller = controller else { return }
                self?.presentViewController(controller, animated: true, completion: nil)
            }
            .addDisposableTo(self.disposeBag)
        
        return controller
        }()

    
    var viewModel : ConversationInfoViewModel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        precondition(viewModel != nil)
        fillViews()
        registerForConversationUpdates()
        setupRX()
    }
    
    override func prefersMenuHamburgerHidden() -> Bool {
        return true
    }
    
    // MARK: - Setup
    
    private func setupRX() {
        
        headerView.chatImageButton
            .rx_tap
            .asDriver()
            .driveNext {[unowned self] in
                self.mediaPickerController.showMediaPickerController()
            }
            .addDisposableTo(disposeBag)
        
        headerView.chatSubjectTextField
            .rx_text
            .asDriver()
            .driveNext {[weak self] (text) in
                self?.viewModel.chatSubject = text
            }
            .addDisposableTo(disposeBag)
        
        
        
    }
    
    func registerForConversationUpdates() {
        socketsBag = DisposeBag()
        
        Account.sharedInstance.pusherManager.conversationObservable(self.viewModel.conversation).subscribeNext { (event) -> Void in
            if event.eventType() == .ConversationUpdate {
                if let conversation: Conversation = event.object() {
                    self.viewModel.conversation = conversation
                    self.tableView.reloadData()
                    self.fillViews()
                } else {
                    print(event.data)
                    assertionFailure("Expected Conversation Object")
                }
            }
        }.addDisposableTo(socketsBag!)
    }

    private func fillViews() {
        
        // fill footer
        let createdDateString = DateFormatters.sharedInstance.stringFromDateEpoch(viewModel.conversation.createdAt ?? 0)
        
        if let creator = viewModel.conversation.creator, name = creator.name {
            self.footerLabel.text = NSLocalizedString("Chat created by \(name)\nCreated on \(createdDateString)", comment: "Chat Info Bottom Description")
        } else {
            self.footerLabel.text = NSLocalizedString("Chat created by Shoutit", comment: "Chat Info Bottom Description")
        }
        
        guard case .PublicChat = viewModel.conversation.type() else {
            self.tableView.tableHeaderView = nil
            return
        }
        
        // fill header
        let isAdmin = viewModel.conversation.isAdmin(Account.sharedInstance.user?.id)
        
        headerView.chatSubjectTextField.text = viewModel.conversation.display.title
        headerView.chatSubjectTextField.enabled = isAdmin
        headerView.chatImageButton.enabled = isAdmin
        headerView.chatSubjectTextField.alpha = isAdmin ? 1.0 : 0.5
        
        if let path = viewModel.conversation.display.image {
            headerView.setupImageViewWithStatus(.Uploaded)
            headerView.setChatImage(.URL(path: path))
        } else {
            headerView.setupImageViewWithStatus(.NoImage)
        }
        
        guard isAdmin else {
            return
        }
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Save, target: nil, action: nil)
        navigationItem.rightBarButtonItem?
            .rx_tap
            .flatMapFirst{[unowned self] in
                return self.viewModel.saveChat()
            }
            .observeOn(MainScheduler.instance)
            .subscribeNext{[weak self] (status) in
                switch status {
                case .Error(let error):
                    self?.showError(error)
                case .Progress(let show):
                    if show {
                        MBProgressHUD.showHUDAddedTo(self?.view, animated: true)
                    } else {
                        MBProgressHUD.hideAllHUDsForView(self?.view, animated: true)
                    }
                case .Ready:
                    self?.pop()
                }
            }
            .addDisposableTo(disposeBag)
    }
    
    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return viewModel.numberOfSections()
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.numberOfRows(section)
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(viewModel.cellIdentifierForIndexPath(indexPath), forIndexPath: indexPath)
        viewModel.fillCell(cell, indexPath: indexPath)
        return cell
    }

    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return viewModel.sectionTitleForSection(section)
    }
    
    override func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 2 {
            return 5.0
        }
        return 20.0
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        let isAdmin = viewModel.conversation.isAdmin(Account.sharedInstance.user?.id)
        
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        switch (indexPath.section, indexPath.row, isAdmin, self.viewModel.conversation.isPublicChat()) {
        case (0, 0, _, _):
            showShouts()
        case (0, 1, _, _):
            showMedia()
        case (1, 0, true, _):
            addMember()
        case (1, 0, false, _):
            showNotAuthorizedMessage()
        case (1, 1, _, _):
            showParticipants()
        case (1, 2, true, _):
            showBlocked()
        case (1, 2, false, _):
            showNotAuthorizedMessage()
        case (2, 0, _, true):
            reportChat()
        case (2, 0, _, false):
            exitChat()
        case (2, 1, _, _):
            exitChat()
        default:
            assertionFailure()
            break
        }
    }
    
    func showNotAuthorizedMessage() {
        self.showErrorMessage(NSLocalizedString("You are not allowed to do this action", comment: "Chat Info actions message"))
    }
    
    func showShouts() {
        flowDelegate?.showShoutsForConversation(viewModel.conversation)
    }
    
    func showMedia() {
        flowDelegate?.showMediaForConversation(viewModel.conversation)
    }
    
    func addMember() {
        guard let username = Account.sharedInstance.user?.username else { fatalError() }
        let controller = Wireframe.conversationSelectProfileAttachmentController()
        
        controller.eventHandler = SelectProfileProfilesListEventHandler(choiceHandler: { (profile) in
            
            self.viewModel.addParticipantToConversation(profile).subscribe({ (event) in
                
                switch event {
                    case .Next(_):
                        let profileName = profile.fullName()
                        self.showSuccessMessage(NSLocalizedString("You've successfully added \(profileName) to chat.", comment: ""))
                    case .Error(let error):
                        self.showError(error)
                    default:
                        break
                }
                
            }).addDisposableTo(self.disposeBag)
        })
        
        controller.viewModel = ListenersProfilesListViewModel(username: username, showListenButtons: false)
        controller.navigationItem.title = NSLocalizedString("Add Member", comment: "")
        controller.dismissAfterSelection = true
        
        let configurator = AddMemberCellConfigurator()
        
        if let users = viewModel.conversation.users {
            let members : [Profile] = users.map({ (box) -> Profile in
                return box.value
            })
            
            let ids = members.map({ (profile) -> String in
                return profile.id
            })
            
            controller.viewModel.pager.itemExclusionRule = { (profile) -> Bool in
                return ids.contains(profile.id)
            }
            
            configurator.members = members
        }
        
        controller.cellConfigurator = configurator
        
        self.navigationController?.showViewController(controller, sender: nil)
    }
    
    func showParticipants() {
        let isAdmin = viewModel.conversation.isAdmin(Account.sharedInstance.user?.id)
        
        let controller = Wireframe.conversationSelectProfileAttachmentController()
        
        controller.eventHandler = SelectProfileProfilesListEventHandler(choiceHandler: { (profile) in
            
        })
        
        controller.viewModel = ConversationMembersListViewModel(conversation: viewModel.conversation)
        controller.navigationItem.title = NSLocalizedString("Participants", comment: "")
        
        let configurator = ConversationMemberCellConfigurator()
        
        configurator.blocked = viewModel.conversation.blocked
        configurator.admins = viewModel.conversation.admins
        
        configurator.canAdministrate = isAdmin
        
        controller.cellConfigurator = configurator
        controller.autoDeselct = true
        
        
        controller.eventHandler = SelectProfileProfilesListEventHandler(choiceHandler: { (profile) in
            if !isAdmin {
                return
            }
            
            if profile.id == Account.sharedInstance.user?.id {
                return
            }
            
            let optionsController = UIAlertController(title: profile.fullName(), message: NSLocalizedString("Manage User", comment: ""), preferredStyle: .ActionSheet)
            
            let isAdmin = self.viewModel.conversation.admins.contains{$0 == profile.id}
            let isBlocked = self.viewModel.conversation.blocked.contains{$0 == profile.id}
            
            if !isAdmin {
                optionsController.addAction(UIAlertAction(title: NSLocalizedString("Promote to admin", comment: ""), style: .Default, handler: { (action) in
                    self.promoteToAdmin(profile)
                }))
            }
            
            if !isBlocked {
                optionsController.addAction(UIAlertAction(title: NSLocalizedString("Block", comment: ""), style: .Default, handler: { (action) in
                    self.block(profile)
                }))
            } else {
                optionsController.addAction(UIAlertAction(title: NSLocalizedString("Unblock", comment: ""), style: .Default, handler: { (action) in
                    self.unblock(profile)
                }))
            }
            
            optionsController.addAction(UIAlertAction(title: NSLocalizedString("Remove", comment: ""), style: .Destructive, handler: { (action) in
                self.remove(profile)
            }))
            
            optionsController.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .Cancel, handler: { (action) in
            }))
            
            self.navigationController?.presentViewController(optionsController, animated: true, completion: nil)
        })
        
        self.navigationController?.showViewController(controller, sender: nil)
    }
    
    func remove(profile: Profile) {
        self.viewModel.removeParticipantFromConversation(profile).subscribe({ (event) in
            
            switch event {
            case .Next(_):
                let profileName = profile.fullName()
                self.showSuccessMessage(NSLocalizedString("You've successfully removed \(profileName) from chat.", comment: ""))
                self.navigationController?.popToViewController(self, animated: true)
            case .Error(let error):
                self.showError(error)
            default:
                break
            }
            
        }).addDisposableTo(self.disposeBag)
    }
    
    func promoteToAdmin(profile: Profile) {
        APIChatsService.promoteToAdminProfileInConversationWithId(viewModel.conversation.id, profile: profile).subscribe { (event) in
            
            switch event {
            case .Next(_):
                let profileName = profile.fullName()
                self.showSuccessMessage(NSLocalizedString("\(profileName) can now administrate this chat", comment: ""))
                self.navigationController?.popToViewController(self, animated: true)
            case .Error(let error):
                self.showError(error)
            default:
                break
            }
            
        }.addDisposableTo(disposeBag)
    }

    func block(profile: Profile) {
        APIChatsService.blockProfileInConversationWithId(viewModel.conversation.id, profile: profile).subscribe { (event) in
            switch event {
            case .Next(_):
                let profileName = profile.fullName()
                self.showSuccessMessage(NSLocalizedString("You've successfully blocked \(profileName)", comment: ""))
                self.navigationController?.popToViewController(self, animated: true)
            case .Error(let error):
                self.showError(error)
            default:
                break
            }
        }.addDisposableTo(disposeBag)
    }
    
    func unblock(profile: Profile) {
        APIChatsService.unblockProfileInConversationWithId(viewModel.conversation.id, profile: profile).subscribe { (event) in
            switch event {
            case .Next(_):
                let profileName = profile.fullName()
                self.showSuccessMessage(NSLocalizedString("You've successfully unblocked \(profileName)", comment: ""))
                self.navigationController?.popToViewController(self, animated: true)
            case .Error(let error):
                self.showError(error)
            default:
                break
            }
        }.addDisposableTo(disposeBag)
    }
    
    func showBlocked() {
        let isAdmin = viewModel.conversation.isAdmin(Account.sharedInstance.user?.id)
        
        if !isAdmin {
            return
        }
        
        let controller = Wireframe.conversationSelectProfileAttachmentController()
        
        controller.viewModel = ConversationBlockedListModel(conversation: viewModel.conversation)
        controller.navigationItem.title = NSLocalizedString("Blocked", comment: "")
        
        let configurator = ConversationMemberCellConfigurator()
        
        configurator.blocked = viewModel.conversation.blocked
        configurator.admins = []
        controller.cellConfigurator = configurator
        
        controller.eventHandler = SelectProfileProfilesListEventHandler(choiceHandler: { (profile) in
            
            
            if profile.id == Account.sharedInstance.user?.id {
                return
            }
            
            let optionsController = UIAlertController(title: profile.fullName(), message: NSLocalizedString("Manage User", comment: ""), preferredStyle: .ActionSheet)
            
            optionsController.addAction(UIAlertAction(title: NSLocalizedString("Unblock", comment: ""), style: .Default, handler: { (action) in
                self.unblock(profile)
            }))
            
            optionsController.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .Cancel, handler: { (action) in
            }))
            
            self.navigationController?.presentViewController(optionsController, animated: true, completion: nil)
        })
        self.navigationController?.showViewController(controller, sender: nil)
    }
    
    func clearChat() {
        
    }
    
    func reportChat() {
        
        let alert = self.viewModel.conversation.reportAlert { (report) in
            APIMiscService.makeReport(report).subscribe({ [weak self] (event) in
                switch event {
                case .Next(_):
                    self?.showSuccessMessage(NSLocalizedString("Conversation reported succesfully", comment: ""))
                case .Error(let error):
                    self?.showError(error)
                default:
                    break
                }
            }).addDisposableTo(self.disposeBag)
        }
        
        self.navigationController?.presentViewController(alert, animated: true, completion: nil)
    }
    
    func exitChat() {
        
        let alert = UIAlertController(title: NSLocalizedString("Are you sure?", comment: ""), message: NSLocalizedString("Do you want to delete this conversation", comment: ""), preferredStyle: .ActionSheet)
        
        alert.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .Cancel, handler: nil))
        
        alert.addAction(UIAlertAction(title: NSLocalizedString("Delete Conversation", comment: ""), style: .Destructive, handler: { [weak self] (alertAction) in
            self?.deleteConversation()
        }))
        
        self.navigationController?.presentViewController(alert, animated: true, completion: nil)
    }
    
    func deleteConversation() {
        APIChatsService.deleteConversationWithId(self.viewModel.conversation.id).subscribe { [weak self] (event) in
            switch event {
            case .Next(_):
                self?.showSuccessMessage(NSLocalizedString("Conversation Deleted succesfully", comment: ""))
                self?.navigationController?.popToRootViewControllerAnimated(true)
            case .Error(let error):
                self?.showError(error)
            default:
                break
            }
        }.addDisposableTo(disposeBag)
    }
}

extension ConversationInfoViewController: MediaPickerControllerDelegate {
    
    func attachmentSelected(attachment: MediaAttachment, mediaPicker: MediaPickerController) {
        
        let task = viewModel.uploadImageAttachment(attachment)
        headerView.setChatImage(.Image(image: attachment.image))
        
        task.status
            .asDriver()
            .driveNext{[weak self] (status) in
                switch status {
                case .Error:
                    self?.headerView.setupImageViewWithStatus(.NoImage)
                case .Uploaded:
                    self?.headerView.setupImageViewWithStatus(.Uploaded)
                case .Uploading:
                    self?.headerView.setupImageViewWithStatus(.Uploading)
                }
            }
            .addDisposableTo(disposeBag)
        
        task.progress
            .asDriver()
            .driveNext{[weak headerView] (progress) in
                headerView?.chatImageProgressView.setProgress(progress, animated: true)
            }
            .addDisposableTo(disposeBag)
    }
}

