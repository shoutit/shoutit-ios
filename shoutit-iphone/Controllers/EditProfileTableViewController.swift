//
//  EditProfileTableViewController.swift
//  shoutit-iphone
//
//  Created by Łukasz Kasperek on 07.03.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import MBProgressHUD

class EditProfileTableViewController: UITableViewController {
    
    enum UploadType {
        case Cover
        case Avatar
    }
    
    var viewModel: EditProfileTableViewModel!
    
    // RX
    private let disposeBag = DisposeBag()
    
    // UI
    @IBOutlet weak var headerView: EditProfileTableViewHeaderView!
    @IBOutlet weak var cancelBarButtonItem: UIBarButtonItem!
    @IBOutlet weak var saveBarButtonItem: UIBarButtonItem!
    
    // children
    lazy var mediaPickerController: MediaPickerController = {[unowned self] in
        var pickerSettings = MediaPickerSettings()
        pickerSettings.allowsVideos = false
        let controller = MediaPickerController(delegate: self, settings: pickerSettings)
        
        controller.presentingSubject.observeOn(MainScheduler.instance).subscribeNext {[weak self] controller in
            guard let controller = controller else { return }
            self?.presentViewController(controller, animated: true, completion: nil)
        }.addDisposableTo(self.disposeBag)
        
        return controller
    }()
    
    var uploadType: UploadType?
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.estimatedRowHeight = 70
        
        // setup photos
        headerView.avatarImageView.sh_setImageWithURL(viewModel.user.imagePath?.toURL(), placeholderImage: UIImage.squareAvatarPlaceholder())
        headerView.coverImageView.sh_setImageWithURL(viewModel.user.coverPath?.toURL(), placeholderImage: UIImage.profileCoverPlaceholder())
        
        setupRX()
    }
    
    // MARK: - Setup
    
    private func setupRX() {
        
        cancelBarButtonItem
            .rx_tap
            .asDriver()
            .driveNext {[unowned self] in
                self.dismissViewControllerAnimated(true, completion: nil)
            }
            .addDisposableTo(disposeBag)
        
        headerView.coverButton
            .rx_tap
            .asDriver()
            .driveNext {[unowned self] in
                self.uploadType = .Cover
                self.mediaPickerController.showMediaPickerController()
            }
            .addDisposableTo(disposeBag)
        
        headerView.avatarButton
            .rx_tap
            .asDriver()
            .driveNext {[unowned self] in
                self.uploadType = .Avatar
                self.mediaPickerController.showMediaPickerController()
            }
            .addDisposableTo(disposeBag)
        
        saveBarButtonItem
            .rx_tap
            .flatMapFirst {[unowned self] () -> Observable<EditProfileTableViewModel.OperationStatus> in
                return self.viewModel.save()
            }
            .observeOn(MainScheduler.instance).subscribeNext {[weak self] (status) in
                switch status {
                case .Error(let error):
                    self?.showError(error)
                case .Progress(let show):
                    if show {
                        MBProgressHUD.showHUDAddedTo(self?.view, animated: true)
                    } else {
                        MBProgressHUD.hideAllHUDsForView(self?.view, animated: true)
                    }
                case .Ready:
                    self?.dismissViewControllerAnimated(true, completion: nil)
                }
            }
            .addDisposableTo(disposeBag)
    }
}

// MARK: - UITableViewDataSource

extension EditProfileTableViewController {
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.cells.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cellViewModel = viewModel.cells[indexPath.row]
        let cell = tableView.dequeueReusableCellWithIdentifier(cellViewModel.reuseIdentifier, forIndexPath: indexPath)
        
        switch cellViewModel {
        case .BasicText(let value, let placeholder, _):
            let cell = cell as! EditProfileTextFieldTableViewCell
            cell.textField.placeholder = placeholder
            cell.textField.text = value
            cell.textField
                .rx_text
                .asDriver()
                .driveNext{[unowned self] (text) in
                    self.viewModel.mutateModelForIndex(indexPath.row, withString: text)
                }
                .addDisposableTo(cell.disposeBag)
        case .RichText(let value, let placeholder, _):
            let cell = cell as! EditProfileTextViewTableViewCell
            cell.textView.placeholderLabel?.text = placeholder
            cell.textView.text = value
            cell.textView.rx_text
                .observeOn(MainScheduler.instance)
                .distinctUntilChanged()
                .subscribeNext{[unowned self, weak textView = cell.textView] (text) in
                    self.viewModel.mutateModelForIndex(indexPath.row, withString: text)
                    textView?.detailLabel?.text = "\(text.utf16.count)/50"
                }
                .addDisposableTo(cell.disposeBag)
            
            cell.textView.contentSizeDidChange = {[weak tableView, weak cell] (size) in
                guard let cell = cell else { return }
                guard let tableView = tableView else { return }
                guard let heightConstraint = cell.heightConstraint else { return }
                guard heightConstraint.constant != size.height else { return }
                tableView.beginUpdates()
                heightConstraint.constant = max(75, size.height)
                tableView.endUpdates()
                cell.textView.setNeedsLayout()
                cell.textView.layoutIfNeeded()
            }
        case .Location(let value, let placeholder, _):
            let cell = cell as! EditProfileSelectButtonTableViewCell
            cell.selectButton.smallTitleLabel.text = placeholder
            cell.selectButton.setTitle(value.address, forState: .Normal)
            cell.selectButton
                .rx_tap
                .asDriver()
                .driveNext({ [weak self] () -> Void in
                    
                    let controller = Wireframe.changeShoutLocationController()
                    
                    controller.finishedBlock = {[weak indexPath](success, place) -> Void in
                        if let place = place, indexPath = indexPath {
                            let newViewModel = EditProfileCellViewModel(location: place)
                            self?.viewModel.cells[indexPath.row] = newViewModel
                            self?.tableView.reloadRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)
                        }
                    }
                    
                    controller.navigationItem.leftBarButtonItem = UIBarButtonItem(title: NSLocalizedString("Cancel", comment: ""), style: .Plain, target: controller, action: #selector(controller.pop))
                    self?.navigationController?.showViewController(controller, sender: nil)
                    
                    })
                .addDisposableTo(cell.disposeBag)
        }
        
        
        return cell
    }
}

extension EditProfileTableViewController: MediaPickerControllerDelegate {
    
    func attachmentSelected(attachment: MediaAttachment, mediaPicker: MediaPickerController) {
        
        guard let uploadType = uploadType else { return }
        
        let task = uploadType == .Cover ? viewModel.uploadCoverAttachment(attachment) : viewModel.uploadAvatarAttachment(attachment)
        let progressType: EditProfileTableViewHeaderView.ProgressType = uploadType == .Avatar ? .Avatar : .Cover
        let progressView = uploadType == .Avatar ? self.headerView.avatarUploadProgressView : self.headerView.coverUploadProgressView
        let imageView = uploadType == .Cover ? self.headerView.coverImageView : self.headerView.avatarImageView
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
        
        self.uploadType = nil
    }
}
