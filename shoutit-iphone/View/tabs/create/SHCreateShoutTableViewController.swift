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
    private var isEditingMode = false
    private var shout: SHShout?
    
    static func presentEditorFromViewController(parent: UIViewController, shout: SHShout) {
        if let viewController = Constants.ViewControllers.CREATE_SHOUT as? SHCreateShoutTableViewController {
            viewController.isEditingMode = true
            viewController.shout = shout
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.collectionView.delegate = viewModel
        self.collectionView.dataSource = viewModel
        self.tableView.delegate = viewModel
        self.tableView.dataSource = viewModel
        
        viewModel?.viewDidLoad()
    }
    
    override func initializeViewModel() {
        viewModel = SHCreateShoutViewModel(viewController: self)
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
    }
    
}
