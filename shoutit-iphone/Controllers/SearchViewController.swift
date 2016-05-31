//
//  SearchViewController.swift
//  shoutit-iphone
//
//  Created by Łukasz Kasperek on 15.03.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

final class SearchViewController: UIViewController {
    
    // consts
    private let animationDuration: NSTimeInterval = 0.25
    private let categoryCellReuseId = "SearchCategoryTableViewCell"
    private let suggestionCellReuseId = "SearchSuggestionTableViewCell"
    
    // UI
    @IBOutlet weak var searchBar: UISearchBar! {
        didSet {
            searchBar.delegate = self
            searchBar.layer.borderColor = UIColor(shoutitColor: .SearchBarGray).CGColor
            searchBar.layer.borderWidth = 1.0
        }
    }
    @IBOutlet weak var tableView: UITableView! {
        didSet {
            tableView.dataSource = self
            tableView.delegate = self
        }
    }
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    @IBOutlet weak var segmentedControlSectionHeightConstraint: NSLayoutConstraint!
    
    lazy var tableViewPlaceholder: TableViewPlaceholderView = {[unowned self] in
        let view = NSBundle.mainBundle().loadNibNamed("TableViewPlaceholderView", owner: nil, options: nil)[0] as! TableViewPlaceholderView
        view.frame = CGRect(x: 0, y: 0, width: self.tableView.bounds.width, height: max(self.tableView.bounds.height * 0.8, 300))
        return view
    }()
    
    // view model
    var viewModel: SearchViewModel!
    
    // RX
    private let disposeBag = DisposeBag()
    
    // navigation
    weak var flowDelegate: FlowController?
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        precondition(viewModel != nil)
        
        setupKeyboardNotifcationListenerForScrollView(tableView)
        setupAppearance()
        setupRX()
        registerReusables()
        viewModel.reloadContent()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        tableView.contentOffset = CGPoint.zero
        unlockCancelButton()
    }
    
    override func prefersNavigationBarHidden() -> Bool {
        return true
    }
    
    deinit {
        removeKeyboardNotificationListeners()
    }
    
    // MARK: - Setup
    
    private func setupRX() {
        
        // user actions observers
        segmentedControl
            .rx_value
            .skip(1)
            .observeOn(MainScheduler.instance)
            .subscribeNext{[weak self] (segment) in
                if segment == 0 { self?.viewModel.segmentedControlState.value = .Shown(option: .Shouts) }
                else if segment == 1 { self?.viewModel.segmentedControlState.value = .Shown(option: .Users) }
            }
            .addDisposableTo(disposeBag)
        
        // view model observers
        viewModel
            .sectionViewModel
            .asDriver()
            .driveNext {[weak self] (sectionViewModel) in
                switch sectionViewModel {
                case .Categories, .Suggestions:
                    self?.tableView.tableHeaderView = nil
                case .LoadingPlaceholder:
                    self?.tableView.tableHeaderView = self?.tableViewPlaceholder
                    self?.tableViewPlaceholder.showActivity()
                case .MessagePlaceholder(let message, let image):
                    self?.tableView.tableHeaderView = self?.tableViewPlaceholder
                    self?.tableViewPlaceholder.showMessage(message, image: image)
                }
                self?.tableView.reloadData()
            }
            .addDisposableTo(disposeBag)
        
        viewModel
            .segmentedControlState
            .asDriver()
            .distinctUntilChanged()
            .throttle(animationDuration)
            .driveNext {[weak self] (state) in
                if case .Hidden = state {
                    self?.showSegmentedControl(false)
                } else {
                    self?.showSegmentedControl(true)
                }
            }
            .addDisposableTo(disposeBag)
    }
    
    private func setupAppearance() {
        
        // search bar
        let textField: UITextField? = searchBar.searchForView()
        textField?.backgroundColor = UIColor(shoutitColor: .SearchBarTextFieldGray)
        searchBar.placeholder = viewModel.searchBarPlaceholder()
        
        // table view
        tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 20, right: 0)
    }
    
    private func unlockCancelButton() {
        let button: UIButton? = searchBar.searchForView()
        button?.enabled = true
    }
    
    private func registerReusables() {
        self.tableView.registerNib(UINib(nibName: categoryCellReuseId, bundle: nil), forCellReuseIdentifier: categoryCellReuseId)
        self.tableView.registerNib(UINib(nibName: suggestionCellReuseId, bundle: nil), forCellReuseIdentifier: suggestionCellReuseId)
    }
    
    // MARK: - Navigation
    
    @IBAction func unwindToSearch(segue: UIStoryboardSegue) {}
    
    // MARK: - Helpers
    
    private func showSegmentedControl(show: Bool) {
        segmentedControlSectionHeightConstraint.constant = show ? 44 : 0
        UIView.animateWithDuration(animationDuration) {
            self.view.layoutIfNeeded()
        }
    }
    
    private func sectionPlaceholderWithType(type: SearchSectionViewModel.HeaderType) -> UIView? {
        switch type {
        case .None:
            return nil
        case .TitleCentered(let title):
            let headerView = NSBundle.mainBundle().loadNibNamed("SearchCategoriesHeaderView", owner: nil, options: nil).first as! SearchCategoriesHeaderView
            headerView.titleLabel.text = title
            return headerView
        case .TitleAlignedLeftWithButton(let title, let buttonTitle):
            let headerView = NSBundle.mainBundle().loadNibNamed("SearchRecentsHeaderView", owner: nil, options: nil).first as! SearchRecentsHeaderView
            headerView.titleLabel.text = title
            headerView.clearButton.setTitle(buttonTitle, forState: .Normal)
            headerView.clearButton.rx_tap.asDriver().driveNext{[unowned self] () in
                self.viewModel.clearRecentSearches()
            }.addDisposableTo(disposeBag)
            return headerView
        }
    }
    
    private func showSearchResultsForPhrase(phrase: String) {
        switch viewModel.segmentedControlState.value {
        case .Shown(option: .Users):
            flowDelegate?.showUserSearchResultsWithPhrase(phrase)
        default:
            flowDelegate?.showShoutsSearchResultsWithPhrase(phrase, context: viewModel.context)
            break
        }
    }
}

