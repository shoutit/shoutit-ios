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
import ShoutitKit

enum ShoutDetailTabbarButton {
    case call
    case videoCall
    case chat
    case more
    case chats
    case promote(promoted: Bool)
    case edit
    case delete
    
    var title: String {
        switch self {
        case .call:
            return NSLocalizedString("Call", comment: "Shout detail tab bar item")
        case .videoCall:
            return NSLocalizedString("Video call", comment: "Shout detail tab bar item")
        case .chat:
            return NSLocalizedString("Chat", comment: "Shout detail tab bar item")
        case .more:
            return NSLocalizedString("More", comment: "Shout detail tab bar item")
        case .chats:
            return NSLocalizedString("Chats", comment: "Shout detail tab bar item")
        case .promote(true):
            return NSLocalizedString("Promoted", comment: "Shout detail tab bar item")
        case .promote(false):
            return NSLocalizedString("Promote", comment: "Shout detail tab bar item")
        case .edit:
            return LocalizedString.edit
        case .delete:
            return LocalizedString.delete
        default:
            fatalError()
        }
    }
    
    var image: UIImage {
        switch self {
        case .call:
            return UIImage.shoutDetailTabBarCallImage()
        case .videoCall:
            return UIImage.shoutDetailTabBarVideoCallImage()
        case .chat:
            return UIImage.shoutDetailTabBarChatImage()
        case .more:
            return UIImage.shoutDetailTabBarMoreImage()
        case .chats:
            return UIImage.shoutDetailTabBarChatImage()
        case .promote:
            return UIImage.shoutDetailTabBarPromoteStarImage()
        case .edit:
            return UIImage.shoutDetailTabBarEditImage()
        case .delete:
            return UIImage.shoutDetailTabBarDeleteImage()
        }
    }
    
    var color: UIColor {
        switch self {
        case .promote:
            return UIColor(shoutitColor: .promoteActionYellowColor)
        default:
            return UIColor.white
        }
    }
}

class ShowDetailContainerViewController: UIViewController {
    
    // view model
    var viewModel: ShoutDetailViewModel!
    
    // navigation
    weak var flowDelegate: FlowController?
    
    // RX
    fileprivate var buttonsDisposeBag = DisposeBag()
    fileprivate let disposeBag = DisposeBag()
    
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
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        
        if let destination = segue.destination as? ShoutDetailTableViewController {
            destination.viewModel = viewModel
            destination.flowDelegate = flowDelegate
        }
    }
    
    override func prefersTabbarHidden() -> Bool {
        return true
    }
    
    // MARK: - Setup
    
    fileprivate func setupRx() {
        
        viewModel.reloadObservable
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: { [weak self] in
                self?.layoutButtons(reload: true)
            })
            .addDisposableTo(disposeBag)
    }
    
    @IBAction func shareAction() {
        let url = viewModel.shout.webPath.toURL()!
        let activityController = UIActivityViewController(activityItems: [url], applicationActivities: nil)
        activityController.excludedActivityTypes = [UIActivityType.print, UIActivityType.saveToCameraRoll, UIActivityType.postToFlickr, UIActivityType.postToVimeo]
        self.navigationController?.present(activityController, animated: true, completion: nil)
    }
    
    // MARK: - Helpers
    
    fileprivate func layoutButtons(reload: Bool) {
        
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
            button.setImage(model.image, for: UIControlState())
            button.setTitle(model.title, for: UIControlState())
            button.tintColor = model.color
            button.titleLabel?.textColor = model.color
            addActionToButton(button, withModel: model)
        }
        
        if reload {
            tabBarButtonsBar.layoutIfNeeded()
        }
    }
    
    fileprivate func addActionToButton(_ button: UIButton, withModel model: ShoutDetailTabbarButton) {
        
        button
            .rx.tap
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: {[weak self] in
                switch model {
                case .call:
                    self?.makeCall()
                case .videoCall:
                    self?.videoCall()
                case .chat:
                    self?.startChat()
                case .more:
                    self?.moreAction()
                case .chats:
                    self?.notImplemented()
                case .edit:
                    self?.showEditController()
                case .delete:
                    self?.deleteAction()
                case .promote(true):
                    self?.promotedAction()
                case .promote(false):
                    self?.promoteAction()
                default:
                    fatalError()
                }
            })
            .addDisposableTo(buttonsDisposeBag)
    }
}

