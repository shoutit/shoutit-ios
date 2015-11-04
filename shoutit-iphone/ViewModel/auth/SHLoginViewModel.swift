//
//  SHLoginViewModel.swift
//  shoutit-iphone
//
//  Created by Hitesh Sondhi on 02/11/15.
//  Copyright © 2015 Shoutit. All rights reserved.
//

import UIKit

class SHLoginViewModel: NSObject, TableViewControllerModelProtocol, UITableViewDelegate, UITableViewDataSource {

    var viewController: SHLoginViewController
    
    required init(viewController: SHLoginViewController) {
        self.viewController = viewController
    }
    
    func viewDidLoad() {
        
    }
    
    func viewWillAppear() {
        
    }
    
    func viewDidAppear() {
        
    }
    
    func viewWillDisappear() {
        
    }
    
    func viewDidDisappear() {
        
    }
    
    func destroy() {
        
    }
    
    // MARK - UITableView Delegate
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("SHLoginInputCell", forIndexPath: indexPath)
        let textView = cell.viewWithTag(100) as! TextFieldValidator
        textView.presentInView = tableView.window
        let dict = viewController.signArray[indexPath.row]
        textView.text = dict["text"]?.stringValue
        textView.placeholder = dict["placeholder"]?.stringValue
        textView.addTarget(self, action: NSSelectorFromString(dict["selector"]! as! String), forControlEvents: UIControlEvents.EditingChanged)
        textView.addTarget(self, action: NSSelectorFromString(dict["selectorBegin"]! as! String), forControlEvents: UIControlEvents.EditingDidBegin)
        textView.isMandatory = true
        
        switch (indexPath.row) {
        case 0:
            viewController.signArray[indexPath.row]["emailTextField"] = textView
            textView.addRegx(Constants.RegEx.REGEX_EMAIL, withMsg: "Enter valid email.") // Todo Localization
        case 1:
            viewController.signArray[indexPath.row]["passwordTextField"] = textView
            textView.addRegx(Constants.RegEx.REGEX_PASSWORD_LIMIT, withMsg: "Password charaters limit should be come between 6-20") // Todo Localization
            textView.secureTextEntry = true
        case 2:
            viewController.signArray[indexPath.row]["nameTextField"] = textView
        default:
            break;
        }
        return cell;
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewController.isSignIn ? 2 : 3
    }
    
}
