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
    private let facebookTappedSubject: PublishSubject<NSIndexPath> = PublishSubject()
    
    var type : ShoutType!
    
    var viewModel : CreateShoutViewModel!
    
    @IBOutlet var headerView : CreateShoutTableHeaderView!
    @IBOutlet var footerView : UIView!
    
    weak var imagesController : SelectShoutImagesController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupAppearance()
        createViewModel()
        setupRX()
    }
    
    private func setupAppearance() {
        tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 20, right: 0)
    }
    
    func createViewModel() {
        viewModel = CreateShoutViewModel(type: type)
    }
    
    // RX
    
    private func setupRX() {
        
        viewModel.detailsSectionViewModel.currencies
            .asDriver()
            .driveNext { [weak self] (currencies) -> Void in
                self?.headerView.currencyButton.showActivity(currencies.count == 0)
            }
            .addDisposableTo(disposeBag)
        
        viewModel.shoutParams.currency
            .asDriver()
            .driveNext { [weak self] (currency) -> Void in
                self?.headerView.setCurrency(currency)
            }
            .addDisposableTo(disposeBag)
        
        let categoriesObserver = viewModel.detailsSectionViewModel.categories.asDriver().map{_ in return Void()}
        let reloadObserver = viewModel.detailsSectionViewModel.reloadSubject.asDriver(onErrorJustReturn: Void())
        Observable.of(categoriesObserver, reloadObserver)
            .merge()
            .subscribeNext {[weak self] in
                self?.tableView.reloadSections(NSIndexSet(index: 0), withRowAnimation: .Automatic)
            }
            .addDisposableTo(disposeBag)
        
        viewModel.shoutParams.category
            .asDriver()
            .driveNext {[weak self] (category) -> Void in
                self?.tableView.reloadData()
            }
            .addDisposableTo(disposeBag)
        
        headerView.titleTextField
            .rx_text
            .flatMap{ (text) -> Observable<String?> in
                return Observable.just(text)
            }
            .bindTo(viewModel.shoutParams.title)
            .addDisposableTo(disposeBag)
        
        headerView.priceTextField
            .rx_text
            .flatMap{ (stringValue) -> Observable<Double?> in
                return Observable.just(stringValue.doubleValue)
            }
            .bindTo(viewModel.shoutParams.price)
            .addDisposableTo(disposeBag)
        
        facebookTappedSubject.flatMapFirst {[unowned self] (indexPath) -> Observable<(Bool, NSIndexPath)> in
            return Observable
                .zip(self.viewModel.sharingSectionViewModel.togglePublishToFacebookFromViewController(self), Observable.just(indexPath),
                    resultSelector: { (publish, indexPath) -> (Bool, NSIndexPath) in return (publish, indexPath)})
        }.subscribe {[weak self] (event) in
            switch event {
            case .Next(let publish, let indexPath):
                if publish {
                    self?.tableView.selectRowAtIndexPath(indexPath, animated: false, scrollPosition: .None)
                } else {
                    self?.tableView.deselectRowAtIndexPath(indexPath, animated: false)
                }
            case .Error(let error):
                self?.showError(error)
            case .Completed:
                break
            }
        }.addDisposableTo(disposeBag)
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
        }
    }

    // MARK: Select Currency
    
    @IBAction func selectCurrency(sender: UIButton) {
        let actionSheetController = viewModel.currenciesActionSheet(nil)
        self.presentViewController(actionSheetController, animated: true, completion: nil)
    }
}

// MARK: - UITableViewDataSource

