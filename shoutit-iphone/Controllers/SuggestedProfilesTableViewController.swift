//
//  SuggestedProfilesTableViewController.swift
//  shoutit-iphone
//
//  Created by Piotr Bernad on 26.05.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import Kingfisher
import DZNEmptyDataSet
import ShoutitKit

class SuggestedProfilesTableViewController: UITableViewController, DZNEmptyDataSetSource, DZNEmptyDataSetDelegate {
    var flowDelegate : FlowController?
    
    let viewModel = PostSignupSuggestionViewModel()
    
    var sectionViewModel: PostSignupSuggestionsSectionViewModel!
    
    // RX
    private let disposeBag = DisposeBag()
    
    lazy var placeholderView: TableViewPlaceholderView = {[unowned self] in
        let view = NSBundle.mainBundle().loadNibNamed("TableViewPlaceholderView", owner: nil, options: nil)[0] as! TableViewPlaceholderView
        view.frame = CGRect(x: 0, y: 0, width: self.tableView.bounds.width, height: self.tableView.bounds.height * 0.5)
        return view
        }()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupRX()
        
        viewModel.fetchSections()
        
        self.navigationItem.title = NSLocalizedString("Suggestions", comment: "")
        
        tableView.emptyDataSetSource = self
        tableView.emptyDataSetDelegate = self
        
        // register cells
        tableView.registerNib(UINib(nibName: "PostSignupSuggestionsTableViewCell", bundle: nil), forCellReuseIdentifier: "PostSignupSuggestionsTableViewCell")

    }
    
    func titleForEmptyDataSet(scrollView: UIScrollView!) -> NSAttributedString! {
        let attributes : [String: AnyObject] = [NSFontAttributeName: UIFont.systemFontOfSize(18)]
        
        switch viewModel.state.value {
        case .Loading:
            return NSAttributedString(string: NSLocalizedString("Loading suggestions", comment: ""), attributes: attributes)
        case .Idle:
            return NSAttributedString(string: NSLocalizedString("Loading suggestions", comment: ""), attributes: attributes)
        case .ContentUnavailable:
            return NSAttributedString(string: self.sectionViewModel.noContentTitle, attributes: attributes)
        case .ContentLoaded:
            return NSAttributedString(string: self.sectionViewModel.noContentTitle, attributes: attributes)
        case .Error(let error):
            return NSAttributedString(string: (error as NSError).localizedDescription, attributes: attributes)
        }
        
    }
    
    private func setupRX() {
        
        viewModel.state.asObservable()
            .subscribeNext {[weak self] (state) in
                self?.tableView.reloadData()
                self?.tableView.reloadEmptyDataSet()
            }
            .addDisposableTo(disposeBag)
        
        tableView.rx_itemSelected
            .subscribeNext{[unowned self] (indexPath) in
                
                let cellViewModel = self.sectionViewModel.cells[indexPath.row]
                if let profile = cellViewModel.item as? Profile {
                    self.flowDelegate?.showProfile(profile)
                }
                
            }
            .addDisposableTo(disposeBag)
    }
    
    // MARK: - UITableViewDelegate
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 58
    }
    
    // MARK: - UITableViewDataSource
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        guard case LoadingState.ContentLoaded = viewModel.state.value else {
            return 0
        }
        
        guard sectionViewModel.cells.count > 0 else {
            return 0
        }
        
        
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard case LoadingState.ContentLoaded = viewModel.state.value else {
            return 0
        }
        
        return sectionViewModel.cells.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        guard case LoadingState.ContentLoaded = viewModel.state.value else {
            fatalError()
        }
        
        let cellViewModel = sectionViewModel.cells[indexPath.row]
        let cell = tableView.dequeueReusableCellWithIdentifier("PostSignupSuggestionsTableViewCell", forIndexPath: indexPath) as! PostSignupSuggestionsTableViewCell
        
        cell.nameLabel.text = cellViewModel.item.suggestionTitle
        cell.thumbnailImageView.sh_setImageWithURL(cellViewModel.item.thumbnailURL, placeholderImage: UIImage.squareAvatarPlaceholder())
        if case .Some(.Page(_)) = Account.sharedInstance.loginState {
        cell.thumbnailImageView.sh_setImageWithURL(cellViewModel.item.thumbnailURL, placeholderImage: UIImage.squareAvatarPagePlaceholder())
        }
        let image = cellViewModel.selected ? UIImage.suggestionAccessoryViewSelected() : UIImage.suggestionAccessoryView()
        cell.listenButton.setImage(image, forState: .Normal)
        
        cell.reuseDisposeBag = DisposeBag()
        cell.listenButton.rx_tap.flatMapFirst({ () -> Observable<(successMessage: String?, error: ErrorType?)> in
            return cellViewModel.listen()
        }).subscribeNext({[weak self] (let successMessage, let error) in
            if let successMessage = successMessage {
                self?.showSuccessMessage(successMessage)
            } else if let error = error {
                self?.showError(error)
            }
            self?.tableView.reloadData()
            }).addDisposableTo(cell.reuseDisposeBag!)
        
        return cell
    }
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sectionViewModel.section.title
    }
    
}
