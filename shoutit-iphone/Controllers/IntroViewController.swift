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

class IntroViewController: UIViewController {
    
    // subviews
    @IBOutlet weak var loginButton: CustomUIButton!
    @IBOutlet weak var skipButton: UIButton!
    @IBOutlet weak var helpButton: UIButton!
    
    // rx
    let disposeBag = DisposeBag()
    
    // MARK: - Lifecycle
    
    final override func viewDidLoad() {
        super.viewDidLoad()
        
        //
        setupRX()
    }
    
    // MARK: - Setup
    
    private func setupRX() {
        
        // login
        loginButton
            .rx_tap
            .subscribeNext {
            
            }
            .addDisposableTo(disposeBag)
        
        // skip
        skipButton
            .rx_tap
            .subscribeNext {
                SHOauthToken.goToDiscover() // replace
            }
            .addDisposableTo(disposeBag)
        
        // help
        helpButton
            .rx_tap
            .subscribeNext{
                print("Help tapped")
            }
            .addDisposableTo(disposeBag)
    }
}
