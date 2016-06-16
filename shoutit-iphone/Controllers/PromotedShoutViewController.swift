//
//  PromotedShoutViewController.swift
//  shoutit
//
//  Created by Łukasz Kasperek on 16.06.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import Foundation

final class PromotedShoutViewController: UIViewController {
    
    var viewModel: PromotedShoutViewModel!
    weak var flowDelegate : FlowController?
    
    @IBOutlet weak var shoutTitleLabel: UILabel!
    @IBOutlet weak var promotionLabelViewContainer: UIView!
    @IBOutlet weak var availableShoutitCreditLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        precondition(viewModel != nil)
    }
}
