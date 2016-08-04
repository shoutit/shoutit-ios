
//
//  CreatePageInfoViewController.swift
//  shoutit
//
//  Created by Piotr Bernad on 27/06/16.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import UIKit
import ShoutitKit
import RxSwift

class CreatePageInfoViewController: UITableViewController {

    @IBOutlet var nameTextField : FormTextField!
    
    @IBOutlet var fullNameTextField : FormTextField!
    @IBOutlet var emailTextField : FormTextField!
    @IBOutlet var passwordTextField : FormTextField!
    @IBOutlet var categoryButton : UIButton!
    
    
    var viewModel : LoginWithEmailViewModel?
    
    var locked : Bool = false
    
    var preselectedCategory : PageCategory?
    var selectedCategory : PageCategory?
    weak var flowDelegate: FlowController?
    
    private let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        applyBackButton()
        setupFields()
        
        self.navigationItem.title = preselectedCategory?.name ?? NSLocalizedString("Create Page", comment: "create page screen title")
    }
    
    func setupFields() {
        nameTextField.addValidator(ShoutitValidator.validateName, withDisposeBag: disposeBag)
        fullNameTextField.addValidator(ShoutitValidator.validateName, withDisposeBag: disposeBag)
        passwordTextField.addValidator(ShoutitValidator.validatePassword, withDisposeBag: disposeBag)
        emailTextField.addValidator(ShoutitValidator.validateEmail, withDisposeBag: disposeBag)
    }
    
    @IBAction func createPageAction() {
        if Account.sharedInstance.isUserLoggedIn {
            validateAndCreatePageForLoggedUser()
            return
        }
        validFieldsAndCreatePageBySignupIfPossible()
    }
    
    func validFieldsAndCreatePageBySignupIfPossible() {
        guard let pageName = nameTextField.text else {
            self.showErrorMessage(NSLocalizedString("Please fill all fields", comment: "Create Page Validation Message"))
            return
        }
        
        guard case .Valid = ShoutitValidator.validateName(pageName) else {
            return
        }
        
        guard let fullName = fullNameTextField.text else {
            return
        }
        
        guard case .Valid = ShoutitValidator.validateName(fullName) else {
            return
        }
        
        guard let email = emailTextField.text else {
            return
        }
        
        guard case .Valid = ShoutitValidator.validateEmail(email) else {
            return
        }
        
        guard let password = passwordTextField.text else {
            return
        }
        
        guard case .Valid = ShoutitValidator.validatePassword(password) else {
            return
        }
        
        guard let category = selectedCategory else {
            self.showErrorMessage(NSLocalizedString("Please select category", comment: "Create Page Error"))
            return
        }
        
        createPageWith(pageName, fullname: fullName, email: email, password: password, category: category)
        
    }
    
    func validateAndCreatePageForLoggedUser() {
        guard let pageName = nameTextField.text else {
            self.showErrorMessage(NSLocalizedString("Please fill all fields", comment: "Create Page Error"))
            return
        }
        
        guard case .Valid = ShoutitValidator.validateName(pageName) else {
            self.showErrorMessage(NSLocalizedString("Please fill all fields", comment: "Create Page Error"))
            return
        }
        
        guard let category = selectedCategory else {
            self.showErrorMessage(NSLocalizedString("Please select category", comment: "Create Page Error"))
            return
        }
        
        if locked {
            return
        }
        
        locked = true

        let params = PageCreationParams(category: category, name: pageName)
        
        self.showProgressHUD()
        
        APIPageService.createPage(params).subscribe { [weak self] (event) in
            self?.hideProgressHUD()
            self?.locked = false
            
            switch event {
            case .Next(let page):
                self?.navigationController?.popToRootViewControllerAnimated(true)
                if case .Some(.Logged(_)) = Account.sharedInstance.loginState {
                    Account.sharedInstance.switchToPage(page)
                }
            case .Error(let error):
                self?.showError(error)
            
            default: break
            }
        }.addDisposableTo(disposeBag)
        
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return Account.sharedInstance.isUserLoggedIn ? 1 : 2
    }
    
    @IBAction func showSubCategories() {
        
        let alert = UIAlertController(title: NSLocalizedString("Please select subcategory", comment: "Create Page Error"), message: nil, preferredStyle: .ActionSheet)
        
        alert.addAction(UIAlertAction(title: LocalizedString.cancel, style: .Cancel, handler: nil))
        
        guard let categories = self.preselectedCategory?.children else {
            return
        }
        
        categories.each { (subcat) in
            alert.addAction(UIAlertAction(title: subcat.name, style: .Default, handler: { (action) in
                self.selectedCategory = subcat
                self.categoryButton.setTitle(subcat.name, forState: .Normal)
            }))
        }
        
        self.navigationController?.presentViewController(alert, animated: true, completion: nil)
    }
    
    func createPageWith(name: String, fullname: String, email: String, password: String, category: PageCategory) {
        guard let viewModel = viewModel else {
            return
        }
        
        let params = PageSignupParams(category: category, name: name, email: email, userFullName: fullname, password: password, mixPanelDistinctId: MixpanelHelper.getDistictId(), currentUserCoordinates: LocationManager.sharedInstance.currentLocation.coordinate)
        
        viewModel.authenticatePageWithParameters(params)
    }
    
}
