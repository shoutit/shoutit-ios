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

protocol PostSignupSuggestionViewControllerFlowDelegate: class, LoginFinishable {}

final class PostSignupSuggestionsWrappingViewController: UIViewController {
    
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
    weak var flowDelegate: PostSignupSuggestionViewControllerFlowDelegate?
    
    // RX
    private let disposeBag = DisposeBag()
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupRX()
        setupAppearance()
        
        // setup page control
        pageControl.numberOfPages = 2
        pageControl.currentPage = 0
        
        viewModel.fetchSections()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.navigationBarHidden = true
    }
    
    // MARK: - Setup
    
    private func setupRX() {
        
        skipButton
            .rx_tap
            .subscribeNext {[unowned self] in
                self.flowDelegate?.didFinishLoginProcessWithSuccess(true)
            }
            .addDisposableTo(disposeBag)
        
        doneButton
            .rx_tap
            .subscribeNext {[unowned self] in
                self.flowDelegate?.didFinishLoginProcessWithSuccess(true)
            }
            .addDisposableTo(disposeBag)
    }
    
    private func setupAppearance() {
        shadowView.layer.cornerRadius = 10
        shadowView.layer.borderColor = UIColor.lightGrayColor().CGColor
        shadowView.layer.borderWidth = 0.5
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