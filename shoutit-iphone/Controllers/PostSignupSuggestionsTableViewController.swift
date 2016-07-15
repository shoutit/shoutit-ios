//
//  PostSignupSuggestionsTableViewController.swift
//  shoutit-iphone
//
//  Created by Łukasz Kasperek on 09.02.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import Kingfisher

final class PostSignupSuggestionsTableViewController: UITableViewController {
    
    // UI
    lazy var placeholderView: TableViewPlaceholderView = {[unowned self] in
        let view = NSBundle.mainBundle().loadNibNamed("TableViewPlaceholderView", owner: nil, options: nil)[0] as! TableViewPlaceholderView
        view.frame = CGRect(x: 0, y: 0, width: self.tableView.bounds.width, height: self.tableView.bounds.height * 0.5)
        return view
    }()
    
    // view model
    var viewModel: PostSignupSuggestionViewModel!
    var sectionViewModel: PostSignupSuggestionsSectionViewModel!
    
    // RX
    private let disposeBag = DisposeBag()
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // setup layer
        view.layer.borderColor = UIColor.lightGrayColor().CGColor
        view.layer.borderWidth = 0.5
        view.layer.cornerRadius = 10
        
        // register cells
        tableView.registerNib(UINib(nibName: "PostSignupSuggestionsTableViewCell", bundle: nil), forCellReuseIdentifier: "PostSignupSuggestionsTableViewCell")
        
        // configure table view
        tableView.separatorStyle = .None
        
        // configure rx
        setupRX()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        tableView.scrollEnabled = tableView.contentSize.height > tableView.frame.height
    }
    
    private func setupRX() {
        
        viewModel.state.asObservable()
            .subscribeNext {[weak self] (state) in
                switch state {
                case .Idle:
                    self?.tableView.tableHeaderView = nil
                case .Loading:
                    self?.placeholderView.showActivity()
                    self?.tableView.tableHeaderView = self?.placeholderView
                case .ContentUnavailable:
                    self?.placeholderView.label.text = NSLocalizedString("Categories unavailable", comment: "")
                    self?.tableView.tableHeaderView = self?.placeholderView
                case .Error(let error):
                    self?.placeholderView.showMessage(error.sh_message)
                    self?.tableView.tableHeaderView = self?.placeholderView
                case .ContentLoaded:
                    self?.tableView.tableHeaderView = nil
                }
                
                self?.tableView.reloadData()
            }
            .addDisposableTo(disposeBag)
        
        tableView.rx_itemSelected
            .subscribeNext{[unowned self] (indexPath) in
                let cellViewModel = self.sectionViewModel.cells[indexPath.row]
                cellViewModel.selected = !cellViewModel.selected
                self.tableView.reloadData()
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
    
    override func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let view = NSBundle.mainBundle().loadNibNamed("PostSignupSuggestionsSectionHeader", owner: nil, options: nil).first as! PostSignupSuggestionsSectionHeader
        view.sectionTitleLabel.text = sectionViewModel.section.title
        
        return view
    }
    
    override func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 44
    }
}
