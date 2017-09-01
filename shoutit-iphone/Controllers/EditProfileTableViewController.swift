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
import ShoutitKit

final class EditProfileTableViewController: UITableViewController {
    
    enum UploadType {
        case cover
        case avatar
    }
    
    var viewModel: EditProfileTableViewModel!
    
    // RX
    fileprivate let disposeBag = DisposeBag()
    
    // UI
    @IBOutlet weak var headerView: EditProfileTableViewHeaderView!
    @IBOutlet weak var cancelBarButtonItem: UIBarButtonItem!
    @IBOutlet weak var saveBarButtonItem: UIBarButtonItem!
    
    weak fileprivate var dateField : UITextField?
    
    // children
    lazy var mediaPickerController: MediaPickerController = {[unowned self] in
        var pickerSettings = MediaPickerSettings()
        pickerSettings.allowsVideos = false
        let controller = MediaPickerController(delegate: self, settings: pickerSettings)
        
        controller.presentingSubject.observeOn(MainScheduler.instance).subscribe(onNext: {[weak self] controller in
            guard let controller = controller else { return }
            self?.present(controller, animated: true, completion: nil)
        }).addDisposableTo(self.disposeBag)
        
        return controller
    }()
    
    var uploadType: UploadType?
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // setup photos
        headerView.avatarImageView.sh_setImageWithURL(viewModel.user.imagePath?.toURL(), placeholderImage: UIImage.squareAvatarPlaceholder())
        headerView.coverImageView.sh_setImageWithURL(viewModel.user.coverPath?.toURL(), placeholderImage: UIImage.profileCoverPlaceholder())
        
        self.tableView.keyboardDismissMode = .onDrag
        
        setupRX()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    
        if (UserDefaults.standard.bool(forKey: "CompleteProfileAlertWasShown") == false && !viewModel.user.hasAllRequiredFieldsFilled()) {
            showCompleteProfileInfo()
            UserDefaults.standard.set(true, forKey: "CompleteProfileAlertWasShown")
            UserDefaults.standard.synchronize()
        }
    }
    
    func showCompleteProfileInfo() {
        let alert = UIAlertController(title: NSLocalizedString("Completing your Profile", comment: "Edit Profile Alert Title"), message: NSLocalizedString("Complete your profile to earn 1 Shoutit Credit", comment: "Edit Profile Alert Message"), preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: LocalizedString.ok, style: .default, handler: nil))
        
        self.navigationController?.present(alert, animated: true, completion: nil)
    }
    
    // MARK: - Setup
    
    fileprivate func setupRX() {
        
        cancelBarButtonItem
            .rx.tap
            .asDriver()
            .drive(onNext: { [unowned self] in
                self.dismiss(animated: true, completion: nil)
            })
            .addDisposableTo(disposeBag)
        
        headerView.coverButton
            .rx.tap
            .asDriver()
            .drive(onNext: { [unowned self] in
                self.uploadType = .cover
                self.mediaPickerController.showMediaPickerController()
            })
            .addDisposableTo(disposeBag)
        
        headerView.avatarButton
            .rx.tap
            .asDriver()
            .drive(onNext: { [unowned self] in
                self.uploadType = .avatar
                self.mediaPickerController.showMediaPickerController()
            })
            .addDisposableTo(disposeBag)
        
        saveBarButtonItem
            .rx.tap
            .flatMapFirst {[unowned self] () -> Observable<EditProfileTableViewModel.OperationStatus> in
                return self.viewModel.save()
            }
            .observeOn(MainScheduler.instance).subscribe(onNext: {[weak self] (status) in
                switch status {
                case .error(let error):
                    self?.showError(error)
                case .progress(let show):
                    if show {
                        if let view = self?.view {
                            MBProgressHUD.showAdded(to: view, animated: true)
                        }
                    } else {
                        if let view = self?.view {
                            MBProgressHUD.hideAllHUDs(for: view, animated: true)
                        }
                    }
                case .ready:
                    self?.dismiss(animated: true, completion: nil)
                }
            })
            .addDisposableTo(disposeBag)
    }
}

// MARK: - UITableViewDataSource

extension EditProfileTableViewController {
    
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
            let cell = cell as! EditProfileTextFieldTableViewCell
            cell.textField.placeholder = placeholder
            cell.textField.text = value
            cell.textField.inputView = nil
            if case .mobile = identity {
                cell.textField.keyboardType = .phonePad
            }
            // ref
//            cell.textField
//                .rx.text
//                .asDriver()
//                .drive(onNext: { [weak self] (text) in
//                    self?.viewModel.mutateModelForIndex(indexPath.row, object: text)
//                })
//                .addDisposableTo(cell.disposeBag)
        case .date(let value, let placeholder, _):
            let cell = cell as! EditProfileTextFieldTableViewCell
            cell.textField.placeholder = placeholder
            
            if let value = value {
                cell.textField.text = DateFormatters.sharedInstance.stringFromDate(value)
            }
            
