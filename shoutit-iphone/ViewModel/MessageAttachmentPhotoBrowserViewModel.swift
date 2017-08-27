//
//  MessageAttachmentPhotoBrowserViewModel.swift
//  shoutit-iphone
//
//  Created by Łukasz Kasperek on 17.05.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import Foundation
import RxSwift
import ShoutitKit

class MessageAttachmentPhotoBrowserViewModel: NSObject {

    let pageSize = 20
    let conversation: ShoutitKit.Conversation
    
    fileprivate let disposeBag = DisposeBag()
    let reloadSubject: PublishSubject<Void> = PublishSubject()
    fileprivate(set) var requestDisposeBag: DisposeBag = DisposeBag()
    fileprivate(set) var state: Variable<PagedViewModelState<MessageAttachment, Int, MessageAttachment>> = Variable(.idle)
    fileprivate(set) var cellViewModels: [MessageAttachmentPhotoBrowserCellViewModel]?
    fileprivate(set) var thumbnailCellViewModels: [MessageAttachmentPhotoBrowserCellViewModel]?
    fileprivate(set) var numberOfResults: Int? {
        didSet {
            guard let number = numberOfResults, oldValue == nil else { return }
            hydrateCellViewModelsArrayWithNumberOfItems(number)
            reloadSubject.onNext()
        }
    }
    
    init(conversation: ShoutitKit.Conversation) {
        self.conversation = conversation
        super.init()
        observeLoadingState()
    }
    
    func loadContent() {
        state.value = .loading
        fetchPage(1)
    }
    
    func fetchNextPage() {
        if case .loadedAllContent = state.value { return }
        guard case .loaded(let cells, let page, _) = state.value else { return }
        let pageToLoad = page + 1
        self.state.value = .loadingMore(cells: cells, currentPage: page, loadingPage: pageToLoad)
        fetchPage(pageToLoad)
    }
}

private extension MessageAttachmentPhotoBrowserViewModel {
    
    func fetchPage(_ page: Int) {
        
        requestDisposeBag = DisposeBag()
        
        createFetchPageObservableForPage(page)
            .subscribe {[weak self] (event) in
                switch event {
                case .next(let results):
                    self?.appendItems(results, forPage: page)
                case .error(let error):
                    assert(false, error.sh_message)
                    self?.state.value = .error(error)
                default:
                    break
                }
            }
            .addDisposableTo(requestDisposeBag)
    }
    
    func createFetchPageObservableForPage(_ page: Int) -> Observable<PagedResults<MessageAttachment>> {
        return APIChatsService.getAttachmentsForConversationWithId(conversation.id, params: PageParams(page: page, pageSize: pageSize))
    }
    
    func appendItems(_ results: PagedResults<MessageAttachment>, forPage page: Int) {
        
        defer {
            numberOfResults = results.count ?? numberOfResults
        }
        let items = results.results.filter{($0.images ?? []).count > 0 || ($0.videos ?? []).count > 0}
        let lastPageDidLoad = results.nextPath == nil
        
        if case .loadingMore(var cells, _, let loadingPage) = self.state.value, loadingPage == page {
            cells += items
            if lastPageDidLoad {
                state.value = .loadedAllContent(cells: cells, page: page)
            } else {
                state.value = .loaded(cells: cells, page: page, lastPageResults: results)
            }
            return
        }
        
        assert(page == 1)
        
        if items.count == 0 {
            state.value = .noContent
            return
        }
        
        if lastPageDidLoad {
            state.value = .loadedAllContent(cells: items, page: page)
        } else {
            state.value = .loaded(cells: items, page: page, lastPageResults: results)
        }
    }
    
    func observeLoadingState() {
        
        state.asObservable()
            .subscribe(onNext: {[weak self] (status) in
                switch status {
                case .loaded(let attachments, _, _):
                    self?.refreshViewModelsWithAttachments(attachments)
                case .loadedAllContent(let attachments, _):
                    self?.refreshViewModelsWithAttachments(attachments)
                default:
                    break
                }
            })
            .addDisposableTo(disposeBag)
    }
    
    func refreshViewModelsWithAttachments(_ attachments: [MessageAttachment]) {
        guard let cellViewModels = self.cellViewModels, let thumbnailCellViewModels = self.thumbnailCellViewModels else { return }
        let zipped = zip(zip(attachments, cellViewModels), thumbnailCellViewModels).map {($0.0.0, $0.0.1, $0.1)}
        for (attachment, cellViewModel, thumbnailCellViewModel) in zipped {
            cellViewModel.attachment = attachment
            thumbnailCellViewModel.attachment = attachment
        }
    }
}

private extension MessageAttachmentPhotoBrowserViewModel {
    
    func hydrateCellViewModelsArrayWithNumberOfItems(_ number: Int) {
        let models = state.value.getCellViewModels() ?? []
        let nilsToAppend = number - models.count
        let nils = [MessageAttachment?](repeating: nil, count: nilsToAppend)
        let hydratedArray = models.map{Optional.some($0)} + nils
        cellViewModels = hydratedArray.map{MessageAttachmentPhotoBrowserCellViewModel(attachment: $0, isThumbnail: false, parent: self)}
        thumbnailCellViewModels = hydratedArray.map{MessageAttachmentPhotoBrowserCellViewModel(attachment: $0, isThumbnail: true, parent: self)}
    }
}

extension MessageAttachmentPhotoBrowserViewModel: MWPhotoBrowserDelegate {
    
    func numberOfPhotosInPhotoBrowser(_ photoBrowser: MWPhotoBrowser!) -> UInt {
        return UInt(cellViewModels?.count ?? 0)
    }
    
    func photoBrowser(_ photoBrowser: MWPhotoBrowser!, photoAtIndex index: UInt) -> MWPhotoProtocol! {
        return cellViewModels?[Int(index)]
    }
    
    func photoBrowser(_ photoBrowser: MWPhotoBrowser!, thumbPhotoAtIndex index: UInt) -> MWPhotoProtocol! {
        return thumbnailCellViewModels?[Int(index)]
    }
}
