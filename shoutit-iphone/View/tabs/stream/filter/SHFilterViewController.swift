//
//  SHFilterViewController.swift
//  shoutit-iphone
//
//  Created by Vishal Thakur on 16/11/15.
//  Copyright © 2015 Shoutit. All rights reserved.
//

import UIKit

protocol SHFilterViewControllerDelegate {
    func applyFilter(filter: SHFilter?, isApplied: Bool)
}

class SHFilterViewController: BaseViewController {
    
    @IBOutlet var tableView: UITableView!
    private var viewModel: SHFilterViewModel?
    private var lastResultCount: Int?
    private var activeTextField: UITextField?
    private var keyToolbar: UIToolbar?
    private var loadMoreView: SHLoadMoreView?
    var delegate: SHFilterViewControllerDelegate?
    var filter: SHFilter?
    var filters: [AnyObject] = []
    var fetchedResultsController = []
    var tapTagsSelect: UITapGestureRecognizer?
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        lastResultCount = 0
        filter = SHFilter()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        //tableView DataSource and Delegate
        self.tableView.dataSource = viewModel
        self.tableView.delegate = viewModel
        
        var frame = self.tableView.frame
        frame.size.height = 44
        self.keyToolbar = UIToolbar(frame: frame)
        self.keyToolbar?.frame = frame
        
        let done = UIBarButtonItem(title: NSLocalizedString("Done", comment: "Done"), style: UIBarButtonItemStyle.Plain, target: self, action: Selector("doneEdit:"))
        done.tintColor = UIColor(hexString: Constants.Style.COLOR_SHOUT_DARK_GREEN)
        
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.FlexibleSpace, target: nil, action: nil)
        self.keyToolbar?.items = [flexibleSpace, done]
    
        self.navigationController?.navigationBar.tintColor = UIColor.whiteColor()
        let cancel = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Cancel, target: self, action: Selector("cancelAction:"))
        self.navigationItem.leftBarButtonItem = cancel
        
        let apply = UIBarButtonItem(title: NSLocalizedString("Apply", comment: "Apply"), style: UIBarButtonItemStyle.Done, target: self, action: Selector("applyAction:"))
        self.navigationItem.rightBarButtonItem = apply
        // Do any additional setup after loading the view.
        self.tapTagsSelect = UITapGestureRecognizer(target: self, action: Selector("selectTags:"))
        
        self.tableView.registerNib(UINib(nibName: "SHTopTagTableViewCell", bundle: NSBundle.mainBundle()), forCellReuseIdentifier: "SHTopTagTableViewCell")
        
        self.tableView.tableFooterView = self.loadMoreView
        viewModel?.viewDidLoad()
    }
    
    func doneEdit(sender: AnyObject) {
        self.view.endEditing(true)
    }
    
    func applyAction(sender: AnyObject) {
        if let filter = self.filter {
            self.delegate?.applyFilter(filter.isApplied ? filter : nil, isApplied: filter.isApplied)
        }
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func cancelAction(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    override func initializeViewModel() {
        viewModel = SHFilterViewModel(viewController: self)
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


}
