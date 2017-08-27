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
import ShoutitKit

final class FiltersViewController: UIViewController {
    
    // view model
    var viewModel: FiltersViewModel!
    var completionBlock: ((FiltersState) -> Void)?
    
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
    
    fileprivate let disposeBag = DisposeBag()
    
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
    
    fileprivate func setupRx() {
        
        // UI observing
        doneButton
            .rx.tap
            .asDriver()
            .drive(onNext: { [weak self] in
                guard let `self` = self else { return }
                let state = self.viewModel.composeFiltersState()
                self.completionBlock?(state)
                self.dismiss(animated: true, completion: nil)
            })
            .addDisposableTo(disposeBag)
        
        resetButton
            .rx.tap
            .asDriver()
            .drive(onNext: { [unowned self] in
                self.viewModel.resetFilters()
            })
            .addDisposableTo(disposeBag)
        
        // view model observing
        viewModel.reloadSubject
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: {[weak self] () in
                self?.tableView.reloadData()
            })
            .addDisposableTo(disposeBag)
    }
}

extension FiltersViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.cellViewModels.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellViewModel = viewModel.cellViewModels[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifierForCellViewModel(cellViewModel), for: indexPath)
        switch cellViewModel {
        case .shoutTypeChoice:
            let shoutTypeCell = cell as! LabeledSelectButtonFilterTableViewCell
            shoutTypeCell.button.fieldTitleLabel.text = NSLocalizedString("Type", comment: "Shout type button title label")
            shoutTypeCell.button.setTitle(cellViewModel.buttonTitle(), for: UIControlState())
            shoutTypeCell.button
                .rx.tap
                .asDriver()
                .drive(onNext: { [weak self] in
                    self?.presentShoutChoiceActionSheet()
                })
                .addDisposableTo(shoutTypeCell.reuseDisposeBag)
        case .sortTypeChoice(_, let loaded):
            let sortTypeCell = cell as! LabeledSelectButtonFilterTableViewCell
            sortTypeCell.button.fieldTitleLabel.text = NSLocalizedString("Sort By", comment: "Sort type button title label")
            sortTypeCell.button.setTitle(cellViewModel.buttonTitle(), for: UIControlState())
            sortTypeCell.button.showActivity(!loaded())
            
            sortTypeCell.button
                .rx.tap
                .asDriver()
                .drive(onNext: { [weak self] in
                    self?.presentSortTypeChoiceActionSheet()
                })
                .addDisposableTo(sortTypeCell.reuseDisposeBag)
            
        case .categoryChoice(let category, let enabled, let loaded):
            let categoryCell = cell as! SelectButtonFilterTableViewCell
            categoryCell.button.setTitle(cellViewModel.buttonTitle(), for: UIControlState())
            categoryCell.button.showIcon(category?.icon != nil)
            if let path = category?.icon, let url = path.toURL() {
                categoryCell.button.iconImageView.kf.setImage(with: url, placeholder: nil)
            }
            categoryCell.button.isEnabled = enabled
            categoryCell.button.alpha = enabled ? 1.0 : 0.5
            categoryCell.button.showActivity(!loaded())
            
            categoryCell.button
                .rx.tap
                .observeOn(MainScheduler.instance)
                .subscribe(onNext: { [weak self] in
                    self?.presentCategoryChoiceActionSheet()
                })
                .addDisposableTo(categoryCell.reuseDisposeBag)
        case .priceRestriction(let from, let to):
            let priceCell = cell as! LimitingTextFieldsFilterTableViewCell
            priceCell.minimumValueTextField.text = from != nil ? String(from!) : nil
            priceCell.maximumValueTextField.text = to != nil ? String(to!) : nil
            priceCell.minimumValueTextField
                .rx.text
                .skip(1)
                .observeOn(MainScheduler.instance)
                .subscribe(onNext: { [weak self] (value) in
                    self?.viewModel.changeMinimumPriceTo(Int(value ?? 0))
                })
                .addDisposableTo(priceCell.reuseDisposeBag)
            priceCell.maximumValueTextField
                .rx.text
                .skip(1)
                .observeOn(MainScheduler.instance)
                .subscribe(onNext: { [weak self] (value) in
                    self?.viewModel.changeMaximumPriceTo(Int(value ?? 0))
                })
                .addDisposableTo(priceCell.reuseDisposeBag)
        case .locationChoice(let address):
            let locationCell = cell as! SelectButtonFilterTableViewCell
            locationCell.button.setTitle(cellViewModel.buttonTitle(), for: UIControlState())
            if let location = address {
                locationCell.button.iconImageView.image = UIImage(named: location.country)
                locationCell.button.showIcon(true)
            } else {
                locationCell.button.showIcon(false)
            }
            locationCell.button
                .rx.tap
                .asDriver()
                .drive(onNext: { [weak self] in
                    self?.presentLocationChoiceController()
                })
                .addDisposableTo(locationCell.reuseDisposeBag)
        case .distanceRestriction(let distanceOption):
            let distanceCell = cell as! SliderFilterTableViewCell
            distanceCell.slider.value = viewModel.sliderValueForDistanceRestrictionOption(distanceOption)
            distanceCell.slider
                .rx.value
                .asDriver()
                .drive(onNext: { [unowned self] (value) in
                    let option = self.viewModel.distanceRestrictionOptionForSliderValue(value)
                    let newViewModel = FiltersCellViewModel.distanceRestriction(distanceOption: option)
                    self.viewModel.cellViewModels[indexPath.row] = newViewModel
                    distanceCell.currentValueLabel.text = newViewModel.buttonTitle()
                })
                .addDisposableTo(distanceCell.reuseDisposeBag)
        case .filterValueChoice(let filter, let selectedValues):
            let filterCell = cell as! BigLabelButtonFilterTableViewCell
            filterCell.button.fieldTitleLabel.text = filter.name
            filterCell.button.setTitle(cellViewModel.buttonTitle(), for: UIControlState())
            filterCell.button
                .rx.tap
                .asDriver()
                .drive(onNext: { [weak self] in
                    self?.presentFilterChoiceScreenWithFilter(filter, selectedValues: selectedValues)
                })
                .addDisposableTo(filterCell.reuseDisposeBag)
        }
        
        return cell
    }
}

