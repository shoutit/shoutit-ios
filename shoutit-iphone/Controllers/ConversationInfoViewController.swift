//
//  ConversationInfoViewController.swift
//  shoutit-iphone
//
//  Created by Piotr Bernad on 16/05/16.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import UIKit
import RxSwift

protocol ConversationInfoViewControllerFlowDelegate: class, ChatDisplayable, ShoutDisplayable, PageDisplayable, ProfileDisplayable {}

class ConversationInfoViewController: UITableViewController {

    weak var flowDelegate: ConversationInfoViewControllerFlowDelegate?
    
    @IBOutlet weak var headerView: ConversationInfoHeaderView!
    @IBOutlet weak var footerLabel: UILabel!
    
    private let disposeBag = DisposeBag()
    
    var conversation: Conversation! {
        didSet {
            viewModel = ConversationInfoViewModel()
            viewModel.conversation = conversation
            self.tableView.reloadData()
            fillViews()
        }
    }
    
    var viewModel : ConversationInfoViewModel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        fillViews()
    }

    func fillViews() {
        
        if conversation.type() != .PublicChat {
            // clear header
            self.tableView.tableHeaderView = nil
        } else {
            
            // fill header
            self.headerView.subjectTextField?.text = self.conversation.subject
            
            let isAdmin = self.conversation.isAdmin(Account.sharedInstance.user?.id)
            
            self.headerView.subjectTextField?.enabled = isAdmin
            
            
            let imagePlaceholder = UIImage(named: "chats_image_placeholder")
            
            if let path = self.conversation.icon {
                self.headerView.imageView?.sh_setImageWithURL(NSURL(string: path), placeholderImage: imagePlaceholder)
            } else {
                self.headerView.imageView?.image = imagePlaceholder
            }
            
            self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Save, target: self, action: #selector(saveAction))
        }
        
        // fill footer
        let createdDateString = DateFormatters.sharedInstance.stringFromDateEpoch(self.conversation.createdAt)
        self.footerLabel.text = NSLocalizedString("Chat created by \(self.conversation)\nCreated on \(createdDateString)", comment: "Chat Info Bottom Description")
        
    }
    
    func saveAction() {
        APIChatsService.updateConversationWithId(self.conversation.id, params: ConversationUpdateParams(subject: self.headerView.subjectTextField?.text)).subscribe { [weak self] (event) in
            switch event {
                
            case .Next(let conversation):
                    self?.conversation = conversation
                    self?.navigationController?.popViewControllerAnimated(true)
                
            case .Error(let error):
                    self?.showError(error)
                
            default:
                break
                
            }
        }.addDisposableTo(disposeBag)
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
        
        let isAdmin = self.conversation.isAdmin(Account.sharedInstance.user?.id)
        
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        switch indexPath.section {
        case 0:
            switch indexPath.row {
            case 0:
                showShouts()
            case 1:
                showMedia()
            default:
                break
            }
        case 1:
            switch indexPath.row {
            case 0:
                if isAdmin {
                    addMember()
                } else {
                    notAuthorized()
                }
            case 1:
                showParticipants()
            case 2:
                if isAdmin {
                    showBlocked()
                } else {
                    notAuthorized()
                }
            default:
                break
            }
        case 2:
            switch indexPath.row {
            case 0:
                if isAdmin {
                    clearChat()
                } else {
                    notAuthorized()
                }
            default:
                exitChat()
            }
        default:
            break
        }
        
    }
    
    func notAuthorized() {
        self.showErrorMessage(NSLocalizedString("You are not allowed to do this action", comment: "Chat Info actions message"))
    }
    
    func showShouts() {
        
    }
    
    func showMedia() {
        
    }
    
    func addMember() {
        guard let username = Account.sharedInstance.user?.username else { fatalError() }
        let controller = Wireframe.conversationSelectProfileAttachmentController()
        
        controller.eventHandler = SelectProfileProfilesListEventHandler(choiceHandler: { (profile) in
            
            self.viewModel.addParticipantToConversation(profile).subscribe({ (event) in
                
                switch event {
                    case .Next(_):
                        let profileName = profile.firstName ?? profile.username
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
        
        if let users = self.conversation.users {
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
        let controller = Wireframe.conversationSelectProfileAttachmentController()
        
        controller.eventHandler = SelectProfileProfilesListEventHandler(choiceHandler: { (profile) in
            
        })
        
        controller.viewModel = ConversationMembersListViewModel(conversation: self.conversation)
        controller.navigationItem.title = NSLocalizedString("Participants", comment: "")
        
        self.navigationController?.showViewController(controller, sender: nil)
    }
    
    func showBlocked() {
        let controller = Wireframe.conversationSelectProfileAttachmentController()
        
        controller.eventHandler = SelectProfileProfilesListEventHandler(choiceHandler: { (profile) in
            
        })
        
        controller.viewModel = ConversationBlockedListModel(conversation: self.conversation)
        controller.navigationItem.title = NSLocalizedString("Blocked", comment: "")
        
        self.navigationController?.showViewController(controller, sender: nil)
        
    }
    
    func clearChat() {
        
    }
    
    func exitChat() {
        
    }
}
