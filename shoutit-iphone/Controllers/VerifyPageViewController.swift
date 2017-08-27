//
//  VerifyPageViewController.swift
//  shoutit
//
//  Created by Piotr Bernad on 12/07/16.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import UIKit
import ShoutitKit
import RxSwift
import RxCocoa
import MBProgressHUD
import ACPDownload

class VerifyPageViewController: UITableViewController {

    var viewModel: VerifyPageViewModel!
    
    // RX
    fileprivate let disposeBag = DisposeBag()
    
    @IBOutlet weak var businessNameTextField: UITextField!
    @IBOutlet weak var contactPersonTextField: UITextField!
    @IBOutlet weak var contactNumberTextfield: UITextField!
    @IBOutlet weak var businessEmail: UITextField!
    
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var cancelBarButtonItem: UIBarButtonItem!
    
    @IBOutlet weak var firstImageView: UIImageView!
    @IBOutlet weak var secondImageView: UIImageView!
    @IBOutlet weak var thirdImageView: UIImageView!
    
    @IBOutlet weak var firstDownloadView: ACPDownloadView!
    @IBOutlet weak var secondDownloadView: ACPDownloadView!
    @IBOutlet weak var thirdDownloadView: ACPDownloadView!
    
    @IBOutlet weak var verificationStatusLabel: UILabel!
    @IBOutlet var firstTapGestureRecognizer: UITapGestureRecognizer!
    @IBOutlet var secondTapGestureRecognizer: UITapGestureRecognizer!
    @IBOutlet var thirdTapGestureRecognizer: UITapGestureRecognizer!
    
    fileprivate var imageViews: [UIImageView] {
        return [firstImageView, secondImageView, thirdImageView]
    }
    
    fileprivate var progressViews: [ACPDownloadView] {
        return [firstDownloadView, secondDownloadView, thirdDownloadView]
    }
    
    fileprivate var tapGestureRecognizers: [UITapGestureRecognizer] {
        return [firstTapGestureRecognizer, secondTapGestureRecognizer, thirdTapGestureRecognizer]
    }
    
    fileprivate var selectedImageViewIndex: Int?
    
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        precondition(viewModel != nil)
        
        setupRX()
        viewModel.updateVerification()
    }
    
    func setupRX() {
        saveButton
            .rx.tap
            .asDriver()
            .drive(onNext: { [weak self] in
                self?.viewModel.verifyPage()
            })
            .addDisposableTo(disposeBag)
        
        cancelBarButtonItem
            .rx.tap
            .asDriver()
            .drive(onNext:{[weak self] in
                    self?.navigationController?.dismiss(animated: true, completion:nil)
                })
            .addDisposableTo(disposeBag)
        
        viewModel.updateVerificationSubject
            .observeOn(MainScheduler.instance)
            .subscribe(onNext:{[weak self] (verification) in
                    self?.populateWithVerification(verification)
                })
            .addDisposableTo(disposeBag)
        

        
        viewModel.progressSubject
            .distinctUntilChanged( { $0 == $1 })
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: {[weak self] (show) in
                if show {
                    if let view = self?.view {
                            MBProgressHUD.showAdded(to: view, animated: true)
                        }
                } else {
                    if let view = self?.view {
                    MBProgressHUD.hide(for: view, animated: true)
                }
                }
            })
            .addDisposableTo(disposeBag)
        
        viewModel.successSubject
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: {[weak self] (message) in
                self?.navigationController?.dismiss(animated: true, completion:nil)
            })
            .addDisposableTo(disposeBag)
        
        viewModel.errorSubject
        .observeOn(MainScheduler.instance)
            .subscribe(onNext: {[weak self] (error) in
                self?.showError(error)
            })
            .addDisposableTo(disposeBag)
        
        
        for (index, tapGestureRecognizer) in tapGestureRecognizers.enumerated() {
           tapGestureRecognizer
            .rx.event
            .asDriver()
            .drive(onNext:{[unowned self] (UIGestureRecognizer) in
                self.selectedImageViewIndex = index
                self.mediaPickerController.showMediaPickerController()
            })
            .addDisposableTo(disposeBag)
        }
        
        businessEmail.rx.text.bind(to: viewModel.email).addDisposableTo(disposeBag)
        contactPersonTextField.rx.text.bind(to: viewModel.contactPerson).addDisposableTo(disposeBag)
        contactNumberTextfield.rx.text.bind(to: viewModel.contactNumber).addDisposableTo(disposeBag)
        businessNameTextField.rx.text.bind(to: viewModel.businessName).addDisposableTo(disposeBag)
        viewModel.verificationStatus.asDriver().drive(onNext: { (status) in
            self.verificationStatusLabel.text = status
        }).addDisposableTo(disposeBag)
    }
    
    fileprivate func populateWithVerification(_ verification: PageVerification) {
        self.businessEmail.text = verification.businessEmail
        self.businessNameTextField.text = verification.businessName
        self.contactNumberTextfield.text = verification.contactNumber
        self.contactPersonTextField.text = verification.contactPerson
        self.verificationStatusLabel.text = NSLocalizedString("Verification Status: ", comment: "Verify Page Verification Status") + verification.status
        
        if let images = verification.images {
            for (index, imageURLString) in images.enumerated() where index < imageViews.count {
                guard let imageURL = URL(string: imageURLString) else { continue }
                
                let imageView = imageViews[index]
                
                imageView.sd_setImage(with: imageURL)
            }
        }
    }
}

extension VerifyPageViewController: MediaPickerControllerDelegate {
    func attachmentSelected(_ attachment: MediaAttachment, mediaPicker: MediaPickerController) {
        guard let selectedIndex = selectedImageViewIndex else { return }
    
        let imageView = imageViews[selectedIndex]
        imageView.image = attachment.image
        
        let progressView = progressViews[selectedIndex]
        let task = viewModel.uploadAttachment(attachment)
        
        task.status
            .asDriver()
            .drive(onNext: {[weak progressView] (status) in
                switch (status) {
                case .uploading:
                    progressView?.isHidden = false
                    progressView?.setIndicatorStatus(.running)
                case .error:
                    progressView?.isHidden = true
                    progressView?.setIndicatorStatus(.none)
                case .uploaded:
                    progressView?.isHidden = true
                }
            })
            .addDisposableTo(disposeBag)
        
        task.progress
            .asDriver()
            .drive(onNext: {[weak progressView] (progress) in
                progressView?.setProgress(progress, animated: true)
            })
            .addDisposableTo(disposeBag)

        
        self.selectedImageViewIndex = nil
    }
}
