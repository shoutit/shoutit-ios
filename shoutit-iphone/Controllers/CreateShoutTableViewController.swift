//
//  CreateShoutTableViewController.swift
//  shoutit-iphone
//
//  Created by Piotr Bernad on 26.02.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class CreateShoutTableViewController: UITableViewController, ShoutTypeController {

    private let headerReuseIdentifier = "CreateShoutSectionHeaderReuseIdentifier"
    let disposeBag = DisposeBag()
    
    var disposables : [NSIndexPath: Disposable?] = [NSIndexPath():nil]
    
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
        viewModel.shoutParams
            .type
            .asDriver()
            .driveNext { [weak self] (type) -> Void in
                self?.headerView.fillWithType(type)
            }
            .addDisposableTo(disposeBag)
        
        viewModel.currencies
            .asDriver()
            .driveNext { [weak self] (currencies) -> Void in
                self?.headerView.currencyButton.optionsLoaded = currencies.count > 0
            }
            .addDisposableTo(disposeBag)
        
        viewModel.shoutParams.currency
            .asDriver()
            .driveNext { [weak self] (currency) -> Void in
                self?.headerView.setCurrency(currency)
            }
            .addDisposableTo(disposeBag)
        
        viewModel.categories
            .asDriver()
            .driveNext({ [weak self] (category) -> Void in
                self?.tableView.reloadSections(NSIndexSet(index: 0), withRowAnimation: .Automatic)
            })
            .addDisposableTo(disposeBag)
        
        headerView.titleTextField.rx_text.flatMap({ (text) -> Observable<String?> in
            return Observable.just(text)
        }).bindTo(viewModel.shoutParams.title).addDisposableTo(disposeBag)
        
        headerView.priceTextField.rx_text.flatMap({ (stringValue) -> Observable<Int?> in
            return Observable.just(Int(stringValue))
        }).bindTo(viewModel.shoutParams.price).addDisposableTo(disposeBag)
        
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
        
        guard let selectCell = cell as? CreateShoutSelectCell else {
            return cell
        }
        
        if let existingDisposable = disposables[indexPath] {
            existingDisposable?.dispose()
        }
        
        
        if indexPath.section == 1 {
            
            let disposable = selectCell.selectButton
                .rx_controlEvent(.TouchUpInside)
                .asDriver()
                .driveNext({ [weak self] () -> Void in
                    
                    let controller = Wireframe.changeShoutLocationController()
                    
                    controller.finishedBlock = { (success, place) -> Void in
                        self?.viewModel.shoutParams.location.value = place?.toAddressObject()
                        self?.tableView.reloadData()
                    }
                    
                    self?.navigationController?.showViewController(controller, sender: nil)

                })
            
            disposables[indexPath] = disposable
            
            return selectCell
        }
        
        if indexPath.row == 0 {
            
            let disposable = selectCell.selectButton
                .rx_controlEvent(.TouchUpInside)
                .asDriver()
                .driveNext({ [weak self] () -> Void in
                    let actionSheetController = self?.viewModel.categoriesActionSheet({ (alertAction) -> Void in
                        self?.tableView.reloadData()
                    })
                    self?.presentViewController(actionSheetController!, animated: true, completion: nil)
                    })
            
            disposables[indexPath] = disposable
          
            return selectCell
        }
        
        let disposable = selectCell.selectButton
            .rx_controlEvent(.TouchUpInside)
            .asDriver()
            .driveNext({ [weak self] () -> Void in
                guard let actionSheetController = self?.viewModel.filterActionSheet(forIndexPath: indexPath, handler: { (alertAction) -> Void in
                    self?.tableView.reloadRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)
                }) else {
                    return
                }
                
                self?.presentViewController(actionSheetController, animated: true, completion: nil)
                
                })
        
        disposables[indexPath] = disposable
        
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
    
    @IBAction func submitAction() {
        let parameters = viewModel.shoutParams.encode().JSONObject() as! [String : AnyObject]
        APIShoutsService.createShoutWithParams(parameters).subscribeNext { (shout) -> Void in
            
        }.addDisposableTo(disposeBag)
    }

}
