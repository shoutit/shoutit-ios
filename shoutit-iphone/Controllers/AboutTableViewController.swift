//
//  AboutTableViewController.swift
//  shoutit-iphone
//
//  Created by Łukasz Kasperek on 10.02.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

protocol AboutTableViewControllerFlowDelegate: class, TermsAndPolicyDisplayable {}

final class AboutTableViewController: UITableViewController {
    
    weak var flowDelegate: AboutTableViewControllerFlowDelegate?
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        switch indexPath.row {
        case 0:
            flowDelegate?.showTermsAndConditions()
        case 1:
            flowDelegate?.showPrivacyPolicy()
        case 2:
            flowDelegate?.showRules()
        default:
            fatalError()
        }
    }
}
