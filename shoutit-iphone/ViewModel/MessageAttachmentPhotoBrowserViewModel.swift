//
//  MessageAttachmentPhotoBrowserViewModel.swift
//  shoutit-iphone
//
//  Created by Łukasz Kasperek on 17.05.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import Foundation
import MWPhotoBrowser
import RxSwift

class MessageAttachmentPhotoBrowserViewModel: NSObject {
    
    // consts
    let pageSize = 20
    var requestDisposeBag = DisposeBag()
    var numberOfResults: Int?
    
    //func reloadContent() -> Void
    //func fetchShoutsAtPage(page: Int) -> Observable<PagedResults<Shout>>
}

//extension MessageAttachmentPhotoBrowserViewModel {
//    
//    func reloadContent() {
//        state.value = .Loading
//        fetchPage(1)
//    }
//    
//    func fetchNextPage() {
//        if case .LoadedAllContent = state.value { return }
//        guard case .Loaded(let cells, let page, _) = state.value else { return }
//        let pageToLoad = page + 1
//        self.state.value = .LoadingMore(cells: cells, currentPage: page, loadingPage: pageToLoad)
//        fetchPage(pageToLoad)
//    }
//}
//
//private extension MessageAttachmentPhotoBrowserViewModel {
//    
//    private func fetchPage(page: Int) {
//        
//        requestDisposeBag = DisposeBag()
//        
//        fetchShoutsAtPage(page)
//            .subscribe {[weak self] (event) in
//                switch event {
//                case .Next(let results):
//                    self?.updateViewModelWithResult(results, forPage: page)
//                case .Error(let error):
//                    self?.state.value = .Error(error)
//                default:
//                    break
//                }
//            }
//            .addDisposableTo(requestDisposeBag)
//    }
//    
//    private func updateViewModelWithResult(result: PagedResults<Shout>, forPage page: Int) {
//        
//        numberOfResults = result.count ?? numberOfResults
//        
//        if case .LoadingMore(var cells, _, let loadingPage) = self.state.value where loadingPage == page {
//            cells += result.results.map{ShoutCellViewModel(shout: $0)}
//            if cells.count < pageSize || result.nextPath == nil {
//                state.value = .LoadedAllContent(cells: cells, page: page)
//            } else {
//                state.value = .Loaded(cells: cells, page: page, lastPageResults: result)
//            }
//            return
//        }
//        
//        assert(page == 1)
//        
//        let shouts = result.results
//        if shouts.count == 0 {
//            state.value = .NoContent
//        }
//        
//        let cellViewModels = shouts.map{ShoutCellViewModel(shout: $0)}
//        if shouts.count < pageSize || result.nextPath == nil {
//            state.value = .LoadedAllContent(cells: cellViewModels, page: page)
//        } else {
//            state.value = .Loaded(cells: cellViewModels, page: page, lastPageResults: result)
//        }
//    }
//}
//
//extension MessageAttachmentPhotoBrowserViewModel: MWPhotoBrowserDelegate {
//    
//    func numberOfPhotosInPhotoBrowser(photoBrowser: MWPhotoBrowser!) -> UInt {
//        return UInt(numberOfResults ?? 0)
//    }
//    
//    func photoBrowser(photoBrowser: MWPhotoBrowser!, photoAtIndex index: UInt) -> MWPhotoProtocol! {
//        
//    }
//}
