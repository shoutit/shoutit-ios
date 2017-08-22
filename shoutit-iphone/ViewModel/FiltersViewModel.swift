//
//  FiltersViewModel.swift
//  shoutit-iphone
//
//  Created by Łukasz Kasperek on 31.03.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import Foundation
import RxSwift
import ShoutitKit

enum FilterOptionDownloadState<T> {
    case loading
    case loaded(values: [T])
    case cantLoadContent
}

final class FiltersViewModel {
    
    // RX
    let disposeBag = DisposeBag()
    
    var cellViewModels: [FiltersCellViewModel] = []
    let filtersState: FiltersState
    let reloadSubject: PublishSubject<Void> = PublishSubject()
    let categories: Variable<FilterOptionDownloadState<ShoutitKit.Category>> = Variable(.loading)
    let sortTypes: Variable<FilterOptionDownloadState<SortType>> = Variable(.loading)
    
    // consts
    lazy var distanceRestrictionOptions: [FiltersState.DistanceRestriction] = {
        return [
            .distance(kilometers: 1),
            .distance(kilometers: 2),
            .distance(kilometers: 3),
            .distance(kilometers: 5),
            .distance(kilometers: 7),
            .distance(kilometers: 10),
            .distance(kilometers: 15),
            .distance(kilometers: 20),
            .distance(kilometers: 30),
            .distance(kilometers: 60),
            .distance(kilometers: 100),
            .distance(kilometers: 200),
            .distance(kilometers: 300),
            .distance(kilometers: 400),
            .distance(kilometers: 500),
            .entireCountry
        ]
    }()
    
    init(filtersState: FiltersState) {
        self.filtersState = filtersState
        cellViewModels = initialCellViewModels()
        fetchCategories()
        fetchSortTypes()
    }
    
    // MARK: - Action
    
    func resetFilters() {
        cellViewModels = resetCellViewModels()
        reloadSubject.onNext()
    }
    
    // MARK: - Settings filters
    
    func changeLocationToLocation(_ location: Address) {
        for case (let index, .locationChoice) in cellViewModels.enumerated() {
            cellViewModels[index] = .locationChoice(location: location)
            reloadSubject.onNext()
            return
        }
    }
    
    func changeValuesForFilter(_ filter: Filter, toValues values: [FilterValue]) {
        for case (let index, .filterValueChoice(filter, _)) in cellViewModels.enumerated() {
            cellViewModels[index] = .filterValueChoice(filter: filter, selectedValues: values)
            reloadSubject.onNext()
            return
        }
    }
    
    func changeCategoryToCategory(_ category: ShoutitKit.Category?) {
        for case (let index, .categoryChoice(_, true, let loaded)) in cellViewModels.enumerated() {
            cellViewModels[index] = .categoryChoice(category: category, enabled: true, loaded: loaded)
            extendViewModelsWithFilters(category?.filters ?? [])
            reloadSubject.onNext()
            return
        }
    }
    
    func changeShoutTypeToType(_ shoutType: ShoutType?) {
        for case (let index, .shoutTypeChoice) in cellViewModels.enumerated() {
            cellViewModels[index] = .shoutTypeChoice(shoutType: shoutType)
            reloadSubject.onNext()
            return
        }
    }
    
    func changeSortTypeToType(_ sortType: SortType) {
        for case (let index, .sortTypeChoice(_, let loaded)) in cellViewModels.enumerated() {
            cellViewModels[index] = .sortTypeChoice(sortType: sortType, loaded: loaded)
            reloadSubject.onNext()
            return
        }
    }
    
    func changeMinimumPriceTo(_ price: Int?) {
        for case (let index, .priceRestriction(_, let to)) in cellViewModels.enumerated() {
            cellViewModels[index] = .priceRestriction(from: price, to: to)
            return
        }
    }
    
    func changeMaximumPriceTo(_ price: Int?) {
        for case (let index, .priceRestriction(let from, _)) in cellViewModels.enumerated() {
            cellViewModels[index] = .priceRestriction(from: from, to: price)
            return
        }
    }
    
    // MARK: - Public helpers
    
