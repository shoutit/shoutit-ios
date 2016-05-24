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
        case Next
        case Done
    }
    
    // UI
    @IBOutlet weak var shadowView: UIView!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var skipButton: CustomUIButton!
    @IBOutlet weak var doneButton: CustomUIButton!
    @IBOutlet weak var pageControl: UIPageControl!
    
    // children controllers
    private var pageViewController: UIPageViewController! {
        didSet {
            pageViewController?.dataSource = self
            pageViewController?.delegate = self
        }
    }
    
    // view model
    var viewModel: PostSignupSuggestionViewModel!
    
    // navigation
    weak var flowDelegate: LoginFlowController?
    
    // RX
    private let disposeBag = DisposeBag()
    private var doneButtonDisposeBag = DisposeBag()
    
    // done button
    private var doneButtonMode: DoneButtonMode! {
        didSet {
            doneButtonDisposeBag = DisposeBag()
            guard let mode = doneButtonMode else { return }
            switch mode {
            case .Next:
                doneButton.setTitle(NSLocalizedString("Next", comment: ""), forState: .Normal)
                doneButton.backgroundColor = UIColor(shoutitColor: .ShoutitLightBlueColor)
                doneButton
                    .rx_tap
                    .subscribeNext {[unowned self] in
                        self.flipToNextViewController()
                        self.pageControl.currentPage += 1
                    }
                    .addDisposableTo(doneButtonDisposeBag)
            case .Done:
                doneButton.setTitle(NSLocalizedString("Done", comment: ""), forState: .Normal)
                doneButton.backgroundColor = UIColor(shoutitColor: .PrimaryGreen)
                doneButton
                    .rx_tap
                    .subscribeNext {[unowned self] in
                        self.flowDelegate?.didFinishLoginProcessWithSuccess(true)
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
        doneButtonMode = .Next
        
        viewModel.fetchSections()
    }
    
    // MARK: - Setup
    
    private func setupRX() {
        
        skipButton
            .rx_tap
            .subscribeNext {[unowned self] in
                self.flowDelegate?.didFinishLoginProcessWithSuccess(true)
            }
            .addDisposableTo(disposeBag)
    }
    
    private func setupAppearance() {
        shadowView.layer.cornerRadius = 10
        shadowView.layer.shadowColor = UIColor.grayColor().CGColor
        shadowView.layer.shadowOpacity = 0.6
        shadowView.layer.shadowRadius = 3.0
        shadowView.layer.shadowOffset = CGSize(width: 2, height: 2)
        shadowView.layer.masksToBounds = false
        containerView.clipsToBounds = true
        containerView.layer.cornerRadius = 10
    }
    
    // MARK: - Navigation
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        super.prepareForSegue(segue, sender: sender)
        
        if let vc = segue.destinationViewController as? UIPageViewController {
            pageViewController = vc
            vc.setViewControllers([self.suggestionsViewControllerForSection(.Users)], direction: .Forward, animated: false, completion: nil)
        }
    }
    
    // MARK: - Helpers
    
    private func flipToNextViewController() {
        let currentController = pageViewController.viewControllers?.first
        if let vc = currentController as? PostSignupSuggestionsTableViewController where vc.sectionViewModel.section == .Users {
            pageViewController.setViewControllers([suggestionsViewControllerForSection(.Pages)], direction: .Forward, animated: true, completion: nil)
        }
    }
}

extension PostSignupSuggestionsWrappingViewController: UIPageViewControllerDataSource {
    
    func pageViewController(pageViewController: UIPageViewController, viewControllerBeforeViewController viewController: UIViewController) -> UIViewController? {
        
        if let vc = viewController as? PostSignupSuggestionsTableViewController where vc.sectionViewModel.section == .Pages {
            return suggestionsViewControllerForSection(.Users)
        }
        
        return nil
    }
    
    func pageViewController(pageViewController: UIPageViewController, viewControllerAfterViewController viewController: UIViewController) -> UIViewController? {
        
        if let vc = viewController as? PostSignupSuggestionsTableViewController where vc.sectionViewModel.section == .Users {
            return suggestionsViewControllerForSection(.Pages)
        }
        
        return nil
    }
    
    func suggestionsViewControllerForSection(section: PostSignupSuggestionsSection) -> UIViewController {
        
        let viewController = Wireframe.postSignupSuggestionsTableViewController()
        viewController.viewModel = viewModel
        
        switch section {
        case .Users:
            viewController.sectionViewModel = viewModel.usersSection
        case .Pages:
            viewController.sectionViewModel = viewModel.pagesSection
            // when last view controller appears for the first time, change button to done
            self.doneButtonMode = .Done
        }
        
        return viewController
    }
}

extension PostSignupSuggestionsWrappingViewController: UIPageViewControllerDelegate {
    
    func pageViewController(pageViewController: UIPageViewController,
                            willTransitionToViewControllers pendingViewControllers: [UIViewController]) {
        
        guard let viewController = pendingViewControllers.first as? PostSignupSuggestionsTableViewController else {
            assert(false)
            return
        }
        
        switch viewController.sectionViewModel.section {
        case .Users:
            pageControl.currentPage = 0
        case .Pages:
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