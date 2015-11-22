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
import FBSDKShareKit

class SHShoutDetailTableViewController: BaseTableViewController, UIActionSheetDelegate {
    private var viewModel: SHShoutDetailTableViewModel?
    
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
    }
    
    @IBAction func share(sender: AnyObject) {
        let action = UIActionSheet(title: NSLocalizedString("Share", comment: "Share"), delegate: self, cancelButtonTitle: NSLocalizedString("Cancel", comment: "Cancel"), destructiveButtonTitle: nil, otherButtonTitles: "Facebook", "Google+", "Mail", "Standard")
        action.tag = 2
        action.showInView(self.view)
    }
    
    @IBAction func reportAction(sender: AnyObject) {
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
        
//        switch(buttonIndex) {
//        case 0:
//            break
//        case 1:
//            break
//        case 2:
//            break
//        case 3:
//            break
//        default:
//            break
//        }
        
        
//        switch (buttonIndex) {
//        case 0:
//            {
//                [FBShareManager openShareDialogWith:self.shoutModel.shout succsess:^(FBAppCall *call, id result) {
//                    [SVProgressHUD showSuccessWithStatus:NSLocalizedString(@"Shout shared", @"Shout shared")];
//                    } failure:^(FBAppCall *call, id result, NSError *error) {
//                    [SVProgressHUD showErrorWithStatus:error.localizedDescription];
//                    }];
//            }
//            break;
//        case 1:
//            {
//                [GShareManager shareShout:self.shoutModel.shout];
//            }
//            break;
//        case 2:
//            {
//                if ([MFMailComposeViewController canSendMail]) {
//                    MFMailComposeViewController *composeViewController = [[MFMailComposeViewController alloc] initWithNibName:nil bundle:nil];
//                    [composeViewController setMailComposeDelegate:self];
//                    [composeViewController setMessageBody:self.shoutModel.shout.web_url isHTML:NO];
//                    [self presentViewController:composeViewController animated:YES completion:nil];
//                }
//            }
//            break;
//        case 3:
//            {
//                NSMutableArray *sharingItems = [NSMutableArray new];
//                [sharingItems addObject:self.shoutModel.shout.web_url];
//                UIActivityViewController *activityController = [[UIActivityViewController alloc] initWithActivityItems:sharingItems applicationActivities:nil];
//                [self presentViewController:activityController animated:YES completion:nil];
//            }
//            break;
//            
//        }
    }
    
    deinit {
        viewModel?.destroy()
    }
}
