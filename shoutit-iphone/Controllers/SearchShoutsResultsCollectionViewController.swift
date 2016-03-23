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
        case ShoutExtended
        case Placeholder
        
        var resuseIdentifier: String {
            switch self {
            case .Shout:
                return "ShoutsCollectionViewCell"
            case .ShoutExtended:
                return "ShoutsExtendedCollectionViewCell"
            case .Placeholder:
                return "PlaceholderCollectionViewCell"
                
            }
        }
    }
    
    // view model
    var viewModel: SearchShoutsResultsViewModel!
    
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
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        viewModel.reloadContent()
    }
    
    // MARK: - Setup
    
    private func prepareReusables() {
        collectionView?.registerNib(UINib(nibName: "ShoutsCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: CellType.Shout.resuseIdentifier)
        collectionView?.registerNib(UINib(nibName: "ShoutsExtendedCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: CellType.ShoutExtended.resuseIdentifier)
        collectionView?.registerNib(UINib(nibName: "PlaceholderCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: CellType.Placeholder.resuseIdentifier)
        
        collectionView?.registerNib(UINib(nibName: "SearchShoutsResultsCategoriesHeaderSupplementeryView", bundle: nil), forSupplementaryViewOfKind: SearchShoutsResultsCollectionViewLayout.SectionType.Regular.headerKind, withReuseIdentifier: SearchShoutsResultsCollectionViewLayout.SectionType.Regular.headerReuseIdentifier)
        collectionView?.registerNib(UINib(nibName: "SearchShoutsResultsShoutsHeaderSupplementeryView", bundle: nil), forSupplementaryViewOfKind: SearchShoutsResultsCollectionViewLayout.SectionType.LayoutModeDependent.headerKind, withReuseIdentifier: SearchShoutsResultsCollectionViewLayout.SectionType.LayoutModeDependent.headerReuseIdentifier)
    }
    
    private func setupRX() {
        
        viewModel.shoutsSection.state
            .asDriver()
            .driveNext {[weak self] (state) in
                self?.collectionView?.reloadData()
            }
            .addDisposableTo(disposeBag)
    }
}

// MARK: - UICollectionViewDataSource

extension SearchShoutsResultsCollectionViewController {
    
    override func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        switch viewModel.shoutsSection.state.value {
        case .Idle:
            return 0
        case .Loaded(let cells, _):
            return cells.count
        case .LoadingMore(let cells, _, _):
            return cells.count
        case .LoadedAllContent(let cells, _):
            return cells.count
        case .Error, .NoContent, .Loading:
            return 1
        }
    }
    
    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        let collectionViewLayoutType = (collectionView.collectionViewLayout as! SearchShoutsResultsCollectionViewLayout).mode
        
        let placeholderCellWithMessage: (message: String?, activityIndicator: Bool) -> PlcaholderCollectionViewCell = {(message, activity) in
            let cell = collectionView.dequeueReusableCellWithReuseIdentifier(CellType.Placeholder.resuseIdentifier, forIndexPath: indexPath) as! PlcaholderCollectionViewCell
            cell.setupCellForActivityIndicator(activity)
            cell.placeholderTextLabel.text = message
            return cell
        }
        
        let shoutCellWithModel: (SearchShoutsResultsShoutCellViewModel -> UICollectionViewCell) = {cellViewModel in
            
            let cell: ShoutsCollectionViewCell
            switch collectionViewLayoutType {
            case .Grid:
                cell = collectionView.dequeueReusableCellWithReuseIdentifier(CellType.Shout.resuseIdentifier, forIndexPath: indexPath) as! ShoutsCollectionViewCell
            case .List:
                cell = collectionView.dequeueReusableCellWithReuseIdentifier(CellType.ShoutExtended.resuseIdentifier, forIndexPath: indexPath) as! ShoutsCollectionViewCell
            }
            cell.hydrateWithShout(cellViewModel.shout)
            return cell
        }
        
        switch viewModel.shoutsSection.state.value {
        case .Idle:
            fatalError()
        case .LoadedAllContent(let cells, _):
            let cellViewModel = cells[indexPath.row]
            return shoutCellWithModel(cellViewModel)
        case .Loaded(let cells, _):
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
        view.filterButton
            .rx_tap
            .asDriver()
            .driveNext{
                
            }
            .addDisposableTo(view.reuseDisposeBag)
        
        view.layoutButton
            .rx_tap
            .asDriver()
            .driveNext{
                
            }
            .addDisposableTo(view.reuseDisposeBag)

        return view
    }
}

// MARK: - UICollectionViewDelegate

extension SearchShoutsResultsCollectionViewController {
    
    override func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        
    }
    
    override func scrollViewDidScroll(scrollView: UIScrollView) {
        if scrollView.contentOffset.y > scrollView.contentSize.height - 50 {
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
        switch viewModel.shoutsSection.state.value {
        case .Loaded, .LoadingMore:
            return .Regular
        default:
            return .Placeholder
        }
    }
}
