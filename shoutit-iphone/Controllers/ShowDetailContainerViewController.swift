//
//  ShowDetailContainerViewController.swift
//  shoutit-iphone
//
//  Created by Łukasz Kasperek on 01.03.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import MBProgressHUD

enum ShoutDetailTabbarButton {
    case Call
    case VideoCall
    case Chat
    case More
    case Chats
    case Edit
    case Delete
    
    var title: String {
        switch self {
        case .Call:
            return NSLocalizedString("Call", comment: "Shout detail tab bar item")
        case .VideoCall:
            return NSLocalizedString("Video call", comment: "Shout detail tab bar item")
        case .Chat:
            return NSLocalizedString("Chat", comment: "Shout detail tab bar item")
        case .More:
            return NSLocalizedString("More", comment: "Shout detail tab bar item")
        case .Chats:
            return NSLocalizedString("Chats", comment: "Shout detail tab bar item")
        case .Edit:
            return NSLocalizedString("Edit", comment: "Shout detail tab bar item")
        case .Delete:
            return NSLocalizedString("Delete", comment: "Shout detail tab bar item")
        }
    }
    
    var image: UIImage {
        switch self {
        case .Call:
            return UIImage.shoutDetailTabBarCallImage()
        case .VideoCall:
            return UIImage.shoutDetailTabBarVideoCallImage()
        case .Chat:
            return UIImage.shoutDetailTabBarChatImage()
        case .More:
            return UIImage.shoutDetailTabBarMoreImage()
        case .Chats:
            return UIImage.shoutDetailTabBarChatImage()
        case .Edit:
            return UIImage.shoutDetailTabBarEditImage()
        case .Delete:
            return UIImage.shoutDetailTabBarDeleteImage()
        }
    }
}

class ShowDetailContainerViewController: UIViewController {
    
    // view model
    var viewModel: ShoutDetailViewModel!
    
    // navigation
    weak var flowDelegate: ShoutDetailTableViewControllerFlowDelegate?
    
    // RX
    private var buttonsDisposeBag = DisposeBag()
    private let disposeBag = DisposeBag()
    
    // UI
    @IBOutlet var tabBatButtons: [TabbarButton]! // tagged from 0 to 3
    @IBOutlet var tabBarButtonsWidthConstraints: [NSLayoutConstraint]!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        precondition(viewModel != nil)
        
        self.navigationItem.titleView = UIImageView(image: UIImage.navBarLogoWhite())
        setupRx()
        layoutButtons(reload: false)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        super.prepareForSegue(segue, sender: sender)
        
        if let destination = segue.destinationViewController as? ShoutDetailTableViewController {
            destination.viewModel = viewModel
            destination.flowDelegate = flowDelegate
        }
    }
    
    override func prefersTabbarHidden() -> Bool {
        return true
    }
    
    // MARK: - Setup
    
    private func setupRx() {
        
        viewModel.reloadObservable
            .observeOn(MainScheduler.instance)
            .subscribeNext { [weak self] in
                self?.layoutButtons(reload: true)
            }
            .addDisposableTo(disposeBag)
    }
    
    // MARK: - Actions
    
    func startChat() {
        guard userIsLoggedIn() else {
            return
        }
        
        if self.viewModel.shout.conversations?.count == 0 {
            let conversation = Conversation(id: "", createdAt: 0, modifiedAt: 0, apiPath: "", webPath: "", typeString: "about_shout", users:  [Box(viewModel.shout.user)], lastMessage: nil, shout: viewModel.shout, readby: nil)
            
            self.flowDelegate?.showConversation(conversation)
            
            return
        }
        
        
        if self.viewModel.shout.conversations?.count  > 1 {
            print("multiple conversations")
        } else {
            self.flowDelegate?.showConversation((self.viewModel.shout.conversations?.first!)!)
        }
    }
    
    private func makeCall() {
        MBProgressHUD.showHUDAddedTo(self.view, animated: true)
        viewModel.makeCall()
            .subscribe {[weak self] (event) in
                MBProgressHUD.hideHUDForView(self?.view, animated: true)
                switch event {
                case .Next(let mobile):
                    guard let url = NSURL(string: "tel://\(mobile.phone)") else {
                        assertionFailure()
                        return
                    }
                    UIApplication.sharedApplication().openURL(url)
                case .Error(let error):
                    self?.showError(error)
                default:
                    break
                }
            }
            .addDisposableTo(disposeBag)
    }
    
    @IBAction func searchAction() {
        flowDelegate?.showSearchInContext(.General)
    }
    
    // MARK: - Helpers
    
    private func layoutButtons(reload reload: Bool) {
        
        buttonsDisposeBag = DisposeBag()
        let buttonModels = viewModel.tabbarButtons()
        let singleButtonWidth = floor(view.frame.width / CGFloat(buttonModels.count))
        
        for button in tabBatButtons {
            let constraint = tabBarButtonsWidthConstraints[button.tag]
            guard buttonModels.count > button.tag else {
                constraint.constant = 0
                continue
            }
            constraint.constant = singleButtonWidth
            let model = buttonModels[button.tag]
            button.setImage(model.image, forState: .Normal)
            button.setTitle(model.title, forState: .Normal)
            addActionToButton(button, withModel: model)
        }
        
        if reload {
            view.layoutIfNeeded()
        }
    }
    
    private func addActionToButton(button: UIButton, withModel model: ShoutDetailTabbarButton) {
        
        button
            .rx_tap
            .observeOn(MainScheduler.instance)
            .subscribeNext {
                switch model {
                case .Call:
                    self.makeCall()
                case .VideoCall:
                    self.notImplemented()
                case .Chat:
                    self.startChat()
                case .More:
                    self.notImplemented()
                case .Chats:
                    self.notImplemented()
                case .Edit:
                    self.showEditController()
                case .Delete:
                    self.notImplemented()
                }
            }
            .addDisposableTo(buttonsDisposeBag)
    }
    
    private func showEditController() {
        let editController = Wireframe.editShoutController()
        editController.shout = viewModel.shout
        self.navigationController?.pushViewController(editController, animated: true)
    }
}
