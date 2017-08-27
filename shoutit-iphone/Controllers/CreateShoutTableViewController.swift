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

    fileprivate let headerReuseIdentifier = "CreateShoutSectionHeaderReuseIdentifier"
    let disposeBag = DisposeBag()
    fileprivate let facebookTappedSubject: PublishSubject<Void> = PublishSubject()
    
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
        self.tableView.register(UINib(nibName: "SectionHeaderWithDetailsButton", bundle: nil), forHeaderFooterViewReuseIdentifier: "SectionHeaderWithDetailsButton")
    }
    
    fileprivate func setupAppearance() {
        tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 20, right: 0)
    }
    
    func createViewModel() {
        viewModel = CreateShoutViewModel(type: type)
    }
    
    // RX
    
    fileprivate func setupRX() {
        
        viewModel.detailsSectionViewModel.currencies
            .asDriver()
            .drive(onNext: { [weak self] (currencies) -> Void in
                self?.headerView.currencyButton.showActivity(currencies.count == 0)
            })
            .addDisposableTo(disposeBag)
        
        viewModel.shoutParams.currency
            .asDriver()
            .drive(onNext: { [weak self] (currency) -> Void in
                self?.headerView.setCurrency(currency)
            })
            .addDisposableTo(disposeBag)
        
        let categoriesObserver = viewModel.detailsSectionViewModel.categories.asDriver().map{_ in return Void()}
        let reloadObserver = viewModel.detailsSectionViewModel.reloadSubject.asDriver(onErrorJustReturn: Void())
        Observable.of(categoriesObserver, reloadObserver)
            .merge()
            .subscribe(onNext: {[weak self] in
                self?.tableView.reloadSections(IndexSet(integer: 0), with: .automatic)
            })
            .addDisposableTo(disposeBag)
        
        viewModel.shoutParams.category
            .asDriver()
            .drive(onNext: { [weak self] (category) -> Void in
                self?.tableView.reloadData()
            })
            .addDisposableTo(disposeBag)
        
        headerView.titleTextField
            .rx.text
            .flatMap{ (text) -> Observable<String?> in
                return Observable.just(text)
            }
            .bind(to: viewModel.shoutParams.title)
            .addDisposableTo(disposeBag)
        
        headerView.priceTextField
            .rx.text
            .flatMap{ (stringValue) -> Observable<Double?> in
                if stringValue?.characters.count == 0 {
                    return Observable.just(nil)
                }
                
                return Observable.just(stringValue!.doubleValue)
            }
            .bind(to: viewModel.shoutParams.price)
            .addDisposableTo(disposeBag)
        
        viewModel.errorSubject.observeOn(MainScheduler.instance)
            .subscribe(onNext: { [weak self] (error) in
                self?.showError(error)
            })
            .addDisposableTo(disposeBag)
        
        facebookTappedSubject
            .asObserver()
            .subscribe(onNext: {[weak self] in
                guard let `self` = self else { return }
                self.viewModel.sharingSectionViewModel.togglePublishToFacebookFromViewController(self)
            })
            .addDisposableTo(disposeBag)
    }
    
    // MARK: Media Selection
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let imagesController = segue.destination as? SelectShoutImagesController {
            self.imagesController = imagesController
            imagesController.mediaPicker
                .presentingSubject
                .observeOn(MainScheduler.instance).subscribe(onNext: { [weak self] (controllerToShow) in
                    if let controllerToShow = controllerToShow {
                        self?.navigationController?.present(controllerToShow, animated: true, completion: nil)
                    }
                })
                .addDisposableTo(disposeBag)
        }
        
        if let descriptionViewController = segue.destination as? ShoutDescriptionViewController {
            descriptionViewController.initialText = self.viewModel.shoutParams.text.value
            descriptionViewController.completionSubject.asObservable().subscribe(onNext: { (description) in
                self.viewModel.shoutParams.text.value = description
                self.tableView.reloadData()
            }).addDisposableTo(disposeBag)
        }
    }

    // MARK: Select Currency
    
    @IBAction func selectCurrency(_ sender: UIButton) {
        let actionSheetController = viewModel.currenciesActionSheet(nil)
        self.present(actionSheetController, animated: true, completion: nil)
    }
}

// MARK: - UITableViewDataSource