private extension ShowDetailContainerViewController {
    
    func startChat() {
        guard checkIfUserIsLoggedInAndDisplayAlertIfNot() else { return }
        guard let user = viewModel.shout.user else { return }
        if let conversation = viewModel.shout.conversations?.first {
            flowDelegate?.showConversation(.created(conversation: conversation))
        } else {
            flowDelegate?.showConversation(.notCreated(type: .AboutShout, user: user, aboutShout: viewModel.shout))
        }
    }
    
    func reportAction() {
        
        let alert = self.viewModel.shout.reportAlert { (report) in
            MBProgressHUD.showAdded(to: self.view, animated: true)
            
            APIMiscService.makeReport(report).subscribe({ [weak self] (event) in
                if let view = self?.view {
                    MBProgressHUD.hide(for: view, animated: true)
                }
                
                switch event {
                case .next:
                    self?.showSuccessMessage(NSLocalizedString("Shout Reported Successfully", comment: ""))
                case .error(let error):
                    self?.showError(error)
                default:
                    break
                }
                
                }).addDisposableTo(self.disposeBag)
        }
        
        self.navigationController?.present(alert, animated: true, completion: nil)
    }
    
    func moreAction() {
        let isShoutOwnedByCurrentUser = viewModel.shout.user?.id == Account.sharedInstance.user?.id
        let reportHandler: ((Void) -> Void)? = isShoutOwnedByCurrentUser ? nil : reportAction
        let deleteHandler: ((Void) -> Void)? = isShoutOwnedByCurrentUser ? deleteAction : nil
        let alert = moreAlert(reportHandler, deleteHandler: deleteHandler)
        self.navigationController?.present(alert, animated: true, completion: nil)
    }
    
    func deleteAction() {
        let alert = deleteAlert {
            MBProgressHUD.showHUDAddedTo(self.view, animated: true)
            
            APIShoutsService.deleteShoutWithId(self.viewModel.shout.id).subscribeOn(MainScheduler.instance).subscribe({ [weak self] (event) in
                MBProgressHUD.hideHUDForView(self?.view, animated: true)
                
                switch event {
                case .Next:
                    self?.showSuccessMessage(NSLocalizedString("Shout deleted Successfully", comment: ""))
                    NSNotificationCenter.defaultCenter().postNotificationName(Constants.Notification.ShoutDeletedNotification, object: self, userInfo: nil)
                    self?.navigationController?.popViewControllerAnimated(true)
                case .error(let error):
                    self?.showError(error)
                default:
                    break
                }
                }).addDisposableTo(self.disposeBag)
        }
        
        self.navigationController?.present(alert, animated: true, completion: nil)
    }
    
    func makeCall() {
        MBProgressHUD.showAdded(to: self.view, animated: true)
        viewModel.makeCall()
            .subscribe {[weak self] (event) in
                if let view = self?.view {
                    MBProgressHUD.hide(for: view, animated: true)
                }
                switch event {
                case .next(let mobile):
                    guard let url = URL(string: "telprompt://\(mobile.phone)") else {
                        assertionFailure()
                        return
                    }
                    UIApplication.shared.openURL(url)
                case .error(let error):
                    self?.showError(error)
                default:
                    break
                }
            }
            .addDisposableTo(disposeBag)
    }
    
    func videoCall() {
        guard checkIfUserIsLoggedInAndDisplayAlertIfNot() else { return }
        guard let user = viewModel.shout.user else { return }
        self.flowDelegate?.startVideoCallWithProfile(user)
    }
    
    func showEditController() {
        self.flowDelegate?.showEditShout(viewModel.shout)
    }
    
    func promoteAction() {
        flowDelegate?.showPromoteViewWithShout(viewModel.shout)
    }
    
    func promotedAction() {
        flowDelegate?.showPromotedViewWithShout(viewModel.shout)
    }
}