    func composeFiltersState() -> FiltersState {
        var shoutType: ShoutType?
        var sort: SortType?
        var category: ShoutitKit.Category?
        var minimumPrice: Int?
        var maximumPrice: Int?
        var location: Address?
        var distanceRestriction: FiltersState.DistanceRestriction?
        var filters: [(Filter, [FilterValue])] = []
        
        for cellViewModel in cellViewModels {
            switch cellViewModel {
            case .shoutTypeChoice(let type):
                shoutType = type
            case .sortTypeChoice(let sortType, _):
                sort = sortType
            case .categoryChoice(let cat, _, _):
                category = cat
            case .priceRestriction(let from, let to):
                minimumPrice = from
                maximumPrice = to
            case .locationChoice(let address):
                location = address
            case .distanceRestriction(let distanceOption):
                distanceRestriction = distanceOption
            case .filterValueChoice(let filter, let selectedValues):
                filters.append((filter, selectedValues))
            }
        }
        
        return FiltersState(shoutType: (shoutType, filtersState.shoutType.1),
                            sortType: (sort, filtersState.sortType.1),
                            category: (category, filtersState.category.1),
                            minimumPrice: (minimumPrice, filtersState.minimumPrice.1),
                            maximumPrice: (maximumPrice, filtersState.maximumPrice.1),
                            location: (location, filtersState.location.1),
                            withinDistance: (distanceRestriction, filtersState.withinDistance.1),
                            filters: filters)
    }
    
    func distanceRestrictionOptionForSliderValue(_ value: Float) -> FiltersState.DistanceRestriction {
        let steps = sliderValueStepsForDistanceRestrictionOptions()
        for (index, rangeEndValue) in steps.enumerated() {
            if value <= rangeEndValue {
                return distanceRestrictionOptions[index]
            }
        }
        return .entireCountry
    }
    
    func sliderValueForDistanceRestrictionOption(_ option: FiltersState.DistanceRestriction) -> Float {
        for (index, distanceRestrictionOption) in distanceRestrictionOptions.enumerated() {
            if distanceRestrictionOption == option {
                return sliderValueStepsForDistanceRestrictionOptions()[index]
            }
        }
        return 1
    }
}

private extension FiltersViewModel {
    
    func fetchCategories() {
        APIShoutsService.listCategories()
            .subscribe {[weak self] (event) in
                switch event {
                case .next(let categories):
                    self?.categories.value = .loaded(values: categories)
                    self?.reloadSubject.onNext()
                case .Error(let error):
                    debugPrint(error)
                    self?.categories.value = .cantLoadContent
                default:
                    break
                }
            }
            .addDisposableTo(disposeBag)
    }
    
    func fetchSortTypes() {
        APIShoutsService.getSortTypes()
            .subscribe {[weak self] (event) in
                switch event {
                case .next(let sortTypes):
                    self?.sortTypes.value = .loaded(values: sortTypes)
                    self?.handleSortDidLoad()
                    self?.reloadSubject.onNext()
                case .Error(let error):
                    debugPrint(error)
                    self?.sortTypes.value = .cantLoadContent
                default:
                    break
                }
            }
            .addDisposableTo(disposeBag)
    }
}

private extension FiltersViewModel {
    
    func initialCellViewModels() -> [FiltersCellViewModel] {
        
        if let filters = filtersState.filters {
            return basicCellViewModels() + filters.map{FiltersCellViewModel.filterValueChoice(filter: $0.0, selectedValues: $0.1)}
        } else if case (let category?, _) = filtersState.category {
            return basicCellViewModels() + (category.filters ?? []).map{FiltersCellViewModel.filterValueChoice(filter: $0, selectedValues: [])}
        }
        return basicCellViewModels()
    }
    
    func basicCellViewModels() -> [FiltersCellViewModel] {
        let shoutTypeCellViewModel: FiltersCellViewModel
        let sortTypeCellViewModel: FiltersCellViewModel
        let categoryCellViewModel: FiltersCellViewModel = .categoryChoice(category: filtersState.category.0,
                                                                          enabled: filtersState.category.1 == .enabled,
                                                                          loaded: categoriesLoaded)
        let priceConstraintCellViewModel: FiltersCellViewModel = .priceRestriction(from: filtersState.minimumPrice.0, to: filtersState.maximumPrice.0)
        let locationViewModel: FiltersCellViewModel = .locationChoice(location: filtersState.location.0)
        let distanceConstraintViewModel: FiltersCellViewModel
        
        if case (let shoutType?, _) = filtersState.shoutType {
            shoutTypeCellViewModel = .shoutTypeChoice(shoutType: shoutType)
        } else {
            shoutTypeCellViewModel = .shoutTypeChoice(shoutType: nil)
        }
        
        if case (let sortType?, _) = filtersState.sortType {
            sortTypeCellViewModel = .sortTypeChoice(sortType: sortType, loaded: sortTypesLoaded)
        } else if case .loaded(let sortTypes) = sortTypes.value {
            sortTypeCellViewModel = .sortTypeChoice(sortType: sortTypes.first, loaded: sortTypesLoaded)
        } else {
            sortTypeCellViewModel = .sortTypeChoice(sortType: nil, loaded: sortTypesLoaded)
        }
        
        if case (let distanceRestriction?, _) = filtersState.withinDistance {
            distanceConstraintViewModel = .distanceRestriction(distanceOption: distanceRestriction)
        } else {
            distanceConstraintViewModel = .distanceRestriction(distanceOption: .entireCountry)
        }
        
        return [shoutTypeCellViewModel,
                sortTypeCellViewModel,
                categoryCellViewModel,
                priceConstraintCellViewModel,
                locationViewModel,
                distanceConstraintViewModel]
    }
    
