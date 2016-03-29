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
    let disposeBag = DisposeBag()
    
    // UI
    @IBOutlet var tabBatButtons: [TabbarButton]! // tagged from 0 to 3
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // setup navigation bar
        self.navigationItem.titleView = UIImageView(image: UIImage.navBarLogoWhite())
        
        // setup tabbar buttons
        let buttonModels = viewModel.tabbarButtons()
        for button in tabBatButtons {
            let model = buttonModels[button.tag]
            button.setImage(model.image, forState: .Normal)
            button.setTitle(model.title, forState: .Normal)
            addActionToButton(button, withModel: model)
        }
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
    
    func videoCall() {
        guard userIsLoggedIn() else {
          return
        }
        
        self.flowDelegate?.startVideoCallWithProfile(viewModel.shout.user)
        
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
    
    @IBAction func searchAction() {
        flowDelegate?.showSearchInContext(.General)
    }
    
    // MARK: - Helpers
    
    private func addActionToButton(button: UIButton, withModel model: ShoutDetailTabbarButton) {
        
        button
            .rx_tap
            .observeOn(MainScheduler.instance)
            .subscribeNext {
                switch model {
                case .Call:
                    self.notImplemented()
                case .VideoCall:
                    self.videoCall()
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
            .addDisposableTo(disposeBag)
    }
    
    private func showEditController() {
        let editController = Wireframe.editShoutController()
        editController.shout = viewModel.shout
        self.navigationController?.pushViewController(editController, animated: true)
    }
}
