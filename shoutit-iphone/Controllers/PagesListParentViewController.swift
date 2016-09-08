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
    private let disposeBag = DisposeBag()
    
    @IBOutlet weak var listChoiceSegmentedControl: UISegmentedControl!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var createPageButton: UIButton!
    @IBOutlet weak var disclosureIndicatorImageView: UIImageView!
    
    @IBOutlet var leftTabConstraints : [NSLayoutConstraint]!
    @IBOutlet var rightTabConstraints : [NSLayoutConstraint]!
    
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
    
    private func setupViews() {
        disclosureIndicatorImageView.image = UIImage.rightGreenArrowDisclosureIndicator()
        createPageButton.contentHorizontalAlignment = Platform.isRTL ? .Right : .Left
    }
    
    private func setupNavigationBar() {
        navigationItem.titleView = UIImageView(image: UIImage(named: "logo_navbar_white"))
    }
    
    @IBAction func searchAction() {
        flowDelegate?.showSearchInContext(.General)
    }
    
    @IBAction func switchToPublicChats() {
        NSLayoutConstraint.deactivateConstraints(self.leftTabConstraints)
        NSLayoutConstraint.activateConstraints(self.rightTabConstraints)
        
        self.changeContentTo(self.publicPagesViewController)
    }
    
    @IBAction func switchToMyChats() {
        NSLayoutConstraint.deactivateConstraints(self.rightTabConstraints)
        NSLayoutConstraint.activateConstraints(self.leftTabConstraints)
        
        self.changeContentTo(self.myPagesViewController)
    }
    
    private func setupRX() {
        
        createPageButton
            .rx_tap
            .asDriver().driveNext { [weak self] in
                self?.showCreatePageView()
            }
            .addDisposableTo(disposeBag)
    }
    
    private func showCreatePageView() {
        let viewModel = LoginWithEmailViewModel()
        
        viewModel.loginSuccessSubject.subscribeNext { (created) in
            if created {
                self.navigationController?.popToViewController(self, animated: true)
            }
        }.addDisposableTo(disposeBag)
        
        self.flowDelegate?.showCreatePage(viewModel)
    }
}
