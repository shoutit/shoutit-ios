//
//  CreateShoutTableViewController.swift
//  shoutit-iphone
//
//  Created by Piotr Bernad on 26.02.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import UIKit
import RxSwift

class CreateShoutTableViewController: UITableViewController, ShoutTypeController {

    private let headerReuseIdentifier = "CreateShoutSectionHeaderReuseIdentifier"
    let disposeBag = DisposeBag()
    
    var viewModel : CreateShoutViewModel! = CreateShoutViewModel()
    @IBOutlet var headerView : CreateShoutTableHeaderView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupRX()
        loadData()
    }
    
    
    // Load Data
    func loadData() {
        viewModel.fetchCurrencies()
        viewModel.fetchCategories()
    }
    
    // RX
    
    func setupRX() {
        viewModel.currentType.asObservable().subscribeNext { [weak self] (type) -> Void in
            self?.headerView.fillWithType(type)
        }.addDisposableTo(disposeBag)
        
        viewModel.currencies.asObservable().subscribeNext { [weak self] (currencies) -> Void in
            self?.headerView.currencyButton.optionsLoaded = currencies.count > 0
        }.addDisposableTo(disposeBag)
        
        viewModel.selectedCurrency.asObservable().subscribeNext { [weak self] (currency) -> Void in
            self?.headerView.setCurrency(currency)
        }.addDisposableTo(disposeBag)
        
        viewModel.categories.asObservable().subscribeNext { [weak self] (categories) -> Void in
            self?.tableView.reloadSections(NSIndexSet(index: 0), withRowAnimation: .Automatic)
        }.addDisposableTo(disposeBag)
        
        viewModel.selectedCategory.asObservable().subscribeNext { [weak self] (category) -> Void in
           self?.tableView.reloadSections(NSIndexSet(index: 0), withRowAnimation: .Automatic) 
        }.addDisposableTo(disposeBag)
    }
    
    // MARK: Shout Type Selection
    
    @IBAction func changeTypeAction(sender: AnyObject) {
        
        let actionSheetController = viewModel.changeTypeActionSheet { (alertAction) -> Void in
            guard let title = alertAction.title else {
                fatalError("Not supported action")
            }
            
            if title == "Request" {
                self.selectShoutType(.Request)
                
            } else if title == "Shout" {
                self.selectShoutType(.Offer)
                
            }
        }
        
        self.presentViewController(actionSheetController, animated: true, completion: nil)
    }
    
    func selectShoutType(type: ShoutType) {
        switch type {
        case .Offer: self.viewModel.changeToShout()
        case .Request: self.viewModel.changeToRequest()
        default: break
        }
    }

    // MARK: Select Currency
    
    @IBAction func selectCurrency(sender: UIButton) {
        let actionSheetController = viewModel.currenciesActionSheet(nil)
        
        self.presentViewController(actionSheetController, animated: true, completion: nil)
    }
    
    @IBAction func selectCategory(sender: UIButton) {
        let actionSheetController = viewModel.categoriesActionSheet(nil)
        
        self.presentViewController(actionSheetController, animated: true, completion: nil)
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return self.viewModel.numberOfSections()
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.viewModel.numberOfRowsInSection(section)
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(self.viewModel.cellIdentifierAt(indexPath)) as UITableViewCell!
        
        self.viewModel.fillCell(cell, forIndexPath: indexPath)
        
        if indexPath.section == 0 && indexPath.row == 0 {
            if let locationCell = cell as? CreateShoutSelectCell {
                locationCell.selectButton.addTarget(self, action: "selectCategory:", forControlEvents: .TouchUpInside)
            }
        }
        
        return cell
    }
    
    override func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40.0
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return self.viewModel.heightForRowAt(indexPath)
    }
    
    override func tableView(tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        if let header = view as? UITableViewHeaderFooterView {
            header.tintColor = UIColor.whiteColor()
            header.textLabel?.font = UIFont.systemFontOfSize(14.0)
        }
    }
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return self.viewModel.sectionTitle(section)
    }

}
