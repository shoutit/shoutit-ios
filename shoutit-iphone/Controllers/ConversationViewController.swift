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
import DZNEmptyDataSet

protocol ConversationViewControllerFlowDelegate: class, ChatDisplayable, ShoutDisplayable, PageDisplayable, ProfileDisplayable {}

class ConversationViewController: SLKTextViewController, ConversationPresenter, DZNEmptyDataSetDelegate, DZNEmptyDataSetSource, UIViewControllerTransitioningDelegate {
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
        
        if let shout = conversation.shout {
            setTopicShout(shout)
        }
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        if let _ = conversation.shout {
            tableView.contentInset = UIEdgeInsetsMake(0, 0, 130.0, 0)
        }
    }
    
    func setNavigationTitle() {
        navigationItem.title = conversation.firstLineText()?.string
    }
    
    func setTopicShout(shout: Shout) {
        guard let shoutView = NSBundle.mainBundle().loadNibNamed("ConversationShoutHeader", owner: self, options: nil)[0] as? ConversationShoutHeader else {
            return
        }
        
        shoutView.tapGesture.addTarget(self, action: #selector(ConversationViewController.showShout))
        shoutView.translatesAutoresizingMaskIntoConstraints = false
        
        shoutView.bindWith(Shout: shout)
        
        view.addSubview(shoutView)
        
        view.addConstraints([NSLayoutConstraint(item: shoutView, attribute: .Leading, relatedBy: .Equal, toItem: view, attribute: .Leading, multiplier: 1.0, constant: 0),
                            NSLayoutConstraint(item: shoutView, attribute: .Trailing, relatedBy: .Equal, toItem: view, attribute: .Trailing, multiplier: 1.0, constant: 0),
                            NSLayoutConstraint(item: shoutView, attribute: .Top, relatedBy: .Equal, toItem: view, attribute: .Top, multiplier: 1.0, constant: 64.0)])
        
        shoutView.addConstraint(NSLayoutConstraint(item: shoutView, attribute: .Height, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1.0, constant: 64.0))
        
        shoutView.clipsToBounds = true
        
        shoutView.layoutIfNeeded()
        
        tableView.contentInset = UIEdgeInsetsMake(0, 0, 130.0, 0)
    }
    
    func showShout() {
        if let shout = self.conversation.shout {
            self.flowDelegate?.showShout(shout)
        }        
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
        
        tableView.emptyDataSetDelegate = self
        tableView.emptyDataSetSource = self
        
    }
    
    func customizeInputView() {
        rightButton.setImage(UIImage(named: "send"), forState: .Normal)
        rightButton.setTitle("", forState: .Normal)
        rightButton.tintColor = UIColor(shoutitColor: ShoutitColor.ShoutitButtonGreen)
        
        leftButton.setImage(UIImage(named: "attach"), forState: .Normal)
        leftButton.setTitle("", forState: .Normal)
        leftButton.tintColor = UIColor(shoutitColor: ShoutitColor.FontGrayColor)
        
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
        let footerHeight : CGFloat = 60.0
        
        loadMoreView = NSBundle.mainBundle().loadNibNamed("ConversationLoadMoreFooter", owner: self, options: nil)[0] as? ConversationLoadMoreFooter
        
        loadMoreView?.frame = CGRect(x: 0, y: 0, width: tableView.frame.width, height: footerHeight)
        loadMoreView?.layoutIfNeeded()
        loadMoreView?.transform = tableView.transform
        
        loadMoreView?.setState(.ReadyToLoad)
        loadMoreView?.loadMoreButton.addTarget(self, action: #selector(ConversationViewController.loadMore), forControlEvents: .TouchUpInside)
        
        loadMoreBag = DisposeBag()
        
        viewModel.loadMoreState.asDriver().driveNext({ [weak self] (state) -> Void in
            self?.loadMoreView?.frame = CGRect(x: 0, y: 0, width: (self?.tableView.frame.width ?? 220), height: footerHeight)
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
    
    override func didPressLeftButton(sender: AnyObject!) {
        self.flowDelegate?.showAttachmentController({ (type) in
            print(type)
        }, transitionDelegate: self)
    }
    
    func showSendingError(error: NSError) -> Void {
        let controller = viewModel.alertControllerWithTitle(NSLocalizedString("Could not send message", comment: ""), message: error.localizedDescription)
        
        navigationController?.presentViewController(controller, animated: true, completion: nil)
    }
    
    override func textViewDidChange(textView: UITextView) {
        super.textViewDidChange(textView)

        viewModel.sendTypingEvent()
    }
    
    func customViewForEmptyDataSet(scrollView: UIScrollView!) -> UIView! {
        let attributedText : NSAttributedString
        if self.conversation.id == "" {
            attributedText = NSAttributedString(string: NSLocalizedString("Don't be so shy. Say something.", comment: ""))
        } else if viewModel.loadMoreState.value == .ReadyToLoad {
            attributedText = NSAttributedString(string: NSLocalizedString("No Messages to show", comment: ""))
        } else {
            attributedText = NSAttributedString(string: NSLocalizedString("Loading Messages...", comment: ""))
        }
        
        let lbl = UILabel(frame: CGRect(x: 0, y: 0, width: self.tableView.frame.width, height: self.tableView.frame.height))
        lbl.attributedText = attributedText
        lbl.transform = tableView.transform
        lbl.textAlignment = .Center
        lbl.font = UIFont.boldSystemFontOfSize(18.0)
        lbl.textColor = UIColor.lightGrayColor()
        
        return lbl
    }
    
    @IBAction func moreAction() {
        let alert = viewModel.moreActionAlert { [weak self] in
            self?.navigationController?.popViewControllerAnimated(true)
        }
        self.navigationController?.presentViewController(alert, animated: true, completion: nil)
    }
}

extension ConversationViewController {
    func animationControllerForPresentedController(presented: UIViewController, presentingController presenting: UIViewController, sourceController source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return OverlayAnimationController()
    }
    
    func animationControllerForDismissedController(dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return OverlayDismissAnimationController()
    }
}
