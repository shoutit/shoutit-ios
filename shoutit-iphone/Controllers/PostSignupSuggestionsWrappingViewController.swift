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
    
    // view model
    var viewModel: PostSignupSuggestionViewModel!
    
    // navigation
    weak var flowDelegate: PostSignupSuggestionViewControllerFlowDelegate?
    
    // RX
    let disposeBag = DisposeBag()
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupRX()
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
        
        if let vc = segue.destinationViewController as? PostSignupSuggestionsTableViewController {
            vc.viewModel = viewModel
        }
    }
}