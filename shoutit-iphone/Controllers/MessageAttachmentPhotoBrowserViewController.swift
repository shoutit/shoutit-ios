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
        enableGrid = true
        startOnGrid = true
        setupRX()
        viewModel.loadContent()
    }
    
    private func setupRX() {
        
        viewModel
            .reloadSubject
            .observeOn(MainScheduler.instance)
            .subscribeNext {[weak self] in
                self?.reloadData()
            }
            .addDisposableTo(disposeBag)
    }
}
