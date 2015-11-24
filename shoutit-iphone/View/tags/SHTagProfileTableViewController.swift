//
//  SHTagProfileTableViewController.swift
//  shoutit-iphone
//
//  Created by Vishal Thakur on 17/11/15.
//  Copyright © 2015 Shoutit. All rights reserved.
//

import UIKit

class SHTagProfileTableViewController: BaseTableViewController {

    @IBOutlet weak var lgView: UIView!
    @IBOutlet weak var listenButton: UIButton!
    @IBOutlet weak var listeningLabel: UILabel!
    @IBOutlet weak var tagLabel: UILabel!
    
    
    private var viewModel: SHTagProfileTableViewModel?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //[self setListenSelected:self.model.tag.is_listening];
        self.tableView.dataSource = viewModel
        self.tableView.delegate = viewModel
        self.tagLabel.layer.cornerRadius = self.tagLabel.frame.size.height / 2
        self.tagLabel.layer.masksToBounds = true
        self.tagLabel.layer.borderColor = UIColor(hexString: Constants.Style.COLOR_SHOUT_DARK_GREEN)?.CGColor
        self.edgesForExtendedLayout = UIRectEdge.None
        self.tableView.registerNib(UINib(nibName: Constants.TableViewCell.SHShoutTableViewCell, bundle: NSBundle.mainBundle()), forCellReuseIdentifier: Constants.TableViewCell.SHShoutTableViewCell)
        self.navigationItem.leftBarButtonItem?.tintColor = UIColor.whiteColor()
        self.lgView.layer.cornerRadius = 5
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
        self.viewModel?.listenAction()
    }
    
    @IBAction func listeningAction(sender: AnyObject) {
        self.viewModel?.listeningAction()
    }
    
    func setListenSelected(isFollowing: Bool) {
        if(!isFollowing) {
            self.listenButton.setTitle(NSLocalizedString("Listen", comment: "Listen"), forState: UIControlState.Normal)
            self.listenButton.layer.cornerRadius = 5
            self.listenButton.layer.borderWidth = 1
            self.listenButton.layer.borderColor = UIColor(hexString: Constants.Style.COLOR_SHOUT_GREEN)?.CGColor
            self.listenButton.setTitleColor(UIColor(hexString: Constants.Style.COLOR_SHOUT_GREEN), forState: UIControlState.Normal)
            self.listenButton.backgroundColor = UIColor.whiteColor()
           // self.listenButton.setLeftIcon(UIImage(named: "listen"), withSize: CGSizeMake(32, 32))
        } else {
            self.listenButton.setTitle(NSLocalizedString("Listening", comment: "Listening"), forState: UIControlState.Normal)
            self.listenButton.layer.cornerRadius = 5
            self.listenButton.layer.borderWidth = 2
            self.listenButton.layer.borderColor = UIColor(hexString: Constants.Style.COLOR_SHOUT_GREEN)?.CGColor
            self.listenButton.backgroundColor = UIColor(hexString: Constants.Style.COLOR_SHOUT_GREEN)
            self.listenButton.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
           // self.listenButton.setLeftIcon(UIImage(named: "listenGreen"), withSize: CGSizeMake(32, 32))
            
        }
        self.listenButton.alpha = 1
    }
    

}