extension CreateShoutTableViewController {
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return viewModel.sectionViewModels.count
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.sectionViewModels[section].cellViewModels.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cellViewModel = viewModel.sectionViewModels[indexPath.section].cellViewModels[indexPath.row]
        switch cellViewModel {
        case .category:
            let cell = tableView.dequeueReusableCell(withIdentifier: "CreateShoutCellCategory", for: indexPath) as! CreateShoutSelectCell
            viewModel.fillCategoryCell(cell)
            cell.selectButton
                .rx.controlEvent(.touchUpInside)
                .asDriver()
                .drive(onNext: { [weak self] () -> Void in
                    let actionSheetController = self?.viewModel.categoriesActionSheet({ (alertAction) -> Void in
                        self?.tableView.reloadData()
                    })
                    self?.present(actionSheetController!, animated: true, completion: nil)
                })
                .addDisposableTo(cell.reuseDisposeBag)
            
            return cell
        case .description:
            let cell = tableView.dequeueReusableCell(withIdentifier: "DescriptionCell", for: indexPath) as! CreateShoutDescriptionTableViewCell
            cell.textLabel?.text = NSLocalizedString("Description", comment: "Create Shout Description Button Title")
            
            cell.detailTextLabel?.text = self.viewModel.shoutParams.text.value
            
            cell.selectionStyle = .none
            
            return cell
        case .filterChoice(let filter):
            let cell = tableView.dequeueReusableCell(withIdentifier: "CreateShoutCellOption", for: indexPath) as! CreateShoutSelectCell
            viewModel.fillFilterCell(cell, withFilter: filter)
            cell.selectButton
                .rx.controlEvent(.touchUpInside)
                .asDriver()
                .drive(onNext: { [weak self] () -> Void in
                    guard let actionSheetController = self?.viewModel.filterActionSheet(forFilter: filter, handler: { (alertAction) -> Void in
                        self?.tableView.reloadRows(at: [indexPath], with: .automatic)
                    }) else {
                        return
                    }
                    
                    self?.present(actionSheetController, animated: true, completion: nil)
                })
                .addDisposableTo(cell.reuseDisposeBag)
            return cell
        case .location:
            let cell = tableView.dequeueReusableCell(withIdentifier: "CreateShoutCellLocation", for: indexPath) as! CreateShoutSelectCell
            viewModel.fillLocationCell(cell)
            cell.selectButton
                .rx.controlEvent(.touchUpInside)
                .asDriver()
                .drive(onNext: { [weak self] () -> Void in
                    
                    let controller = Wireframe.changeShoutLocationController()
                    
                    controller.finishedBlock = { (success, place) -> Void in
                        self?.viewModel.shoutParams.location.value = place
                        self?.tableView.reloadData()
                    }
                    
                    self?.navigationController?.show(controller, sender: nil)
                    
                    })
                .addDisposableTo(cell.reuseDisposeBag)
            return cell
        case .mobile:
            let cell = tableView.dequeueReusableCell(withIdentifier: "createShoutCellMobile", for: indexPath) as! CreateShoutMobileCell
            cell.mobileTextField
                .rx.text
                .flatMap{ (text) -> Observable<String?> in
                    return Observable.just(text)
                }
                .bind(to: viewModel.shoutParams.mobile)
                .addDisposableTo(cell.reuseDisposeBag)
            
            if let shout = self.viewModel.shoutParams.shout {
                if cell.mobileTextField.text == "" {
                    cell.mobileTextField.text = shout.mobile
                }
            }
            return cell
        case .facebook:
            let cell = tableView.dequeueReusableCell(withIdentifier: "CreateShoutSelectableCell", for: indexPath) as! CreateShoutSelectableCell
            cell.selectionTitleLabel.text = NSLocalizedString("Facebook", comment: "Facebook cell title on sharing options in create shout view")
            cell.setBorders(cellIsFirst: true, cellIsLast: true)
            viewModel
                .shoutParams
                .publishToFacebook
                .asDriver().drive(onNext: {[weak cell] (publish) in
                    cell?.ticked = publish
                })
                .addDisposableTo(cell.reuseDisposeBag)
            
            return cell
        }
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return viewModel.sectionViewModels[section].title
    }
}

// MARK: - UITableViewDelegate

extension CreateShoutTableViewController {
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        switch section {
        case 0:
            return viewModel.detailsSectionViewModel.hideFilters ? 0 : 40
        default:
            return 40
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.5
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let cellViewModel = viewModel.sectionViewModels[indexPath.section].cellViewModels[indexPath.row]
        switch cellViewModel {
        case .mobile: return 80
        case .description: return 60.0
        case .facebook: return 70.0
        default: return 70
        }
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cellViewModel = viewModel.sectionViewModels[indexPath.section].cellViewModels[indexPath.row]
        
        if case .description = cellViewModel {
            showDescriptionViewController()
        }
        
        guard case .facebook = cellViewModel else { return }
        facebookTappedSubject.onNext()
    }
    
    func showDescriptionViewController() {
        self.performSegue(withIdentifier: "shoutDescription", sender: nil)
    }
    
    
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if let sectionHeader = self.tableView.dequeueReusableHeaderFooterView(withIdentifier: "SectionHeaderWithDetailsButton") as? SectionHeaderWithDetailsButton {
            sectionHeader.titleLabel.text = self.tableView(tableView, titleForHeaderInSection: section)
            sectionHeader.infoButton.isHidden = section != 2
            sectionHeader.infoButton.tag = section
            sectionHeader.infoButton.addTarget(self, action: #selector(showSharingAlert), for: .touchUpInside)
            return sectionHeader
        }
        
        return nil
    }
    
    override func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool {
        let cellViewModel = viewModel.sectionViewModels[indexPath.section].cellViewModels[indexPath.row]
        if case .facebook = cellViewModel {
            return true
        }
        if case .description = cellViewModel {
            return true
        }
        return false
    }
    
    func showSharingAlert() {
        let alert = UIAlertController(title: NSLocalizedString("Earn Shoutit Credit", comment: "Create Shout Share Alert Title"), message: NSLocalizedString("Earn 1 Shoutit Credit for each shout you publicly share on Facebook", comment: "Create Shout Share Alert Message"), preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: LocalizedString.ok, style: .default, handler: { (alertaction) in
        }))
        
        self.navigationController?.present(alert, animated: true, completion: nil)
    }
}
