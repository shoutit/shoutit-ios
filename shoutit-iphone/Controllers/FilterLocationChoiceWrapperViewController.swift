//
//  FilterLocationChoiceWrapperViewController.swift
//  shoutit-iphone
//
//  Created by Łukasz Kasperek on 05.04.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import UIKit
import RxSwift
import ShoutitKit

final class FilterLocationChoiceWrapperViewController: UIViewController {
    
    var finishedBlock: ((Bool, Address?) -> Void)?
    
    // UI
    @IBOutlet weak var backButton: UIButton!
    
    // RX
    fileprivate let disposeBag = DisposeBag()
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupRX()
    }
    
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        if let locationController = segue.destination as? SelectShoutLocationViewController {
            locationController.finishedBlock = {[weak self](success, address) in
                self?.finishedBlock?(success, address)
                self?.pop()
            }
        }
    }
    
    // MARK: - Setup
    
    fileprivate func setupRX() {
        backButton
            .rx.tap
            .asDriver()
            .drive(onNext: { [weak self] in
                self?.pop()
            })
            .addDisposableTo(disposeBag)
    }
}
