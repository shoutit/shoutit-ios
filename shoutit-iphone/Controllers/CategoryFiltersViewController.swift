//
//  CategoryFiltersTableViewController.swift
//  shoutit-iphone
//
//  Created by Łukasz Kasperek on 05.04.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import UIKit
import RxSwift
import ShoutitKit

final class CategoryFiltersViewController: UIViewController {
    
    // consts
    fileprivate let cellReuseIdentifier = "CategoryFiltersTableViewCell"
    
    // view model
    var viewModel: CategoryFiltersViewModel!
    var completionBlock: (([FilterValue]) -> Void)?
    
    @IBOutlet weak var controllerTitleLabel: UILabel! {
        didSet {
            controllerTitleLabel.text = viewModel.filter.name
        }
    }
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var resetButton: UIButton!
    @IBOutlet weak var tableView: UITableView! {
        didSet {
            tableView.dataSource = self
            tableView.delegate = self
        }
    }
    
    // RX
    fileprivate let disposeBag = DisposeBag()
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        precondition(viewModel != nil)
        
        setupRx()
    }
    
    // MARK: - Setup
    
    fileprivate func setupRx() {
        
        backButton.rx_tap
            .asDriver()
            .driveNext{[unowned self] in
                self.completionBlock?(self.viewModel.selectedFilterValues())
                self.pop()
            }
            .addDisposableTo(disposeBag)
        
        resetButton.rx_tap
            .asDriver()
            .driveNext{[unowned self] in
                for i in 0..<self.viewModel.cellViewModels.count {
                    self.viewModel.cellViewModels[i].selected = false
                }
                self.tableView.reloadData()
            }
            .addDisposableTo(disposeBag)
    }
}

extension CategoryFiltersViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.cellViewModels.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellReuseIdentifier, for: indexPath) as! CategoryFiltersTableViewCell
        let cellViewModel = viewModel.cellViewModels[indexPath.row]
        cell.nameLabel.text = cellViewModel.filterValue.name
        if cellViewModel.selected {
            tableView.selectRow(at: indexPath, animated: false, scrollPosition: .none)
        } else {
            tableView.deselectRow(at: indexPath, animated: false)
        }
        return cell
    }
}

extension CategoryFiltersViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        viewModel.cellViewModels[indexPath.row].selected = true
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        viewModel.cellViewModels[indexPath.row].selected = false
    }
}