extension FiltersViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let cellViewModel = viewModel.cellViewModels[indexPath.row]
        switch cellViewModel {
        case .shoutTypeChoice, .sortTypeChoice, .categoryChoice, .filterValueChoice:
            return 60
        case .priceRestriction, .locationChoice:
            return 96
        case .distanceRestriction:
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
        navigationController?.show(controller, sender: nil)
    }
    
    func presentFilterChoiceScreenWithFilter(_ filter: Filter, selectedValues: [FilterValue]) {
        
        let controller = Wireframe.categoryFiltersChoiceViewController()
        controller.viewModel = CategoryFiltersViewModel(filter: filter, selectedValues: selectedValues)
        controller.completionBlock = {[weak self](newSelectedValues) in
            self?.viewModel.changeValuesForFilter(filter, toValues: newSelectedValues)
        }
        self.navigationController?.show(controller, sender: nil)
    }
    
    func presentCategoryChoiceActionSheet() {
        
        guard case .loaded(let categories) = self.viewModel.categories.value else { return }
        let categoryNames = categories.map{$0.name}
        let options = [NSLocalizedString("All Categories", comment: "Filters View")] + categoryNames
        self.presentActionSheetWithTitle(NSLocalizedString("Please select category", comment: "Filters View"), options: options) {[weak self] (index) in
            let category: ShoutitKit.Category? = index == 0 ? nil : categories[index - 1]
            self?.viewModel.changeCategoryToCategory(category)
        }
    }
    
    func presentShoutChoiceActionSheet() {
        let shoutTypes: [ShoutType] = [.Offer, .Request]
        let options = [NSLocalizedString("Offers and Requests", comment: "Filter shout type"),
                       NSLocalizedString("Only Offers", comment: "Filter shout type"),
                       NSLocalizedString("Only Requests", comment: "Filter shout type")]
        self.presentActionSheetWithTitle(NSLocalizedString("Please select type", comment: "Filters View"), options: options, completion: {[weak self] (index) in
            let shoutType: ShoutType? = index == 0 ? nil : shoutTypes[index - 1]
            self?.viewModel.changeShoutTypeToType(shoutType)
        })
    }
    
    func presentSortTypeChoiceActionSheet() {
        guard case .loaded(let sortTypes) = viewModel.sortTypes.value else { return }
        let names = sortTypes.map{$0.name}
        self.presentActionSheetWithTitle(NSLocalizedString("Please select sort type", comment: "Filters View"), options: names, completion: {[weak self] (index) in
            self?.viewModel.changeSortTypeToType(sortTypes[index])
        })
    }
}

// MARK: - Helpers

private extension FiltersViewController {
    
    func reuseIdentifierForCellViewModel(_ cellViewModel: FiltersCellViewModel) -> String {
        switch cellViewModel {
        case .shoutTypeChoice:
            return "ShoutTypeChoiceCell"
        case .sortTypeChoice:
            return "SortByChoiceCell"
        case .categoryChoice:
            return "CategoryChoiceCell"
        case .priceRestriction:
            return "PriceRestrictionCell"
        case .locationChoice:
            return "LocationChoiceCell"
        case .distanceRestriction:
            return "DistanceRestrictionCell"
        case .filterValueChoice:
            return "FilterCell"
        }
    }
    
    func presentActionSheetWithTitle(_ title: String, options: [String], completion:((Int) -> Void)?) {
        let alertController = UIAlertController(title: title, message: nil, preferredStyle: .actionSheet)
        for (index, option) in options.enumerated() {
            let action = UIAlertAction(title: option, style: .default) { (action) in
                completion?(index)
            }
            alertController.addAction(action)
        }
        let cancelAction = UIAlertAction(title: LocalizedString.cancel, style: .cancel, handler: nil)
        alertController.addAction(cancelAction)
        
        self.present(alertController, animated: true, completion: nil)
    }
}
