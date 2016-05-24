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

final class ConversationViewController: SLKTextViewController, ConversationPresenter, DZNEmptyDataSetDelegate, DZNEmptyDataSetSource, UIViewControllerTransitioningDelegate {
    weak var flowDelegate: FlowController?
    
    var viewModel : ConversationViewModel!
    let attachmentManager = ConversationAttachmentManager()
    var loadMoreView : ConversationLoadMoreFooter?
    var titleView : ConversationTitleView!
    
    private let disposeBag = DisposeBag()
    private var loadMoreBag = DisposeBag()
 
    override func viewDidLoad() {
        super.viewDidLoad()
        
        registerSupplementaryViews()
        
        customizeInputView()
        customizeTable()
        
        setTitleView()
        hideSendingMessage()
        
        setupDataSource()
        setLoadMoreFooter()
        
        setupAttachmentManager()
        
        if let shout = viewModel.conversation.value.shout {
            setTopicShout(shout)
        }
    }
    
    func subscribeSockets() {
        self.viewModel.createSocketObservable()
    }
    
    func unsubscribeSockets() {
        self.viewModel.unsubscribeSockets()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        viewModel.createSocketObservable()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(subscribeSockets), name: UIApplicationWillEnterForegroundNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(unsubscribeSockets), name: UIApplicationDidEnterBackgroundNotification, object: nil)
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        viewModel.unsubscribeSockets()
        
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIApplicationWillEnterForegroundNotification, object: nil)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIApplicationDidEnterBackgroundNotification, object: nil)
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        layoutInsets()
    }
    
    func layoutInsets() {
        if let _ = viewModel.conversation.value.shout?.id {
            tableView?.contentInset = UIEdgeInsetsMake(0, 0, 64.0, 0)
        } else {
            tableView?.contentInset = UIEdgeInsetsZero
        }
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
        
        layoutInsets()
    }
    
    func showShout() {
        if let shout = viewModel.conversation.value.shout {
            self.flowDelegate?.showShout(shout)
        }        
    }
    
    private func setupDataSource() {
        
        viewModel.fetchFullConversation()
        viewModel.fetchMessages()
        
        viewModel.messages.asDriver().driveNext { [weak self] (messages) -> Void in
            self?.tableView?.reloadData()
        }.addDisposableTo(disposeBag)
        
        viewModel.typingUsers.asDriver(onErrorJustReturn: nil).driveNext { [weak self] (profile) -> Void in
            guard let profile = profile else { return }
            self?.typingIndicatorView?.insertUsername(profile.username)
        }.addDisposableTo(disposeBag)
        
        viewModel.sendingMessages.asDriver().driveNext { [weak self] (messages) in
            if messages.count > 0 {
                self?.showSendingMessage()
            } else {
                self?.hideSendingMessage()
            }
        }.addDisposableTo(disposeBag)
        
        viewModel.presentingSubject.subscribeNext { [weak self] (controller) in
            guard let controller = controller else { return }
            self?.navigationController?.presentViewController(controller, animated: true, completion: nil)
        }.addDisposableTo(disposeBag)
        
        viewModel.conversation.asObservable()
            .observeOn(MainScheduler.instance)
            .subscribeNext {[weak self] (conversationExistance) in
                if let conversation = self?.viewModel.conversation.value.conversationInterface {
                    self?.navigationItem.rightBarButtonItems?.forEach{$0.enabled = true}
                    if let moreButtonItem = self?.navigationItem.rightBarButtonItems?.first where conversation.type() == .PublicChat {
                        self?.navigationItem.rightBarButtonItems = [moreButtonItem]
                    }
                } else {
                    self?.navigationItem.rightBarButtonItems?.forEach{$0.enabled = false}
                }
            }
            .addDisposableTo(disposeBag)
    }
    
    private func setupAttachmentManager() {
        attachmentManager.attachmentSelected.subscribeNext { [weak self] (attachment) in
            self?.viewModel.sendMessageWithAttachment(attachment)
        }.addDisposableTo(disposeBag)
        
        attachmentManager.presentingSubject
            .subscribeNext { [weak self] (controller) in
                guard let controller = controller else { return }
                self?.navigationController?.presentViewController(controller, animated: true, completion: nil)
            }
            .addDisposableTo(disposeBag)
        
        attachmentManager.pushingSubject
            .subscribeNext { [weak self] (controller) in
                guard let controller = controller else { return }
                self?.navigationController?.showViewController(controller, sender: nil)
            }
            .addDisposableTo(disposeBag)
        
    }
    
    private func registerSupplementaryViews() {
        guard let tableView = tableView else {
            assertionFailure()
            return
        }
        tableView.registerNib(UINib(nibName: "ConversationDayHeader", bundle: nil), forHeaderFooterViewReuseIdentifier: ConversationCellIdentifier.Wireframe.daySection)
        
        tableView.registerNib(UINib(nibName: "OutgoingCell", bundle: nil), forCellReuseIdentifier: ConversationCellIdentifier.Text.outgoing)
        tableView.registerNib(UINib(nibName: "IncomingCell", bundle: nil), forCellReuseIdentifier: ConversationCellIdentifier.Text.incoming)
        
        tableView.registerNib(UINib(nibName: "IncomingLocationCell", bundle: nil), forCellReuseIdentifier: ConversationCellIdentifier.Location.incoming)
        tableView.registerNib(UINib(nibName: "OutgoingLocationCell", bundle: nil), forCellReuseIdentifier: ConversationCellIdentifier.Location.outgoing)
        
        tableView.registerNib(UINib(nibName: "OutgoingPictureCell", bundle: nil), forCellReuseIdentifier: ConversationCellIdentifier.Picture.outgoing)
        tableView.registerNib(UINib(nibName: "IncomingPictureCell", bundle: nil), forCellReuseIdentifier: ConversationCellIdentifier.Picture.incoming)
        
        tableView.registerNib(UINib(nibName: "OutgoingVideoCell", bundle: nil), forCellReuseIdentifier: ConversationCellIdentifier.Video.outgoing)
        tableView.registerNib(UINib(nibName: "IncomingVideoCell", bundle: nil), forCellReuseIdentifier: ConversationCellIdentifier.Video.incoming)
        
        tableView.registerNib(UINib(nibName: "OutgoingShoutCell", bundle: nil), forCellReuseIdentifier: ConversationCellIdentifier.Shout.outgoing)
        tableView.registerNib(UINib(nibName: "IncomingShoutCell", bundle: nil), forCellReuseIdentifier: ConversationCellIdentifier.Shout.incoming)
        
        tableView.registerNib(UINib(nibName: "OutgoingProfileCell", bundle: nil), forCellReuseIdentifier: ConversationCellIdentifier.Profile.outgoing)
        tableView.registerNib(UINib(nibName: "IncomingProfileCell", bundle: nil), forCellReuseIdentifier: ConversationCellIdentifier.Profile.incoming)
    }
    
    private func customizeTable() {
        guard let tableView = tableView else {
            assertionFailure()
            return
        }
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 50.0
        tableView.separatorStyle = .None
        
        tableView.emptyDataSetDelegate = self
        tableView.emptyDataSetSource = self
        
    }
    
    private func customizeInputView() {
        rightButton.setImage(UIImage.chatsSendButtonImage(), forState: .Normal)
        rightButton.setTitle("", forState: .Normal)
        rightButton.tintColor = UIColor(shoutitColor: ShoutitColor.ShoutitButtonGreen)
        
        leftButton.setImage(UIImage(named: "attach"), forState: .Normal)
        leftButton.setTitle("", forState: .Normal)
        leftButton.tintColor = UIColor(shoutitColor: ShoutitColor.FontGrayColor)
        
        typingIndicatorView?.interval = 3.0
        textView.placeholder = NSLocalizedString("Type a message", comment: "")
        
        // since autolayout swaps text bar, we swap it back to keep send button on the right
        if UIApplication.sharedApplication().userInterfaceLayoutDirection == .RightToLeft {
            textInputbar.transform = CGAffineTransformMakeScale(-1, 1)
            textInputbar.textView.transform = CGAffineTransformMakeScale(-1, 1)
        }
    }
    
    override func prefersTabbarHidden() -> Bool {
        return true
    }
    
    override class func tableViewStyleForCoder(decoder: NSCoder) -> UITableViewStyle {
        return UITableViewStyle.Plain
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(viewModel.cellIdentifierAtIndexPath(indexPath))
        
        let msg = viewModel.messageAtIndexPath(indexPath)
        let previousMsg = viewModel.previousMessageFor(msg)
        
        if let conversationCell = cell as? ConversationCell {
            conversationCell.bindWithMessage(msg, previousMessage: previousMsg)
        }
        
        cell!.transform = tableView.transform
        
        return cell!
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return viewModel.messages.value.keys.count
    }
    
    override func tableView(tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let view = tableView.dequeueReusableHeaderFooterViewWithIdentifier(ConversationCellIdentifier.Wireframe.daySection) as! ConversationDayHeader
        
        view.dateLabel.text = viewModel.sectionTitle(section)
        view.transform = tableView.transform
        
        return view
    }
    
    func setLoadMoreFooter() {
        
        guard let tableView = tableView else {
            assertionFailure()
            return
        }
        
        loadMoreView = NSBundle.mainBundle().loadNibNamed("ConversationLoadMoreFooter", owner: self, options: nil)[0] as? ConversationLoadMoreFooter
//        let footerHeight : CGFloat = 60.0
//        loadMoreView?.frame = CGRect(x: 0, y: -64.0, width: 300, height: 5*footerHeight)
        loadMoreView?.layoutIfNeeded()
        loadMoreView?.transform = tableView.transform
        loadMoreView?.backgroundColor = UIColor.redColor()
        
        loadMoreView?.setState(.ReadyToLoad)
        loadMoreView?.loadMoreButton.addTarget(self, action: #selector(ConversationViewController.loadMore), forControlEvents: .TouchUpInside)
        
        loadMoreBag = DisposeBag()
        
        viewModel.loadMoreState.asDriver().driveNext({ [weak self] (state) -> Void in
            self?.loadMoreView?.setState(state)
            self?.tableView?.reloadData()
        }).addDisposableTo(loadMoreBag)
        
        tableView.tableFooterView = loadMoreView
    }
    
    func setTitleView() {
        titleView = NSBundle.mainBundle().loadNibNamed("ConversationTitleViewMessage", owner: self, options: nil)[0] as? ConversationTitleView
        self.navigationItem.titleView = titleView
        
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
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let msg = self.viewModel.messageAtIndexPath(indexPath)
        
        guard let attachmentType = msg.attachment()?.type() else { return }
        
        switch attachmentType {
        case .LocationAttachment(let location): flowDelegate?.showLocation(location.coordinate())
        case .ImageAttachment(let path): flowDelegate?.showImagePreview(path.toURL()!)
        case .VideoAttachment(let video): flowDelegate?.showVideoPreview(video.path.toURL()!)
        case .ShoutAttachment(let shout): flowDelegate?.showShout(shout)
        case .ProfileAttachment(let profile): flowDelegate?.showProfile(profile)
        }
    }
    
    override func didPressRightButton(sender: AnyObject!) {
        textView.refreshFirstResponder()
        
        if viewModel.sendMessageWithText(textView.text) {
            textView.text = ""
        }
    }
    
    override func didPressLeftButton(sender: AnyObject!) {
        textView.resignFirstResponder()
        
        flowDelegate?.showAttachmentControllerWithTransitioningDelegate(self) {[weak self] (type) in
            self?.attachmentManager.requestAttachmentWithType(type)
        }
    }
    
    func showSendingError(error: ErrorType) -> Void {
        let controller = viewModel.alertControllerWithTitle(NSLocalizedString("Could not send message", comment: ""), message: error.sh_message)
        navigationController?.presentViewController(controller, animated: true, completion: nil)
    }
    
    override func textViewDidChange(textView: UITextView) {
        super.textViewDidChange(textView)

        viewModel.sendTypingEvent()
    }
    
    func customViewForEmptyDataSet(scrollView: UIScrollView!) -> UIView! {
        
        let attributedText : NSAttributedString
        if case .NotCreated = viewModel.conversation.value {
            attributedText = NSAttributedString(string: NSLocalizedString("Don't be so shy. Say something.", comment: ""))
        } else if viewModel.loadMoreState.value == .ReadyToLoad {
            attributedText = NSAttributedString(string: NSLocalizedString("No Messages to show", comment: ""))
        } else {
            attributedText = NSAttributedString(string: NSLocalizedString("Loading Messages...", comment: ""))
        }
        
        let lbl = UILabel(frame: CGRect(x: 0, y: 0, width: tableView?.frame.width ?? 0, height: tableView?.frame.height ?? 0))
        lbl.attributedText = attributedText
        lbl.transform = tableView!.transform
        lbl.textAlignment = .Center
        lbl.font = UIFont.boldSystemFontOfSize(18.0)
        lbl.textColor = UIColor.lightGrayColor()
        
        return lbl
    }
    
    @IBAction func moreAction() {
        guard case .CreatedAndLoaded(let conversation) = viewModel.conversation.value else { return }
        self.flowDelegate?.showConversationInfo(conversation)
    }
    
    func deleteAction() {
        let alert = viewModel.deleteActionAlert { [weak self] in
            self?.navigationController?.popViewControllerAnimated(true)
        }
        
        self.navigationController?.presentViewController(alert, animated: true, completion: nil)
    }
    
    @IBAction func videoCall() {
        guard case .CreatedAndLoaded(let conversation) = viewModel.conversation.value else { return }
        if let profile = conversation.coParticipant() {
          self.flowDelegate?.startVideoCallWithProfile(profile)
            return
        }
        
        if let user = conversation.shout?.user {
            self.flowDelegate?.startVideoCallWithProfile(user)
        }
    }
}

extension ConversationViewController {
    
    func showSendingMessage() {
        switch viewModel.conversation.value {
        case let .Created(conversation):
            titleView.setTitle(conversation.firstLineText()?.string, message: NSLocalizedString("Sending message", comment: ""))
        case let .CreatedAndLoaded(conversation):
            titleView.setTitle(conversation.firstLineText()?.string, message: NSLocalizedString("Sending message", comment: ""))
        case let .NotCreated(_, user, _):
            titleView.setTitle(user.name, message: NSLocalizedString("Sending message", comment: ""))
        }
    }
    
    func hideSendingMessage() {
        switch viewModel.conversation.value {
        case let .Created(conversation):
            titleView.setTitle(conversation.firstLineText()?.string, message: nil)
        case let .CreatedAndLoaded(conversation):
            titleView.setTitle(conversation.firstLineText()?.string, message: nil)
        case let .NotCreated(_, user, _):
            titleView.setTitle(user.name, message: nil)
        }
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
