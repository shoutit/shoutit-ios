//
//  CreateShoutDetailsSectionViewModel.swift
//  shoutit-iphone
//
//  Created by Łukasz Kasperek on 27.05.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import Foundation
import RxSwift
import ShoutitKit

final class CreateShoutDetailsSectionViewModel: CreateShoutSectionViewModel {
    
    // CreateShoutSectionViewModel
    var title: String {
        return " " + NSLocalizedString("DETAILS", comment: "Create Shout Details Section Title")
    }
    var cellViewModels: [CreateShoutCellViewModel] {
        if hideFilters {
            return internal_cellViewModels
        }
        return internal_cellViewModels + filters.map{CreateShoutCellViewModel.filterChoice(filter: $0)}
    }
    let reloadSubject: PublishSubject<Void> = PublishSubject()
    let hideFilters: Bool
    
    // private
    fileprivate var internal_cellViewModels: [CreateShoutCellViewModel]
    fileprivate unowned var parent: CreateShoutViewModel
    
    fileprivate let disposeBag = DisposeBag()
    let categories : Variable<[ShoutitKit.Category]> = Variable([])
    let currencies : Variable<[Currency]> = Variable([])
    fileprivate(set) var filters : [Filter] = []
    
    init(cellViewModels: [CreateShoutCellViewModel], parent: CreateShoutViewModel, hideFilters: Bool) {
        self.internal_cellViewModels = cellViewModels
        self.parent = parent
        self.hideFilters = hideFilters
        fetchData()
    }
    
    fileprivate func fetchData() {
        fetchCategories()
        fetchCurrencies()
    }
}

extension CreateShoutDetailsSectionViewModel {
    
    func setCategory(_ category: ShoutitKit.Category?) {
        
        parent.shoutParams.filters.value = [:]
        parent.shoutParams.category.value = category
        
        guard let filters = category?.filters else {
            self.filters = []
            return
        }
        self.filters = filters
        
        guard let shout = parent.shoutParams.shout, let shoutFilters = shout.filters else { return }
        
        for filter in filters {
            for fl in shoutFilters {
                if fl == filter {
                    parent.shoutParams.filters.value[fl] = fl.value
                }
            }
        }
        
        reloadSubject.onNext()
    }
}

private extension CreateShoutDetailsSectionViewModel {
    
    func fillCategoryFromShout() {
        guard let shout = parent.shoutParams.shout else { return }
        for cat in self.categories.value {
            if shout.category == cat {
                self.setCategory(cat)
                return
            }
        }
    }
    
    func fillCurrencyFromShout() {
        guard let shout = parent.shoutParams.shout else { return }
        for currency in self.currencies.value {
            if currency.code == shout.currency {
                parent.shoutParams.currency.value = currency
                return
            }
        }
    }
}

private extension CreateShoutDetailsSectionViewModel {
    
    func fetchCurrencies() {
        APIMiscService.requestCurrencies()
            .subscribe {[weak self] (event) in
                switch event {
                case .next(let currencies):
                    self?.currencies.value = currencies
                    self?.fillCurrencyFromShout()
                case .error(let error):
                    print(error)
                default:
                    break
                }
            }
            .addDisposableTo(disposeBag)
    }
    
    func fetchCategories() {
        APIMiscService.requestCategories()
            .subscribe {[weak self] (event) in
                switch event {
                case .next(let categories):
                    self?.categories.value = categories
                    self?.fillCategoryFromShout()
                case .error(let error):
                    print(error)
                default:
                    break
                }
            }
            .addDisposableTo(disposeBag)
    }
}
