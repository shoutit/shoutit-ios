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

class EditProfileTableViewController: UITableViewController {
    
    var viewModel: EditProfileTableViewModel!
    
    // RX
    private let disposeBag = DisposeBag()
    
    // UI
    @IBOutlet weak var headerView: EditProfileTableViewHeaderView!
    @IBOutlet weak var cancelBarButtonItem: UIBarButtonItem!
    @IBOutlet weak var saveBarButtonItem: UIBarButtonItem!
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.estimatedRowHeight = 70
        
        // setup photos
        headerView.avatarImageView.sh_setImageWithURL(viewModel.user.imagePath?.toURL(), placeholderImage: UIImage.squareAvatarPlaceholder())
        headerView.coverImageView.sh_setImageWithURL(viewModel.user.coverPath?.toURL(), placeholderImage: UIImage.profileCoverPlaceholder())
        
        setupRX()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBarHidden = false
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
        case .BasicText(let value, let placeholder):
            let cell = cell as! EditProfileTextFieldTableViewCell
            cell.textField.placeholder = placeholder
            cell.textField.text = value
            cell.textField
                .rx_text
                .asDriver()
                .driveNext{[unowned self] (text) in
                    
                }
                .addDisposableTo(cell.disposeBag)
        case .RichText(let value, let placeholder):
            let cell = cell as! EditProfileTextViewTableViewCell
            cell.textView.placeholderLabel?.text = placeholder
            cell.textView.text = value
            cell.textView.rx_text
                .observeOn(MainScheduler.instance)
                .distinctUntilChanged()
                .subscribeNext{[weak textView = cell.textView] (text) in
                    textView?.detailLabel?.text = "\(text.characters.count)/250"
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
        case .Location(let value, let placeholder):
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
                    
                    self?.navigationController?.showViewController(controller, sender: nil)
                    
                    })
                .addDisposableTo(cell.disposeBag)
        }
        
        
        return cell
    }
}