extension SearchViewController: UITableViewDataSource {
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch viewModel.sectionViewModel.value {
        case .LoadingPlaceholder, .MessagePlaceholder:
            return 0
        case .Categories(let cells, _):
            return cells.count
        case .Suggestions(let cells, _):
            return cells.count
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        switch viewModel.sectionViewModel.value {
        case .LoadingPlaceholder, .MessagePlaceholder:
            fatalError()
        case .Categories(let cells, _):
            let cellModel = cells[indexPath.row]
            let cell = tableView.dequeueReusableCellWithIdentifier(categoryCellReuseId, forIndexPath: indexPath) as! SearchCategoryTableViewCell
            cell.titleLabel.text = cellModel.category.name
            
            if let path = cellModel.category.icon, url = NSURL(string: path) {
                cell.thumbnailImageView.kf_setImageWithURL(url, placeholderImage: nil)
            }
            let numberOfRows = self.tableView(tableView, numberOfRowsInSection: indexPath.section)
            cell.setConstraintForPosition(isLast: indexPath.row == numberOfRows - 1)
            return cell
        case .Suggestions(let cells, _):
            let cellModel = cells[indexPath.row]
            let cell = tableView.dequeueReusableCellWithIdentifier(suggestionCellReuseId, forIndexPath: indexPath) as! SearchSuggestionTableViewCell
            switch cellModel {
            case .APISuggestion(let phrase):
                cell.titleLabel.text = phrase
                cell.showLeadingIcon(nil)
                cell.accessoryButton.setImage(UIImage.searchFillArrow(), forState: .Normal)
                cell.accessoryButton
                    .rx_tap
                    .asDriver()
                    .driveNext{[weak self] () in
                        self?.searchBar.text = cell.titleLabel.text
                    }
                    .addDisposableTo(cell.reuseDisposeBag)
                return cell
            case .RecentSearch(let phrase):
                cell.titleLabel.text = phrase
                cell.showLeadingIcon(UIImage.searchRecentsIcon())
                cell.accessoryButton.setImage(UIImage.searchRecentRemoveIcon(), forState: .Normal)
                cell.accessoryButton
                    .rx_tap
                    .asDriver()
                    .driveNext{[weak self] () in
                        self?.viewModel.removeRecentSearchPhrase(phrase)
                    }
                    .addDisposableTo(cell.reuseDisposeBag)
                return cell
            }
        }
    }
}

extension SearchViewController: UITableViewDelegate {
    
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        switch viewModel.sectionViewModel.value {
        case .LoadingPlaceholder, .MessagePlaceholder:
            return nil
        case .Categories(_, let header):
            return sectionPlaceholderWithType(header)
        case .Suggestions(_, let header):
            return sectionPlaceholderWithType(header)
        }
    }
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        switch viewModel.sectionViewModel.value {
        case .LoadingPlaceholder, .MessagePlaceholder:
            return 0
        case .Categories(_, let header):
            guard let headerView = sectionPlaceholderWithType(header) else {
                return 0
            }
            return headerView.frame.height
        case .Suggestions(_, let header):
            guard let headerView = sectionPlaceholderWithType(header) else {
                return 0
            }
            return headerView.frame.height
        }
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        switch viewModel.sectionViewModel.value {
        case .Categories(let cells, _):
            let model = cells[indexPath.row]
            flowDelegate?.showShoutsSearchResultsWithPhrase(nil, context: .CategoryShouts(category: model.category))
        case .Suggestions(let cells, _):
            let model = cells[indexPath.row]
            switch model {
            case .APISuggestion(let phrase):
                viewModel.savePhraseToRecentSearchesIfApplicable(phrase)
                showSearchResultsForPhrase(phrase)
            case .RecentSearch(let phrase):
                showSearchResultsForPhrase(phrase)
            }
        default:
            break
        }
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
}

extension SearchViewController: UISearchBarDelegate {
    
    func searchBarTextDidBeginEditing(searchBar: UISearchBar) {
        if let text = searchBar.text where text.utf16.count >= viewModel.minimumNumberOfCharactersForAutocompletion {
            self.viewModel.searchState.value = .Typing(phrase: text)
        } else {
            self.viewModel.searchState.value = .Active
        }
    }
    
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        self.viewModel.searchState.value = searchText.utf16.count >= viewModel.minimumNumberOfCharactersForAutocompletion ? .Typing(phrase: searchText) : .Active
    }
    
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        guard let phrase = searchBar.text where phrase.utf16.count > 0 else {
            return
        }
        viewModel.savePhraseToRecentSearchesIfApplicable(phrase)
        showSearchResultsForPhrase(phrase)
        searchBar.resignFirstResponder()
    }
    
    func searchBarTextDidEndEditing(searchBar: UISearchBar) {
        //self.viewModel.searchState.value = .Inactive
    }
    
    func searchBarCancelButtonClicked(searchBar: UISearchBar) {
        self.navigationController?.popViewControllerAnimated(true)
    }
}
