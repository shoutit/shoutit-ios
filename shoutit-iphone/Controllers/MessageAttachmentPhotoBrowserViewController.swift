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
    
    fileprivate let disposeBag = DisposeBag()
    var viewModel: MessageAttachmentPhotoBrowserViewModel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        enableGrid = true
        startOnGrid = true
        setupRX()
        viewModel.loadContent()
    }
    
    fileprivate func setupRX() {
        
        viewModel
            .reloadSubject
            .observeOn(MainScheduler.instance)
            .subscribeNext {[weak self] in
                self?.reloadData()
            }
            .addDisposableTo(disposeBag)
    }
}
