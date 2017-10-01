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
import ShoutitKit

final class ConversationViewController: SLKTextViewController, ConversationPresenter, DZNEmptyDataSetDelegate, DZNEmptyDataSetSource, UIViewControllerTransitioningDelegate {
    weak var flowDelegate: FlowController?
    
    var viewModel : ConversationViewModel!
    let attachmentManager = ConversationAttachmentManager()
    var loadMoreView : ConversationLoadMoreFooter?
    var titleView : ConversationTitleView!
    @IBOutlet var moreRightBarButtonItem: UIBarButtonItem!
    @IBOutlet var videoCallRightBarButtonItem: UIBarButtonItem!
    
    fileprivate let disposeBag = DisposeBag()
    fileprivate var loadMoreBag = DisposeBag()
 
    // MARK: - Lifecycle
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
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        viewModel.createSocketObservable()
        
        NotificationCenter.default.addObserver(self, selector: #selector(subscribeSockets), name: NSNotification.Name.UIApplicationWillEnterForeground, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(unsubscribeSockets), name: NSNotification.Name.UIApplicationDidEnterBackground, object: nil)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        self.textView.becomeFirstResponder()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        viewModel.unsubscribeSockets()
        
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIApplicationWillEnterForeground, object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIApplicationDidEnterBackground, object: nil)
    }

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        layoutInsets()
    }
    
    func subscribeSockets() {
        self.viewModel.createSocketObservable()
    }
    
    func unsubscribeSockets() {
        self.viewModel.unsubscribeSockets()
    }
    
    func layoutInsets() {
        if let _ = viewModel.conversation.value.shout?.id {
            tableView?.contentInset = UIEdgeInsetsMake(0, 0, 64.0, 0)
        } else {
            tableView?.contentInset = UIEdgeInsets.zero
        }
    }
    
    fileprivate func setTopicShout(_ shout: Shout) {
        guard let shoutView = Bundle.main.loadNibNamed("ConversationShoutHeader", owner: self, options: nil)?[0] as? ConversationShoutHeader else {
            return
        }
        
        shoutView.tapGesture.addTarget(self, action: #selector(ConversationViewController.showShout))
        shoutView.translatesAutoresizingMaskIntoConstraints = false
        
        shoutView.bindWith(Shout: shout)
        
        view.addSubview(shoutView)
        
        view.addConstraints([NSLayoutConstraint(item: shoutView, attribute: .leading, relatedBy: .equal, toItem: view, attribute: .leading, multiplier: 1.0, constant: 0),
                            NSLayoutConstraint(item: shoutView, attribute: .trailing, relatedBy: .equal, toItem: view, attribute: .trailing, multiplier: 1.0, constant: 0),
                            NSLayoutConstraint(item: shoutView, attribute: .top, relatedBy: .equal, toItem: view, attribute: .top, multiplier: 1.0, constant: 64.0)])
        
        shoutView.addConstraint(NSLayoutConstraint(item: shoutView, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 64.0))
        
        shoutView.clipsToBounds = true
        
        shoutView.layoutIfNeeded()
        
        layoutInsets()
    }
    
    func showShout() {
        if let shout = viewModel.conversation.value.shout {
            self.flowDelegate?.showShout(shout)
        }        
    }
    
    fileprivate func setupDataSource() {
        
        viewModel.fetchFullConversation()
        viewModel.fetchMessages()
        
        viewModel.messages.asDriver().drive(onNext: { [weak self] (messages) -> Void in
            self?.tableView?.reloadData()
        }).addDisposableTo(disposeBag)
        
        viewModel.typingUsers.asDriver(onErrorJustReturn: nil).drive(onNext: { [weak self] (profile) -> Void in
            guard let profile = profile else { return }
            self?.typingIndicatorView?.insertUsername(profile.username)
        }).addDisposableTo(disposeBag)
        
        viewModel.sendingMessages.asDriver().drive(onNext: { [weak self] (messages) in
            if messages.count > 0 {
                self?.showSendingMessage()
            } else {
                self?.hideSendingMessage()
            }
        }).addDisposableTo(disposeBag)
        
        viewModel.presentingSubject.subscribe(onNext: { [weak self] (controller) in
            guard let controller = controller else { return }
            self?.navigationController?.present(controller, animated: true, completion: nil)
        }).addDisposableTo(disposeBag)
        
        viewModel.conversation.asObservable()
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: {[weak self] (conversationExistance) in
                if let shout = conversationExistance.shout {
                    self?.setTopicShout(shout)
                }
                self?.setupBarButtonItemsForConversationState(conversationExistance)
            })
            .addDisposableTo(disposeBag)
    }
    
    fileprivate func setupAttachmentManager() {
        attachmentManager.attachmentSelected.subscribe(onNext: { [weak self] (attachment) in
            self?.viewModel.sendMessageWithAttachment(attachment)
        }).addDisposableTo(disposeBag)
        
        attachmentManager.presentingSubject
            .subscribe(onNext: { [weak self] (controller) in
                guard let controller = controller else { return }
                self?.navigationController?.present(controller, animated: true, completion: nil)
            })
            .addDisposableTo(disposeBag)
        
        attachmentManager.pushingSubject
            .subscribe(onNext: { [weak self] (controller) in
                guard let controller = controller else { return }
                self?.navigationController?.show(controller, sender: nil)
            })
            .addDisposableTo(disposeBag)
        
    }
    
    fileprivate func registerSupplementaryViews() {
        guard let tableView = tableView else {
            assertionFailure()
            return
        }
        tableView.register(UINib(nibName: "ConversationDayHeader", bundle: nil), forHeaderFooterViewReuseIdentifier: ConversationCellIdentifier.Wireframe.daySection)
        
        tableView.register(UINib(nibName: "OutgoingCell", bundle: nil), forCellReuseIdentifier: ConversationCellIdentifier.Text.outgoing)
        tableView.register(UINib(nibName: "IncomingCell", bundle: nil), forCellReuseIdentifier: ConversationCellIdentifier.Text.incoming)
        
        tableView.register(UINib(nibName: "IncomingLocationCell", bundle: nil), forCellReuseIdentifier: ConversationCellIdentifier.Location.incoming)
        tableView.register(UINib(nibName: "OutgoingLocationCell", bundle: nil), forCellReuseIdentifier: ConversationCellIdentifier.Location.outgoing)
        
        tableView.register(UINib(nibName: "OutgoingPictureCell", bundle: nil), forCellReuseIdentifier: ConversationCellIdentifier.Picture.outgoing)
        tableView.register(UINib(nibName: "IncomingPictureCell", bundle: nil), forCellReuseIdentifier: ConversationCellIdentifier.Picture.incoming)
        
        tableView.register(UINib(nibName: "OutgoingVideoCell", bundle: nil), forCellReuseIdentifier: ConversationCellIdentifier.Video.outgoing)
        tableView.register(UINib(nibName: "IncomingVideoCell", bundle: nil), forCellReuseIdentifier: ConversationCellIdentifier.Video.incoming)
        
        tableView.register(UINib(nibName: "OutgoingShoutCell", bundle: nil), forCellReuseIdentifier: ConversationCellIdentifier.Shout.outgoing)
        tableView.register(UINib(nibName: "IncomingShoutCell", bundle: nil), forCellReuseIdentifier: ConversationCellIdentifier.Shout.incoming)
        
        tableView.register(UINib(nibName: "OutgoingProfileCell", bundle: nil), forCellReuseIdentifier: ConversationCellIdentifier.Profile.outgoing)
        tableView.register(UINib(nibName: "IncomingProfileCell", bundle: nil), forCellReuseIdentifier: ConversationCellIdentifier.Profile.incoming)
        
        tableView.register(UINib(nibName: "SpecialMessageCell", bundle: nil), forCellReuseIdentifier: ConversationCellIdentifier.special)
        
    }
    
    fileprivate func customizeTable() {
        guard let tableView = tableView else {
            assertionFailure()
            return
        }
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 50.0
        tableView.separatorStyle = .none
        
        tableView.emptyDataSetDelegate = self
        tableView.emptyDataSetSource = self
        
        if #available(iOS 11.0, *) {
            tableView.contentInsetAdjustmentBehavior = .never
        }
    }
    
    fileprivate func customizeInputView() {
        rightButton.setImage(UIImage.chatsSendButtonImage(), for: UIControlState())
        rightButton.setTitle("", for: UIControlState())
        rightButton.tintColor = UIColor(shoutitColor: ShoutitColor.shoutitButtonGreen)
        
        leftButton.setImage(UIImage(named: "attach"), for: UIControlState())
        leftButton.setTitle("", for: UIControlState())
        leftButton.tintColor = UIColor(shoutitColor: ShoutitColor.fontGrayColor)
        
        typingIndicatorView?.interval = 3.0
        textView.placeholder = NSLocalizedString("Type a message", comment: "Chat textview placeholder")
        
        textView.keyboardType = .default
        
        // since autolayout swaps text bar, we swap it back to keep send button on the right
        if UIApplication.shared.userInterfaceLayoutDirection == .rightToLeft {
            textInputbar.transform = CGAffineTransform(scaleX: -1, y: 1)
            textInputbar.textView.transform = CGAffineTransform(scaleX: -1, y: 1)
        }
    }
    
    override func prefersTabbarHidden() -> Bool {
        return true
    }
    
    override class func tableViewStyle(for decoder: NSCoder) -> UITableViewStyle {
        return UITableViewStyle.plain
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: viewModel.cellIdentifierAtIndexPath(indexPath))
        
        let msg = viewModel.messageAtIndexPath(indexPath)
        let previousMsg = viewModel.previousMessageFor(msg)
        
        if let conversationCell = cell as? ConversationCell {
            hydrateCell(conversationCell, withMessage: msg, previousMessage: previousMsg)
        }
        
        cell!.transform = tableView.transform
        
        return cell!
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return viewModel.messages.value.keys.count
    }
    
    override func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let view = tableView.dequeueReusableHeaderFooterView(withIdentifier: ConversationCellIdentifier.Wireframe.daySection) as! ConversationDayHeader
        
        view.dateLabel.text = viewModel.sectionTitle(section)
        view.transform = tableView.transform
        
        return view
    }
    
    func setLoadMoreFooter() {
        
        guard let tableView = tableView else {
            assertionFailure()
            return
        }
        
        loadMoreView = Bundle.main.loadNibNamed("ConversationLoadMoreFooter", owner: self, options: nil)?[0] as? ConversationLoadMoreFooter
//        let footerHeight : CGFloat = 60.0
//        loadMoreView?.frame = CGRect(x: 0, y: -64.0, width: 300, height: 5*footerHeight)
        loadMoreView?.layoutIfNeeded()
        loadMoreView?.transform = tableView.transform
        loadMoreView?.backgroundColor = UIColor.red
        
        loadMoreView?.setState(.readyToLoad)
        loadMoreView?.loadMoreButton.addTarget(self, action: #selector(ConversationViewController.loadMore), for: .touchUpInside)
        
        loadMoreBag = DisposeBag()
        
        viewModel.loadMoreState.asDriver().drive(onNext: { [weak self] (state) -> Void in
            self?.loadMoreView?.setState(state)
            self?.tableView?.reloadData()
        }).addDisposableTo(loadMoreBag)
        
        tableView.tableFooterView = loadMoreView
    }
    
    func setTitleView() {
        titleView = Bundle.main.loadNibNamed("ConversationTitleViewMessage", owner: self, options: nil)?[0] as? ConversationTitleView
        self.navigationItem.titleView = titleView
        
    }
    
    func loadMore() {
        viewModel.triggerLoadMore()
    }
    
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 30.0
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.viewModel.numberOfRowsInSection(section)
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let msg = self.viewModel.messageAtIndexPath(indexPath)
        
        guard let attachmentType = msg.attachment()?.type() else { return }
        
        switch attachmentType {
        case .locationAttachment(let location): flowDelegate?.showLocation(location.coordinate())
        case .imageAttachment(let path): flowDelegate?.showImagePreview(path.toURL()!)
        case .videoAttachment(let video):
            guard let videoURL = video.path.toURL(), let thumbURL = video.thumbnailPath.toURL() else { return }
            flowDelegate?.showVideoPreview(videoURL, thumbnailURL: thumbURL)
        case .shoutAttachment(let shout): flowDelegate?.showShout(shout)
        case .profileAttachment(let profile): flowDelegate?.showProfile(profile)
        }
    }
    
    override func didPressRightButton(_ sender: Any!) {
        textView.refreshFirstResponder()
        
        if viewModel.sendMessageWithText(textView.text) {
            textView.text = ""
        }
    }
    
    override func didPressLeftButton(_ sender: Any!) {
        textView.resignFirstResponder()
        
        flowDelegate?.showAttachmentControllerWithTransitioningDelegate(self) {[weak self] (type) in
            self?.attachmentManager.requestAttachmentWithType(type)
        }
    }
    
    func showSendingError(_ error: Error) -> Void {
        let controller = viewModel.alertControllerWithTitle(NSLocalizedString("Could not send message", comment: "Error Message"), message: error.sh_message)
        navigationController?.present(controller, animated: true, completion: nil)
    }
    
    override func textViewDidChange(_ textView: UITextView) {
        super.textViewDidChange(textView)

        viewModel.sendTypingEvent()
    }
    
    func customView(forEmptyDataSet scrollView: UIScrollView!) -> UIView! {
        
        let attributedText : NSAttributedString
        if case .notCreated = viewModel.conversation.value {
            attributedText = NSAttributedString(string: NSLocalizedString("Don't be so shy. Say something.", comment: "New Conversation Placeholder"))
        } else if viewModel.loadMoreState.value == .readyToLoad {
            attributedText = NSAttributedString(string: NSLocalizedString("No Messages to show", comment: "No Chat Messages Message"))
        } else {
            attributedText = NSAttributedString(string: NSLocalizedString("Loading Messages...", comment: "Loading Chat messages"))
        }
        
        let lbl = UILabel(frame: CGRect(x: 0, y: 0, width: tableView?.frame.width ?? 0, height: tableView?.frame.height ?? 0))
        lbl.attributedText = attributedText
        lbl.transform = tableView!.transform
        lbl.textAlignment = .center
        lbl.font = UIFont.boldSystemFont(ofSize: 18.0)
        lbl.textColor = UIColor.lightGray
        
        return lbl
    }
    
    @IBAction func moreAction() {
        guard case .createdAndLoaded(let conversation) = viewModel.conversation.value else { return }
        self.flowDelegate?.showConversationInfo(conversation)
    }
    
    func deleteAction() {
        let alert = viewModel.deleteActionAlert { [weak self] in
            self?.navigationController?.popViewController(animated: true)
        }
        
        self.navigationController?.present(alert, animated: true, completion: nil)
    }
    
    @IBAction func videoCall() {
        guard case .createdAndLoaded(let conversation) = viewModel.conversation.value else { return }
        if let profile = conversation.coParticipant(Account.sharedInstance.user?.id) {
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
        case let .created(conversation):
            titleView.setTitle(conversation.firstLineText()?.string, message: NSLocalizedString("Sending message", comment: "Sending Chat Message"))
        case let .createdAndLoaded(conversation):
            titleView.setTitle(conversation.firstLineText()?.string, message: NSLocalizedString("Sending message", comment: "Sending Chat Message"))
        case let .notCreated(_, user, _):
            titleView.setTitle(user.name, message: NSLocalizedString("Sending message", comment: "Sending Chat Message"))
        }
    }
    
    func hideSendingMessage() {
        switch viewModel.conversation.value {
        case let .created(conversation):
            titleView.setTitle(conversation.firstLineText()?.string, message: nil)
        case let .createdAndLoaded(conversation):
            titleView.setTitle(conversation.firstLineText()?.string, message: nil)
        case let .notCreated(_, user, _):
            titleView.setTitle(user.name, message: nil)
        }
    }
}

extension ConversationViewController {
    
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return OverlayAnimationController()
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return OverlayDismissAnimationController()
    }
}

private extension ConversationViewController {
    
    func setupBarButtonItemsForConversationState(_ state: ConversationViewModel.ConversationExistance) {
        
        switch state {
        case .created:
            navigationItem.rightBarButtonItems?.forEach{$0.isEnabled = true}
            navigationItem.setRightBarButtonItems([moreRightBarButtonItem], animated: true)
        case .createdAndLoaded(let conversation):
            navigationItem.rightBarButtonItems?.forEach{$0.isEnabled = true}
            if conversation.type() == .PublicChat {
                navigationItem.setRightBarButtonItems([moreRightBarButtonItem], animated: true)
            } else if let participants = conversation.users, participants.count != 2 {
                navigationItem.setRightBarButtonItems([moreRightBarButtonItem], animated: true)
            } else {
                navigationItem.setRightBarButtonItems([moreRightBarButtonItem, videoCallRightBarButtonItem], animated: true)
            }
        case .notCreated:
            navigationItem.rightBarButtonItems?.forEach{$0.isEnabled = false}
        }
    }
}
