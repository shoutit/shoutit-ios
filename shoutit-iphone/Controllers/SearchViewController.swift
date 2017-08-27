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
import ShoutitKit

final class SearchViewController: UIViewController {
    
    // consts
    fileprivate let animationDuration: TimeInterval = 0.25
    fileprivate let categoryCellReuseId = "SearchCategoryTableViewCell"
    fileprivate let suggestionCellReuseId = "SearchSuggestionTableViewCell"
    
    // UI
    @IBOutlet weak var searchBar: UISearchBar! {
        didSet {
            searchBar.delegate = self
            searchBar.layer.borderColor = UIColor(shoutitColor: .searchBarGray).cgColor
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
        let view = Bundle.main.loadNibNamed("TableViewPlaceholderView", owner: nil, options: nil)?[0] as! TableViewPlaceholderView
        view.frame = CGRect(x: 0, y: 0, width: self.tableView.bounds.width, height: max(self.tableView.bounds.height * 0.8, 300))
        return view
    }()
    
    // view model
    var viewModel: SearchViewModel!
    
    // RX
    fileprivate let disposeBag = DisposeBag()
    
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
        
        if #available(iOS 9.0, *) {
            (UIBarButtonItem.appearance(whenContainedInInstancesOf: [UISearchBar.self])).tintColor = UIColor(red: 64/255, green: 196/255, blue: 255/255, alpha: 1.0)
        }
        
        UIBarButtonItem.my_appearanceWhenContained(in: UISearchBar.self).tintColor = UIColor(red: 64/255, green: 196/255, blue: 255/255, alpha: 1.0)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
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
    
    fileprivate func setupRX() {
        
        // user actions observers
        segmentedControl
            .rx.value
            .skip(1)
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: { [weak self] (segment) in
                if segment == 0 { self?.viewModel.segmentedControlState.value = .shown(option: .shouts) }
                else if segment == 1 { self?.viewModel.segmentedControlState.value = .shown(option: .users) }
            })
            .addDisposableTo(disposeBag)
        
        // view model observers
        viewModel
            .sectionViewModel
            .asDriver()
            .drive(onNext: { [weak self] (sectionViewModel) in
                switch sectionViewModel {
                case .categories, .suggestions:
                    self?.tableView.tableHeaderView = nil
                case .loadingPlaceholder:
                    self?.tableView.tableHeaderView = self?.tableViewPlaceholder
                    self?.tableViewPlaceholder.showActivity()
                case .messagePlaceholder(let message, let image):
                    self?.tableView.tableHeaderView = self?.tableViewPlaceholder
                    self?.tableViewPlaceholder.showMessage(message, image: image)
                }
                self?.tableView.reloadData()
            })
            .addDisposableTo(disposeBag)
        
        viewModel
            .segmentedControlState
            .asDriver()
            .distinctUntilChanged( { $0 == $1 })
            .throttle(animationDuration)
            .drive(onNext: { [weak self] (state) in
                if case .hidden = state {
                    self?.showSegmentedControl(false)
                } else {
                    self?.showSegmentedControl(true)
                }
            })
            .addDisposableTo(disposeBag)
    }
    
    fileprivate func setupAppearance() {
        
        // search bar
        let textField: UITextField? = searchBar.searchForView()
        textField?.backgroundColor = UIColor(shoutitColor: .searchBarTextFieldGray)
        searchBar.placeholder = viewModel.searchBarPlaceholder()
        
        // table view
        tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 20, right: 0)
    }
    
    fileprivate func unlockCancelButton() {
        let button: UIButton? = searchBar.searchForView()
        button?.isEnabled = true
    }
    
    fileprivate func registerReusables() {
        self.tableView.register(UINib(nibName: categoryCellReuseId, bundle: nil), forCellReuseIdentifier: categoryCellReuseId)
        self.tableView.register(UINib(nibName: suggestionCellReuseId, bundle: nil), forCellReuseIdentifier: suggestionCellReuseId)
    }
    
    // MARK: - Navigation
    
    @IBAction func unwindToSearch(_ segue: UIStoryboardSegue) {}
    
    // MARK: - Helpers
    
    fileprivate func showSegmentedControl(_ show: Bool) {
        segmentedControlSectionHeightConstraint.constant = show ? 44 : 0
        UIView.animate(withDuration: animationDuration, animations: {
            self.view.layoutIfNeeded()
        }) 
    }
    
    fileprivate func sectionPlaceholderWithType(_ type: SearchSectionViewModel.HeaderType) -> UIView? {
        switch type {
        case .none:
            return nil
        case .titleCentered(let title):
            let headerView = Bundle.main.loadNibNamed("SearchCategoriesHeaderView", owner: nil, options: nil)?.first as! SearchCategoriesHeaderView
            headerView.titleLabel.text = title
            return headerView
        case .titleAlignedLeftWithButton(let title, let buttonTitle):
            let headerView = Bundle.main.loadNibNamed("SearchRecentsHeaderView", owner: nil, options: nil)?.first as! SearchRecentsHeaderView
            headerView.titleLabel.text = title
            headerView.clearButton.setTitle(buttonTitle, for: UIControlState())
            headerView.clearButton.rx.tap.asDriver().drive(onNext: { [weak self] () in
                self?.viewModel.clearRecentSearches()
            }).addDisposableTo(disposeBag)
            return headerView
        }
    }
    
    fileprivate func showSearchResultsForPhrase(_ phrase: String) {
        switch viewModel.segmentedControlState.value {
        case .shown(option: .users):
            flowDelegate?.showUserSearchResultsWithPhrase(phrase)
        default:
            flowDelegate?.showShoutsSearchResultsWithPhrase(phrase, context: viewModel.context)
            break
        }
    }
}

