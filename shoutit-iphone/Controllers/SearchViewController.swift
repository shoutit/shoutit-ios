//
//  SearchViewController.swift
//  shoutit-iphone
//
//  Created by Łukasz Kasperek on 15.03.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class SearchViewController: UIViewController {
    
    // UI
    @IBOutlet weak var searchBar: UISearchBar! {
        didSet {
            searchBar.delegate = self
            searchBar.layer.borderColor = UIColor(shoutitColor: .SearchBarGray).CGColor
            searchBar.layer.borderWidth = 1.0
        }
    }
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    @IBOutlet weak var segmentedControlSectionHeightConstraint: NSLayoutConstraint!
    
    // view model
    var viewModel: SearchViewModel!
    
    // RX
    private let disposeBag = DisposeBag()
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        precondition(viewModel != nil)
        
        setupAppearance()
        setupRX()
    }
    
    override func prefersNavigationBarHidden() -> Bool {
        return true
    }
    
    // MARK: - Setup
    
    private func setupRX() {
        
        segmentedControl
            .rx_value
            .asDriver()
            .driveNext { (segment) in
                
            }
            .addDisposableTo(disposeBag)
    }
    
    private func setupAppearance() {
        let textField = searchBar.searchForTextField()
        textField?.backgroundColor = UIColor(shoutitColor: .SearchBarTextFieldGray)
    }
    
    // MARK: - Helpers
    
    private func showSegmentedControl(show: Bool) {
        segmentedControlSectionHeightConstraint.constant = show ? 44 : 0
        UIView.animateWithDuration(0.25) { 
            self.view.layoutIfNeeded()
        }
    }
}

extension SearchViewController: UITableViewDataSource {
    
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

extension SearchViewController: UITableViewDelegate {
    
}

extension SearchViewController: UISearchBarDelegate {
    
    func searchBarTextDidBeginEditing(searchBar: UISearchBar) {
        if case .General = viewModel.context {
            showSegmentedControl(true)
        }
    }
    
    func searchBarTextDidEndEditing(searchBar: UISearchBar) {
        showSegmentedControl(false)
    }
    
    func searchBarCancelButtonClicked(searchBar: UISearchBar) {
        self.navigationController?.dismissViewControllerAnimated(true, completion: nil)
    }
}
