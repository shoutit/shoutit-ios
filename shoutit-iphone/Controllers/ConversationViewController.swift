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
    
    private let conversationTextCellIdentifier = "conversationTextCellIdentifier"
    private let disposeBag = DisposeBag()
 
    override func viewDidLoad() {
        super.viewDidLoad()
        
        viewModel = ConversationViewModel(conversation: self.conversation, delegate: self)
        viewModel.fetchMessages()
    
        tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: conversationTextCellIdentifier)
        
        viewModel.messages.asDriver().driveNext { [weak self] (messages) -> Void in
            self?.tableView.reloadData()
        }.addDisposableTo(disposeBag)
        
    }
    
    override func prefersTabbarHidden() -> Bool {
        return true
    }
    
    override class func tableViewStyleForCoder(decoder: NSCoder!) -> UITableViewStyle {
        return UITableViewStyle.Plain
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(conversationTextCellIdentifier) as UITableViewCell!
        
        let msg = viewModel.messages.value[indexPath.row]
        
        cell.textLabel?.text = msg.text
        
        cell.transform = tableView.transform
        
        return cell
    }
    
    override func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.viewModel.messages.value.count
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
