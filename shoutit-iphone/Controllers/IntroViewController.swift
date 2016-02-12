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

protocol IntroViewControllerFlowDelegate: class, HelpDisplayable, LoginFinishable {
    func showLoginChoice() -> Void
}

final class IntroViewController: UIViewController {
    
    // subviews
    @IBOutlet weak var loginButton: CustomUIButton!
    @IBOutlet weak var skipButton: UIButton!
    @IBOutlet weak var helpButton: UIButton!
    
    // rx
    private let disposeBag = DisposeBag()
    
    // navigation
    weak var flowDelegate: IntroViewControllerFlowDelegate?
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //
        setupRX()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.navigationBarHidden = true
    }
    
    // MARK: - Setup
    
    private func setupRX() {
        
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
                self.flowDelegate?.didFinishLoginProcessWithSuccess(false)
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
