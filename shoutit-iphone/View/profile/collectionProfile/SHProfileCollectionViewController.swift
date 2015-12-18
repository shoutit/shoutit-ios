//
//  SHProfileCollectionViewController.swift
//  shoutit-iphone
//
//  Created by Vishal Thakur on 28/11/15.
//  Copyright © 2015 Shoutit. All rights reserved.
//

import UIKit

class SHProfileCollectionViewController: BaseCollectionViewController {
    
    private var viewModel: SHProfileCollectionViewModel?
    var user: SHUser?
    let settingsViewControler = SHSettingsTableViewController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if(SHOauthToken.getFromCache()?.accessToken?.characters.count < 0) {
            SHOauthToken.goToLogin()
            SHProgressHUD.showError(NSLocalizedString("Please log in to continue", comment: "Please log in to continue"))
        }
        self.collectionView?.dataSource = viewModel
        self.collectionView?.delegate = viewModel
        self.collectionView?.registerNib(UINib(nibName: Constants.CollectionViewCell.SHShoutSquareCollectionViewCell, bundle: nil), forCellWithReuseIdentifier: Constants.CollectionViewCell.SHShoutSquareCollectionViewCell)
        self.collectionView?.registerNib(UINib(nibName: Constants.CollectionReusableView.SHHeaderProfileReusableView, bundle: nil), forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: Constants.CollectionReusableView.SHHeaderProfileReusableView)
        if(self.user?.username == SHOauthToken.getFromCache()?.user?.username) {
            let editBtn = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Edit, target: self, action: Selector("editProfile:"))
            editBtn.tintColor = UIColor.darkTextColor()
            self.navigationItem.setRightBarButtonItem(editBtn, animated: true)
            let setBtn = UIBarButtonItem(image: UIImage(named: "settingsTabBar"), style: UIBarButtonItemStyle.Plain, target: self, action: Selector("openSettings"))
            self.navigationItem.leftBarButtonItem = setBtn
        } else {
            if let _ = self.user {
               // if(self.user.is_listener && self.user.is_following)
//                let reply = UIBarButtonItem(image: UIImage(named: "chatTabBar"), style: UIBarButtonItemStyle.Plain, target: self, action: Selector("replyAction:"))
//                self.navigationItem.rightBarButtonItem = reply
            } else {
                self.navigationItem.rightBarButtonItem = nil
            }
        }
        if let frame = self.collectionView?.frame {
             self.collectionView?.backgroundView = UIView(frame: frame)
        }
        self.collectionView?.alwaysBounceVertical = true
        self.edgesForExtendedLayout = UIRectEdge.None
        viewModel?.viewDidLoad()
    }
    
    override func initializeViewModel() {
        viewModel = SHProfileCollectionViewModel(viewController: self)
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
    
    func requestUser(user: SHUser) {
        self.user = user
        self.title = self.user?.name
    }
    
    func replyAction (sender: AnyObject) {
        self.viewModel?.replyToAction()
    }
    
    func editProfile(sender: AnyObject) {
        if let user = self.user {
            SHEditProfileTableViewController.presentFromViewController(self, user: user)
        }
    }
    
    func openSettings () {
        dispatch_async(dispatch_get_main_queue()) { () -> Void in
            let vc = UIStoryboard.getSettings().instantiateViewControllerWithIdentifier(Constants.ViewControllers.SHSETTINGS) as! SHSettingsTableViewController
            vc.user = self.user
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    deinit {
        viewModel?.destroy()
    }
    
}
