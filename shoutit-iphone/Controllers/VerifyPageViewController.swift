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

    var page: DetailedPageProfile!

    var viewModel: VerifyPageViewModel!
    
    // RX
    private let disposeBag = DisposeBag()
    
    @IBOutlet weak var businessNameTextField: UITextField!
    @IBOutlet weak var contactPersonTextField: UITextField!
    @IBOutlet weak var contactNumberTextfield: UITextField!
    @IBOutlet weak var businessEmail: UITextField!
    
    @IBOutlet weak var locationButton: SelectionButton!
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var cancelBarButtonItem: UIBarButtonItem!
    
    @IBOutlet weak var firstImageView: UIImageView!
    @IBOutlet weak var secondImageView: UIImageView!
    @IBOutlet weak var thirdImageView: UIImageView!
    
    @IBOutlet weak var firstDownloadView: ACPDownloadView!
    @IBOutlet weak var secondDownloadView: ACPDownloadView!
    @IBOutlet weak var thirdDownloadView: ACPDownloadView!
    
    @IBOutlet var firstTapGestureRecognizer: UITapGestureRecognizer!
    @IBOutlet var secondTapGestureRecognizer: UITapGestureRecognizer!
    @IBOutlet var thirdTapGestureRecognizer: UITapGestureRecognizer!
    
    private var imageViews: [UIImageView] {
        return [firstImageView, secondImageView, thirdImageView]
    }
    
    private var progressViews: [ACPDownloadView] {
        return [firstDownloadView, secondDownloadView, thirdDownloadView]
    }
    
    private var tapGestureRecognizers: [UITapGestureRecognizer] {
        return [firstTapGestureRecognizer, secondTapGestureRecognizer, thirdTapGestureRecognizer]
    }
    
    private var selectedImageViewIndex: Int?
    
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        precondition(viewModel != nil)
        
        setupRX()
    }
    
    func setupRX() {
        saveButton
            .rx_tap
            .asDriver()
            .driveNext {[weak self] in
                self?.viewModel.verifyPage()
            }
            .addDisposableTo(disposeBag)
        
        cancelBarButtonItem
            .rx_tap
            .asDriver()
            .driveNext({[weak self] in
                    self?.navigationController?.dismissViewControllerAnimated(true, completion:nil)
                })
            .addDisposableTo(disposeBag)
        
        locationButton
            .rx_tap
            .asDriver()
            .driveNext({[weak self] in
                let controller = Wireframe.changeShoutLocationController()
                
                controller.finishedBlock = { (success, place) -> Void in
                    self?.locationButton.setTitle(place?.address, forState: .Normal)
                    self?.viewModel.location.value = place
                }
                
                self?.navigationController?.showViewController(controller, sender: nil)
            })
            .addDisposableTo(disposeBag)
        
        viewModel.progressSubject
            .distinctUntilChanged()
            .observeOn(MainScheduler.instance)
            .subscribeNext {[weak self] (show) in
                if show {
                    MBProgressHUD.showHUDAddedTo(self?.view, animated: true)
                } else {
                    MBProgressHUD.hideHUDForView(self?.view, animated: true)
                }
            }
            .addDisposableTo(disposeBag)
        
        viewModel.successSubject
            .observeOn(MainScheduler.instance)
            .subscribeNext {[weak self] (message) in
                self?.navigationController?.dismissViewControllerAnimated(true, completion:nil)
            }
            .addDisposableTo(disposeBag)
        
        viewModel.errorSubject
        .observeOn(MainScheduler.instance)
            .subscribeNext {[weak self] (error) in
                self?.showError(error)
            }
            .addDisposableTo(disposeBag)
        
        
        for (index, tapGestureRecognizer) in tapGestureRecognizers.enumerate() {
           tapGestureRecognizer
            .rx_event
            .asDriver()
            .driveNext({[unowned self] (UIGestureRecognizer) in
                self.selectedImageViewIndex = index
                self.mediaPickerController.showMediaPickerController()
            })
            .addDisposableTo(disposeBag)
        }
        
        businessEmail.rx_text.bindTo(viewModel.email).addDisposableTo(disposeBag)
        contactPersonTextField.rx_text.bindTo(viewModel.contactPerson).addDisposableTo(disposeBag)
        contactNumberTextfield.rx_text.bindTo(viewModel.contactNumber).addDisposableTo(disposeBag)
        businessNameTextField.rx_text.bindTo(viewModel.businessName).addDisposableTo(disposeBag)
    }
}

extension VerifyPageViewController: MediaPickerControllerDelegate {
    func attachmentSelected(attachment: MediaAttachment, mediaPicker: MediaPickerController) {
        guard let selectedIndex = selectedImageViewIndex else { return }
    
        let imageView = imageViews[selectedIndex]
        imageView.image = attachment.image
        
        let progressView = progressViews[selectedIndex]
        let task = viewModel.uploadAttachment(attachment)
        
        task.status
            .asDriver()
            .driveNext{[weak progressView] (status) in
                switch (status) {
                case .Uploading:
                    progressView?.hidden = false
                    progressView?.setIndicatorStatus(.Running)
                case .Error:
                    progressView?.hidden = true
                    progressView?.setIndicatorStatus(.None)
                case .Uploaded:
                    progressView?.hidden = true
                }
            }
            .addDisposableTo(disposeBag)
        
        task.progress
            .asDriver()
            .driveNext{[weak progressView] (progress) in
                progressView?.setProgress(progress, animated: true)
            }
            .addDisposableTo(disposeBag)

        
        self.selectedImageViewIndex = nil
    }
}
