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
    
    fileprivate let disposeBag = DisposeBag()
    
    var viewModel : LoginWithEmailViewModel!
    
    weak var delegate: LoginWithEmailViewControllerChildDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let categoriesController = segue.destination as? PageCategoriesCollectionViewController {
            categoriesController.selectedCategory.subscribe(onNext: { (category) in
                self.flowDelegate?.showCreatePageInfo(category, loginViewModel: self.viewModel)
            }).addDisposableTo(disposeBag)
        }
    }
    
}
