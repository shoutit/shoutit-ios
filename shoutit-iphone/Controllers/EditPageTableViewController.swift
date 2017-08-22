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
        case cover
        case avatar
    }
    
    var viewModel: EditPageTableViewModel! {
        didSet {
            if viewModel.basicProfile != nil {
                loadDetailedProfile()
            }
        }
    }
    
    // RX
    fileprivate let disposeBag = DisposeBag()
    
    // UI
    @IBOutlet weak var headerView: EditPageTableViewHeaderView!
    @IBOutlet weak var cancelBarButtonItem: UIBarButtonItem!
    @IBOutlet weak var saveBarButtonItem: UIBarButtonItem!
    
    weak fileprivate var dateField : UITextField?
    
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
        
        self.tableView.keyboardDismissMode = .onDrag
        self.tableView.estimatedRowHeight = 80.0
        self.tableView.rowHeight = UITableViewAutomaticDimension
        
        setupRX()
    }
    
    func fillHeader() {
        guard let user = viewModel.user else {
            return
        }
        
        headerView.avatarImageView.sh_setImageWithURL(user.imagePath?.toURL(), placeholderImage: UIImage.squareAvatarPagePlaceholder())
        headerView.coverImageView.sh_setImageWithURL(user.coverPath?.toURL(), placeholderImage: UIImage.profileCoverPlaceholder())
    }
    
    func loadDetailedProfile() {
        self.tableView.isUserInteractionEnabled = false
        self.showProgressHUD()
        
        self.viewModel.fetchPageProfile()?.subscribe({ [weak self] (event) in
            self?.tableView.isUserInteractionEnabled = true
            self?.hideProgressHUD()
            switch event {
                case .next(let page):
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
    
    fileprivate func setupRX() {
        
        cancelBarButtonItem
            .rx_tap
            .asDriver()
            .driveNext {[unowned self] in
                self.dismiss(animated: true, completion: nil)
            }
            .addDisposableTo(disposeBag)
        
        headerView.coverButton
            .rx_tap
            .asDriver()
            .driveNext {[unowned self] in
                self.uploadType = .cover
                self.mediaPickerController.showMediaPickerController()
            }
            .addDisposableTo(disposeBag)
        
        headerView.avatarButton
            .rx_tap
            .asDriver()
            .driveNext {[unowned self] in
                self.uploadType = .avatar
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
                case .error(let error):
                    self?.showError(error)
                case .progress(let show):
                    if show {
                        MBProgressHUD.showAdded(to: self?.view, animated: true)
                    } else {
                        MBProgressHUD.hideAllHUDs(for: self?.view, animated: true)
                    }
                case .ready:
                    self?.dismiss(animated: true, completion: nil)
                }
            }
            .addDisposableTo(disposeBag)
    }
}

// MARK: - UITableViewDataSource

extension EditPageTableViewController {
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.cells.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellViewModel = viewModel.cells[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: cellViewModel.reuseIdentifier, for: indexPath)
        
        switch cellViewModel {
        case .basicText(let value, let placeholder, let identity):
            let cell = cell as! EditPageTextFieldTableViewCell
            cell.placeholderLabel.text = placeholder
            cell.textField.placeholder = nil
            cell.textField.text = value
            cell.textField.inputView = nil
            if case .phone = identity {
                cell.textField.keyboardType = .phonePad
            }
            cell.textField
                .rx_text
                .asDriver()
                .driveNext{[unowned self] (text) in
                    self.viewModel.mutateModelForIndex(indexPath.row, object: text)
                }
                .addDisposableTo(cell.disposeBag)
            
        case .richText(let value, let placeholder, _):
            let cell = cell as! EditPageTextViewTableViewCell
            
            cell.setContent(value)
            cell.placeholderLabel.text = placeholder
            cell.textView.rx_text
                .observeOn(MainScheduler.instance)
                .distinctUntilChanged()
                .subscribeNext{[unowned self] (text) in
                    if cell.isEditingText == false { return }
                    self.tableView.beginUpdates()
                    self.viewModel.mutateModelForIndex(indexPath.row, object: text)
                    self.tableView.endUpdates()
                }
                .addDisposableTo(cell.disposeBag)
        case .switch(let value, let placeholder, _):
                let cell = cell as! EditPageSwitchTableViewCell
                cell.switchButton.isOn = value
                cell.placeholderLabel.text = placeholder
            
                cell.switchButton.rx_controlEvent(.valueChanged).asDriver().driveNext({ (x) in
                    self.viewModel.mutateModelForIndex(indexPath.row, object: cell.switchButton.isOn)
                }).addDisposableTo(cell.disposeBag)
        default:
            return cell
        }
        
    
        
        return cell
    }
}


extension EditPageTableViewController {
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
        
//        let cellViewModel = viewModel.cells[indexPath.row]
//        switch cellViewModel {
//        case .BasicText: return 70
//        case .RichText: return 50.0
//        case .Location: return 70
//        case .Switch: return 50
//        }
    }
}

extension EditPageTableViewController: MediaPickerControllerDelegate {
    
    func attachmentSelected(_ attachment: MediaAttachment, mediaPicker: MediaPickerController) {
        
        guard let uploadType = uploadType else { return }
        
        let task = uploadType == .cover ? viewModel.uploadCoverAttachment(attachment) : viewModel.uploadAvatarAttachment(attachment)
        let progressType: EditPageTableViewHeaderView.ProgressType = uploadType == .avatar ? .avatar : .cover
        let progressView = uploadType == .avatar ? self.headerView.avatarUploadProgressView : self.headerView.coverUploadProgressView
        let imageView = uploadType == .cover ? self.headerView.coverImageView : self.headerView.avatarImageView
        imageView?.image = attachment.image
        
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
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        return textView.text.utf16.count < viewModel.charactersLimit || text.utf16.count == 0
    }
}
