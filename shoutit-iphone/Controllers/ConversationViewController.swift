//
//  ConversationViewController.swift
//  shoutit-iphone
//
//  Created by Piotr Bernad on 15.03.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import UIKit
import SlackTextViewController
import RxSwift

protocol ConversationViewControllerFlowDelegate: class, ChatDisplayable, ShoutDisplayable, PageDisplayable, ProfileDisplayable {}

class ConversationViewController: SLKTextViewController, ConversationPresenter {
    weak var flowDelegate: ConversationViewControllerFlowDelegate?
    
    var conversation: Conversation!
    
    var viewModel : ConversationViewModel!
    
    private let disposeBag = DisposeBag()
 
    override func viewDidLoad() {
        super.viewDidLoad()
        
        registerSupplementaryViews()
        
        customizeInputView()
        customizeTable()
        
        setupDataSource()
        setNavigationTitle()
    }
    
    func setNavigationTitle() {
        navigationItem.title = conversation.firstLineText()?.string
    }
    
    func setupDataSource() {
        viewModel = ConversationViewModel(conversation: self.conversation, delegate: self)
        viewModel.fetchMessages()
        
        viewModel.messages.asDriver().driveNext { [weak self] (messages) -> Void in
            self?.tableView.reloadData()
            }.addDisposableTo(disposeBag)
    }
    
    func registerSupplementaryViews() {
        tableView.registerNib(UINib(nibName: "ConversationDayHeader", bundle: nil), forHeaderFooterViewReuseIdentifier: conversationSectionDayIdentifier)
        tableView.registerNib(UINib(nibName: "OutgoingCell", bundle: nil), forCellReuseIdentifier: conversationOutGoingTextCellIdentifier)
        tableView.registerNib(UINib(nibName: "IncomingCell", bundle: nil), forCellReuseIdentifier: conversationIncomingTextCellIdentifier)
    }
    
    func customizeTable() {
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 50.0
        tableView.separatorStyle = .None
    }
    
    func customizeInputView() {
        rightButton.setImage(UIImage(named: "send"), forState: .Normal)
        rightButton.setTitle("", forState: .Normal)
        rightButton.tintColor = UIColor(shoutitColor: ShoutitColor.ShoutitButtonGreen)
    }
    
    override func prefersTabbarHidden() -> Bool {
        return true
    }
    
    override class func tableViewStyleForCoder(decoder: NSCoder!) -> UITableViewStyle {
        return UITableViewStyle.Plain
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(viewModel.cellIdentifierAtIndexPath(indexPath)) as! ConversationCell
        
        let msg = viewModel.messageAtIndexPath(indexPath)
        let previousMsg = viewModel.previousMessageFor(msg)
        
        cell.bindWithMessage(msg, previousMessage: previousMsg)
        
        cell.transform = tableView.transform
        
        return cell
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return viewModel.messages.value.keys.count
    }
    
    override func tableView(tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let view = tableView.dequeueReusableHeaderFooterViewWithIdentifier(conversationSectionDayIdentifier) as! ConversationDayHeader
        
        view.dateLabel.text = viewModel.sectionTitle(section)
        view.transform = tableView.transform
        
        return view
    }
    
    override func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 30.0
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.viewModel.numberOfRowsInSection(section)
    }
    
    override func didPressRightButton(sender: AnyObject!) {
        textView.refreshFirstResponder()
        
        if viewModel.sendMessageWithText(textView.text) {
            textView.text = ""
        }
    }
    
    func showSendingError(error: NSError) -> Void {
        let controller = viewModel.alertControllerWithTitle(NSLocalizedString("Could not send message", comment: ""), message: error.localizedDescription)
        
        navigationController?.presentViewController(controller, animated: true, completion: nil)
    }
    
}
