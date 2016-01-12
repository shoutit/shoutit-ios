//
//  SHPostSignupViewModel.swift
//  shoutit-iphone
//
//  Created by Vishal Thakur on 1/12/16.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import UIKit

class SHPostSignupViewModel: NSObject, UITableViewDelegate, UITableViewDataSource {
    private let viewController: SHPostSignupViewController
    private var categories: [SHCategory] = []
    private var categoriesString: [String] = []
    
    required init(viewController: SHPostSignupViewController) {
        self.viewController = viewController
    }
    
    func viewDidLoad() {
        self.getCategories()
    }
    
    func viewWillAppear() {
        
    }
    
    func viewDidAppear() {
        
    }
    
    func viewWillDisappear() {
        
    }
    
    func viewDidDisappear() {
        
    }
    
    func destroy() {
        
    }
    
    //tableView Datasource
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categoriesString.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(Constants.TableViewCell.SHPostSignupCategoriesCell, forIndexPath: indexPath) as! SHPostSignupCategoriesCell
        cell.setUp(self.categoriesString[indexPath.row])
        return cell
    }
    
    // private 
    private func getCategories () {
        // get categories from cache or update from web
        SHApiMiscService().getCategories({ (categories) -> Void in
            self.setCategories(categories)
            }, completionHandler: { (response) -> Void in
                switch(response.result) {
                case .Success(let result):
                    self.setCategories(result)
                case .Failure(let error):
                    log.warning("Error getting categories \(error.localizedDescription)")
                }
        })
    }
    
    private func setCategories(categories: [SHCategory]) {
        self.categories = categories
        self.categoriesString = categories.map({ (category) -> String in
            category.name
        })
        self.viewController.tableView.reloadData()
    }
    
}
