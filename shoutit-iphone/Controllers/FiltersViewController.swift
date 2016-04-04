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

class FiltersViewController: UIViewController {
    
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
    
    // RX
    
    private let disposeBag = DisposeBag()
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        precondition(viewModel != nil)
        
        setupRx()
    }
    
    // MARK: - Setup
    
    private func setupRx() {
        
        doneButton
            .rx_tap
            .asDriver()
            .driveNext{[unowned self] in
                self.dismissViewControllerAnimated(true, completion: nil)
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
        case .ShoutTypeChoice(let shoutType):
            let shoutTypeCell = cell as! LabeledSelectButtonFilterTableViewCell
            shoutTypeCell.button.smallTitleLabel.text = NSLocalizedString("Type", comment: "Shout type button title label")
            shoutTypeCell.button.setTitle(cellViewModel.buttonTitle(), forState: .Normal)
        case .SortTypeChoice(let sortType):
            let sortTypeCell = cell as! LabeledSelectButtonFilterTableViewCell
            sortTypeCell.button.smallTitleLabel.text = NSLocalizedString("Sort By", comment: "Sort type button title label")
            sortTypeCell.button.setTitle(cellViewModel.buttonTitle(), forState: .Normal)
        case .CategoryChoice(let category):
            let categoryCell = cell as! SelectButtonFilterTableViewCell
            categoryCell.button.setTitle(cellViewModel.buttonTitle(), forState: .Normal)
        case .PriceRestriction(let from, let to):
            let priceCell = cell as! LimitingTextFieldsFilterTableViewCell
        case .LocationChoice(let location):
            let locationCell = cell as! SelectButtonFilterTableViewCell
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
}
