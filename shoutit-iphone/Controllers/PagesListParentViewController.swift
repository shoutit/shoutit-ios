//
//  PagesListParentViewController.swift
//  shoutit
//
//  Created by Łukasz Kasperek on 23.06.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import ShoutitKit

class PagesListParentViewController: UIViewController, ContainerController {
    
    // RX
    fileprivate let disposeBag = DisposeBag()
    
    @IBOutlet weak var listChoiceSegmentedControl: UISegmentedControl!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var createPageButton: UIButton!
    @IBOutlet weak var disclosureIndicatorImageView: UIImageView!
    
    // ContainerController
    weak var currentChildViewController: UIViewController?
    var currentControllerConstraints: [NSLayoutConstraint] = []
    
    // navigation
    weak var flowDelegate: FlowController?
    
    lazy var myPagesViewController: MyPagesTableViewController = {[unowned self] in
        let controller = Wireframe.myPagesTableViewController()
        controller.viewModel = MyPagesViewModel()
        controller.flowDelegate = self.flowDelegate
        return controller
    }()
    
    lazy var publicPagesViewController: PublicPagesTableViewController = {[unowned self] in
        let controller = Wireframe.publicPagesTableViewController()
        controller.viewModel = PublicPagesViewModel()
        controller.flowDelegate = self.flowDelegate
        return controller
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupRX()
        setupNavigationBar()
        setupViews()
    }
    
    fileprivate func setupViews() {
        disclosureIndicatorImageView.image = UIImage.rightGreenArrowDisclosureIndicator()
        createPageButton.contentHorizontalAlignment = Platform.isRTL ? .right : .left
    }
    
    fileprivate func setupNavigationBar() {
        navigationItem.titleView = UIImageView(image: UIImage(named: "logo_navbar_white"))
    }
    
    @IBAction func searchAction() {
        flowDelegate?.showSearchInContext(.general)
    }
    
    func switchToPublicChats() {
        listChoiceSegmentedControl.selectedSegmentIndex = 1
        self.changeContentTo(self.publicPagesViewController)
    }
    
    func switchToMyChats() {
        listChoiceSegmentedControl.selectedSegmentIndex = 0
        self.changeContentTo(self.myPagesViewController)
    }
    
    fileprivate func setupRX() {
        
        listChoiceSegmentedControl
            .rx_value
            .asDriver()
            .driveNext { [unowned self] (value) in
                if value == 0 {
                    self.changeContentTo(self.myPagesViewController)
                }
                else if value == 1 {
                    self.changeContentTo(self.publicPagesViewController)
                }
            }
            .addDisposableTo(disposeBag)
        
        createPageButton
            .rx_tap
            .asDriver().driveNext { [weak self] in
                self?.showCreatePageView()
            }
            .addDisposableTo(disposeBag)
    }
    
    fileprivate func showCreatePageView() {
        let viewModel = LoginWithEmailViewModel()
        
        viewModel.loginSuccessSubject.subscribeNext { (created) in
            if created {
                self.navigationController?.popToViewController(self, animated: true)
            }
        }.addDisposableTo(disposeBag)
        
        self.flowDelegate?.showCreatePage(viewModel)
    }
}
