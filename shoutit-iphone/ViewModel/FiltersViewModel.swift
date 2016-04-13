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
    
    var cellViewModels: [FiltersCellViewModel] = []
    let filtersState: FiltersState
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
    
    func changeLocationToLocation(location: Address) {
        for case (let index, .LocationChoice) in cellViewModels.enumerate() {
            cellViewModels[index] = .LocationChoice(location: location)
            reloadSubject.onNext()
            return
        }
    }
    
    func changeValuesForFilter(filter: Filter, toValues values: [FilterValue]) {
        for case (let index, .FilterValueChoice(filter, _)) in cellViewModels.enumerate() {
            cellViewModels[index] = .FilterValueChoice(filter: filter, selectedValues: values)
            reloadSubject.onNext()
            return
        }
    }
    
    func changeCategoryToCategory(category: Category?) {
        for case (let index, .CategoryChoice(_, true, let loaded)) in cellViewModels.enumerate() {
            cellViewModels[index] = .CategoryChoice(category: category, enabled: true, loaded: loaded)
            extendViewModelsWithFilters(category?.filters ?? [])
            reloadSubject.onNext()
            return
        }
    }
    
    func changeShoutTypeToType(shoutType: ShoutType?) {
        for case (let index, .ShoutTypeChoice) in cellViewModels.enumerate() {
            cellViewModels[index] = .ShoutTypeChoice(shoutType: shoutType)
            reloadSubject.onNext()
            return
        }
    }
    
    func changeSortTypeToType(sortType: SortType) {
        for case (let index, .SortTypeChoice(_, let loaded)) in cellViewModels.enumerate() {
            cellViewModels[index] = .SortTypeChoice(sortType: sortType, loaded: loaded)
            reloadSubject.onNext()
            return
        }
    }
    
    func changeMinimumPriceTo(price: Int?) {
        for case (let index, .PriceRestriction(_, let to)) in cellViewModels.enumerate() {
            cellViewModels[index] = .PriceRestriction(from: price, to: to)
            return
        }
    }
    
    func changeMaximumPriceTo(price: Int?) {
        for case (let index, .PriceRestriction(let from, _)) in cellViewModels.enumerate() {
            cellViewModels[index] = .PriceRestriction(from: from, to: price)
            return
        }
    }
    
    // MARK: - Public helpers
    
    func composeFiltersState() -> FiltersState {
        var shoutType: ShoutType?
        var sort: SortType?
        var category: Category?
        var minimumPrice: Int?
        var maximumPrice: Int?
        var location: Address?
        var distance: Int?
        var filters: [(Filter, [FilterValue])] = []
        
        for cellViewModel in cellViewModels {
            switch cellViewModel {
            case .ShoutTypeChoice(let type):
                shoutType = type
            case .SortTypeChoice(let sortType, _):
                sort = sortType
            case .CategoryChoice(let cat, _, _):
                category = cat
            case .PriceRestriction(let from, let to):
                minimumPrice = from
                maximumPrice = to
            case .LocationChoice(let address):
                location = address
            case .DistanceRestriction(let distanceOption):
                switch distanceOption {
                case .Distance(let kilometers):
                    distance = kilometers
                case .EntireCountry:
                    distance = nil
                }
            case .FilterValueChoice(let filter, let selectedValues):
                filters.append((filter, selectedValues))
            }
        }
        
        return FiltersState(shoutType: (shoutType, filtersState.shoutType.1),
                            sortType: (sort, filtersState.sortType.1),
                            category: (category, filtersState.category.1),
                            minimumPrice: (minimumPrice, filtersState.minimumPrice.1),
                            maximumPrice: (maximumPrice, filtersState.maximumPrice.1),
                            location: (location, filtersState.location.1),
                            withinDistance: (distance, filtersState.withinDistance.1),
                            filters: filters)
    }
    
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
                    self?.reloadSubject.onNext()
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
                    self?.handleSortDidLoad()
                    self?.reloadSubject.onNext()
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
    
    private func initialCellViewModels() -> [FiltersCellViewModel] {
        
        if let filters = filtersState.filters {
            return basicCellViewModels() + filters.map{FiltersCellViewModel.FilterValueChoice(filter: $0.0, selectedValues: $0.1)}
        } else if case (let category?, _) = filtersState.category {
            return basicCellViewModels() + (category.filters ?? []).map{FiltersCellViewModel.FilterValueChoice(filter: $0, selectedValues: [])}
        }
        return basicCellViewModels()
    }
    
    private func basicCellViewModels() -> [FiltersCellViewModel] {
        let shoutTypeCellViewModel: FiltersCellViewModel
        let sortTypeCellViewModel: FiltersCellViewModel
        let categoryCellViewModel: FiltersCellViewModel = .CategoryChoice(category: filtersState.category.0,
                                                                          enabled: filtersState.category.1 == .Enabled,
                                                                          loaded: categoriesLoaded)
        let priceConstraintCellViewModel: FiltersCellViewModel = .PriceRestriction(from: filtersState.minimumPrice.0, to: filtersState.maximumPrice.0)
        let locationViewModel: FiltersCellViewModel = .LocationChoice(location: filtersState.location.0)
        let distanceConstraintViewModel: FiltersCellViewModel
        
        if case (let shoutType?, _) = filtersState.shoutType {
            shoutTypeCellViewModel = .ShoutTypeChoice(shoutType: shoutType)
        } else {
            shoutTypeCellViewModel = .ShoutTypeChoice(shoutType: nil)
        }
        
        if case (let sortType?, _) = filtersState.sortType {
            sortTypeCellViewModel = .SortTypeChoice(sortType: sortType, loaded: sortTypesLoaded)
        } else if case .Loaded(let sortTypes) = sortTypes.value {
            sortTypeCellViewModel = .SortTypeChoice(sortType: sortTypes.first, loaded: sortTypesLoaded)
        } else {
            sortTypeCellViewModel = .SortTypeChoice(sortType: nil, loaded: sortTypesLoaded)
        }
        
        if case (let distance?, _) = filtersState.withinDistance {
            distanceConstraintViewModel = .DistanceRestriction(distanceOption: .Distance(kilometers: distance))
        } else {
            distanceConstraintViewModel = .DistanceRestriction(distanceOption: .EntireCountry)
        }
        
        return [shoutTypeCellViewModel,
                sortTypeCellViewModel,
                categoryCellViewModel,
                priceConstraintCellViewModel,
                locationViewModel,
                distanceConstraintViewModel]
    }
    
    private func resetCellViewModels() -> [FiltersCellViewModel] {
        let shoutTypeCellViewModel: FiltersCellViewModel
        let sortTypeCellViewModel: FiltersCellViewModel
        let categoryCellViewModel: FiltersCellViewModel
        let priceConstraintCellViewModel: FiltersCellViewModel
        let locationViewModel: FiltersCellViewModel
        let distanceConstraintViewModel: FiltersCellViewModel
        var filterViewModels: [FiltersCellViewModel] = []
        
        if case (let shoutType?, .Disabled) = filtersState.shoutType {
            shoutTypeCellViewModel = .ShoutTypeChoice(shoutType: shoutType)
        } else {
            shoutTypeCellViewModel = .ShoutTypeChoice(shoutType: nil)
        }
        
        if case (let sortType?, .Disabled) = filtersState.sortType {
            sortTypeCellViewModel = .SortTypeChoice(sortType: sortType, loaded: sortTypesLoaded)
        } else if case .Loaded(let sortTypes) = sortTypes.value {
            sortTypeCellViewModel = .SortTypeChoice(sortType: sortTypes.first, loaded: sortTypesLoaded)
        } else {
            sortTypeCellViewModel = .SortTypeChoice(sortType: nil, loaded: sortTypesLoaded)
        }
        
        if case (let category?, .Disabled) = filtersState.category {
            categoryCellViewModel = .CategoryChoice(category: category, enabled: false, loaded: categoriesLoaded)
            filterViewModels = (category.filters ?? []).map{FiltersCellViewModel.FilterValueChoice(filter: $0, selectedValues: [])}
        } else {
            categoryCellViewModel = .CategoryChoice(category: nil, enabled: true, loaded: categoriesLoaded)
        }
        
        if case ((let min, .Disabled), (let max, .Disabled)) = (filtersState.minimumPrice, filtersState.maximumPrice) {
            priceConstraintCellViewModel = .PriceRestriction(from: min, to: max)
        } else {
            priceConstraintCellViewModel = .PriceRestriction(from: nil, to: nil)
        }
        
        if case (let location?, .Disabled) = filtersState.location {
            locationViewModel = .LocationChoice(location: location)
        } else {
            locationViewModel = .LocationChoice(location: Account.sharedInstance.user?.location)
        }
        
        if case (let distance?, .Disabled) = filtersState.withinDistance {
            distanceConstraintViewModel = .DistanceRestriction(distanceOption: .Distance(kilometers: distance))
        } else {
            distanceConstraintViewModel = .DistanceRestriction(distanceOption: .EntireCountry)
        }
        
        return [shoutTypeCellViewModel,
                sortTypeCellViewModel,
                categoryCellViewModel,
                priceConstraintCellViewModel,
                locationViewModel,
                distanceConstraintViewModel] + filterViewModels
    }
    
    private func extendViewModelsWithFilters(filters: [Filter]) {
        let basicViewModels = self.cellViewModels[0..<basicCellViewModels().count]
        let filterCellViewModels = filters.map{FiltersCellViewModel.FilterValueChoice(filter: $0, selectedValues: [])}
        self.cellViewModels = basicViewModels + filterCellViewModels
    }
    
    private func handleSortDidLoad() {
        for case (let index, .SortTypeChoice(nil, let loaded)) in cellViewModels.enumerate() {
            guard case .Loaded(let values) = sortTypes.value else { assertionFailure(); return; }
            cellViewModels[index] = .SortTypeChoice(sortType: values.first, loaded: loaded)
            reloadSubject.onNext()
        }
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

private extension FiltersViewModel {
    
    func categoriesLoaded() -> Bool {
        if case .Loaded = categories.value {
            return true
        }
        return false
    }
    
    func sortTypesLoaded() -> Bool {
        if case .Loaded = sortTypes.value {
            return true
        }
        return false
    }
}
