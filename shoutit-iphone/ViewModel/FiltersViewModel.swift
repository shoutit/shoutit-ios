//
//  FiltersViewModel.swift
//  shoutit-iphone
//
//  Created by Łukasz Kasperek on 31.03.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import Foundation
import RxSwift

enum FilterOptionDownloadState<T> {
    case Loading
    case Loaded(values: [T])
    case CantLoadContent
}

final class FiltersViewModel {
    
    // RX
    let disposeBag = DisposeBag()
    
    var cellViewModels: [FiltersCellViewModel] {
        didSet {
            
        }
    }
    let categories: Variable<FilterOptionDownloadState<Category>> = Variable(.Loading)
    let sortTypes: Variable<FilterOptionDownloadState<SortType>> = Variable(.Loading)
    
    init() {
        cellViewModels = FiltersViewModel.basicCellViewModels()
        fetchCategories()
        fetchSortTypes()
    }
    
    // MARK: - Action
    
    func resetFilters() {
        
    }
    
    // MARK: - Observables
    
    
    
    // MARK: - Helpers
    
    private func fetchCategories() {
        APIShoutsService.listCategories()
            .subscribe {[weak self] (event) in
                switch event {
                case .Next(let categories):
                    self?.categories.value = .Loaded(values: categories)
                case .Error(let error):
                    debugPrint(error)
                    self?.categories.value = .CantLoadContent
                default:
                    break
                }
            }
            .addDisposableTo(disposeBag)
    }
    
    private func fetchSortTypes() {
        APIShoutsService.getSortTypes()
            .subscribe {[weak self] (event) in
                switch event {
                case .Next(let sortTypes):
                    self?.sortTypes.value = .Loaded(values: sortTypes)
                case .Error(let error):
                    debugPrint(error)
                    self?.sortTypes.value = .CantLoadContent
                default:
                    break
                }
            }
            .addDisposableTo(disposeBag)
    }
    
    private static func basicCellViewModels() -> [FiltersCellViewModel] {
        let shoutTypeCellViewModel = FiltersCellViewModel.ShoutTypeChoice(shoutType: .All)
        let sortTypeCellViewModel = FiltersCellViewModel.SortTypeChoice(sortType: nil)
        let categoryCellViewModel = FiltersCellViewModel.CategoryChoice(category: nil)
        let priceConstraintCellViewModel = FiltersCellViewModel.PriceRestriction(from: nil, to: nil)
        let locationViewModel = FiltersCellViewModel.LocationChoice(location: Account.sharedInstance.user?.location)
        let distanceConstraintViewModel = FiltersCellViewModel.DistanceRestriction(distanceOption: .EntireCountry)
        return [shoutTypeCellViewModel,
                sortTypeCellViewModel,
                categoryCellViewModel,
                priceConstraintCellViewModel,
                locationViewModel,
                distanceConstraintViewModel]
    }
}
