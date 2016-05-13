//
//  CreatePublicChatTableViewController.swift
//  shoutit-iphone
//
//  Created by Łukasz Kasperek on 12.05.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class CreatePublicChatTableViewController: UITableViewController {
    
    // RX
    private let disposeBag = DisposeBag()
    
    // children
    lazy var mediaPickerController: MediaPickerController = {[unowned self] in
        var pickerSettings = MediaPickerSettings()
        pickerSettings.allowsVideos = false
        let controller = MediaPickerController(delegate: self, settings: pickerSettings)
        
        controller.presentingSubject
            .observeOn(MainScheduler.instance)
            .subscribeNext {[weak self] controller in
                guard let controller = controller else { return }
                self?.presentViewController(controller, animated: true, completion: nil)
            }
            .addDisposableTo(self.disposeBag)
        
        return controller
    }()
    
    // view model
    weak var viewModel: CreatePublicChatViewModel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupRX()
        view.setNeedsLayout()
        view.layoutIfNeeded()
        if let headerView = tableView.tableHeaderView {
            let size = headerView.systemLayoutSizeFittingSize(UILayoutFittingCompressedSize)
            tableView.frame = CGRect(x: 0, y: 0, width: headerView.bounds.width, height: size.height)
            tableView.tableHeaderView = headerView
        }
    }
    
    // MARK: - Setup
    
    private func setupRX() {
        
        chatImageButton
            .rx_tap
            .asDriver()
            .driveNext {[unowned self] in
                self.mediaPickerController.showMediaPickerController()
            }
            .addDisposableTo(disposeBag)

    }
}

extension CreatePublicChatTableViewController: MediaPickerControllerDelegate {
    
    func attachmentSelected(attachment: MediaAttachment, mediaPicker: MediaPickerController) {
        
        let task = viewModel.uploadImageAttachment(attachment)
        imageView.image = attachment.image
        
        task.status
            .asDriver()
            .driveNext{[weak self] (status) in
                self?.headerView.hydrateProgressView(progressType, withStatus: status)
            }
            .addDisposableTo(disposeBag)
        
        task.progress
            .asDriver()
            .driveNext{[weak progressView] (progress) in
                progressView?.setProgress(progress, animated: true)
            }
            .addDisposableTo(disposeBag)
    }
}
