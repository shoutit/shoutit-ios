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
    var completionBlock: (FiltersState -> Void)?
    
    // UI
    @IBOutlet weak var resetButton: UIButton!
    @IBOutlet weak var doneButton: CustomUIButton!
    @IBOutlet weak var tableView: UITableView! {
        didSet {
            tableView.dataSource = self
            tableView.delegate = self
            tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 10, right: 0)
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
            .driveNext{[weak self] in
                guard let `self` = self else { return }
                let state = self.viewModel.composeFiltersState()
                self.completionBlock?(state)
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
        
        // view model observing
        viewModel.reloadSubject
            .observeOn(MainScheduler.instance)
            .subscribeNext {[weak self] () in
                self?.tableView.reloadData()
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
            shoutTypeCell.button.fieldTitleLabel.text = NSLocalizedString("Type", comment: "Shout type button title label")
            shoutTypeCell.button.setTitle(cellViewModel.buttonTitle(), forState: .Normal)
            shoutTypeCell.button
                .rx_tap
                .asDriver()
                .driveNext{[weak self] in
                    self?.presentShoutChoiceActionSheet()
                }
                .addDisposableTo(shoutTypeCell.reuseDisposeBag)
        case .SortTypeChoice(_, let loaded):
            let sortTypeCell = cell as! LabeledSelectButtonFilterTableViewCell
            sortTypeCell.button.fieldTitleLabel.text = NSLocalizedString("Sort By", comment: "Sort type button title label")
            sortTypeCell.button.setTitle(cellViewModel.buttonTitle(), forState: .Normal)
            sortTypeCell.button.showActivity(!loaded())
            
            sortTypeCell.button
                .rx_tap
                .asDriver()
                .driveNext{[weak self] () in
                    self?.presentSortTypeChoiceActionSheet()
                }
                .addDisposableTo(sortTypeCell.reuseDisposeBag)
            
        case .CategoryChoice(let category, let enabled, let loaded):
            let categoryCell = cell as! SelectButtonFilterTableViewCell
            categoryCell.button.setTitle(cellViewModel.buttonTitle(), forState: .Normal)
            categoryCell.button.showIcon(category?.icon != nil)
            categoryCell.button.iconImageView.sh_setImageWithURL(category?.icon?.toURL(), placeholderImage: nil)
            categoryCell.button.enabled = enabled
            categoryCell.button.alpha = enabled ? 1.0 : 0.5
            categoryCell.button.showActivity(!loaded())
            
            categoryCell.button
                .rx_tap
                .observeOn(MainScheduler.instance)
                .subscribeNext{[weak self] () in
                    self?.presentCategoryChoiceActionSheet()
                }
                .addDisposableTo(categoryCell.reuseDisposeBag)
        case .PriceRestriction(let from, let to):
            let priceCell = cell as! LimitingTextFieldsFilterTableViewCell
            priceCell.minimumValueTextField.text = from != nil ? String(from!) : nil
            priceCell.maximumValueTextField.text = to != nil ? String(to!) : nil
            priceCell.minimumValueTextField
                .rx_text
                .skip(1)
                .observeOn(MainScheduler.instance)
                .subscribeNext{[weak self] (value) in
                    self?.viewModel.changeMinimumPriceTo(Int(value))
                }
                .addDisposableTo(priceCell.reuseDisposeBag)
            priceCell.maximumValueTextField
                .rx_text
                .skip(1)
                .observeOn(MainScheduler.instance)
                .subscribeNext{[weak self] (value) in
                    self?.viewModel.changeMaximumPriceTo(Int(value))
                }
                .addDisposableTo(priceCell.reuseDisposeBag)
        case .LocationChoice(let address):
            let locationCell = cell as! SelectButtonFilterTableViewCell
            locationCell.button.setTitle(cellViewModel.buttonTitle(), forState: .Normal)
            if let location = address {
                locationCell.button.iconImageView.image = UIImage(named: location.country)
                locationCell.button.showIcon(true)
            } else {
                locationCell.button.showIcon(false)
            }
            locationCell.button
                .rx_tap
                .asDriver()
                .driveNext{[weak self] () in
                    self?.presentLocationChoiceController()
                }
                .addDisposableTo(locationCell.reuseDisposeBag)
        case .DistanceRestriction(let distanceOption):
            let distanceCell = cell as! SliderFilterTableViewCell
            distanceCell.slider.value = viewModel.sliderValueForDistanceRestrictionOption(distanceOption)
            distanceCell.slider
                .rx_value
                .asDriver()
                .driveNext{[unowned self] (value) in
                    let option = self.viewModel.distanceRestrictionOptionForSliderValue(value)
                    self.viewModel.cellViewModels[indexPath.row] = .DistanceRestriction(distanceOption: option)
                    distanceCell.currentValueLabel.text = option.title
                }
                .addDisposableTo(distanceCell.reuseDisposeBag)
        case .FilterValueChoice(let filter, let selectedValues):
            let filterCell = cell as! BigLabelButtonFilterTableViewCell
            filterCell.button.fieldTitleLabel.text = filter.name
            filterCell.button.setTitle(cellViewModel.buttonTitle(), forState: .Normal)
            filterCell.button
                .rx_tap
                .asDriver()
                .driveNext{[unowned self] in
                    self.presentFilterChoiceScreenWithFilter(filter, selectedValues: selectedValues)
                }
                .addDisposableTo(filterCell.reuseDisposeBag)
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

// MARK: - Filters LocationChoice

private extension FiltersViewController {
    
    func presentLocationChoiceController() {
        
        let controller = Wireframe.filtersChangeLocationViewController()
        controller.finishedBlock = {[weak self](success, place) -> Void in
            if let place = place {
                self?.viewModel.changeLocationToLocation(place)
            }
        }
        navigationController?.showViewController(controller, sender: nil)
    }
    
    func presentFilterChoiceScreenWithFilter(filter: Filter, selectedValues: [FilterValue]) {
        
        let controller = Wireframe.categoryFiltersChoiceViewController()
        controller.viewModel = CategoryFiltersViewModel(filter: filter, selectedValues: selectedValues)
        controller.completionBlock = {[weak self](newSelectedValues) in
            self?.viewModel.changeValuesForFilter(filter, toValues: newSelectedValues)
        }
        self.navigationController?.showViewController(controller, sender: nil)
    }
    
    func presentCategoryChoiceActionSheet() {
        
        guard case .Loaded(let categories) = self.viewModel.categories.value else { return }
        let categoryNames = categories.map{$0.name}
        let options = [NSLocalizedString("All Categories", comment: "")] + categoryNames
        self.presentActionSheetWithTitle(NSLocalizedString("Please select category", comment: ""), options: options) {[weak self] (index) in
            let category: Category? = index == 0 ? nil : categories[index - 1]
            self?.viewModel.changeCategoryToCategory(category)
        }
    }
    
    func presentShoutChoiceActionSheet() {
        let shoutTypes: [ShoutType] = [.Offer, .Request]
        let options = [NSLocalizedString("Offers and Requests", comment: "Filter shout type"),
                       NSLocalizedString("Only Offers", comment: "Filter shout type"),
                       NSLocalizedString("Only Requests", comment: "Filter shout type")]
        self.presentActionSheetWithTitle(NSLocalizedString("Please select type", comment: ""), options: options, completion: {[weak self] (index) in
            let shoutType: ShoutType? = index == 0 ? nil : shoutTypes[index - 1]
            self?.viewModel.changeShoutTypeToType(shoutType)
        })
    }
    
    func presentSortTypeChoiceActionSheet() {
        guard case .Loaded(let sortTypes) = viewModel.sortTypes.value else { return }
        let names = sortTypes.map{$0.name}
        self.presentActionSheetWithTitle(NSLocalizedString("Please select sort type", comment: ""), options: names, completion: {[weak self] (index) in
            self?.viewModel.changeSortTypeToType(sortTypes[index])
        })
    }
}

// MARK: - Helpers

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
