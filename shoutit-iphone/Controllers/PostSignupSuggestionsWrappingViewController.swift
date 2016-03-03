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
    @IBOutlet weak var skipButton: CustomUIButton!
    @IBOutlet weak var doneButton: CustomUIButton!
    
    // children controllers
    private var pageViewController: UIPageViewController! {
        didSet {
            pageViewController?.dataSource = self
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
        
        if let vc = viewController as? PostSignupSuggestionsTableViewController<Profile> where vc.sectionViewModel.section == .Pages {
            return suggestionsViewControllerForSection(.Users)
        }
        
        return nil
    }
    
    func pageViewController(pageViewController: UIPageViewController, viewControllerAfterViewController viewController: UIViewController) -> UIViewController? {
        
        if let vc = viewController as? PostSignupSuggestionsTableViewController<Profile> where vc.sectionViewModel.section == .Users {
            return suggestionsViewControllerForSection(.Pages)
        }
        
        return nil
    }
    
    func presentationCountForPageViewController(pageViewController: UIPageViewController) -> Int {
        return 2
    }
    
    func presentationIndexForPageViewController(pageViewController: UIPageViewController) -> Int {
        return 0
    }
    
    func suggestionsViewControllerForSection(section: PostSignupSuggestionsSection) -> UIViewController {
        
        let viewController = PostSignupSuggestionsTableViewController<Profile>()
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