extension SearchViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch viewModel.sectionViewModel.value {
        case .loadingPlaceholder, .messagePlaceholder:
            return 0
        case .categories(let cells, _):
            return cells.count
        case .suggestions(let cells, _):
            return cells.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch viewModel.sectionViewModel.value {
        case .loadingPlaceholder, .messagePlaceholder:
            fatalError()
        case .categories(let cells, _):
            let cellModel = cells[indexPath.row]
            let cell = tableView.dequeueReusableCell(withIdentifier: categoryCellReuseId, for: indexPath) as! SearchCategoryTableViewCell
            cell.titleLabel.text = cellModel.category.name
            
            if let path = cellModel.category.icon, let url = URL(string: path) {
                cell.thumbnailImageView.kf.setImage(with:url, placeholder: nil)
            }
            let numberOfRows = self.tableView(tableView, numberOfRowsInSection: indexPath.section)
            cell.setConstraintForPosition(isLast: indexPath.row == numberOfRows - 1)
            return cell
        case .suggestions(let cells, _):
            let cellModel = cells[indexPath.row]
            let cell = tableView.dequeueReusableCell(withIdentifier: suggestionCellReuseId, for: indexPath) as! SearchSuggestionTableViewCell
            switch cellModel {
            case .apiSuggestion(let phrase):
                cell.titleLabel.text = phrase
                cell.showLeadingIcon(nil)
                cell.accessoryButton.setImage(UIImage.searchFillArrow(), for: UIControlState())
                cell.accessoryButton
                    .rx.tap
                    .asDriver()
                    .drive(onNext: { [weak self] in
                        self?.searchBar.text = cell.titleLabel.text
                    })
                    .addDisposableTo(cell.reuseDisposeBag)
                return cell
            case .recentSearch(let phrase):
                cell.titleLabel.text = phrase
                cell.showLeadingIcon(UIImage.searchRecentsIcon())
                cell.accessoryButton.setImage(UIImage.searchRecentRemoveIcon(), for: UIControlState())
                cell.accessoryButton
                    .rx.tap
                    .asDriver()
                    .drive(onNext: { [weak self] in
                        self?.viewModel.removeRecentSearchPhrase(phrase)
                    })
                    .addDisposableTo(cell.reuseDisposeBag)
                return cell
            }
        }
    }
}

extension SearchViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        switch viewModel.sectionViewModel.value {
        case .loadingPlaceholder, .messagePlaceholder:
            return nil
        case .categories(_, let header):
            return sectionPlaceholderWithType(header)
        case .suggestions(_, let header):
            return sectionPlaceholderWithType(header)
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        switch viewModel.sectionViewModel.value {
        case .loadingPlaceholder, .messagePlaceholder:
            return 0
        case .categories(_, let header):
            guard let headerView = sectionPlaceholderWithType(header) else {
                return 0
            }
            return headerView.frame.height
        case .suggestions(_, let header):
            guard let headerView = sectionPlaceholderWithType(header) else {
                return 0
            }
            return headerView.frame.height
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        switch viewModel.sectionViewModel.value {
        case .categories(let cells, _):
            let model = cells[indexPath.row]
            flowDelegate?.showShoutsSearchResultsWithPhrase(nil, context: .categoryShouts(category: model.category))
        case .suggestions(let cells, _):
            let model = cells[indexPath.row]
            switch model {
            case .apiSuggestion(let phrase):
                viewModel.savePhraseToRecentSearchesIfApplicable(phrase)
                showSearchResultsForPhrase(phrase)
            case .recentSearch(let phrase):
                showSearchResultsForPhrase(phrase)
            }
        default:
            break
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

extension SearchViewController: UISearchBarDelegate {
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        if let text = searchBar.text, text.utf16.count >= viewModel.minimumNumberOfCharactersForAutocompletion {
            self.viewModel.searchState.value = .typing(phrase: text)
        } else {
            self.viewModel.searchState.value = .active
        }
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        self.viewModel.searchState.value = searchText.utf16.count >= viewModel.minimumNumberOfCharactersForAutocompletion ? .typing(phrase: searchText) : .active
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard let phrase = searchBar.text, phrase.utf16.count > 0 else {
            return
        }
        viewModel.savePhraseToRecentSearchesIfApplicable(phrase)
        showSearchResultsForPhrase(phrase)
        searchBar.resignFirstResponder()
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        //self.viewModel.searchState.value = .Inactive
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        self.navigationController?.popViewController(animated: true)
    }
}