            let picker =  UIDatePicker()
            picker.datePickerMode = .date
            picker.addTarget(self, action: #selector(birthDateSelected), for: .valueChanged)
            
            dateField = cell.textField
            cell.textField.inputView = picker
            
            // ref
//            cell.textField
//                .rx.text
//                .asDriver()
//                .drive(onNext: { [weak self] (text) in
//                    self?.viewModel.mutateModelForIndex(indexPath.row, object: text)
//                })
//                .addDisposableTo(cell.disposeBag)
        case .gender(let value, let placeholder, _):
            let cell = cell as! EditProfileSelectButtonTableViewCell
            cell.selectButton.fieldTitleLabel.text = placeholder
            cell.selectButton.showIcon(false)
            cell.selectButton.setTitle((value != nil ? (value!.capitalized) : (genderValues().first!.capitalized)), for: UIControlState())
            cell.selectButton
                .rx.tap
                .asDriver()
                .drive(onNext: { [weak self] () -> Void in
                    
                    
                    let controller = UIAlertController(title: NSLocalizedString("Select Gender", comment: "Edit Profile"), message: nil, preferredStyle: .actionSheet)
                    
                    self?.genderValues().each({ (genderString) in
                    controller.addAction(UIAlertAction(title: genderString.capitalized, style: .default, handler: { (alert) in
                        self?.viewModel.mutateModelForIndex(indexPath.row, object: genderString as AnyObject)
                        self?.tableView.reloadRows(at: [indexPath], with: .automatic)
                    }))
                    })
                    
                    self?.navigationController?.present(controller, animated: true, completion: nil)
                    
                    })
                .addDisposableTo(cell.disposeBag)
        case .richText(let value, let placeholder, _):
            let cell = cell as! EditProfileTextViewTableViewCell
            cell.textView.placeholderLabel?.text = placeholder
            cell.textView.text = value
            cell.textView.delegate = self
            cell.textView.rx.text
                .observeOn(MainScheduler.instance)
                .distinctUntilChanged( { $0 == $1 })
                .subscribe(onNext: {[unowned self, weak textView = cell.textView] (text) in
                    self.viewModel.mutateModelForIndex(indexPath.row, object: text as AnyObject)
                    textView?.detailLabel?.text = "\(text?.utf16.count)/\(self.viewModel.charactersLimit)"
                })
                .addDisposableTo(cell.disposeBag)
        case .location(let value, let placeholder, _):
            let cell = cell as! EditProfileSelectButtonTableViewCell
            cell.selectButton.fieldTitleLabel.text = placeholder
            cell.selectButton.iconImageView.image = UIImage(named: value.country)
            cell.selectButton.setTitle(value.address, for: UIControlState())
            cell.selectButton
                .rx.tap
                .asDriver()
                .drive(onNext: { [weak self] () -> Void in
                    
                    let controller = Wireframe.changeShoutLocationController()
                    
                    controller.finishedBlock = { (success, place) -> Void in
                        if let place = place {
                            let newViewModel = EditProfileCellViewModel(location: place)
                            self?.viewModel.cells[indexPath.row] = newViewModel
                            self?.tableView.reloadRows(at: [indexPath], with: .automatic)
                        }
                    }
                    
                    controller.navigationItem.leftBarButtonItem = UIBarButtonItem(title: NSLocalizedString("Cancel", comment: "Edit Profile"), style: .plain, target: controller, action: #selector(controller.pop))
                    self?.navigationController?.show(controller, sender: nil)
                    
                    })
                .addDisposableTo(cell.disposeBag)
        }
        
        return cell
    }
}

extension EditProfileTableViewController {
    func genderValues() -> [String] {
        return [NSLocalizedString("Not specified", comment: "Edit Profile Not Specified Gender"), Gender.Male.rawValue, Gender.Female.rawValue, Gender.Other.rawValue]
    }
    
    func birthDateSelected(_ sender: UIDatePicker) {
        let result = DateFormatters.sharedInstance.stringFromDate(sender.date)
        
        let newViewModel = EditProfileCellViewModel(birthday: sender.date)
        
        self.viewModel.cells[7] = newViewModel
        
        dateField?.text = result
    }
}

extension EditProfileTableViewController {
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        let cellViewModel = viewModel.cells[indexPath.row]
        switch cellViewModel {
        case .basicText: return 70
        case .richText: return 150
        case .location: return 70
        case .date: return 70
        case .gender: return 70
        }
    }
}

extension EditProfileTableViewController: MediaPickerControllerDelegate {
    
    func attachmentSelected(_ attachment: MediaAttachment, mediaPicker: MediaPickerController) {
        
        guard let uploadType = uploadType else { return }
        
        let task = uploadType == .cover ? viewModel.uploadCoverAttachment(attachment) : viewModel.uploadAvatarAttachment(attachment)
        let progressType: EditProfileTableViewHeaderView.ProgressType = uploadType == .avatar ? .avatar : .cover
        let progressView = uploadType == .avatar ? self.headerView.avatarUploadProgressView : self.headerView.coverUploadProgressView
        let imageView = uploadType == .cover ? self.headerView.coverImageView : self.headerView.avatarImageView
        imageView?.image = attachment.image
        
        task.status
            .asDriver()
            .drive(onNext: { [weak self] (status) in
                self?.headerView.hydrateProgressView(progressType, withStatus: status)
            })
            .addDisposableTo(disposeBag)
        
        task.progress
            .asDriver()
            .drive(onNext: {[weak progressView] (progress) in
                progressView?.setProgress(progress, animated: true)
            })
            .addDisposableTo(disposeBag)
        
        self.uploadType = nil
    }
}

extension EditProfileTableViewController: UITextViewDelegate {
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        return textView.text.utf16.count < viewModel.charactersLimit || text.utf16.count == 0
    }
}
