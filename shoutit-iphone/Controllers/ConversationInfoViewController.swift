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
        let createdDateString = DateFormatters.sharedInstance.stringFromDateEpoch(self.conversation.createdAt)
        
        self.footerLabel.text = NSLocalizedString("Chat created by \(self.conversation)\nCreated on \(createdDateString)", comment: "Chat Info Bottom Description")
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
        
    }
    
    func showParticipants() {
        
    }
    
    func showBlocked() {
        
    }
    
    func clearChat() {
        
    }
    
    func exitChat() {
        
    }
}
