//
//  SHTagProfileTableViewController.swift
//  shoutit-iphone
//
//  Created by Vishal Thakur on 17/11/15.
//  Copyright © 2015 Shoutit. All rights reserved.
//

import UIKit

class SHTagProfileTableViewController: BaseViewController {

    @IBOutlet weak var lgView: UIView!
    @IBOutlet weak var listenButton: UIButton!
    @IBOutlet weak var listeningLabel: UILabel!
    @IBOutlet weak var tagLabel: UILabel!
    
    
    private var viewModel: SHTagProfileTableViewModel?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel?.viewDidLoad()
    }
    
    override func initializeViewModel() {
        viewModel = SHTagProfileTableViewModel(viewController: self)
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
    
    deinit {
        viewModel?.destroy()
    }
    
    @IBAction func listenAction(sender: AnyObject) {
        
    }
    
    @IBAction func listeningAction(sender: AnyObject) {
        
    }

}
