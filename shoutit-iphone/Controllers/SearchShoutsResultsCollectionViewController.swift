//
//  SearchShoutsResultsCollectionViewController.swift
//  shoutit-iphone
//
//  Created by Łukasz Kasperek on 18.03.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import UIKit
import RxSwift

final class SearchShoutsResultsCollectionViewController: UICollectionViewController {
    
    // consts
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
    
    // view model
    var viewModel: SearchShoutsResultsViewModel!
    
    // navigation
    weak var flowDelegate: FlowController?
    
    // RX
    let disposeBag = DisposeBag()
    
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
    }
    
    // MARK: - Setup
    
    private func prepareReusables() {
        collectionView?.registerNib(UINib(nibName: "ShoutsExpandedCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: CellType.Shout.resuseIdentifier)
        collectionView?.registerNib(UINib(nibName: "PlaceholderCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: CellType.Placeholder.resuseIdentifier)
        
        collectionView?.registerNib(UINib(nibName: "SearchShoutsResultsCategoriesHeaderSupplementeryView", bundle: nil), forSupplementaryViewOfKind: SearchShoutsResultsCollectionViewLayout.SectionType.Regular.headerKind, withReuseIdentifier: SearchShoutsResultsCollectionViewLayout.SectionType.Regular.headerReuseIdentifier)
        collectionView?.registerNib(UINib(nibName: "SearchShoutsResultsShoutsHeaderSupplementeryView", bundle: nil), forSupplementaryViewOfKind: SearchShoutsResultsCollectionViewLayout.SectionType.LayoutModeDependent.headerKind, withReuseIdentifier: SearchShoutsResultsCollectionViewLayout.SectionType.LayoutModeDependent.headerReuseIdentifier)
    }
    
    private func setupRX() {
        
        viewModel.shoutsSection.pager.state
            .asDriver()
            .driveNext {[weak self] (state) in
                self?.collectionView?.reloadData()
            }
            .addDisposableTo(disposeBag)
    }
    
    // MARK: - Actions
    
    @IBAction func searchAction() {
        if case .CategoryShouts(let category) = viewModel.context {
            flowDelegate?.showSearchInContext(.CategoryShouts(category: category))
        } else if self.navigationController?.viewControllers.first === self {
            flowDelegate?.showSearchInContext(.General)
        } else {
            pop()
        }
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

extension SearchShoutsResultsCollectionViewController {
    
    override func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        switch viewModel.shoutsSection.pager.state.value {
        case .Idle:
            return 0
        case .Loaded(let cells, _, _):
            return cells.count
        case .LoadingMore(let cells, _, _):
            return cells.count
        case .LoadedAllContent(let cells, _):
            return cells.count
        case .Refreshing(let cells, _):
            return cells.count
        case .Error, .NoContent, .Loading:
            return 1
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
            cell.bindWith(Shout: cellViewModel.shout)
            return cell
        }
        
        switch viewModel.shoutsSection.pager.state.value {
        case .Idle:
            fatalError()
        case .LoadedAllContent(let cells, _):
            let cellViewModel = cells[indexPath.row]
            return shoutCellWithModel(cellViewModel)
        case .Refreshing(let cells, _):
            let cellViewModel = cells[indexPath.row]
            return shoutCellWithModel(cellViewModel)
        case .Loaded(let cells, _, _):
            let cellViewModel = cells[indexPath.row]
            return shoutCellWithModel(cellViewModel)
        case .LoadingMore(let cells, _, _):
            let cellViewModel = cells[indexPath.row]
            return shoutCellWithModel(cellViewModel)
        case .Error(let error):
            return placeholderCellWithMessage(message: error.sh_message, activityIndicator: false)
        case .NoContent:
            return placeholderCellWithMessage(message: NSLocalizedString("No results were found", comment: "Empty search results placeholder"), activityIndicator: false)
        case .Loading:
            return placeholderCellWithMessage(message: nil, activityIndicator: true)
        }
    }
    
    override func collectionView(collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, atIndexPath indexPath: NSIndexPath) -> UICollectionReusableView {
        let sectionType = SearchShoutsResultsCollectionViewLayout.SectionType.LayoutModeDependent
        let view = collectionView.dequeueReusableSupplementaryViewOfKind(sectionType.headerKind, withReuseIdentifier: sectionType.headerReuseIdentifier, forIndexPath: indexPath) as! SearchShoutsResultsShoutsHeaderSupplementeryView
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
    
    override func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        switch viewModel.shoutsSection.pager.state.value {
        case .LoadedAllContent(let cells, _):
            let cellViewModel = cells[indexPath.row]
            flowDelegate?.showShout(cellViewModel.shout)
        case .Loaded(let cells, _, _):
            let cellViewModel = cells[indexPath.row]
            flowDelegate?.showShout(cellViewModel.shout)
        case .LoadingMore(let cells, _, _):
            let cellViewModel = cells[indexPath.row]
            flowDelegate?.showShout(cellViewModel.shout)
        default:
            return
        }
    }
    
    override func scrollViewDidScroll(scrollView: UIScrollView) {
        if scrollView.contentOffset.y + scrollView.bounds.height > scrollView.contentSize.height - 50 {
            viewModel.shoutsSection.fetchNextPage()
        }
    }
}

// MARK: - SearchShoutsResultsCollectionViewLayoutDelegate

extension SearchShoutsResultsCollectionViewController: SearchShoutsResultsCollectionViewLayoutDelegate {
    
    func sectionTypeForSection(section: Int) -> SearchShoutsResultsCollectionViewLayout.SectionType {
        return .LayoutModeDependent
    }
    
    func lastCellTypeForSection(section: Int) -> SearchShoutsResultsCollectionViewLayout.CellType {
        switch viewModel.shoutsSection.pager.state.value {
        case .Loaded, .LoadingMore, .LoadedAllContent:
            return .Regular
        default:
            return .Placeholder
        }
    }
}
