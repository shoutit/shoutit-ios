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
    var loadMoreView : ConversationLoadMoreFooter?
    
    private let disposeBag = DisposeBag()
    private var loadMoreBag = DisposeBag()
 
    override func viewDidLoad() {
        super.viewDidLoad()
        
        registerSupplementaryViews()
        
        customizeInputView()
        customizeTable()
        
        setupDataSource()
        setNavigationTitle()
        
        setLoadMoreFooter()
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
        
        viewModel.typingUsers.asDriver(onErrorJustReturn: nil).driveNext { [weak self] (profile) -> Void in
            guard let profile = profile else {
                return
            }
            
            self?.typingIndicatorView.insertUsername(profile.username)
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
        
        typingIndicatorView.interval = 3.0
        textView.placeholder = NSLocalizedString("Type a message", comment: "")
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
    
    func setLoadMoreFooter() {
        loadMoreView = NSBundle.mainBundle().loadNibNamed("ConversationLoadMoreFooter", owner: self, options: nil)[0] as? ConversationLoadMoreFooter
        
        loadMoreView?.frame = CGRect(x: 0, y: 0, width: tableView.frame.width, height: 80.0)
        loadMoreView?.layoutIfNeeded()
        loadMoreView?.transform = tableView.transform
        
        loadMoreView?.setState(.ReadyToLoad)
        loadMoreView?.loadMoreButton.addTarget(self, action: "loadMore", forControlEvents: .TouchUpInside)
        
        loadMoreBag = DisposeBag()
        
        viewModel.loadMoreState.asDriver().driveNext({ [weak self] (state) -> Void in
            self?.loadMoreView?.frame = CGRect(x: 0, y: 0, width: (self?.tableView.frame.width ?? 220), height: 80.0)
            self?.loadMoreView?.setState(state)
            self?.tableView.reloadData()
        }).addDisposableTo(loadMoreBag)
        
        self.tableView.tableFooterView = loadMoreView
    }
    
    func loadMore() {
        viewModel.triggerLoadMore()
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
    
    override func textViewDidChange(textView: UITextView) {
        super.textViewDidChange(textView)

        viewModel.sendTypingEvent()
    }
}
