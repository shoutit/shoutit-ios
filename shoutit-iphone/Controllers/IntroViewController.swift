//
//  IntroViewController.swift
//  shoutit-iphone
//
//  Created by Łukasz Kasperek on 27.01.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import MBProgressHUD

protocol IntroViewControllerFlowDelegate: class, HelpDisplayable, LoginFinishable {
    func showLoginChoice() -> Void
}

final class IntroViewController: UIViewController {
    
    // consts
    let numberOfPagesInScrollView: CGFloat = 5
    
    // subviews
    @IBOutlet weak var loginButton: CustomUIButton!
    @IBOutlet weak var skipButton: UIButton!
    @IBOutlet weak var helpButton: UIButton!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var pageControl: UIPageControl!
    
    // view model
    var viewModel: IntroViewModel!
    
    // rx
    private let disposeBag = DisposeBag()
    
    // navigation
    weak var flowDelegate: IntroViewControllerFlowDelegate?
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //
        setupRX()
        scrollView.delegate = self
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return .LightContent
    }
    
    // MARK: - Setup
    
    private func setupRX() {
        
        // view model signals
        viewModel.errorSubject.subscribeNext {[weak self] (error) -> Void in
                self?.showError(error)
            }.addDisposableTo(disposeBag)
        
        viewModel.loginSuccessSubject.subscribeNext {[weak self] in
                self?.flowDelegate?.didFinishLoginProcessWithSuccess(false)
            }
            .addDisposableTo(disposeBag)
        
        viewModel.progressHUDSubject.subscribeNext{[weak self](show) in
            if show {
                MBProgressHUD.showHUDAddedTo(self?.view, animated: true)
            } else {
                MBProgressHUD.hideHUDForView(self?.view, animated: true)
            }
            }.addDisposableTo(disposeBag)
        
        // login
        loginButton
            .rx_tap
            .subscribeNext {[unowned self] in
                self.flowDelegate?.showLoginChoice()
            }
            .addDisposableTo(disposeBag)
        
        // skip
        skipButton
            .rx_tap
            .subscribeNext {[unowned self] in
                self.viewModel.fetchGuestUser()
            }
            .addDisposableTo(disposeBag)
        
        // help
        helpButton
            .rx_tap
            .subscribeNext{[unowned self] in
                self.flowDelegate?.showHelpInterface()
            }
            .addDisposableTo(disposeBag)
    }
}

extension IntroViewController: UIScrollViewDelegate {
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        let pageWidth = scrollView.contentSize.width / numberOfPagesInScrollView
        let page = floor((scrollView.contentOffset.x + 0.5 * pageWidth) / pageWidth)
        pageControl.currentPage = Int(page)
    }
}

// MARK: - NavigationBarContext

extension IntroViewController {
    
    override func prefersNavigationBarHidden() -> Bool {
        return true
    }
}
