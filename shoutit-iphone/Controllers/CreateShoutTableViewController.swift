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
import MBProgressHUD

class CreateShoutTableViewController: UITableViewController, ShoutTypeController {

    private let headerReuseIdentifier = "CreateShoutSectionHeaderReuseIdentifier"
    let disposeBag = DisposeBag()
    
    var type : ShoutType!
    
    var disposables : [NSIndexPath: Disposable?] = [NSIndexPath():nil]
    
    var viewModel : CreateShoutViewModel!
    
    @IBOutlet var headerView : CreateShoutTableHeaderView!
    @IBOutlet var footerView : UIView!
    
    weak var imagesController : SelectShoutImagesController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        createViewModel()
        setupRX()
        loadData()
    }
    
    func createViewModel() {
        viewModel = CreateShoutViewModel(type: type)
    }
    
    // Load Data
    func loadData() {
        viewModel.fetchCurrencies()
        viewModel.fetchCategories()
    }
    
    // RX
    
    func setupRX() {
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
        
        viewModel.filters
            .asDriver()
            .driveNext { [weak self] (filters) -> Void in
                self?.tableView.reloadSections(NSIndexSet(index: 0), withRowAnimation: .Automatic)
            }.addDisposableTo(disposeBag)
        
        viewModel.shoutParams.category
            .asDriver()
            .driveNext { (category) -> Void in
                self.tableView.reloadData()
            }.addDisposableTo(disposeBag)
        
        headerView.titleTextField.rx_text.flatMap({ (text) -> Observable<String?> in
            return Observable.just(text)
        }).bindTo(viewModel.shoutParams.title).addDisposableTo(disposeBag)
        
        headerView.priceTextField.rx_text.flatMap({ (stringValue) -> Observable<Double?> in
            return Observable.just(stringValue.doubleValue)
        }).bindTo(viewModel.shoutParams.price).addDisposableTo(disposeBag)
        
    }
    
    // MARK: Media Selection
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let imagesController = segue.destinationViewController as? SelectShoutImagesController {
            
            self.imagesController = imagesController
            
            imagesController.mediaPicker.presentingSubject.asDriver(onErrorRecover: { (error) -> Driver<UIViewController?> in
                return Driver.just(nil)
            }).driveNext({ [weak self] (controllerToShow) -> Void in
                if let controllerToShow = controllerToShow {
                    self?.navigationController?.presentViewController(controllerToShow, animated: true, completion: nil)
                }
            }).addDisposableTo(disposeBag)
        }
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
        let identifier = self.viewModel.cellIdentifierAt(indexPath)
        let cell = tableView.dequeueReusableCellWithIdentifier(identifier) as UITableViewCell!
        
        self.viewModel.fillCell(cell, forIndexPath: indexPath)
        
        if let existingDisposable = disposables[indexPath] {
            existingDisposable?.dispose()
        }
        
        if let textCell = cell as? CreateShoutTextCell {
            
            let disposable = textCell.textField.rx_text.flatMap({ (text) -> Observable<String?> in
                return Observable.just(text)
            }).bindTo(viewModel.shoutParams.text)
            
            if let shout = self.viewModel.shoutParams.shout {
                if textCell.textField.text == "" {
                    textCell.textField.text = shout.text
                }
            }
            
            disposables[indexPath] = disposable
            
        }
        
        if let mobileCell = cell as? CreateShoutMobileCell {
            let disposable = mobileCell.mobileTextField.rx_text.flatMap({ (text) -> Observable<String?> in
                return Observable.just(text)
            }).bindTo(viewModel.shoutParams.mobile)
        
            if let shout = self.viewModel.shoutParams.shout {
                if mobileCell.mobileTextField.text == "" {
                    mobileCell.mobileTextField.text = shout.mobile
                }
            }
            
            disposables[indexPath] = disposable
        }
        
        guard let selectCell = cell as? CreateShoutSelectCell else {
            return cell
        }
        
        if indexPath.section == 1 {
            
            let disposable = selectCell.selectButton
                .rx_controlEvent(.TouchUpInside)
                .asDriver()
                .driveNext({ [weak self] () -> Void in
                    
                    let controller = Wireframe.changeShoutLocationController() 
                    
                    controller.finishedBlock = { (success, place) -> Void in
                        self?.viewModel.shoutParams.location.value = place
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
        return self.viewModel.heightForHeaderAt(section)
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
