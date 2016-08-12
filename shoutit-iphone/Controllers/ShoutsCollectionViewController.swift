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
        case Shout
        case Placeholder
        
        var resuseIdentifier: String {
            switch self {
            case .Shout:
                return "ShoutsExpandedCollectionViewCell"
            case .Placeholder:
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
    
        
        refreshControl.tintColor = UIColor.darkGrayColor()
        refreshControl.addTarget(self, action: #selector(reload), forControlEvents: .ValueChanged)
        
        self.collectionView?.addSubview(refreshControl)
        self.collectionView?.alwaysBounceVertical = true
    }
    
    func reload() {
        self.viewModel.reloadContent()
    }
    
    // MARK: - Setup
    
    private func prepareReusables() {
        collectionView?.registerNib(UINib(nibName: "ShoutsExpandedCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: CellType.Shout.resuseIdentifier)
        collectionView?.registerNib(UINib(nibName: "PlaceholderCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: CellType.Placeholder.resuseIdentifier)
        collectionView?.registerNib(UINib(nibName: "ShoutsSectionHeader", bundle: nil), forSupplementaryViewOfKind: SearchShoutsResultsCollectionViewLayout.SectionType.LayoutModeDependent.headerKind, withReuseIdentifier: SearchShoutsResultsCollectionViewLayout.SectionType.LayoutModeDependent.headerReuseIdentifier)
    }
    
    private func setupRX() {
        
        viewModel.pager.state
            .asDriver()
            .driveNext {[weak self] (state) in
                
                switch state {
                case .Loading: self?.refreshControl.beginRefreshing()
                case .LoadedAllContent(_,_):
                    self?.refreshControl.endRefreshing()
                    self?.collectionView?.reloadData()
                case .Loaded(_,_,_):
                    self?.refreshControl.endRefreshing()
                    self?.collectionView?.reloadData()
                case .Error(_):
                    self?.refreshControl.endRefreshing()
                case .LoadingMore(_,_,_): break;
                case .NoContent:
                    self?.refreshControl.endRefreshing()
                    self?.collectionView?.reloadData()
                default: break;
                }
            }
            .addDisposableTo(disposeBag)
    }
    
    // MARK: - Actions
    
    @IBAction func searchAction() {
        flowDelegate?.showSearchInContext(.General)
    }
    
    // MARK: - Helpers
    
    private func toggleLayout(sender: UIButton?) {
        guard let layout = collectionView?.collectionViewLayout as? SearchShoutsResultsCollectionViewLayout else { return }
        let newMode: SearchShoutsResultsCollectionViewLayout.LayoutMode = layout.mode == .Grid ? .List : .Grid
        let newLayout = SearchShoutsResultsCollectionViewLayout(mode: newMode)
        newLayout.delegate = self
        let image = newMode == .List ? UIImage.shoutsLayoutGridIcon() : UIImage.shoutsLayoutListIcon()
        sender?.setImage(image, forState: .Normal)
        UIView.animateWithDuration(0.3) {[weak self] in
            self?.collectionView?.collectionViewLayout = newLayout
        }
    }
}

// MARK: - UICollectionViewDataSource

extension ShoutsCollectionViewController {
    
    override func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        switch viewModel.pager.state.value {
        case .Idle:
            return 0
        case .Error, .NoContent, .Loading:
            return 1
        default:
            return self.viewModel.pager.shoutCellViewModels().count
        }
    }
    
    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        let placeholderCellWithMessage: (message: String?, activityIndicator: Bool) -> PlcaholderCollectionViewCell = {(message, activity) in
            let cell = collectionView.dequeueReusableCellWithReuseIdentifier(CellType.Placeholder.resuseIdentifier, forIndexPath: indexPath) as! PlcaholderCollectionViewCell
            cell.setupCellForActivityIndicator(activity)
            cell.placeholderTextLabel.text = message
            return cell
        }
        
        let shoutCellWithModel: (ShoutCellViewModel -> UICollectionViewCell) = {cellViewModel in
            
            let cell: ShoutsCollectionViewCell
            cell = collectionView.dequeueReusableCellWithReuseIdentifier(CellType.Shout.resuseIdentifier, forIndexPath: indexPath) as! ShoutsCollectionViewCell
            
            if let shout = cellViewModel.shout {
                cell.bindWith(Shout: shout)
                cell.bookmarkButton?.tag = indexPath.item
                cell.bookmarkButton?.addTarget(self, action: #selector(self.switchBookmarkState), forControlEvents: .TouchUpInside)
            } else if let ad = cellViewModel.ad {
                cell.bindWithAd(Ad: ad)
                ad.registerViewForInteraction(cell, withViewController: self)
            }
            
            return cell
        }
        
        switch viewModel.pager.state.value {
        case .Idle:
            fatalError()
        case .Error(let error):
            return placeholderCellWithMessage(message: error.sh_message, activityIndicator: false)
        case .NoContent:
            return placeholderCellWithMessage(message: NSLocalizedString("No results were found", comment: "Empty search results placeholder"), activityIndicator: false)
        case .Loading:
            return placeholderCellWithMessage(message: nil, activityIndicator: true)
        default:
            let cellViewModel = self.viewModel.pager.shoutCellViewModels()[indexPath.row]
            return shoutCellWithModel(cellViewModel)
        }
    }
    
    override func collectionView(collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, atIndexPath indexPath: NSIndexPath) -> UICollectionReusableView {
        let sectionType = SearchShoutsResultsCollectionViewLayout.SectionType.LayoutModeDependent
        let view = collectionView.dequeueReusableSupplementaryViewOfKind(sectionType.headerKind, withReuseIdentifier: sectionType.headerReuseIdentifier, forIndexPath: indexPath) as! ShoutsSectionHeader
        view.titleLabel.text = viewModel.sectionTitle()
        view.subtitleLabel.text = viewModel.resultsCountString()
        view.backgroundColor = viewModel.headerBackgroundColor()
        view.setSubtitleHidden(viewModel.subtitleHidden())
        view.filterButton
            .rx_tap
            .asDriver()
            .driveNext{[unowned self] in
                self.flowDelegate?.showFiltersWithState(self.viewModel.getFiltersState(), completionBlock: { (state) in
                    self.viewModel.applyFilters(state)
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

extension ShoutsCollectionViewController {
    
    override func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        let models = self.viewModel.pager.shoutCellViewModels()
        
        guard indexPath.item < models.count else {
            return
        }
        
        let cellViewModel = models[indexPath.item]
        
        if let shout = cellViewModel.shout {
            flowDelegate?.showShout(shout)
        }
    }
    
    override func scrollViewDidScroll(scrollView: UIScrollView) {
        if scrollView.contentOffset.y + scrollView.bounds.height > scrollView.contentSize.height - 50 {
            viewModel.fetchNextPage()
        }
    }
}

// MARK: - SearchShoutsResultsCollectionViewLayoutDelegate

extension ShoutsCollectionViewController: SearchShoutsResultsCollectionViewLayoutDelegate {
    
    func sectionTypeForSection(section: Int) -> SearchShoutsResultsCollectionViewLayout.SectionType {
        return .LayoutModeDependent
    }
    
    func lastCellTypeForSection(section: Int) -> SearchShoutsResultsCollectionViewLayout.CellType {
        switch viewModel.pager.state.value {
        case .Loaded, .LoadingMore, .LoadedAllContent, .Refreshing:
            return .Regular
        default:
            return .Placeholder
        }
    }
}

// MARK - Bookmarking

extension ShoutsCollectionViewController : Bookmarking {
    func shoutForIndexPath(indexPath: NSIndexPath) -> Shout? {
        let cellViewModel = self.viewModel.pager.shoutCellViewModels()[indexPath.item]
        return cellViewModel.shout
    }
    
    func indexPathForShout(shout: Shout?) -> NSIndexPath? {
        guard let shout = shout else {
            return nil
        }
        
        if let idx = self.viewModel.pager.indexOf(shout) {
            return NSIndexPath(forItem: idx, inSection: 0)
        }
        
        return nil
    }
    
    func replaceShoutAndReload(shout: Shout) {
        if let idx = self.viewModel.pager.indexInRealResultsOf(shout) {
            _ = try? self.viewModel.pager.replaceItemAtIndex(idx, withItem: shout)
        }
    }
    
    @objc func switchBookmarkState(sender: UIButton) {
        switchShoutBookmarkShout(sender)
    }

}
