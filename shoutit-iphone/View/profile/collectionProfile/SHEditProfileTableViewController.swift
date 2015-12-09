//
//  SHEditProfileTableViewController.swift
//  shoutit-iphone
//
//  Created by Vishal Thakur on 09/12/15.
//  Copyright © 2015 Shoutit. All rights reserved.
//

import UIKit

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
    
    override func viewDidLoad() {
        super.viewDidLoad()
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
    
    @IBAction func editProfilePic(sender: AnyObject) {
    }
    
    
    deinit {
        viewModel?.destroy()
    }

}
