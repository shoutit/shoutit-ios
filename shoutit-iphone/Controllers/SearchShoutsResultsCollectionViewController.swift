//
//  SearchShoutsResultsCollectionViewController.swift
//  shoutit-iphone
//
//  Created by Łukasz Kasperek on 18.03.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import UIKit
import RxSwift
import ShoutitKit

final class SearchShoutsResultsCollectionViewController: UICollectionViewController {
    
    // consts
    enum CellType {
        case shout
        case placeholder
        
        var resuseIdentifier: String {
            switch self {
            case .shout:
                return "ShoutsExpandedCollectionViewCell"
            case .placeholder:
                return "PlaceholderCollectionViewCell"
                
            }
        }
    }
    
    // view model
    var viewModel: SearchShoutsResultsViewModel!
    
    // navigation
    weak var flowDelegate: FlowController?
    
    // RX
    let disposeBag = DisposeBag()
    
    var bookmarksDisposeBag : DisposeBag?
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        precondition(viewModel != nil)
        
        if let layout = collectionView?.collectionViewLayout as? SearchShoutsResultsCollectionViewLayout {
            layout.delegate = self
        }
        
        prepareReusables()
        setupRX()
        viewModel.reloadContent()
        bookmarksDisposeBag = DisposeBag()
    }
    
    // MARK: - Setup
    
    fileprivate func prepareReusables() {
        collectionView?.register(UINib(nibName: "ShoutsExpandedCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: CellType.shout.resuseIdentifier)
        collectionView?.register(UINib(nibName: "PlaceholderCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: CellType.placeholder.resuseIdentifier)
        
        collectionView?.register(UINib(nibName: "SearchShoutsResultsCategoriesHeaderSupplementeryView", bundle: nil), forSupplementaryViewOfKind: SearchShoutsResultsCollectionViewLayout.SectionType.regular.headerKind, withReuseIdentifier: SearchShoutsResultsCollectionViewLayout.SectionType.regular.headerReuseIdentifier)
        collectionView?.register(UINib(nibName: "SearchShoutsResultsShoutsHeaderSupplementeryView", bundle: nil), forSupplementaryViewOfKind: SearchShoutsResultsCollectionViewLayout.SectionType.layoutModeDependent.headerKind, withReuseIdentifier: SearchShoutsResultsCollectionViewLayout.SectionType.layoutModeDependent.headerReuseIdentifier)
    }
    
    fileprivate func setupRX() {
        
        viewModel.shoutsSection.pager.state
            .asDriver()
            .driveNext {[weak self] (state) in
                self?.collectionView?.reloadData()
            }
            .addDisposableTo(disposeBag)
    }
    
    // MARK: - Actions
    
    @IBAction func searchAction() {
        if case .categoryShouts(let category) = viewModel.context {
            flowDelegate?.showSearchInContext(.categoryShouts(category: category))
        } else if self.navigationController?.viewControllers.first === self {
            flowDelegate?.showSearchInContext(.general)
        } else {
            pop()
        }
    }
    
    // MARK: - Helpers
    
    fileprivate func toggleLayout(_ sender: UIButton?) {
        guard let layout = collectionView?.collectionViewLayout as? SearchShoutsResultsCollectionViewLayout else { return }
        let newMode: SearchShoutsResultsCollectionViewLayout.LayoutMode = layout.mode == .grid ? .list : .grid
        let newLayout = SearchShoutsResultsCollectionViewLayout(mode: newMode)
        newLayout.delegate = self
        let image = newMode == .list ? UIImage.shoutsLayoutGridIcon() : UIImage.shoutsLayoutListIcon()
        sender?.setImage(image, for: UIControlState())
        UIView.animate(withDuration: 0.3, animations: {[weak self] in
            self?.collectionView?.collectionViewLayout = newLayout
        }) 
    }
}

// MARK: - UICollectionViewDataSource

extension SearchShoutsResultsCollectionViewController {
    
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        switch viewModel.shoutsSection.pager.state.value {
        case .idle:
            return 0
        case .error, .noContent, .loading:
            return 1
        default:
            return viewModel.shoutsSection.pager.shoutCellViewModels().count
        }
        
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let placeholderCellWithMessage: (_ message: String?, _ activityIndicator: Bool) -> PlcaholderCollectionViewCell = {(message, activity) in
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CellType.placeholder.resuseIdentifier, for: indexPath) as! PlcaholderCollectionViewCell
            cell.setupCellForActivityIndicator(activity)
            cell.placeholderTextLabel.text = message
            return cell
        }
        
        let shoutCellWithModel: ((ShoutCellViewModel) -> UICollectionViewCell) = {cellViewModel in
            
            let cell: ShoutsCollectionViewCell
            
            
            
            cell = collectionView.dequeueReusableCell(withReuseIdentifier: CellType.shout.resuseIdentifier, for: indexPath) as! ShoutsCollectionViewCell
            
            
            if let ad = cellViewModel.ad {
                cell.bindWithAd(Ad: ad)
                ad.registerView(forInteraction: cell, with: self)
            } else if let shout = cellViewModel.shout {
                cell.bindWith(Shout: shout)
                cell.bookmarkButton?.tag = indexPath.item
                cell.bookmarkButton?.addTarget(self, action: #selector(self.switchBookmarkState), for: .touchUpInside)
            }
            
            return cell
        }
        
        switch viewModel.shoutsSection.pager.state.value {
        case .idle:
            fatalError()
        case .error(let error):
            return placeholderCellWithMessage(message: error.sh_message, activityIndicator: false)
        case .noContent:
            return placeholderCellWithMessage(NSLocalizedString("No results were found", comment: "Empty search results placeholder"), false)
        case .loading:
            return placeholderCellWithMessage(nil, true)
        default:
            let cellViewModel = viewModel.shoutsSection.pager.shoutCellViewModels()[indexPath.row]
            return shoutCellWithModel(cellViewModel)
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let sectionType = SearchShoutsResultsCollectionViewLayout.SectionType.layoutModeDependent
        let view = collectionView.dequeueReusableSupplementaryView(ofKind: sectionType.headerKind, withReuseIdentifier: sectionType.headerReuseIdentifier, for: indexPath) as! SearchShoutsResultsShoutsHeaderSupplementeryView
        view.titleLabel.text = viewModel.shoutsSection.sectionTitle()
        view.subtitleLabel.text = viewModel.shoutsSection.resultsCountString()
        view.filterButton.hidden = viewModel.shoutsSection.allowsFiltering() == false
        view.filterButton
            .rx_tap
            .asDriver()
            .driveNext{[weak self] in
                guard let `self` = self else { return }
                self.flowDelegate?.showFiltersWithState(self.viewModel.getFiltersState(), completionBlock: { (filtersState) in
                    self.viewModel.applyFilters(filtersState)
                })
            }
            .addDisposableTo(view.reuseDisposeBag)
        
        view.layoutButton
            .rx_tap
            .asDriver()
            .driveNext{[weak view, weak self] in
                self?.toggleLayout(view?.layoutButton)
            }
            .addDisposableTo(view.reuseDisposeBag)

        return view
    }
}

// MARK: - UICollectionViewDelegate

extension SearchShoutsResultsCollectionViewController {
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        switch viewModel.shoutsSection.pager.state.value {
        case .loadedAllContent(_, _):
            let cellViewModel = viewModel.shoutsSection.pager.shoutCellViewModels()[indexPath.row]
            if let shout = cellViewModel.shout {
                flowDelegate?.showShout(shout)
            }
        case .loaded(_, _, _):
            let cellViewModel = viewModel.shoutsSection.pager.shoutCellViewModels()[indexPath.row]
            if let shout = cellViewModel.shout {
                flowDelegate?.showShout(shout)
            }
        case .loadingMore(_, _, _):
            let cellViewModel = viewModel.shoutsSection.pager.shoutCellViewModels()[indexPath.row]
            if let shout = cellViewModel.shout {
                flowDelegate?.showShout(shout)
            }
        default:
            return
        }
    }
    
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.contentOffset.y + scrollView.bounds.height > scrollView.contentSize.height - 50 {
            viewModel.shoutsSection.fetchNextPage()
        }
    }
}

// MARK: - SearchShoutsResultsCollectionViewLayoutDelegate

extension SearchShoutsResultsCollectionViewController: SearchShoutsResultsCollectionViewLayoutDelegate {
    
    func sectionTypeForSection(_ section: Int) -> SearchShoutsResultsCollectionViewLayout.SectionType {
        return .layoutModeDependent
    }
    
    func lastCellTypeForSection(_ section: Int) -> SearchShoutsResultsCollectionViewLayout.CellType {
        switch viewModel.shoutsSection.pager.state.value {
        case .loaded, .loadingMore, .loadedAllContent:
            return .regular
        default:
            return .placeholder
        }
    }
}

extension SearchShoutsResultsCollectionViewController : Bookmarking {
    func shoutForIndexPath(_ indexPath: IndexPath) -> Shout? {
        let cellViewModel = self.viewModel.shoutsSection.pager.shoutCellViewModels()[indexPath.item]
        return cellViewModel.shout
    }
    
    func indexPathForShout(_ shout: Shout?) -> IndexPath? {
        guard let shout = shout else {
            return nil
        }
        
        if let idx = self.viewModel.shoutsSection.pager.indexOf(shout) {
            return IndexPath(item: idx, section: 0)
        }
        
        return nil
    }
    
    func replaceShoutAndReload(_ shout: Shout) {
        if let idx = self.viewModel.shoutsSection.pager.indexInRealResultsOf(shout) {
            _ = try? self.viewModel.shoutsSection.pager.replaceItemAtIndex(idx, withItem: shout)
        }
    }
    
    @objc func switchBookmarkState(_ sender: UIButton) {
        switchShoutBookmarkShout(sender)
    }
    
}
