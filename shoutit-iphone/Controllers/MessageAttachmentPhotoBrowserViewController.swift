//
//  MessageAttachmentPhotoBrowserViewController.swift
//  shoutit-iphone
//
//  Created by Łukasz Kasperek on 17.05.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import UIKit
import RxSwift

class MessageAttachmentPhotoBrowserViewController: PhotoBrowser {
    
    private let disposeBag = DisposeBag()
    var viewModel: MessageAttachmentPhotoBrowserViewModel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupRX()
        viewModel.pager.loadContent()
    }
    
    private func setupRX() {
        
        viewModel.pager.state
            .asObservable()
            .subscribeNext {[weak self] (_) in
                self?.reloadData()
            }
            .addDisposableTo(disposeBag)
    }
}
