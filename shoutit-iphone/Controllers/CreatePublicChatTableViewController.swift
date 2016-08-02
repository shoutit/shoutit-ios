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
    
    // outlets
    @IBOutlet weak var headerView: CreatePublicChatHeaderView!
    
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
        setupViews()
    }
    
    // MARK: - Setup
    
    private func setupRX() {
        
        headerView.chatImageButton
            .rx_tap
            .asDriver()
            .driveNext {[unowned self] in
                self.mediaPickerController.showMediaPickerController()
            }
            .addDisposableTo(disposeBag)
        
        headerView.chatSubjectTextField
            .rx_text
            .asDriver()
            .driveNext {[weak self] (text) in
                self?.viewModel.chatSubject = text
            }
            .addDisposableTo(disposeBag)
    }
    
    private func setupViews() {
        headerView.setupImageViewWithStatus(.NoImage)
        
        view.setNeedsLayout()
        view.layoutIfNeeded()
        if let headerView = tableView.tableHeaderView {
            let size = headerView.systemLayoutSizeFittingSize(UILayoutFittingCompressedSize)
            tableView.frame = CGRect(x: 0, y: 0, width: headerView.bounds.width, height: size.height)
            tableView.tableHeaderView = headerView
        }
    }
}

extension CreatePublicChatTableViewController {
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return viewModel.sections.count
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.sections[section].cellViewModels.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cellViewModel = viewModel.sections[indexPath.section].cellViewModels[indexPath.row]
        switch cellViewModel {
        case .Location(let location):
            let cell: LocationChoiceTableViewCell = tableView.dequeueReusableCell(forIndexPath: indexPath)
            cell.button.setTitle(location.address, forState: .Normal)
            cell.button.iconImageView.image = UIImage(named: location.country)
            cell.button
                .rx_tap
                .asDriver()
                .driveNext({ [weak self] () -> Void in
                    
                    let controller = Wireframe.changeShoutLocationController()
                    
                    controller.finishedBlock = {[weak indexPath](success, place) -> Void in
                        if let place = place, indexPath = indexPath {
                            let newViewModel = CreatePublicChatCellViewModel.Location(location: place)
                            self?.viewModel.sections[indexPath.section].cellViewModels[indexPath.row] = newViewModel
                            self?.tableView.reloadRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)
                        }
                    }
                    
                    controller.navigationItem.leftBarButtonItem = UIBarButtonItem(title: LocalizedString.cancel, style: .Plain, target: controller, action: #selector(controller.pop))
                    self?.navigationController?.showViewController(controller, sender: nil)
                    
                    })
                .addDisposableTo(cell.reuseDisposeBag)
            return cell
        case .Selectable(let option, let selected):
            let cell: CreatePublicChatSelectionTableViewCell = tableView.dequeueReusableCell(forIndexPath: indexPath)
            cell.label.text = option.title
            if selected {
                tableView.selectRowAtIndexPath(indexPath, animated: false, scrollPosition: .None)
            }
            return cell
        }
    }
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return viewModel.sections[section].title
    }
}

extension CreatePublicChatTableViewController {
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        let cellViewModel = viewModel.sections[indexPath.section].cellViewModels[indexPath.row]
        if case .Location = cellViewModel {
            return 50
        }
        return 44
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        viewModel.sections[indexPath.section].selectCellViewModelAtIndex(indexPath.row)
    }
}

extension CreatePublicChatTableViewController: MediaPickerControllerDelegate {
    
    func attachmentSelected(attachment: MediaAttachment, mediaPicker: MediaPickerController) {
        
        let task = viewModel.uploadImageAttachment(attachment)
        headerView.setChatImage(.Image(image: attachment.image))
        
        task.status
            .asDriver()
            .driveNext{[weak self] (status) in
                switch status {
                case .Error:
                    self?.headerView.setupImageViewWithStatus(.NoImage)
                case .Uploaded:
                    self?.headerView.setupImageViewWithStatus(.Uploaded)
                case .Uploading:
                    self?.headerView.setupImageViewWithStatus(.Uploading)
                }
            }
            .addDisposableTo(disposeBag)
        
        task.progress
            .asDriver()
            .driveNext{[weak headerView] (progress) in
                headerView?.chatImageProgressView.setProgress(progress, animated: true)
            }
            .addDisposableTo(disposeBag)
    }
}
