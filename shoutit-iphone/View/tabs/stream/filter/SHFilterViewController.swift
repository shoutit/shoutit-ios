//
//  SHFilterViewController.swift
//  shoutit-iphone
//
//  Created by Vishal Thakur on 16/11/15.
//  Copyright © 2015 Shoutit. All rights reserved.
//

import UIKit

class SHFilterViewController: BaseViewController {

    
    @IBOutlet var tableView: UITableView!
    private var viewModel: SHFilterViewModel?
    private var filter: SHFilter?
    private var filters = []
    private var lastResultCount: Int?
    private var activeTextField: UITextField?
    private var keyToolbar: UIToolbar?
    private var tapTagsSelect: UITapGestureRecognizer?
    
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        lastResultCount = 0
        filter = SHFilter()
        self.configureFilter()
    }
    
    private func configureFilter () {
        var firstSection = [[String: AnyObject]]()
        var secondSection = [[String: AnyObject]]()
        var thirdSection = [[String: AnyObject]]()
        var fourthSection = []
        
        let Category = [Constants.Filter.kLeftLablel: NSLocalizedString("Category", comment: "Category"), Constants.Filter.kRightLablel: NSLocalizedString("All", comment: "All"),
            Constants.Filter.kCellType: Constants.Filter.kStandardCellId,
            Constants.Filter.kSelectorName: "selectCategory:"]
        
        let Type = [Constants.Filter.kLeftLablel: NSLocalizedString("Type", comment: "Type"),
            Constants.Filter.kRightLablel: NSLocalizedString("Offer", comment: "Offer"),
            Constants.Filter.kCellType: Constants.Filter.kStandardCellId,
            Constants.Filter.kSelectorName: "selectType:"]
        
        let Tags = [Constants.Filter.kLeftLablel: NSLocalizedString("Tags", comment: "Tags"),
            Constants.Filter.kRightLablel: "",
            Constants.Filter.KTagsArray: [],
            Constants.Filter.kCellType: Constants.Filter.kStandardCellId,
            Constants.Filter.kSelectorName: "selectTags:"]
        
        firstSection = [Category, Type, Tags as! Dictionary<String, AnyObject>]
        
        let Price = [Constants.Filter.kLeftLablel: NSLocalizedString("Price", comment: "Price"),
            Constants.Filter.kRightLablel: NSLocalizedString("Any", comment: "Any"),
            Constants.Filter.kCellType: Constants.Filter.kStandardCellId,
            Constants.Filter.kSelectorName: "selectPrice:"]
        
        secondSection = [Price]
        
        let Location = [Constants.Filter.kLeftLablel: NSLocalizedString("Location", comment: "Location"), Constants.Filter.kRightLablel: NSLocalizedString("Current Location", comment: "Current Location"),
            Constants.Filter.kCellType: Constants.Filter.kStandardCellId,
            Constants.Filter.kSelectorName: "selectLocation:"]
        
        thirdSection = [Location]
        
        let Reset = [Constants.Filter.kLeftLablel: NSLocalizedString("Reset", comment: "Reset"),
            Constants.Filter.kCellType: Constants.Filter.kCenterCellId,
            Constants.Filter.kSelectorName: "resetFilter"]
        
        fourthSection = [Reset]
        
        self.filters = [firstSection, secondSection, thirdSection, fourthSection]
        
        if let location = SHAddress.getUserOrDeviceLocation(), let filter = self.filter{
            let string = String(format: "%@, %@, %@", arguments: [location.city, location.state, location.country])
            self.filters[2][0].setObject(string, forKey: Constants.Filter.kRightLablel)
            self.filters[2][0].setObject(1, forKey: Constants.Filter.kIsApply)
            filter.isApplied = true
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                self.tableView.reloadData()
            })
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
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
        
        //self.tableView.tableFooterView = self.loadMoreView;
        viewModel?.viewDidLoad()
    }
    
    func doneEdit(sender: AnyObject) {
        self.view.endEditing(true)
    }
    
    func applyAction(sender: AnyObject) {
        //[self.delegate applyFilter:self.filter.isApplyed?self.filter:nil isApplyed:self.filter.isApplyed]
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
