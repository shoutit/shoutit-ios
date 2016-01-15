//
//  SHLoginViewController.swift
//  shoutit-iphone
//
//  Created by Hitesh Sondhi on 02/11/15.
//  Copyright © 2015 Shoutit. All rights reserved.
//

import UIKit
import MK

class SHLoginViewController: BaseViewController, TextFieldDelegate, UITextFieldDelegate {

    @IBOutlet weak var termsAndConditionsTextView: UITextView!
    @IBOutlet weak var signUpView: UIView!
    @IBOutlet weak var loginView: UIView!
    @IBOutlet weak var signUpButton: UIButton!
    lazy var firstNameTextField: TextField = TextField()
    lazy var lastNameTextField: TextField = TextField()
    lazy var signUpEmailOrUsername: TextField = TextField()
    lazy var signUpPassword: TextField = TextField()
    lazy var signInEmailOrUsername: TextField = TextField()
    lazy var signInPassword: TextField = TextField()
    lazy var showPasswordButton = UIButton()
    lazy var showLoginPasswordButton = UIButton()
    
    @IBOutlet weak var errorMessageLabel: UILabel!
    @IBOutlet weak var signUpFieldsView: UIView!
    @IBOutlet weak var firstName: TextField!
    private var viewModel: SHLoginViewModel?
    var signUpViewHeight = UIScreen.mainScreen().bounds.height / 2.756
    var signInViewHeight = UIScreen.mainScreen().bounds.height / 4.977
    var firstNameView: UIView?
    var lastNameView: UIView?
    var emailView: UIView?
    var passwordView: UIView?
    var signInEmailView: UIView?
    var signInPasswordView: UIView?
    let lightGrayBorderColor = UIColor(colorLiteralRed: 0, green: 0, blue: 0, alpha: 0.24).CGColor
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("keyboardWillShow:"), name:UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("keyboardWillHide:"), name:UIKeyboardWillHideNotification, object: nil)
        self.setUpLoginViewFields()
        self.setUpSignUpViewFields()
        viewModel?.viewDidLoad()
    }
    
    override func initializeViewModel() {
        viewModel = SHLoginViewModel(viewController: self)
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
    
    @IBAction func resetPasswordAction(sender: AnyObject) {
        viewModel?.resetPassword()
    }
    
    @IBAction func shoutitLoginAction(sender: AnyObject) {
        viewModel?.performLogin()
    }
    
    @IBAction func shoutitSignUpAction(sender: AnyObject) {
        viewModel?.performSignUp()
    }
    
    @IBAction func viewChanged(sender: UISegmentedControl) {
        self.signUpView.hidden = sender.selectedSegmentIndex != 0
        self.loginView.hidden = sender.selectedSegmentIndex == 0
        self.errorMessageLabel.hidden = true
    }
    // SignOut from Google
//    @IBAction func didTapSignOut(sender: AnyObject) {
//        GIDSignIn.sharedInstance().signOut()
//    }
    
    @IBAction func goBack(sender: AnyObject) {
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    @IBAction func showFeedback(sender: AnyObject) {
        viewModel?.showUserVoice(self)
    }
    
    @IBAction func showHelp(sender: AnyObject) {
    }
    
    @IBAction func showTerms(sender: AnyObject) {
        viewModel?.showTerms(self)
    }
    
    @IBAction func showAbout(sender: AnyObject) {
    }
    
    @IBAction func showPassword(sender: AnyObject) {
        if let password = self.signUpPassword.text where !password.isEmpty {
            if(showPasswordButton.titleLabel?.text == "show") {
                showPasswordButton.setTitle("hide", forState: .Normal)
            } else {
                showPasswordButton.setTitle("show", forState: .Normal)
            }
            viewModel?.togglePassword()
        } else if let loginPassword = self.signInPassword.text where !loginPassword.isEmpty {
            if(showLoginPasswordButton.titleLabel?.text == "show") {
                showLoginPasswordButton.setTitle("hide", forState: .Normal)
            } else {
                showLoginPasswordButton.setTitle("show", forState: .Normal)
            }
            viewModel?.togglePassword()
        }
    }
    
    func keyboardWillShow(sender: NSNotification) {
        if(self.loginView.hidden) {
            if (self.signUpPassword.isFirstResponder()) {
                self.view.frame.origin.y -= 150
            }
        }
    }
    
    func keyboardWillHide(sender: NSNotification) {
        if (self.signUpPassword.isFirstResponder()) {
            self.view.frame.origin.y += 150
        }
    }
    
    func highLightSignInEmailAction(recognizer: UITapGestureRecognizer) {
        //self.errorMessageLabel.hidden = true
        signInEmailView?.layer.borderColor = MaterialColor.lightBlue.accent2.CGColor
        signInPasswordView?.layer.borderColor = lightGrayBorderColor
    }
    
    func highLightSignInPasswordAction(recognizer: UITapGestureRecognizer) {
       // self.errorMessageLabel.hidden = true
        signInEmailView?.layer.borderColor = lightGrayBorderColor
        signInPasswordView?.layer.borderColor = MaterialColor.lightBlue.accent2.CGColor
    }
    
    func highLightFirstNameAction(recognizer: UITapGestureRecognizer){
        //self.errorMessageLabel.hidden = true
        firstNameView?.layer.borderColor = MaterialColor.lightBlue.accent2.CGColor
        lastNameView?.layer.borderColor = lightGrayBorderColor
        emailView?.layer.borderColor = lightGrayBorderColor
        passwordView?.layer.borderColor = lightGrayBorderColor
    }
    
    func highLightLastNameAction(recognizer: UITapGestureRecognizer){
       // self.errorMessageLabel.hidden = true
        firstNameView?.layer.borderColor = lightGrayBorderColor
        lastNameView?.layer.borderColor = MaterialColor.lightBlue.accent2.CGColor
        emailView?.layer.borderColor = lightGrayBorderColor
        passwordView?.layer.borderColor = lightGrayBorderColor
    }
    
    func highLightEmailAction(recognizer: UITapGestureRecognizer){
       // self.errorMessageLabel.hidden = true
        firstNameView?.layer.borderColor = lightGrayBorderColor
        lastNameView?.layer.borderColor = lightGrayBorderColor
        emailView?.layer.borderColor = MaterialColor.lightBlue.accent2.CGColor
        passwordView?.layer.borderColor = lightGrayBorderColor
    }
    
    func highLightPasswordAction(recognizer: UITapGestureRecognizer){
        //self.errorMessageLabel.hidden = true
        firstNameView?.layer.borderColor = lightGrayBorderColor
        lastNameView?.layer.borderColor = lightGrayBorderColor
        emailView?.layer.borderColor = lightGrayBorderColor
        passwordView?.layer.borderColor = MaterialColor.lightBlue.accent2.CGColor
    }
    
    // #private 
    private func setUpLoginViewFields () {
        signInEmailView = prepareSignInView(signInViewHeight / 13.4)
        if let signInEmailView = self.signInEmailView {
           // addTapGesture(signInEmailView)
            loginView.addSubview(signInEmailView)
            prepareFloatingTextField(signInEmailOrUsername, frameX: 10, frameY: 15, placeholderText: "Email or Username", view: signInEmailView, parentView: loginView)
        }
        
        signInPasswordView = prepareSignInView(signInViewHeight / 1.97)
        if let signInPasswordView = self.signInPasswordView {
           // addTapGesture(signInPasswordView)
            loginView.addSubview(signInPasswordView)
            prepareFloatingTextField(signInPassword, frameX: 10, frameY: 15, placeholderText: "Password", view: signInPasswordView, parentView: loginView)
        }
    }
    
    private func setUpSignUpViewFields () {
        firstNameView = prepareView(signUpViewHeight / 24.2)
        if let firstNameView = self.firstNameView {
           // addTapGesture(firstNameView)
            signUpView.addSubview(firstNameView)
            prepareFloatingTextField(firstNameTextField, frameX: 10, frameY: 15, placeholderText: "First Name", view: firstNameView, parentView: signUpView)
        }
        lastNameView = prepareView(signUpViewHeight / 3.558)
        if let lastNameView = self.lastNameView {
           // addTapGesture(lastNameView)
            signUpView.addSubview(lastNameView)
            prepareFloatingTextField(lastNameTextField, frameX: 10, frameY: 15, placeholderText: "Last Name", view: lastNameView, parentView: signUpView)
        }
        emailView = prepareView(signUpViewHeight / 1.92)
        if let emailView = self.emailView {
           // addTapGesture(emailView)
            signUpView.addSubview(emailView)
            prepareFloatingTextField(signUpEmailOrUsername, frameX: 10, frameY: 15, placeholderText: "Email", view: emailView, parentView: signUpView)
        }
        passwordView = prepareView(signUpViewHeight / 1.315)
        if let passwordView = self.passwordView {
           // addTapGesture(passwordView)
            signUpView.addSubview(passwordView)
            prepareFloatingTextField(signUpPassword, frameX: 10, frameY: 15, placeholderText: "Password", view: passwordView, parentView: signUpView)
        }
    }
    
    private func prepareFloatingTextField (textField: TextField, frameX: CGFloat, frameY: CGFloat, placeholderText: String, view: UIView, parentView: UIView) {
        textField.delegate = self
        if parentView == signUpView {
            textField.frame = CGRectMake(frameX, frameY, UIScreen.mainScreen().bounds.width - 50, signUpViewHeight / 12.5)
        } else {
            textField.frame = CGRectMake(frameX, frameY, UIScreen.mainScreen().bounds.width - 50, signInViewHeight / 4.18)
        }
        
        textField.placeholder = placeholderText
        textField.font = UIFont(name: "System", size: 16)
        textField.textColor = MaterialColor.black
        textField.titleLabel = UILabel()
        textField.titleLabel?.font = RobotoFont.mediumWithSize(10)
        textField.titleLabelColor = MaterialColor.grey.lighten1
        textField.titleLabelActiveColor = MaterialColor.lightBlue.accent2
        textField.bottomBorderLayer.hidden = true
        textField.clearButtonMode = .WhileEditing
        textField.delegate = viewModel
        if(view == firstNameView) {
            textField.addTarget(self, action: Selector("highLightFirstNameAction:"), forControlEvents: UIControlEvents.AllTouchEvents)
        } else if (view == lastNameView) {
            textField.addTarget(self, action: Selector("highLightLastNameAction:"), forControlEvents: UIControlEvents.AllTouchEvents)
        } else if (view == emailView) {
            textField.addTarget(self, action: Selector("highLightEmailAction:"), forControlEvents: UIControlEvents.AllTouchEvents)
        } else if ((view == passwordView)) {
            showPasswordButton.frame = CGRectMake(UIScreen.mainScreen().bounds.width - 110, frameY - 5, 20, 15)
            showPasswordButton.setTitleColor(UIColor.lightGrayColor(), forState: UIControlState.Normal)
            showPasswordButton.setTitle("show", forState: UIControlState.Normal)
            showPasswordButton.addTarget(self, action: "showPassword:", forControlEvents: UIControlEvents.TouchUpInside)
            textField.secureTextEntry = true
            textField.addTarget(self, action: Selector("highLightPasswordAction:"), forControlEvents: UIControlEvents.AllTouchEvents)
            showPasswordButton.titleLabel?.font =  RobotoFont.mediumWithSize(10)
            showPasswordButton.sizeToFit()
            view.addSubview(textField)
            view.addSubview(showPasswordButton)
            return
        } else if (view == signInEmailView) {
            textField.addTarget(self, action: Selector("highLightSignInEmailAction:"), forControlEvents: UIControlEvents.AllTouchEvents)
        } else if (view == signInPasswordView) {
            showLoginPasswordButton.frame = CGRectMake(UIScreen.mainScreen().bounds.width - 110, frameY - 5, 20, 15)
            showLoginPasswordButton.setTitleColor(UIColor.lightGrayColor(), forState: UIControlState.Normal)
            showLoginPasswordButton.setTitle("show", forState: UIControlState.Normal)
            showLoginPasswordButton.addTarget(self, action: "showPassword:", forControlEvents: UIControlEvents.TouchUpInside)
            textField.secureTextEntry = true
            textField.addTarget(self, action: Selector("highLightSignInPasswordAction:"), forControlEvents: UIControlEvents.AllTouchEvents)
            showLoginPasswordButton.titleLabel?.font =  RobotoFont.mediumWithSize(10)
            showLoginPasswordButton.sizeToFit()
            view.addSubview(textField)
            view.addSubview(showLoginPasswordButton)
            return
        }
        view.addSubview(textField)
    }
    
    private func prepareView (frameY: CGFloat) -> UIView {
        let textView = UIView(frame: CGRectMake(10, frameY, UIScreen.mainScreen().bounds.width - 40, signUpViewHeight / 4.84))
        textView.layer.borderWidth = 1
        textView.layer.cornerRadius = 5
        textView.layer.borderColor = lightGrayBorderColor
        return textView
    }
    
    private func prepareSignInView (frameY: CGFloat) -> UIView {
        let textView = UIView(frame: CGRectMake(10, frameY, UIScreen.mainScreen().bounds.width - 40, signInViewHeight / 2.68))
        textView.layer.borderWidth = 1
        textView.layer.cornerRadius = 5
        textView.layer.borderColor = lightGrayBorderColor
        return textView
    }
    
//    private func addTapGesture (view: UIView) {
//        if(view == firstNameView) {
//            let gesture = UITapGestureRecognizer(target: self, action: "highLightFirstNameAction:")
//            view.addGestureRecognizer(gesture)
//        } else if (view == lastNameView) {
//            let gesture = UITapGestureRecognizer(target: self, action: "highLightLastNameAction:")
//            view.addGestureRecognizer(gesture)
//        } else if (view == emailView) {
//            let gesture = UITapGestureRecognizer(target: self, action: "highLightEmailAction:")
//            view.addGestureRecognizer(gesture)
//        } else if (view == passwordView) {
//            let gesture = UITapGestureRecognizer(target: self, action: "highLightPasswordAction:")
//            view.addGestureRecognizer(gesture)
//        } else if (view == signInEmailView) {
//            let gesture = UITapGestureRecognizer(target: self, action: "highLightSignInEmailAction:")
//            view.addGestureRecognizer(gesture)
//        } else if (view == signInPasswordView) {
//            let gesture = UITapGestureRecognizer(target: self, action: "highLightSignInPasswordAction:")
//            view.addGestureRecognizer(gesture)
//        }
//        
//    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
        viewModel?.destroy()
    }
}
