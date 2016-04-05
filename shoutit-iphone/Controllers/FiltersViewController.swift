//
//  FiltersViewController.swift
//  shoutit-iphone
//
//  Created by Łukasz Kasperek on 31.03.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

final class FiltersViewController: UIViewController {
    
    // view model
    var viewModel: FiltersViewModel!
    
    // UI
    @IBOutlet weak var resetButton: UIButton!
    @IBOutlet weak var doneButton: CustomUIButton!
    @IBOutlet weak var tableView: UITableView! {
        didSet {
            tableView.dataSource = self
            tableView.delegate = self
        }
    }
    @IBOutlet weak var resetButtonToBottomConstraint: NSLayoutConstraint!
    
    // RX
    
    private let disposeBag = DisposeBag()
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        precondition(viewModel != nil)
        
        setupKeyboardNotifcationListenerForBottomLayoutGuideConstraint(resetButtonToBottomConstraint)
        setupRx()
    }
    
    deinit {
        removeKeyboardNotificationListeners()
    }
    
    // MARK: - Setup
    
    private func setupRx() {
        
        // UI observing
        doneButton
            .rx_tap
            .asDriver()
            .driveNext{[unowned self] in
                self.dismissViewControllerAnimated(true, completion: nil)
            }
            .addDisposableTo(disposeBag)
        
        resetButton
            .rx_tap
            .asDriver()
            .driveNext {[unowned self] in
                self.viewModel.resetFilters()
            }
            .addDisposableTo(disposeBag)
    }
}

extension FiltersViewController: UITableViewDataSource {
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.cellViewModels.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cellViewModel = viewModel.cellViewModels[indexPath.row]
        let cell = tableView.dequeueReusableCellWithIdentifier(reuseIdentifierForCellViewModel(cellViewModel), forIndexPath: indexPath)
        switch cellViewModel {
        case .ShoutTypeChoice:
            let shoutTypeCell = cell as! LabeledSelectButtonFilterTableViewCell
            shoutTypeCell.button.smallTitleLabel.text = NSLocalizedString("Type", comment: "Shout type button title label")
            shoutTypeCell.button.setTitle(cellViewModel.buttonTitle(), forState: .Normal)
            shoutTypeCell.button
                .rx_tap
                .asDriver()
                .driveNext{[unowned self] in
                    let options = FiltersCellViewModel.shoutTypeOptions()
                    let titles = options.map{$0.title}
                    self.presentActionSheetWithTitle(NSLocalizedString("Please select type", comment: ""), options: titles, completion: { (index) in
                        self.viewModel.cellViewModels[indexPath.row] = .ShoutTypeChoice(shoutType: options[index])
                        tableView.reloadRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)
                    })
                }
                .addDisposableTo(shoutTypeCell.reuseDisposeBag)
        case .SortTypeChoice:
            let sortTypeCell = cell as! LabeledSelectButtonFilterTableViewCell
            sortTypeCell.button.smallTitleLabel.text = NSLocalizedString("Sort By", comment: "Sort type button title label")
            sortTypeCell.button.setTitle(cellViewModel.buttonTitle(), forState: .Normal)
            viewModel.sortTypes
                .asDriver()
                .driveNext{ (sortTypesDownloadState) in
                    switch sortTypesDownloadState {
                    case .Loading:
                        sortTypeCell.button.optionsLoaded = false
                    case .CantLoadContent:
                        sortTypeCell.button.optionsLoaded = true
                        sortTypeCell.button.setTitle(NSLocalizedString("Filter unavailable", comment: ""), forState: .Normal)
                    case .Loaded:
                        sortTypeCell.button.optionsLoaded = true
                        sortTypeCell.button.setTitle(cellViewModel.buttonTitle(), forState: .Normal)
                    }
                }
                .addDisposableTo(sortTypeCell.reuseDisposeBag)
            
