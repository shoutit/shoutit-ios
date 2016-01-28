//
//  SHEditProfileTableViewController.swift
//  shoutit-iphone
//
//  Created by Vishal Thakur on 09/12/15.
//  Copyright © 2015 Shoutit. All rights reserved.
//

import UIKit

protocol SHEditProfileTableViewControllerDelegate {
    func didUpdateUser(user: SHUser)
}

class SHEditProfileTableViewController: BaseTableViewController {
    
    @IBOutlet weak var bioTextView: UITextView!
    @IBOutlet weak var bluredImageView: UIImageView!
    @IBOutlet weak var emailTextField: TextFieldValidator!
    @IBOutlet weak var firstNameTextField: TextFieldValidator!
    @IBOutlet weak var lastNameTextField: TextFieldValidator!
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var sexTextField: UITextField!
    @IBOutlet weak var usernameTextField: TextFieldValidator!

    private var viewModel: SHEditProfileTableViewModel?
    var user: SHUser?
    var delegate: SHEditProfileTableViewControllerDelegate?
    
    static func presentFromViewController(parent: UIViewController, user: SHUser) {
        let vc = UIStoryboard.getProfile().instantiateViewControllerWithIdentifier(Constants.ViewControllers.SHEDITPROFILE) as! SHEditProfileTableViewController
        vc.user = user
       // vc.delegate = parent
        let navController = UINavigationController(rootViewController: vc)
        navController.navigationBar.barTintColor = UIColor(shoutitColor: .ShoutGreen)
        navController.navigationBar.tintColor = UIColor.whiteColor()
        parent.presentViewController(navController, animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.profileImageView.contentMode = UIViewContentMode.ScaleAspectFill
        self.profileImageView.clipsToBounds = true
        self.profileImageView.layer.borderColor = UIColor.whiteColor().CGColor
        self.profileImageView.layer.borderWidth = 2.0
        self.profileImageView.layer.cornerRadius = self.profileImageView.frame.size.width / 2.0
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Save, target: self, action: Selector("save"))
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Cancel, target: self, action: Selector("cancel"))
        self.navigationItem.rightBarButtonItem?.tintColor = UIColor(shoutitColor: .ShoutDarkGreen)
        self.navigationItem.leftBarButtonItem?.tintColor = UIColor.whiteColor()
        self.setupAlerts()
        viewModel?.viewDidLoad()
    }
    
    override func initializeViewModel() {
        viewModel = SHEditProfileTableViewModel(viewController: self)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        viewModel?.viewDidAppear()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        viewModel?.viewWillAppear()
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        viewModel?.viewWillDisappear()
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        viewModel?.viewDidDisappear()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setupAlerts() {
        self.firstNameTextField.presentInView = self.tableView.tableHeaderView
        self.lastNameTextField.presentInView = self.tableView.tableHeaderView
        self.usernameTextField.presentInView = self.tableView.tableHeaderView
        self.emailTextField.presentInView = self.tableView.tableHeaderView
        
        self.usernameTextField.addRegx(Constants.RegEx.REGEX_USER_NAME, withMsg: NSLocalizedString("Only alpha numeric and ._ characters are allowed. Charaters limit should be come between 2-30", comment: "Only alpha numeric and ._ characters are allowed. Charaters limit should be come between 2-30"))
        self.firstNameTextField.addRegx(Constants.RegEx.REGEX_FIRST_USER_NAME_LIMIT, withMsg: NSLocalizedString("First name charaters limit should be come between 2-30", comment: "First name charaters limit should be come between 2-30"))
        self.lastNameTextField.addRegx(Constants.RegEx.REGEX_LAST_USER_NAME_LIMIT, withMsg: NSLocalizedString("Last name charaters limit should be come between 1-30", comment: "Last name charaters limit should be come between 1-30"))
        self.emailTextField.addRegx(Constants.RegEx.REGEX_EMAIL, withMsg: NSLocalizedString("EnterValidMail", comment: "Enter valid email."))
    }
    
    func cancel() {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func save() {
        self.viewModel?.save()
    }
    
    @IBAction func editProfilePic(sender: AnyObject) {
        self.viewModel?.editProfilePic()
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let rows = super.tableView(tableView, numberOfRowsInSection: section)
        return rows
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if(indexPath.section == 0 && indexPath.row == 0) {
            self.firstNameTextField.becomeFirstResponder()
        }
        if(indexPath.section == 0 && indexPath.row == 1) {
            self.lastNameTextField.becomeFirstResponder()
        }
        if(indexPath.section == 1 && indexPath.row == 0) {
            self.usernameTextField.becomeFirstResponder()
        }
        if(indexPath.section == 2 && indexPath.row == 0) {
            self.emailTextField.becomeFirstResponder()
        }
        if(indexPath.section == 3 && indexPath.row == 0) {
            self.addPickerView(self.sexTextField, array: ["Male", "Female"], title: NSLocalizedString("Gender", comment: "Gender"), showClear: false)
        }
        if (indexPath.section == 3 && indexPath.row == 1) {
            self.bioTextView.becomeFirstResponder()
        }

    }
    
    func addPickerView(textField: UITextField, array: [String], title: String, showClear: Bool) {
        SHSinglePickerTableViewController.presentPickerFromViewController(self, stringList: array, title: title, allowNoneOption: showClear) { (selectedItem) -> () in
            textField.text = selectedItem
        }
    }
    
    deinit {
        viewModel?.destroy()
    }

}
