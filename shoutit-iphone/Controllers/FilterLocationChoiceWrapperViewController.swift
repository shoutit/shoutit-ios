//
//  FilterLocationChoiceWrapperViewController.swift
//  shoutit-iphone
//
//  Created by Łukasz Kasperek on 05.04.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import UIKit
import RxSwift

class FilterLocationChoiceWrapperViewController: UIViewController {
    
    var finishedBlock: ((Bool, Address?) -> Void)?
    
    // UI
    @IBOutlet weak var backButton: UIButton!
    
    // RX
    private let disposeBag = DisposeBag()
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupRX()
    }
    
    // MARK: - Navigation
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        super.prepareForSegue(segue, sender: sender)
        if let locationController = segue.destinationViewController as? SelectShoutLocationViewController {
            locationController.finishedBlock = {[weak self](success, address) in
                self?.finishedBlock?(success, address)
                self?.pop()
            }
        }
    }
    
    // MARK: - Setup
    
    private func setupRX() {
        backButton
            .rx_tap
            .asDriver()
            .driveNext{[unowned self] in
                self.pop()
            }
            .addDisposableTo(disposeBag)
    }
}