            sortTypeCell.button
                .rx_tap
                .asDriver()
                .driveNext{[unowned self] () in
                    guard case .Loaded(let sortTypes) = self.viewModel.sortTypes.value else { return }
                    let names = sortTypes.map{$0.name}
                    self.presentActionSheetWithTitle(NSLocalizedString("Please select sort type", comment: ""), options: names, completion: { (index) in
                        self.viewModel.cellViewModels[indexPath.row] = .SortTypeChoice(sortType: sortTypes[index])
                        tableView.reloadRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)
                    })
                }
                .addDisposableTo(sortTypeCell.reuseDisposeBag)
            
        case .CategoryChoice(let category):
            let categoryCell = cell as! SelectButtonFilterTableViewCell
            categoryCell.button.setTitle(cellViewModel.buttonTitle(), forState: .Normal)
            categoryCell.button.hideIcon = category?.icon == nil
            categoryCell.button.iconImageView.sh_setImageWithURL(category?.icon?.toURL(), placeholderImage: nil)
            viewModel.categories
                .asDriver()
                .driveNext{ (categoriesDownloadState) in
                    switch categoriesDownloadState {
                    case .Loading:
                        categoryCell.button.optionsLoaded = false
                    case .CantLoadContent:
                        categoryCell.button.optionsLoaded = true
                        categoryCell.button.setTitle(NSLocalizedString("Filter unavailable", comment: ""), forState: .Normal)
                    case .Loaded:
                        categoryCell.button.optionsLoaded = true
                        categoryCell.button.setTitle(cellViewModel.buttonTitle(), forState: .Normal)
                    }
                }
                .addDisposableTo(categoryCell.reuseDisposeBag)
            
            categoryCell.button
                .rx_tap
                .observeOn(MainScheduler.instance)
                .subscribeNext{[unowned self] () in
                    guard case .Loaded(let categories) = self.viewModel.categories.value else { return }
                    let categoryNames = categories.map{$0.name}
                    self.presentActionSheetWithTitle(NSLocalizedString("Please select category", comment: ""), options: categoryNames) { (index) in
                        self.viewModel.cellViewModels[indexPath.row] = .CategoryChoice(category: categories[index])
                        tableView.reloadRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)
                    }
                }
                .addDisposableTo(categoryCell.reuseDisposeBag)
        case .PriceRestriction(let from, let to):
            let priceCell = cell as! LimitingTextFieldsFilterTableViewCell
            priceCell.minimumValueTextField
                .rx_text
                .skip(1)
                .observeOn(MainScheduler.instance)
                .subscribeNext{[unowned self] (value) in
                    self.viewModel.cellViewModels[indexPath.row] = .PriceRestriction(from: Int(value), to: to)
                }
                .addDisposableTo(priceCell.reuseDisposeBag)
            priceCell.maximumValueTextField
                .rx_text
                .skip(1)
                .observeOn(MainScheduler.instance)
                .subscribeNext{[unowned self] (value) in
                    self.viewModel.cellViewModels[indexPath.row] = .PriceRestriction(from: from, to: Int(value))
                }
                .addDisposableTo(priceCell.reuseDisposeBag)
        case .LocationChoice:
            let locationCell = cell as! SelectButtonFilterTableViewCell
            locationCell.button.setTitle(cellViewModel.buttonTitle(), forState: .Normal)
            locationCell.button.hideIcon = true
        case .DistanceRestriction(let distanceOption):
            let distanceCell = cell as! SliderFilterTableViewCell
        case .FilterValueChoice(let filter):
            let filterCell = cell as! BigLabelButtonFilterTableViewCell
            
        }
        
        return cell
    }
}

extension FiltersViewController: UITableViewDelegate {
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        let cellViewModel = viewModel.cellViewModels[indexPath.row]
        switch cellViewModel {
        case .ShoutTypeChoice, .SortTypeChoice, .CategoryChoice, .FilterValueChoice:
            return 60
        case .PriceRestriction, .LocationChoice:
            return 96
        case .DistanceRestriction:
            return 91
        }
    }
}

// MARK - Helpers

private extension FiltersViewController {
    
    private func reuseIdentifierForCellViewModel(cellViewModel: FiltersCellViewModel) -> String {
        switch cellViewModel {
        case .ShoutTypeChoice:
            return "ShoutTypeChoiceCell"
        case .SortTypeChoice:
            return "SortByChoiceCell"
        case .CategoryChoice:
            return "CategoryChoiceCell"
        case .PriceRestriction:
            return "PriceRestrictionCell"
        case .LocationChoice:
            return "LocationChoiceCell"
        case .DistanceRestriction:
            return "DistanceRestrictionCell"
        case .FilterValueChoice:
            return "FilterCell"
        }
    }
    
    private func presentActionSheetWithTitle(title: String, options: [String], completion:(Int -> Void)?) {
        let alertController = UIAlertController(title: title, message: nil, preferredStyle: .ActionSheet)
        for (index, option) in options.enumerate() {
            let action = UIAlertAction(title: option, style: .Default) { (action) in
                completion?(index)
            }
            alertController.addAction(action)
        }
        let cancelAction = UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .Cancel, handler: nil)
        alertController.addAction(cancelAction)
        
        self.presentViewController(alertController, animated: true, completion: nil)
    }
}
