//
//  SHCreateShoutTableViewController.swift
//  shoutit-iphone
//
//  Created by Hitesh Sondhi on 14/11/15.
//  Copyright © 2015 Shoutit. All rights reserved.
//

import UIKit
import DWTagList

class SHCreateShoutTableViewController: BaseTableViewController {

    @IBOutlet weak var categoriesLabel: UILabel!
    @IBOutlet weak var categoriesTextField: UITextField!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var currencyTextField: UITextField!
    @IBOutlet weak var locationTextView: UITextField!
    @IBOutlet weak var descriptionTextView: UITextField!
    @IBOutlet weak var priceTextField: UITextField!
    @IBOutlet weak var segmentControl: UISegmentedControl!
    @IBOutlet weak var tagsLabel: UILabel!
    @IBOutlet weak var tagsList: DWTagList!
    @IBOutlet weak var titleTextField: UITextField!
    
    private var viewModel: SHCreateShoutViewModel?
    var shout: SHShout?
    var isEditingMode = false
    var isViewSetUp: Bool?
    
    static func presentEditorFromViewController(parent: UIViewController, shout: SHShout) {
        if let viewController = UIStoryboard.getCreateShout().instantiateViewControllerWithIdentifier(Constants.ViewControllers.CREATE_SHOUT) as? SHCreateShoutTableViewController {
            viewController.isEditingMode = true
            viewController.shout = shout
            let navController = SHNavigationViewController(rootViewController: viewController)
            parent.presentViewController(navController, animated: true, completion: nil)
            //viewController.viewDidLoad()
        }
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.collectionView.delegate = viewModel
        self.collectionView.dataSource = viewModel
        self.tableView.delegate = viewModel
        self.tableView.dataSource = viewModel
        
        setUpNavBar()
        
        viewModel?.viewDidLoad()
    }
    
    override func initializeViewModel() {
        viewModel = SHCreateShoutViewModel(viewController: self)
        viewModel?.isEditing = self.isEditingMode
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

    @IBAction func segmentAction(sender: AnyObject) {
        viewModel?.segmentAction()
    }
    
    func postShout() {
        viewModel?.postShout()
    }
    
    func patchShout() {
        viewModel?.patchShout()
    }
    
    func cleanForms() {
        let alert = UIAlertController(title: nil, message: NSLocalizedString("Discard changes?", comment: "Discard changes?"), preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: "Cancel"), style: UIAlertActionStyle.Default, handler: nil))
        alert.addAction(UIAlertAction(title: NSLocalizedString("YES", comment: "YES"), style: .Default, handler: { (action) -> Void in
            SHProgressHUD.show(NSLocalizedString("Retrieving Location", comment: "Retrieving Location"), maskType: .Black)
             self.viewModel?.cleanForms()
            SHProgressHUD.dismiss()
        }))
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    func cancelBack() {
        let ac = UIAlertController(title: NSLocalizedString("Discard changes?", comment: "Discard changes?"), message: "", preferredStyle: UIAlertControllerStyle.Alert)
        ac.addAction(UIAlertAction(title: NSLocalizedString("Yes", comment: "Yes"), style: UIAlertActionStyle.Default, handler: { (alertAction) -> Void in
            self.dismissViewControllerAnimated(true, completion: nil)
        }))
        ac.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: "Cancel"), style: UIAlertActionStyle.Cancel, handler: nil))
        self.presentViewController(ac, animated: true, completion: nil)
    }
    
    // MARK - Private
    private func setUpNavBar() {
        if self.isEditingMode {
            self.navigationItem.setRightBarButtonItem(UIBarButtonItem(title: NSLocalizedString("Save", comment: "Save"), style: UIBarButtonItemStyle.Done, target: self, action: "patchShout"), animated: false)
        } else {
            self.navigationItem.setRightBarButtonItem(UIBarButtonItem(title: NSLocalizedString("Shout", comment: "Shout"), style: UIBarButtonItemStyle.Done, target: self, action: "postShout"), animated: false)
        }
        
        self.navigationItem.rightBarButtonItem?.tintColor = UIColor(shoutitColor: .ShoutDarkGreen)
        self.navigationItem.leftBarButtonItem?.tintColor = UIColor.whiteColor()
    }
    
}
