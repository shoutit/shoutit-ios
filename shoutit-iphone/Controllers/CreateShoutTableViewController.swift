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
import ShoutitKit

class CreateShoutTableViewController: UITableViewController {

    private let headerReuseIdentifier = "CreateShoutSectionHeaderReuseIdentifier"
    let disposeBag = DisposeBag()
    private let facebookTappedSubject: PublishSubject<Void> = PublishSubject()
    
    var type : ShoutitKit.ShoutType!
    
    var viewModel : CreateShoutViewModel!
    
    @IBOutlet var headerView : CreateShoutTableHeaderView!
    @IBOutlet var footerView : UIView!
    
    weak var imagesController : SelectShoutImagesController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupAppearance()
        createViewModel()
        setupRX()
        
        tableView.allowsSelection = true
        self.tableView.registerNib(UINib(nibName: "SectionHeaderWithDetailsButton", bundle: nil), forHeaderFooterViewReuseIdentifier: "SectionHeaderWithDetailsButton")
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
                if stringValue.characters.count == 0 {
                    return Observable.just(nil)
                }
                
                return Observable.just(stringValue.doubleValue)
            }
            .bindTo(viewModel.shoutParams.price)
            .addDisposableTo(disposeBag)
        
        viewModel.errorSubject.observeOn(MainScheduler.instance)
            .subscribeNext { [weak self] (error) in
                self?.showError(error)
            }
            .addDisposableTo(disposeBag)
        
        facebookTappedSubject
            .asObserver()
            .subscribeNext {[weak self] in
                guard let `self` = self else { return }
                self.viewModel.sharingSectionViewModel.togglePublishToFacebookFromViewController(self)
            }
            .addDisposableTo(disposeBag)
    }
    
    // MARK: Media Selection
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let imagesController = segue.destinationViewController as? SelectShoutImagesController {
            self.imagesController = imagesController
            imagesController.mediaPicker
                .presentingSubject
                .observeOn(MainScheduler.instance).subscribeNext{[weak self] (controllerToShow) in
                    if let controllerToShow = controllerToShow {
                        self?.navigationController?.presentViewController(controllerToShow, animated: true, completion: nil)
                    }
                }
                .addDisposableTo(disposeBag)
        }
        
        if let descriptionViewController = segue.destinationViewController as? ShoutDescriptionViewController {
            descriptionViewController.initialText = self.viewModel.shoutParams.text.value
            descriptionViewController.completionSubject.asObservable().subscribeNext({ (description) in
                self.viewModel.shoutParams.text.value = description
                self.tableView.reloadData()
            }).addDisposableTo(disposeBag)
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
            let cell = tableView.dequeueReusableCellWithIdentifier("DescriptionCell", forIndexPath: indexPath) as! CreateShoutDescriptionTableViewCell
            cell.textLabel?.text = NSLocalizedString("Description", comment: "Create Shout Description Button Title")
            
            cell.detailTextLabel?.text = self.viewModel.shoutParams.text.value
            
            cell.selectionStyle = .None
            
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
            viewModel
                .shoutParams
                .publishToFacebook
                .asDriver().driveNext{[weak cell] (publish) in
                    cell?.ticked = publish
                }
                .addDisposableTo(cell.reuseDisposeBag)
            
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
    
    override func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.5
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        let cellViewModel = viewModel.sectionViewModels[indexPath.section].cellViewModels[indexPath.row]
        switch cellViewModel {
        case .Mobile: return 80
        case .Description: return 60.0
        case .Facebook: return 70.0
        default: return 70
        }
    }

    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let cellViewModel = viewModel.sectionViewModels[indexPath.section].cellViewModels[indexPath.row]
        
        if case .Description = cellViewModel {
            showDescriptionViewController()
        }
        
        guard case .Facebook = cellViewModel else { return }
        facebookTappedSubject.onNext()
    }
    
    func showDescriptionViewController() {
        self.performSegueWithIdentifier("shoutDescription", sender: nil)
    }
    
    
    
    override func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if let sectionHeader = self.tableView.dequeueReusableHeaderFooterViewWithIdentifier("SectionHeaderWithDetailsButton") as? SectionHeaderWithDetailsButton {
            sectionHeader.titleLabel.text = self.tableView(tableView, titleForHeaderInSection: section)
            sectionHeader.infoButton.hidden = section != 2
            sectionHeader.infoButton.tag = section
            sectionHeader.infoButton.addTarget(self, action: #selector(showSharingAlert), forControlEvents: .TouchUpInside)
            return sectionHeader
        }
        
        return nil
    }
    
    override func tableView(tableView: UITableView, shouldHighlightRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        let cellViewModel = viewModel.sectionViewModels[indexPath.section].cellViewModels[indexPath.row]
        if case .Facebook = cellViewModel {
            return true
        }
        if case .Description = cellViewModel {
            return true
        }
        return false
    }
    
    func showSharingAlert() {
        let alert = UIAlertController(title: NSLocalizedString("Earn Shoutit Credit", comment: "Create Shout Share Alert Title"), message: NSLocalizedString("Earn 1 Shoutit Credit for each shout you publicly share on Facebook", comment: "Create Shout Share Alert Message"), preferredStyle: .Alert)
        
        alert.addAction(UIAlertAction(title: LocalizedString.ok, style: .Default, handler: { (alertaction) in
        }))
        
        self.navigationController?.presentViewController(alert, animated: true, completion: nil)
    }
}
