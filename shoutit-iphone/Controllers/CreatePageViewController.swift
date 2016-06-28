//
//  CreatePageViewController.swift
//  shoutit
//
//  Created by Piotr Bernad on 23.06.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import UIKit
import RxSwift

class CreatePageViewController: UIViewController {
    
    // navigation
    weak var flowDelegate: FlowController?
    
    private let disposeBag = DisposeBag()
    
    var viewModel : LoginWithEmailViewModel!
    
    weak var delegate: LoginWithEmailViewControllerChildDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let categoriesController = segue.destinationViewController as? PageCategoriesCollectionViewController {
            categoriesController.selectedCategory.subscribeNext({ (category) in
                self.flowDelegate?.showCreatePageInfo(category, loginViewModel: self.viewModel)
            }).addDisposableTo(disposeBag)
        }
    }
    
}
