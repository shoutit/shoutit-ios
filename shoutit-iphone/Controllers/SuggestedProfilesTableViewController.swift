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
    fileprivate let disposeBag = DisposeBag()
    
    lazy var placeholderView: TableViewPlaceholderView = {[unowned self] in
        let view = Bundle.main.loadNibNamed("TableViewPlaceholderView", owner: nil, options: nil)?[0] as! TableViewPlaceholderView
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
        tableView.register(UINib(nibName: "PostSignupSuggestionsTableViewCell", bundle: nil), forCellReuseIdentifier: "PostSignupSuggestionsTableViewCell")

    }
    
    func title(forEmptyDataSet scrollView: UIScrollView!) -> NSAttributedString! {
        let attributes : [String: AnyObject] = [NSFontAttributeName: UIFont.systemFont(ofSize: 18)]
        
        switch viewModel.state.value {
        case .loading:
            return NSAttributedString(string: NSLocalizedString("Loading suggestions", comment: ""), attributes: attributes)
        case .idle:
            return NSAttributedString(string: NSLocalizedString("Loading suggestions", comment: ""), attributes: attributes)
        case .contentUnavailable:
            return NSAttributedString(string: self.sectionViewModel.noContentTitle, attributes: attributes)
        case .contentLoaded:
            return NSAttributedString(string: self.sectionViewModel.noContentTitle, attributes: attributes)
        case .error(let error):
            return NSAttributedString(string: (error as NSError).localizedDescription, attributes: attributes)
        }
        
    }
    
    fileprivate func setupRX() {
        
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
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 58
    }
    
    // MARK: - UITableViewDataSource
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        guard case LoadingState.contentLoaded = viewModel.state.value else {
            return 0
        }
        
        guard sectionViewModel.cells.count > 0 else {
            return 0
        }
        
        
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard case LoadingState.contentLoaded = viewModel.state.value else {
            return 0
        }
        
        return sectionViewModel.cells.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard case LoadingState.contentLoaded = viewModel.state.value else {
            fatalError()
        }
        
        let cellViewModel = sectionViewModel.cells[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "PostSignupSuggestionsTableViewCell", for: indexPath) as! PostSignupSuggestionsTableViewCell
        
        cell.nameLabel.text = cellViewModel.item.suggestionTitle
        cell.thumbnailImageView.sh_setImageWithURL(cellViewModel.item.thumbnailURL, placeholderImage: UIImage.squareAvatarPlaceholder())
        
        let placeholder : UIImage?
        
        if cellViewModel.item.userType == .Page {
            placeholder = UIImage.squareAvatarPagePlaceholder()
        } else {
            placeholder = UIImage.squareAvatarPlaceholder()
        }
        
        cell.thumbnailImageView.sh_setImageWithURL(cellViewModel.item.thumbnailURL, placeholderImage: placeholder)
        
        let image = cellViewModel.selected ? UIImage.suggestionAccessoryViewSelected() : UIImage.suggestionAccessoryView()
        cell.listenButton.setImage(image, for: UIControlState())
        
        cell.reuseDisposeBag = DisposeBag()
        cell.listenButton.rx_tap.flatMapFirst({ () -> Observable<(successMessage: String?, error: ErrorProtocol?)> in
            return cellViewModel.listen()
        }).subscribeNext({[weak self] (successMessage, error) in
            if let successMessage = successMessage {
                self?.showSuccessMessage(successMessage)
                
            } else if let error = error {
                self?.showError(error)
            }
            self?.tableView.reloadData()
            }).addDisposableTo(cell.reuseDisposeBag!)
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sectionViewModel.section.title
    }
    
}
