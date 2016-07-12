//
//  EditPageTableViewController.swift
//  shoutit
//
//  Created by Abhijeet Chaudhary on 08/07/16.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import MBProgressHUD
import ShoutitKit

class EditPageTableViewController: UITableViewController {

    
    enum UploadType {
        case Cover
        case Avatar
    }
    
    var viewModel: EditPageTableViewModel! {
        didSet {
            if viewModel.basicProfile != nil {
                loadDetailedProfile()
            }
        }
    }
    
    // RX
    private let disposeBag = DisposeBag()
    
    // UI
    @IBOutlet weak var headerView: EditPageTableViewHeaderView!
    @IBOutlet weak var cancelBarButtonItem: UIBarButtonItem!
    @IBOutlet weak var saveBarButtonItem: UIBarButtonItem!
    
    weak private var dateField : UITextField?
    
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
        
        // setup photos
        fillHeader()
        
        self.tableView.keyboardDismissMode = .OnDrag
        
        setupRX()
    }
    
    func fillHeader() {
        guard let user = viewModel.user else {
            return
        }
        
        headerView.avatarImageView.sh_setImageWithURL(user.imagePath?.toURL(), placeholderImage: UIImage.squareAvatarPlaceholder())
        headerView.coverImageView.sh_setImageWithURL(user.coverPath?.toURL(), placeholderImage: UIImage.profileCoverPlaceholder())
    }
    
    func loadDetailedProfile() {
        self.tableView.userInteractionEnabled = false
        self.showProgressHUD()
        
        self.viewModel.fetchPageProfile()?.subscribe({ [weak self] (event) in
            self?.tableView.userInteractionEnabled = true
            self?.hideProgressHUD()
            switch event {
                case .Next(let page):
                    Account.sharedInstance.switchToPage(page)
                    self?.viewModel = EditPageTableViewModel(page: page)
                    self?.tableView.reloadData()
                    self?.fillHeader()
                case .Error(let erorr):
                    self?.showError(erorr)
            default: break
            }
        }).addDisposableTo(disposeBag)
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
            .flatMapFirst {[unowned self] () -> Observable<EditPageTableViewModel.OperationStatus> in
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

extension EditPageTableViewController {
    
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
        case .BasicText(let value, let placeholder, let identity):
            let cell = cell as! EditPageTextFieldTableViewCell
            cell.placeholderLabel.text = placeholder
            cell.textField.placeholder = nil
            cell.textField.text = value
            cell.textField.inputView = nil
            if case .Phone = identity {
                cell.textField.keyboardType = .PhonePad
            }
            cell.textField
                .rx_text
                .asDriver()
                .driveNext{[unowned self] (text) in
                    self.viewModel.mutateModelForIndex(indexPath.row, object: text)
                }
                .addDisposableTo(cell.disposeBag)
            
        case .RichText(let value, let placeholder, _):
            let cell = cell as! EditPageTextViewTableViewCell
            
            cell.textView.text = value
            cell.textView.delegate = self
            cell.placeholderLabel.text = placeholder
            cell.textView.rx_text
                .observeOn(MainScheduler.instance)
                .distinctUntilChanged()
                .subscribeNext{[unowned self, weak textView = cell.textView] (text) in
                    self.viewModel.mutateModelForIndex(indexPath.row, object: text)
                }
                .addDisposableTo(cell.disposeBag)
        case .Location(let value, let placeholder, _):
            let cell = cell as! EditPageSelectButtonTableViewCell
            cell.selectButton.fieldTitleLabel.text = placeholder
            cell.selectButton.iconImageView.image = UIImage(named: value.country)
            cell.selectButton.setTitle(value.address, forState: .Normal)
            cell.selectButton
                .rx_tap
                .asDriver()
                .driveNext({ [weak self] () -> Void in
                    
                    let controller = Wireframe.changeShoutLocationController()
                    
                    controller.finishedBlock = {[weak indexPath](success, place) -> Void in
                        // TODO
//                        if let place = place, indexPath = indexPath {s
//                            let newViewModel = EditPageCellViewModel(location: place)
//                            self?.viewModel.cells[indexPath.row] = newViewModel
//                            self?.tableView.reloadRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)
//                        }
                    }
                    
                    controller.navigationItem.leftBarButtonItem = UIBarButtonItem(title: NSLocalizedString("Cancel", comment: ""), style: .Plain, target: controller, action: #selector(controller.pop))
                    self?.navigationController?.showViewController(controller, sender: nil)
                    
                    })
                .addDisposableTo(cell.disposeBag)
            
            case .Switch(let value, let placeholder, _):
                let cell = cell as! EditPageSwitchTableViewCell
                cell.switchButton.on = value
                cell.placeholderLabel.text = placeholder
            
                cell.switchButton.rx_controlEvent(.ValueChanged).asDriver().driveNext({ (x) in
                    self.viewModel.mutateModelForIndex(indexPath.row, object: cell.switchButton.on)
                }).addDisposableTo(cell.disposeBag)
        }
    
        
        return cell
    }
}


extension EditPageTableViewController {
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        
        let cellViewModel = viewModel.cells[indexPath.row]
        switch cellViewModel {
        case .BasicText: return 70
        case .RichText: return 120
        case .Location: return 70
        case .Switch: return 50
        }
    }
}

extension EditPageTableViewController: MediaPickerControllerDelegate {
    
    func attachmentSelected(attachment: MediaAttachment, mediaPicker: MediaPickerController) {
        
        guard let uploadType = uploadType else { return }
        
        let task = uploadType == .Cover ? viewModel.uploadCoverAttachment(attachment) : viewModel.uploadAvatarAttachment(attachment)
        let progressType: EditPageTableViewHeaderView.ProgressType = uploadType == .Avatar ? .Avatar : .Cover
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

extension EditPageTableViewController: UITextViewDelegate {
    
    func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
        return textView.text.utf16.count < viewModel.charactersLimit || text.utf16.count == 0
    }
}