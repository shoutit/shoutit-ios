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
    
    var cellViewModels: [FiltersCellViewModel] = [] {
        didSet {
            
        }
    }
    let reloadSubject: PublishSubject<Void> = PublishSubject()
    let categories: Variable<FilterOptionDownloadState<Category>> = Variable(.Loading)
    let sortTypes: Variable<FilterOptionDownloadState<SortType>> = Variable(.Loading)
    
    // consts
    lazy var distanceRestrictionOptions: [FiltersCellViewModel.DistanceRestrictionFilterOption] = {
        return [
            .Distance(kilometers: 1),
            .Distance(kilometers: 2),
            .Distance(kilometers: 3),
            .Distance(kilometers: 5),
            .Distance(kilometers: 7),
            .Distance(kilometers: 10),
            .Distance(kilometers: 15),
            .Distance(kilometers: 20),
            .Distance(kilometers: 30),
            .Distance(kilometers: 60),
            .Distance(kilometers: 100),
            .Distance(kilometers: 200),
            .Distance(kilometers: 300),
            .Distance(kilometers: 400),
            .Distance(kilometers: 500),
            .EntireCountry
        ]
    }()
    
    lazy var shoutTypeOptions: [FiltersCellViewModel.ShoutTypeFilterOption] = {
        return [.All, .Specific(shoutType: .Offer), .Specific(shoutType: .Request)]
    }()
    
    init() {
        cellViewModels = basicCellViewModels()
        fetchCategories()
        fetchSortTypes()
    }
    
    // MARK: - Action
    
    func resetFilters() {
        cellViewModels = basicCellViewModels()
        reloadSubject.onNext()
    }
    
    func extendViewModelsWithFilters(filters: [Filter]) {
        let basicViewModels = self.cellViewModels[0..<basicCellViewModels().count]
        let filterCellViewModels = filters.map{FiltersCellViewModel.FilterValueChoice(filter: $0, selectedValues: [])}
        self.cellViewModels = basicViewModels + filterCellViewModels
        reloadSubject.onNext()
    }
    
    // MARK: - Public helpers
    
    func distanceRestrictionOptionForSliderValue(value: Float) -> FiltersCellViewModel.DistanceRestrictionFilterOption {
        let steps = sliderValueStepsForDistanceRestrictionOptions()
        for (index, rangeEndValue) in steps.enumerate() {
            if value <= rangeEndValue {
                return distanceRestrictionOptions[index]
            }
        }
        return .EntireCountry
    }
    
    func sliderValueForDistanceRestrictionOption(option: FiltersCellViewModel.DistanceRestrictionFilterOption) -> Float {
        for (index, distanceRestrictionOption) in distanceRestrictionOptions.enumerate() {
            if distanceRestrictionOption == option {
                return sliderValueStepsForDistanceRestrictionOptions()[index]
            }
        }
        return 1
    }
}

private extension FiltersViewModel {
    
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
}

private extension FiltersViewModel {
    
    private func basicCellViewModels() -> [FiltersCellViewModel] {
        let shoutTypeCellViewModel = FiltersCellViewModel.ShoutTypeChoice(shoutType: .All)
        let sortTypeCellViewModel: FiltersCellViewModel
        if case .Loaded(let sortTypes) = sortTypes.value {
            sortTypeCellViewModel = FiltersCellViewModel.SortTypeChoice(sortType: sortTypes.first)
        } else {
            sortTypeCellViewModel = FiltersCellViewModel.SortTypeChoice(sortType: nil)
        }
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

private extension FiltersViewModel {
    
    private func sliderValueStepsForDistanceRestrictionOptions() -> [Float] {
        let singleStep = 1.0 / Float(distanceRestrictionOptions.count)
        return Array(count: distanceRestrictionOptions.count, repeatedValue: singleStep).reduce([]) { (currentArray, singleStepValue) -> Array<Float> in
            return currentArray + [(currentArray.last ?? 0) + singleStepValue]
        }
    }
}
