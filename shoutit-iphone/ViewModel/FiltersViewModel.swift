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

struct FiltersState {
    
    enum Editing {
        case Enabled
        case Disabled
    }
    let shoutType: (ShoutType?, Editing)
    let sortType: (SortType?, Editing)
    let category: (Category?, Editing)
    let minimumPrice: (Int?, Editing)
    let maximumPrice: (Int?, Editing)
    let location: (Address?, Editing)
    let withinDistance: (Int?, Editing)
    let filters: [Filter : [FilterValue]]?
    
    init(shoutType: (ShoutType?, FieldState) = (nil, .Enabled),
         sortType: (SortType?, FieldState) = (nil, .Enabled),
         category: (Category?, FieldState) = (nil, .Enabled),
         minimumPrice: (Int?, FieldState) = (nil, .Enabled),
         maximumPrice: (Int?, FieldState) = (nil, .Enabled),
         location: (Address?, FieldState) = (nil, .Enabled),
         withinDistance: (Int?, FieldState) = (nil, .Enabled),
         filters: [Filter : [FilterValue]]? = nil)
    {
        self.shoutType = shoutType
        self.sortType = sortType
        self.category = category
        self.minimumPrice = minimumPrice
        self.maximumPrice = maximumPrice
        self.location = location
        self.withinDistance = withinDistance
        self.filters = filters
    }
    
    func composeParams() -> FilteredShoutsParams {
        return FilteredShoutsParams(country: location.0?.country,
                                    state: location.0?.state,
                                    city: location.0?.city,
                                    shoutType: shoutType.0,
                                    category: category.0?.slug,
                                    minimumPrice: minimumPrice.0 == nil ? nil : minimumPrice.0! * 100,
                                    maximumPrice: maximumPrice.0 == nil ? nil : maximumPrice.0! * 100,
                                    withinDistance: withinDistance.0,
                                    entireCountry: withinDistance.0 == nil,
                                    sort: sortType.0,
                                    filters: filters)
    }
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
    
    lazy var shoutTypeOptions: [FiltersCellViewModel.ShoutTypeFilterOption] = {
        return [.All, .Specific(shoutType: .Offer), .Specific(shoutType: .Request)]
    }()
    
    init(filtersState: FiltersState) {
        self.filtersState = filtersState
        cellViewModels = basicCellViewModels()
        fetchCategories()
        fetchSortTypes()
    }
    
    // MARK: - Action
    
    func resetFilters() {
        cellViewModels = resetCellViewModels()
        reloadSubject.onNext()
    }
    
    func extendViewModelsWithFilters(filters: [Filter]) {
        let basicViewModels = self.cellViewModels[0..<basicCellViewModels().count]
        let filterCellViewModels = filters.map{FiltersCellViewModel.FilterValueChoice(filter: $0, selectedValues: [])}
        self.cellViewModels = basicViewModels + filterCellViewModels
        reloadSubject.onNext()
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
        var filters: [Filter : [FilterValue]] = [:]
        
        for cellViewModel in cellViewModels {
            switch cellViewModel {
            case .ShoutTypeChoice(let shoutTypeOption):
                if case .Specific(let type) = shoutTypeOption {
                    shoutType = type
                }
            case .SortTypeChoice(let sortType):
                sort = sortType
            case .CategoryChoice(let category):
                category = category
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
                filters[filter] = selectedValues
            }
        }
        
        return FiltersState(shoutType: (shoutType, filtersState.shoutType.1),
                            sortType: (sortType, filtersState.sortType.1),
                            category: (category, filtersState.category.1),
                            minimumPrice: (minimumPrice, filtersState.minimumPrice.1),
                            maximumPrice: (maximumPrice, filtersState.maximumPrice.1),
                            location: (location, filtersState.location.1),
                            withinDistance: (distance, filtersState.withinDistance.1),
                            filters: filters)
    }
    
    func handleSortDidLoad() {
        for case (let index, .SortTypeChoice(nil)) in cellViewModels.enumerate() {
            cellViewModels[index] = .SortTypeChoice(sortType: sortTypes.value.first)
        }
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
        let shoutTypeCellViewModel: FiltersCellViewModel
        let sortTypeCellViewModel: FiltersCellViewModel
        let categoryCellViewModel: FiltersCellViewModel = .CategoryChoice(category: filtersState.category.0)
        let priceConstraintCellViewModel: FiltersCellViewModel = .PriceRestriction(from: filtersState.minimumPrice.0, to: filtersState.maximumPrice.0)
        let locationViewModel: FiltersCellViewModel = .LocationChoice(location: filtersState.location.0)
        let distanceConstraintViewModel: FiltersCellViewModel
        
        if case (let shoutType?, _) = filtersState.shoutType {
            shoutTypeCellViewModel = .ShoutTypeChoice(shoutType: .Specific(shoutType: shoutType))
        } else {
            shoutTypeCellViewModel = .ShoutTypeChoice(shoutType: .All)
        }
        
        if case (let sortType?, _) = filtersState.sortType {
            sortTypeCellViewModel = .SortTypeChoice(sortType: sortType)
        } else if case .Loaded(let sortTypes) = sortTypes.value {
            sortTypeCellViewModel = .SortTypeChoice(sortType: sortTypes.first)
        } else {
            sortTypeCellViewModel = .SortTypeChoice(sortType: nil)
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
        
        if case (let shoutType?, .Disabled) = filtersState.shoutType {
            shoutTypeCellViewModel = .ShoutTypeChoice(shoutType: .Specific(shoutType: shoutType))
        } else {
            shoutTypeCellViewModel = .ShoutTypeChoice(shoutType: .All)
        }
        
        if case (let sortType?, .Disabled) = filtersState.sortType {
            sortTypeCellViewModel = .SortTypeChoice(sortType: sortType)
        } else if case .Loaded(let sortTypes) = sortTypes.value {
            sortTypeCellViewModel = .SortTypeChoice(sortType: sortTypes.first)
        } else {
            sortTypeCellViewModel = .SortTypeChoice(sortType: nil)
        }
        
        if case (let category?, .Disabled) = filtersState.category {
            categoryCellViewModel = .CategoryChoice(category: category)
        } else {
            categoryCellViewModel = .CategoryChoice(category: nil)
        }
        
        if case ((let min, .Disabled), (let max, .Disabled)) = (filtersState.minimumPrice, filtersState.maximumPrice) {
            priceConstraintCellViewModel = .PriceRestriction(from: min, to: max)
        } else {
            priceConstraintCellViewModel = .PriceRestriction(from: nil, to: nil)
        }
        
        if case (let location?, .Disabled) = filtersState.location {
            locationViewModel = .LocationChoice(location: location)
        } else {
            locationViewModel = .LocationChoice(location: nil)
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
