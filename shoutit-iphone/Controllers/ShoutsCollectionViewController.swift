//
//  ShoutsCollectionViewController.swift
//  shoutit-iphone
//
//  Created by Łukasz Kasperek on 07.04.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import UIKit
import RxSwift
import ShoutitKit

class ShoutsCollectionViewController: UICollectionViewController {

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
    
    let refreshControl = UIRefreshControl()
    
    var viewModel: ShoutsCollectionViewModel!
    
    // navigation
    weak var flowDelegate: FlowController?
    
    // RX
    let disposeBag = DisposeBag()
    var bookmarksDisposeBag : DisposeBag?
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        precondition(viewModel != nil)
        navigationItem.titleView = UIImageView(image: UIImage(named: "logo_navbar_white"))
        
        if let layout = collectionView?.collectionViewLayout as? SearchShoutsResultsCollectionViewLayout {
            layout.delegate = self
        }
        
        prepareReusables()
        setupRX()
        viewModel.reloadContent()
        bookmarksDisposeBag = DisposeBag()
    
        
        refreshControl.tintColor = UIColor.darkGray
        refreshControl.addTarget(self, action: #selector(reload), for: .valueChanged)
        
        self.collectionView?.addSubview(refreshControl)
        self.collectionView?.alwaysBounceVertical = true
    }
    
    func reload() {
        self.viewModel.reloadContent()
    }
    
    // MARK: - Setup
    
    fileprivate func prepareReusables() {
        collectionView?.register(UINib(nibName: "ShoutsExpandedCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: CellType.shout.resuseIdentifier)
        collectionView?.register(UINib(nibName: "PlaceholderCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: CellType.placeholder.resuseIdentifier)
        collectionView?.register(UINib(nibName: "ShoutsSectionHeader", bundle: nil), forSupplementaryViewOfKind: SearchShoutsResultsCollectionViewLayout.SectionType.layoutModeDependent.headerKind, withReuseIdentifier: SearchShoutsResultsCollectionViewLayout.SectionType.layoutModeDependent.headerReuseIdentifier)
    }
    
    fileprivate func setupRX() {
        
        viewModel.pager.state
            .asDriver()
            .drive(onNext: { [weak self] (state) in
                
                switch state {
                case .loading: self?.refreshControl.beginRefreshing()
                case .loadedAllContent(_,_):
                    self?.refreshControl.endRefreshing()
                    self?.collectionView?.reloadData()
                case .loaded(_,_,_):
                    self?.refreshControl.endRefreshing()
                    self?.collectionView?.reloadData()
                case .error(_):
                    self?.refreshControl.endRefreshing()
                case .loadingMore(_,_,_): break;
                case .noContent:
                    self?.refreshControl.endRefreshing()
                    self?.collectionView?.reloadData()
                default: break;
                }
            })
            .addDisposableTo(disposeBag)
    }
    
    // MARK: - Actions
    
    @IBAction func searchAction() {
        flowDelegate?.showSearchInContext(.general)
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

extension ShoutsCollectionViewController {
    
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        switch viewModel.pager.state.value {
        case .idle:
            return 0
        case .error, .noContent, .loading:
            return 1
        default:
            return self.viewModel.pager.shoutCellViewModels().count
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
            
            if let shout = cellViewModel.shout {
                cell.bindWith(Shout: shout)
                cell.bookmarkButton?.tag = indexPath.item
                cell.bookmarkButton?.addTarget(self, action: #selector(self.switchBookmarkState), for: .touchUpInside)
            } else if let ad = cellViewModel.ad {
                cell.bindWithAd(Ad: ad)
                ad.registerView(forInteraction: cell, with: self)
            }
            
            return cell
        }
        
        switch viewModel.pager.state.value {
        case .idle:
            fatalError()
        case .error(let error):
            return placeholderCellWithMessage(error.sh_message, false)
        case .noContent:
            return placeholderCellWithMessage(self.viewModel.noContentMessage(), false)
        case .loading:
            return placeholderCellWithMessage(nil, true)
        default:
            let cellViewModel = self.viewModel.pager.shoutCellViewModels()[indexPath.row]
            return shoutCellWithModel(cellViewModel)
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let sectionType = SearchShoutsResultsCollectionViewLayout.SectionType.layoutModeDependent
        let view = collectionView.dequeueReusableSupplementaryView(ofKind: sectionType.headerKind, withReuseIdentifier: sectionType.headerReuseIdentifier, for: indexPath) as! ShoutsSectionHeader
        view.titleLabel.text = viewModel.sectionTitle()
        view.subtitleLabel.text = viewModel.resultsCountString()
        view.backgroundColor = viewModel.headerBackgroundColor()
        view.setSubtitleHidden(viewModel.subtitleHidden())
        view.filterButton
            .rx.tap
            .asDriver()
            .drive(onNext: { [weak self] in
                self?.flowDelegate?.showFiltersWithState((self?.viewModel.getFiltersState())!, completionBlock: { (state) in
                    self?.viewModel.applyFilters(state)
                })
            })
            .addDisposableTo(view.reuseDisposeBag)
        
        view.layoutButton
            .rx.tap
            .asDriver()
            .drive(onNext: {[weak view, weak self] in
                self?.toggleLayout(view?.layoutButton)
            })
            .addDisposableTo(view.reuseDisposeBag)
        
        return view
    }
}

// MARK: - UICollectionViewDelegate

extension ShoutsCollectionViewController {
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let models = self.viewModel.pager.shoutCellViewModels()
        
        guard indexPath.item < models.count else {
            return
        }
        
        let cellViewModel = models[indexPath.item]
        
        if let shout = cellViewModel.shout {
            flowDelegate?.showShout(shout)
        }
    }
    
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.contentOffset.y + scrollView.bounds.height > scrollView.contentSize.height - 50 {
            viewModel.fetchNextPage()
        }
    }
}

// MARK: - SearchShoutsResultsCollectionViewLayoutDelegate

extension ShoutsCollectionViewController: SearchShoutsResultsCollectionViewLayoutDelegate {
    
    func sectionTypeForSection(_ section: Int) -> SearchShoutsResultsCollectionViewLayout.SectionType {
        return .layoutModeDependent
    }
    
    func lastCellTypeForSection(_ section: Int) -> SearchShoutsResultsCollectionViewLayout.CellType {
        switch viewModel.pager.state.value {
        case .loaded, .loadingMore, .loadedAllContent, .refreshing:
            return .regular
        default:
            return .placeholder
        }
    }
}

// MARK - Bookmarking

extension ShoutsCollectionViewController : Bookmarking {
    func shoutForIndexPath(_ indexPath: IndexPath) -> Shout? {
        let cellViewModel = self.viewModel.pager.shoutCellViewModels()[indexPath.item]
        return cellViewModel.shout
    }
    
    func indexPathForShout(_ shout: Shout?) -> IndexPath? {
        guard let shout = shout else {
            return nil
        }
        
        if let idx = self.viewModel.pager.indexOf(shout) {
            return IndexPath(item: idx, section: 0)
        }
        
        return nil
    }
    
    func replaceShoutAndReload(_ shout: Shout) {
        if let idx = self.viewModel.pager.indexInRealResultsOf(shout) {
            _ = try? self.viewModel.pager.replaceItemAtIndex(idx, withItem: shout)
        }
    }
    
    @objc func switchBookmarkState(_ sender: UIButton) {
        switchShoutBookmarkShout(sender)
    }

}
