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
import Social
import MessageUI
//import FBSDKShareKit

class SHShoutDetailTableViewController: BaseTableViewController, UIActionSheetDelegate, MFMailComposeViewControllerDelegate {
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
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
       // self.pageControl.numberOfPages = [self getCollectionViewCount];
        self.pageControl.currentPage = 0
        self.collectionView.dataSource = viewModel
        self.collectionView.delegate = viewModel
        self.collectionView.showsHorizontalScrollIndicator = false
        self.collectionView.pagingEnabled = true
        
       // [self.tagList setTagDelegate:self];
        self.tagList.automaticResize = true
        self.tagList.backgroundColor = UIColor(hexString: Constants.Style.COLOR_SHOUT_GREEN)
        self.tagList.setTagHighlightColor(UIColor(hexString: Constants.Style.COLOR_SHOUT_DARK_GREEN))
        self.tagList.textShadowColor = UIColor.clearColor()
        
        self.edgesForExtendedLayout = UIRectEdge.None
        self.tableView.registerNib(UINib(nibName: Constants.TableViewCell.SHShoutTableViewCell, bundle: NSBundle.mainBundle()), forCellReuseIdentifier: Constants.TableViewCell.SHShoutTableViewCell)
        self.navigationItem.leftBarButtonItem?.tintColor = UIColor.whiteColor()
        
        
       //  [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
        
       //  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deviceRotation:) name:UIDeviceOrientationDidChangeNotification object:nil];
        self.profileImageView.contentMode = UIViewContentMode.ScaleAspectFill
        self.profileImageView.clipsToBounds = true
        self.profileImageView.layer.borderColor = (UIColor(hexString: Constants.Style.COLOR_SHOUTDETAIL_PROFILEIMAGE))?.CGColor
        self.profileImageView.layer.borderWidth = 1.0
        self.profileImageView.layer.cornerRadius = self.profileImageView.frame.size.width / 2.0
        self.mapView.layer.cornerRadius = 5
        
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
//        if(![self.shoutModel.shout.user.userID isEqualToString:[[[SHLoginModel sharedModel] selfUser] userID]])
//        {
//            SHProfileCollectionViewController* profileViewController = [SHNavigator viewControllerFromStoryboard:@"ProfileStoryboard" withViewControllerId:@"SHProfileCollectionViewController"];
//            [profileViewController requestUser:self.shoutModel.shout.user];
//            
//            [self.navigationController pushViewController:profileViewController animated:YES];
//        }
    }
    
    @IBAction func share(sender: AnyObject) {
        let action = UIActionSheet(title: NSLocalizedString("Share", comment: "Share"), delegate: self, cancelButtonTitle: NSLocalizedString("Cancel", comment: "Cancel"), destructiveButtonTitle: nil, otherButtonTitles: "Facebook", "Google+", "Mail", "Standard")
        action.tag = 2
        action.showInView(self.view)
    }
    
    @IBAction func reportAction(sender: AnyObject) {
//        
//        [SHShoutDetailModel reportShout:self.shoutModel.shout succsess:^(BOOL isSuccess)
//            {
//            dispatch_async(dispatch_get_main_queue(), ^{
//            [SVProgressHUD showSuccessWithStatus:NSLocalizedString(@"Thank you! Shout has been reported as inappropriate and will be reviewed.", @"Thank you! Shout has been reported as inappropriate and will be reviewed.")];
//            });
//            
//            } failure:^(NSError *error) {
//            NSLog(@"Shout not reported");
//            }];
    }
    
    @IBAction func replyAction(sender: AnyObject) {
    }
    
    func actionSheet(actionSheet: UIActionSheet, didDismissWithButtonIndex buttonIndex: Int) {
        if(actionSheet.tag != 2) {
            return
        }
        if(buttonIndex == actionSheet.cancelButtonIndex) {
            return
        }
        
        switch(buttonIndex) {
        case 0:
            let vc = SLComposeViewController(forServiceType: SLServiceTypeFacebook)
            vc.setInitialText("web_url")
          //  vc.addImage(detailImageView.image!)
            vc.addURL(NSURL(string: "http://www.facebook.com"))
            presentViewController(vc, animated: true, completion: nil)
        case 1:
            // Google SingIn
            break
        case 2:
            if(MFMailComposeViewController.canSendMail()) {
                let composeViewController = MFMailComposeViewController(nibName: nil, bundle: nil)
                composeViewController.mailComposeDelegate = self
                composeViewController.setMessageBody("web_url", isHTML: false)
                self.presentViewController(composeViewController, animated: true, completion: nil)
            }
        case 3:
            var sharingItems = [String]()
            sharingItems.append("web_url")
            let activityController = UIActivityViewController.init(activityItems: sharingItems, applicationActivities: nil)
            self.presentViewController(activityController, animated: true, completion: nil)
        default:
            break
        }
    }
    
    func getShoutDetails(shoutID: String) {
        self.shoutID = shoutID
        self.tableView.reloadData()
    }
    
    
    deinit {
        viewModel?.destroy()
    }
}
