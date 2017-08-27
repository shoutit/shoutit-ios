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
        let view = Bundle.main.loadNibNamed("TableViewPlaceholderView", owner: nil, options: nil)?[0] as! TableViewPlaceholderView
        view.frame = CGRect(x: 0, y: 0, width: self.tableView.bounds.width, height: self.tableView.bounds.height * 0.5)
        return view
    }()
    
    // view model
    var viewModel: PostSignupSuggestionViewModel!
    var sectionViewModel: PostSignupSuggestionsSectionViewModel!
    
    // RX
    fileprivate let disposeBag = DisposeBag()
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // setup layer
        view.layer.borderColor = UIColor.lightGray.cgColor
        view.layer.borderWidth = 0.5
        view.layer.cornerRadius = 10
        
        // register cells
        tableView.register(UINib(nibName: "PostSignupSuggestionsTableViewCell", bundle: nil), forCellReuseIdentifier: "PostSignupSuggestionsTableViewCell")
        
        // configure table view
        tableView.separatorStyle = .none
        
        // configure rx
        setupRX()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        tableView.isScrollEnabled = tableView.contentSize.height > tableView.frame.height
    }
    
    fileprivate func setupRX() {
        
        viewModel.state.asObservable()
            .subscribe(onNext: {[weak self] (state) in
                switch state {
                case .idle:
                    self?.tableView.tableHeaderView = nil
                case .loading:
                    self?.placeholderView.showActivity()
                    self?.tableView.tableHeaderView = self?.placeholderView
                case .contentUnavailable:
                    self?.placeholderView.label.text = NSLocalizedString("Categories unavailable", comment: "Could not load categories placeholder")
                    self?.tableView.tableHeaderView = self?.placeholderView
                case .error(let error):
                    self?.placeholderView.showMessage(error.sh_message)
                    self?.tableView.tableHeaderView = self?.placeholderView
                case .contentLoaded:
                    self?.tableView.tableHeaderView = nil
                }
                
                self?.tableView.reloadData()
            })
            .addDisposableTo(disposeBag)
        
        tableView.rx.itemSelected
            .subscribe(onNext: {[unowned self] (indexPath) in
                let cellViewModel = self.sectionViewModel.cells[indexPath.row]
                cellViewModel.selected = !cellViewModel.selected
                self.tableView.reloadData()
            })
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
        let cell = tableView.dequeueReusableCell(withIdentifier: "PostSignupSuggestionsTableViewCell", for: indexPath as IndexPath) as! PostSignupSuggestionsTableViewCell
        cell.nameLabel.text = cellViewModel.item.suggestionTitle
        
        cell.thumbnailImageView.sh_setImageWithURL(cellViewModel.item.thumbnailURL, placeholderImage: cellViewModel.item.userType == .Page ? UIImage.squareAvatarPagePlaceholder() : UIImage.squareAvatarPlaceholder())
        
        
        let image = cellViewModel.selected ? UIImage.suggestionAccessoryViewSelected() : UIImage.suggestionAccessoryView()
        cell.listenButton.setImage(image, for: .normal)
        
        cell.reuseDisposeBag = DisposeBag()
        cell.listenButton.rx.tap.flatMapFirst({ () -> Observable<(successMessage: String?, error: Error?)> in
            return cellViewModel.listen()
        }).subscribe(onNext:{[weak self] (successMessage, error) in
            if let successMessage = successMessage {
                self?.showSuccessMessage(successMessage)
            } else if let error = error {
                self?.showError(error)
            }
            self?.tableView.reloadData()
            }).addDisposableTo(cell.reuseDisposeBag!)
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let view = Bundle.main.loadNibNamed("PostSignupSuggestionsSectionHeader", owner: nil, options: nil)?.first as! PostSignupSuggestionsSectionHeader
        view.sectionTitleLabel.text = sectionViewModel.section.title
        
        return view
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 44
    }
}