extension CreateShoutTableViewController {
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return viewModel.sectionViewModels.count
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.sectionViewModels[section].cellViewModels.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cellViewModel = viewModel.sectionViewModels[indexPath.section].cellViewModels[indexPath.row]
        switch cellViewModel {
        case .Category:
            let cell = tableView.dequeueReusableCellWithIdentifier("CreateShoutCellCategory", forIndexPath: indexPath) as! CreateShoutSelectCell
            viewModel.fillCategoryCell(cell)
            cell.selectButton
                .rx_controlEvent(.TouchUpInside)
                .asDriver()
                .driveNext{ [weak self] () -> Void in
                    let actionSheetController = self?.viewModel.categoriesActionSheet({ (alertAction) -> Void in
                        self?.tableView.reloadData()
                    })
                    self?.presentViewController(actionSheetController!, animated: true, completion: nil)
                }
                .addDisposableTo(cell.reuseDisposeBag)
            
            return cell
        case .Description:
            let cell = tableView.dequeueReusableCellWithIdentifier("CreateShoutCellDescription", forIndexPath: indexPath) as! CreateShoutTextViewCell
            cell.textView
                .rx_text
                .flatMap{ (text) -> Observable<String?> in
                    return Observable.just(text)
                }
                .bindTo(viewModel.shoutParams.text)
                .addDisposableTo(cell.reuseDisposeBag)
            
            cell.textView.placeholderLabel?.text = NSLocalizedString("Description", comment: "Description cell placeholder text")
            
            if let shout = self.viewModel.shoutParams.shout {
                if cell.textView.text == "" {
                    cell.textView.text = shout.text
                }
            }
            return cell
        case .FilterChoice(let filter):
            let cell = tableView.dequeueReusableCellWithIdentifier("CreateShoutCellOption", forIndexPath: indexPath) as! CreateShoutSelectCell
            viewModel.fillFilterCell(cell, withFilter: filter)
            cell.selectButton
                .rx_controlEvent(.TouchUpInside)
                .asDriver()
                .driveNext{ [weak self] () -> Void in
                    guard let actionSheetController = self?.viewModel.filterActionSheet(forFilter: filter, handler: { (alertAction) -> Void in
                        self?.tableView.reloadRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)
                    }) else {
                        return
                    }
                    
                    self?.presentViewController(actionSheetController, animated: true, completion: nil)
                }
                .addDisposableTo(cell.reuseDisposeBag)
            return cell
        case .Location:
            let cell = tableView.dequeueReusableCellWithIdentifier("CreateShoutCellLocation", forIndexPath: indexPath) as! CreateShoutSelectCell
            viewModel.fillLocationCell(cell)
            cell.selectButton
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
                .addDisposableTo(cell.reuseDisposeBag)
            return cell
        case .Mobile:
            let cell = tableView.dequeueReusableCellWithIdentifier("createShoutCellMobile", forIndexPath: indexPath) as! CreateShoutMobileCell
            cell.mobileTextField
                .rx_text
                .flatMap{ (text) -> Observable<String?> in
                    return Observable.just(text)
                }
                .bindTo(viewModel.shoutParams.mobile)
                .addDisposableTo(cell.reuseDisposeBag)
            
            if let shout = self.viewModel.shoutParams.shout {
                if cell.mobileTextField.text == "" {
                    cell.mobileTextField.text = shout.mobile
                }
            }
            return cell
        case .Facebook:
            let cell = tableView.dequeueReusableCellWithIdentifier("CreateShoutSelectableCell", forIndexPath: indexPath) as! CreateShoutSelectableCell
            cell.selectionTitleLabel.text = NSLocalizedString("Facebook", comment: "Facebook cell title on sharing options in create shout view")
            cell.setBorders(cellIsFirst: true, cellIsLast: true)
            let publish = viewModel.shoutParams.publishToFacebook.value
            if publish {
                tableView.selectRowAtIndexPath(indexPath, animated: false, scrollPosition: .None)
            } else {
                tableView.deselectRowAtIndexPath(indexPath, animated: false)
            }
            
            return cell
        }
    }
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return viewModel.sectionViewModels[section].title
    }
}

// MARK: - UITableViewDelegate

extension CreateShoutTableViewController {
    
    override func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        switch section {
        case 0:
            return viewModel.detailsSectionViewModel.hideFilters ? 0 : 40
        default:
            return 40
        }
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        let cellViewModel = viewModel.sectionViewModels[indexPath.section].cellViewModels[indexPath.row]
        switch cellViewModel {
        case .Mobile: return 80
        case .Description: return 160
        case .Facebook: return 44
        default: return 70
        }
    }
    
    override func tableView(tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        guard let header = view as? UITableViewHeaderFooterView else { return }
        header.tintColor = UIColor.whiteColor()
        header.textLabel?.font = UIFont.systemFontOfSize(14.0)
        header.textLabel?.textColor = UIColor(shoutitColor: .FontGrayColor)
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let cellViewModel = viewModel.sectionViewModels[indexPath.section].cellViewModels[indexPath.row]
        guard case .Facebook = cellViewModel else { return }
        facebookTappedSubject.onNext(indexPath)
    }
    
    override func tableView(tableView: UITableView, didDeselectRowAtIndexPath indexPath: NSIndexPath) {
        let cellViewModel = viewModel.sectionViewModels[indexPath.section].cellViewModels[indexPath.row]
        guard case .Facebook = cellViewModel else { return }
        facebookTappedSubject.onNext(indexPath)
    }
    
    override func tableView(tableView: UITableView, shouldHighlightRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        let cellViewModel = viewModel.sectionViewModels[indexPath.section].cellViewModels[indexPath.row]
        if case .Facebook = cellViewModel {
            return true
        }
        return false
    }
}