    func resetCellViewModels() -> [FiltersCellViewModel] {
        let shoutTypeCellViewModel: FiltersCellViewModel
        let sortTypeCellViewModel: FiltersCellViewModel
        let categoryCellViewModel: FiltersCellViewModel
        let priceConstraintCellViewModel: FiltersCellViewModel
        let locationViewModel: FiltersCellViewModel
        let distanceConstraintViewModel: FiltersCellViewModel
        var filterViewModels: [FiltersCellViewModel] = []
        
        if case (let shoutType?, .disabled) = filtersState.shoutType {
            shoutTypeCellViewModel = .shoutTypeChoice(shoutType: shoutType)
        } else {
            shoutTypeCellViewModel = .shoutTypeChoice(shoutType: nil)
        }
        
        if case (let sortType?, .disabled) = filtersState.sortType {
            sortTypeCellViewModel = .sortTypeChoice(sortType: sortType, loaded: sortTypesLoaded)
        } else if case .loaded(let sortTypes) = sortTypes.value {
            sortTypeCellViewModel = .sortTypeChoice(sortType: sortTypes.first, loaded: sortTypesLoaded)
        } else {
            sortTypeCellViewModel = .sortTypeChoice(sortType: nil, loaded: sortTypesLoaded)
        }
        
        if case (let category?, .disabled) = filtersState.category {
            categoryCellViewModel = .categoryChoice(category: category, enabled: false, loaded: categoriesLoaded)
            filterViewModels = (category.filters ?? []).map{FiltersCellViewModel.filterValueChoice(filter: $0, selectedValues: [])}
        } else {
            categoryCellViewModel = .categoryChoice(category: nil, enabled: true, loaded: categoriesLoaded)
        }
        
        if case ((let min, .disabled), (let max, .disabled)) = (filtersState.minimumPrice, filtersState.maximumPrice) {
            priceConstraintCellViewModel = .priceRestriction(from: min, to: max)
        } else {
            priceConstraintCellViewModel = .priceRestriction(from: nil, to: nil)
        }
        
        if case (let location?, .disabled) = filtersState.location {
            locationViewModel = .locationChoice(location: location)
        } else {
            locationViewModel = .locationChoice(location: Account.sharedInstance.user?.location)
        }
        
        if case (let distanceRestriction?, .disabled) = filtersState.withinDistance {
            distanceConstraintViewModel = .distanceRestriction(distanceOption: distanceRestriction)
        } else {
            distanceConstraintViewModel = .distanceRestriction(distanceOption: .entireCountry)
        }
        
        return [shoutTypeCellViewModel,
                sortTypeCellViewModel,
                categoryCellViewModel,
                priceConstraintCellViewModel,
                locationViewModel,
                distanceConstraintViewModel] + filterViewModels
    }
    
    func extendViewModelsWithFilters(_ filters: [Filter]) {
        let basicViewModels = self.cellViewModels[0..<basicCellViewModels().count]
        let filterCellViewModels = filters.map{FiltersCellViewModel.filterValueChoice(filter: $0, selectedValues: [])}
        self.cellViewModels = basicViewModels + filterCellViewModels
    }
    
    func handleSortDidLoad() {
        for case (let index, .sortTypeChoice(nil, let loaded)) in cellViewModels.enumerated() {
            guard case .loaded(let values) = sortTypes.value else { assertionFailure(); return; }
            cellViewModels[index] = .sortTypeChoice(sortType: values.first, loaded: loaded)
            reloadSubject.onNext()
        }
    }
}

private extension FiltersViewModel {
    
    func sliderValueStepsForDistanceRestrictionOptions() -> [Float] {
        let singleStep = 1.0 / Float(distanceRestrictionOptions.count)
        return Array(repeating: singleStep, count: distanceRestrictionOptions.count).reduce([]) { (currentArray, singleStepValue) -> Array<Float> in
            return currentArray + [(currentArray.last ?? 0) + singleStepValue]
        }
    }
}

private extension FiltersViewModel {
    
    func categoriesLoaded() -> Bool {
        if case .loaded = categories.value {
            return true
        }
        return false
    }
    
    func sortTypesLoaded() -> Bool {
        if case .loaded = sortTypes.value {
            return true
        }
        return false
    }
}
