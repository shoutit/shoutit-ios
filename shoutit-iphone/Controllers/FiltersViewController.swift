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
    
    // MARK: - Helpers
    
    private func reuseIdentifierForCellViewModel(cellViewModel: FiltersCellViewModel) -> String {
        switch cellViewModel {
        case .ShoutTypeChoice:
            return "ShoutTypeChoiceCell"
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

extension FiltersViewController: UITableViewDataSource {
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 0
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        fatalError()
    }
}
