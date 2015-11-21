//
//  SHCategoryTagsViewController.swift
//  shoutit-iphone
//
//  Created by Vishal Thakur on 20/11/15.
//  Copyright © 2015 Shoutit. All rights reserved.
//

import UIKit

class SHCategoryTagsViewController: BaseTableViewController {
    
    private var viewModel: SHCategoryTagsViewModel?
    var selectedBlock: (([SHTag]) -> ())?
    var oldTags = []
    var hardCodedTags = []
    var selectedDict = [String: AnyObject]()
    var category = ""
    var lastResultCount: Int?
    var shTagsApi = SHApiTagsService()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Tags"
        self.tableView.dataSource = viewModel
        self.tableView.delegate = viewModel
        
//        [super viewDidLoad];
//        self.title = @"Tags";
//        self.clearsSelectionOnViewWillAppear = YES;
//        // Initialize the refresh control.
//        self.refreshControl = [[UIRefreshControl alloc] init];
//        self.refreshControl.tintColor = [UIColor darkGrayColor];
//        if (!self.hardcodedTags)
//        [self.refreshControl addTarget:self
//        action:@selector(refreshTags)
//        forControlEvents:UIControlEventValueChanged];
        self.edgesForExtendedLayout = UIRectEdge.None
        self.tableView.registerNib(UINib(nibName: Constants.TableViewCell.SHTopTagTableViewCell, bundle: NSBundle.mainBundle()), forCellReuseIdentifier: Constants.TableViewCell.SHTopTagTableViewCell)
        self.tableView.contentOffset = CGPointMake(0.0, 44.0)
        self.navigationItem.leftBarButtonItem?.tintColor = UIColor.whiteColor()
        self.tableView.scrollsToTop = true
        if(self.hardCodedTags.count > 0) {
            self.fetchedResultsController = self.hardCodedTags
        }
        viewModel?.viewDidLoad()
    }
    
    override func initializeViewModel() {
        viewModel = SHCategoryTagsViewModel(viewController: self)
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
    
    func refreshTags(category: String) {
        viewModel?.getTagsForCategory(category)
    }
    
    deinit {
        viewModel?.destroy()
    }
    
}
