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
    weak var flowDelegate: FlowController?
    
    // RX
    private var buttonsDisposeBag = DisposeBag()
    private let disposeBag = DisposeBag()
    
    // UI
    @IBOutlet weak var tabBarButtonsBar: UIView!
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
    
    func startChat() {
        guard checkIfUserIsLoggedInAndDisplayAlertIfNot() else { return }
        guard let user = viewModel.shout.user else { return }
        if let conversation = viewModel.shout.conversations?.first {
            flowDelegate?.showConversation(.Created(conversation: conversation))
        } else {
            flowDelegate?.showConversation(.NotCreated(type: .AboutShout, user: user, aboutShout: viewModel.shout))
        }
    }
    
    private func reportAction() {
        
        let alert = self.viewModel.shout.reportAlert { (report) in
            MBProgressHUD.showHUDAddedTo(self.view, animated: true)
            
            APIMiscService.makeReport(report).subscribe({ [weak self] (event) in
                MBProgressHUD.hideHUDForView(self?.view, animated: true)
                
                switch event {
                case .Next:
                    self?.showSuccessMessage(NSLocalizedString("Shout Reported Successfully", comment: ""))
                case .Error(let error):
                    self?.showError(error)
                default:
                    break
                }
                
                }).addDisposableTo(self.disposeBag)
        }
        
        self.navigationController?.presentViewController(alert, animated: true, completion: nil)
    }
    
    private func moreAction() {
        let alert = viewModel.moreAlert { (alertController) in
            self.reportAction()
        }
        
        self.navigationController?.presentViewController(alert, animated: true, completion: nil)
    }
    
    private func deleteAction() {
        let alert = viewModel.deleteAlert {
            MBProgressHUD.showHUDAddedTo(self.view, animated: true)
            
            APIShoutsService.deleteShoutWithId(self.viewModel.shout.id).subscribeOn(MainScheduler.instance).subscribe({ [weak self] (event) in
                MBProgressHUD.hideHUDForView(self?.view, animated: true)
                
                switch event {
                case .Next:
                    self?.showSuccessMessage(NSLocalizedString("Shout deleted Successfully", comment: ""))
                    NSNotificationCenter.defaultCenter().postNotificationName(Constants.Notification.ShoutDeletedNotification, object: self, userInfo: nil)
                    self?.navigationController?.popViewControllerAnimated(true)
                case .Error(let error):
                    self?.showError(error)
                default:
                    break
                }
            }).addDisposableTo(self.disposeBag)
        }
        
        self.navigationController?.presentViewController(alert, animated: true, completion: nil)
    }
    
    private func makeCall() {
        MBProgressHUD.showHUDAddedTo(self.view, animated: true)
        viewModel.makeCall()
            .subscribe {[weak self] (event) in
                MBProgressHUD.hideHUDForView(self?.view, animated: true)
                switch event {
                case .Next(let mobile):
                    guard let url = NSURL(string: "telprompt://\(mobile.phone)") else {
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

    private func videoCall() {
        guard checkIfUserIsLoggedInAndDisplayAlertIfNot() else { return }
        guard let user = viewModel.shout.user else { return }
        self.flowDelegate?.startVideoCallWithProfile(user)
    }
    
    @IBAction func shareAction() {
        let url = viewModel.shout.webPath.toURL()!
        let activityController = UIActivityViewController(activityItems: [url], applicationActivities: nil)
        activityController.excludedActivityTypes = [UIActivityTypePrint, UIActivityTypeSaveToCameraRoll, UIActivityTypePostToFlickr, UIActivityTypePostToVimeo]
        self.navigationController?.presentViewController(activityController, animated: true, completion: nil)
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
            tabBarButtonsBar.layoutIfNeeded()
        }
    }
    
    private func addActionToButton(button: UIButton, withModel model: ShoutDetailTabbarButton) {
        
        button
            .rx_tap
            .observeOn(MainScheduler.instance)
            .subscribeNext {[weak self] in
                switch model {
                case .Call:
                    self?.makeCall()
                case .VideoCall:
                    self?.videoCall()
                case .Chat:
                    self?.startChat()
                case .More:
                    self?.moreAction()
                case .Chats:
                    self?.notImplemented()
                case .Edit:
                    self?.showEditController()
                case .Delete:
                    self?.deleteAction()
                }
            }
            .addDisposableTo(buttonsDisposeBag)
    }
    
    private func showEditController() {
        self.flowDelegate?.showEditShout(viewModel.shout)
    }
}
