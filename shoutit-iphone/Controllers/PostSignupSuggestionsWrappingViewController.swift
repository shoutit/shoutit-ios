//
//  PostSignupSuggestionsWrappingViewController.swift
//  shoutit-iphone
//
//  Created by Łukasz Kasperek on 09.02.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa


final class PostSignupSuggestionsWrappingViewController: UIViewController {
    
    enum DoneButtonMode {
        case next
        case done
    }
    
    // UI
    @IBOutlet weak var shadowView: UIView!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var skipButton: CustomUIButton!
    @IBOutlet weak var doneButton: CustomUIButton!
    @IBOutlet weak var pageControl: UIPageControl!
    
    // children controllers
    fileprivate var pageViewController: UIPageViewController! {
        didSet {
            pageViewController?.dataSource = self
            pageViewController?.delegate = self
        }
    }
    
    // view model
    var viewModel: PostSignupSuggestionViewModel!
    
    // navigation
    weak var loginDelegate: LoginFlowController?
    weak var flowSimpleDelegate : FlowController?
    
    // RX
    fileprivate let disposeBag = DisposeBag()
    fileprivate var doneButtonDisposeBag = DisposeBag()
    
    // done button
    fileprivate var doneButtonMode: DoneButtonMode! {
        didSet {
            doneButtonDisposeBag = DisposeBag()
            guard let mode = doneButtonMode else { return }
            switch mode {
            case .next:
                doneButton.setTitle(LocalizedString.next, for: UIControlState())
                doneButton.backgroundColor = UIColor(shoutitColor: .shoutitLightBlueColor)
                doneButton
                    .rx_tap
                    .subscribeNext {[unowned self] in
                        self.flipToNextViewController()
                        self.pageControl.currentPage += 1
                    }
                    .addDisposableTo(doneButtonDisposeBag)
            case .done:
                doneButton.setTitle(LocalizedString.done, for: UIControlState())
                doneButton.backgroundColor = UIColor(shoutitColor: .primaryGreen)
                doneButton
                    .rx_tap
                    .subscribeNext {[unowned self] in
                        if let _ = self.flowSimpleDelegate {
                            self.dismiss(animated: true, completion: nil)
                            return
                        }
                        
                        self.loginDelegate?.didFinishLoginProcessWithSuccess(true)
                    }
                    .addDisposableTo(doneButtonDisposeBag)
            }
        }
    }
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupRX()
        setupAppearance()
        
        // setup page control
        pageControl.numberOfPages = 2
        pageControl.currentPage = 0
        
        // setup done button
        doneButtonMode = .next
        
        viewModel.fetchSections()
        
        if self.flowSimpleDelegate != nil {
            self.skipButton.isHidden = true
        }
    }
    
    // MARK: - Setup
    
    fileprivate func setupRX() {
        
        skipButton
            .rx_tap
            .subscribeNext {[unowned self] in
                self.loginDelegate?.didFinishLoginProcessWithSuccess(true)
            }
            .addDisposableTo(disposeBag)
    }
    
    fileprivate func setupAppearance() {
        shadowView.layer.cornerRadius = 10
        shadowView.layer.shadowColor = UIColor.gray.cgColor
        shadowView.layer.shadowOpacity = 0.6
        shadowView.layer.shadowRadius = 3.0
        shadowView.layer.shadowOffset = CGSize(width: 2, height: 2)
        shadowView.layer.masksToBounds = false
        containerView.clipsToBounds = true
        containerView.layer.cornerRadius = 10
    }
    
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        
        if let vc = segue.destination as? UIPageViewController {
            pageViewController = vc
            vc.setViewControllers([self.suggestionsViewControllerForSection(.users)], direction: .forward, animated: false, completion: nil)
        }
    }
    
    // MARK: - Helpers
    
    fileprivate func flipToNextViewController() {
        let currentController = pageViewController.viewControllers?.first
        if let vc = currentController as? PostSignupSuggestionsTableViewController, vc.sectionViewModel.section == .users {
            pageViewController.setViewControllers([suggestionsViewControllerForSection(.pages)], direction: .forward, animated: true, completion: nil)
        }
    }
}

extension PostSignupSuggestionsWrappingViewController: UIPageViewControllerDataSource {
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        
        if let vc = viewController as? PostSignupSuggestionsTableViewController, vc.sectionViewModel.section == .pages {
            return suggestionsViewControllerForSection(.users)
        }
        
        return nil
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        
        if let vc = viewController as? PostSignupSuggestionsTableViewController, vc.sectionViewModel.section == .users {
            return suggestionsViewControllerForSection(.pages)
        }
        
        return nil
    }
    
    func suggestionsViewControllerForSection(_ section: PostSignupSuggestionsSection) -> UIViewController {
        
        let viewController = Wireframe.postSignupSuggestionsTableViewController()
        viewController.viewModel = viewModel
        
        switch section {
        case .users:
            viewController.sectionViewModel = viewModel.usersSection
        case .pages:
            viewController.sectionViewModel = viewModel.pagesSection
            // when last view controller appears for the first time, change button to done
            self.doneButtonMode = .done
        }
        
        return viewController
    }
}

extension PostSignupSuggestionsWrappingViewController: UIPageViewControllerDelegate {
    
    func pageViewController(_ pageViewController: UIPageViewController,
                            willTransitionTo pendingViewControllers: [UIViewController]) {
        
        guard let viewController = pendingViewControllers.first as? PostSignupSuggestionsTableViewController else {
            assert(false)
            return
        }
        
        switch viewController.sectionViewModel.section {
        case .users:
            pageControl.currentPage = 0
        case .pages:
            pageControl.currentPage = 1
        }
    }
}

// MARK: - NavigationBarContext

extension PostSignupSuggestionsWrappingViewController {
    override func prefersNavigationBarHidden() -> Bool {
        return true
    }
}
