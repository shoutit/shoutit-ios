//
//  SHShoutDetailTableViewController.swift
//  shoutit-iphone
//
//  Created by Vishal Thakur on 22/11/15.
//  Copyright © 2015 Shoutit. All rights reserved.
//

import UIKit
import DWTagList
import MapKit

class SHShoutDetailTableViewController: BaseTableViewController {
    private var viewModel: SHShoutDetailTableViewModel?
    var shoutID: String?
    
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var pageControl: UIPageControl!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var descriptionTextView: UITextView!
    @IBOutlet weak var tagList: DWTagList!
    @IBOutlet weak var categoryLabel: UILabel!
    @IBOutlet weak var typeLabel: UILabel!
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var profileButton: UIButton!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var shareButton: UIButton!
    @IBOutlet weak var reportButton: UIButton!
    @IBOutlet weak var titleLabel: UILabel!
    
    @IBOutlet weak var categoryHeight: NSLayoutConstraint!
    @IBOutlet weak var descriptionHeight: NSLayoutConstraint!
    @IBOutlet weak var tagListHeight: NSLayoutConstraint!
    @IBOutlet weak var titleHeight: NSLayoutConstraint!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let count = self.viewModel?.getCollectionViewCount() {
            self.pageControl.numberOfPages = count
        }
        self.pageControl.currentPage = 0
        self.collectionView.dataSource = viewModel
        self.collectionView.delegate = viewModel
        self.collectionView.showsHorizontalScrollIndicator = false
        self.collectionView.pagingEnabled = true
        
        self.tableView.dataSource = viewModel
        self.tableView.delegate = viewModel
        
        self.tagList.tagDelegate = viewModel
        self.tagList.automaticResize = true
        self.tagList.setTagBackgroundColor(UIColor(hexString: Constants.Style.COLOR_SHOUT_GREEN))
        self.tagList.setTagHighlightColor(UIColor(hexString: Constants.Style.COLOR_SHOUT_DARK_GREEN))
        self.tagList.textShadowColor = UIColor.clearColor()
        
        self.edgesForExtendedLayout = UIRectEdge.None
        self.tableView.registerNib(UINib(nibName: Constants.TableViewCell.SHShoutTableViewCell, bundle: NSBundle.mainBundle()), forCellReuseIdentifier: Constants.TableViewCell.SHShoutTableViewCell)
        self.navigationItem.leftBarButtonItem?.tintColor = UIColor.whiteColor()
        
        self.profileImageView.contentMode = UIViewContentMode.ScaleAspectFill
        self.profileImageView.clipsToBounds = true
        self.profileImageView.layer.borderColor = (UIColor(hexString: Constants.Style.COLOR_SHOUTDETAIL_PROFILEIMAGE))?.CGColor
        self.profileImageView.layer.borderWidth = 1.0
        self.profileImageView.layer.cornerRadius = self.profileImageView.frame.size.width / 2.0
        self.mapView.layer.cornerRadius = 5
        self.mapView.delegate = viewModel
        
        viewModel?.viewDidLoad()
    }
    
    override func initializeViewModel() {
        viewModel = SHShoutDetailTableViewModel(viewController: self)
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
    
    @IBAction func contactAction(sender: AnyObject) {
        viewModel?.contactProfileAction()
    }
    
    @IBAction func share(sender: AnyObject) {
        let action = UIActionSheet(title: NSLocalizedString("Share", comment: "Share"), delegate: self.viewModel, cancelButtonTitle: NSLocalizedString("Cancel", comment: "Cancel"), destructiveButtonTitle: nil, otherButtonTitles: "Facebook", "Google+", "Mail", "Standard")
        action.tag = 2
        action.showInView(self.view)
    }
    
    @IBAction func reportAction(sender: AnyObject) {
        viewModel?.reportAction()
    }
    
    @IBAction func replyAction(sender: AnyObject) {
        viewModel?.replyAction()
    }
    
    func getShoutDetails(shoutID: String) {
        self.shoutID = shoutID
    }
    
    
    deinit {
        collectionView = nil;
        profileImageView = nil;
        titleLabel = nil;
        timeLabel = nil;
        priceLabel = nil;
        locationLabel = nil;
        descriptionTextView = nil;
        tagList = nil;
        descriptionHeight = nil;
        titleHeight = nil;
        categoryLabel = nil;
        tagListHeight = nil;
        typeLabel = nil;
        pageControl = nil;
        mapView = nil;
        profileButton = nil;
        shareButton = nil;
        viewModel?.destroy()
    }
}
