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
    
    private let disposeBag = DisposeBag()
    let reloadSubject: PublishSubject<Void> = PublishSubject()
    private(set) var requestDisposeBag: DisposeBag = DisposeBag()
    private(set) var state: Variable<LoadableContentState<MessageAttachment, Int, MessageAttachment>> = Variable(.Idle)
    private(set) var cellViewModels: [MessageAttachmentPhotoBrowserCellViewModel]?
    private(set) var thumbnailCellViewModels: [MessageAttachmentPhotoBrowserCellViewModel]?
    private(set) var numberOfResults: Int? {
        didSet {
            guard let number = numberOfResults where oldValue == nil else { return }
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
        state.value = .Loading
        fetchPage(1)
    }
    
    func fetchNextPage() {
        if case .LoadedAllContent = state.value { return }
        guard case .Loaded(let cells, let page, _) = state.value else { return }
        let pageToLoad = page + 1
        self.state.value = .LoadingMore(cells: cells, currentPage: page, loadingPage: pageToLoad)
        fetchPage(pageToLoad)
    }
}

private extension MessageAttachmentPhotoBrowserViewModel {
    
    private func fetchPage(page: Int) {
        
        requestDisposeBag = DisposeBag()
        
        createFetchPageObservableForPage(page)
            .subscribe {[weak self] (event) in
                switch event {
                case .Next(let results):
                    self?.appendItems(results, forPage: page)
                case .Error(let error):
                    assert(false, error.sh_message)
                    self?.state.value = .Error(error)
                default:
                    break
                }
            }
            .addDisposableTo(requestDisposeBag)
    }
    
    private func createFetchPageObservableForPage(page: Int) -> Observable<PagedResults<MessageAttachment>> {
        return APIChatsService.getAttachmentsForConversationWithId(conversation.id, params: PageParams(page: page, pageSize: pageSize))
    }
    
    private func appendItems(results: PagedResults<MessageAttachment>, forPage page: Int) {
        
        defer {
            numberOfResults = results.count ?? numberOfResults
        }
        let items = results.results.filter{($0.images ?? []).count > 0 || ($0.videos ?? []).count > 0}
        let lastPageDidLoad = results.nextPath == nil
        
        if case .LoadingMore(var cells, _, let loadingPage) = self.state.value where loadingPage == page {
            cells += items
            if lastPageDidLoad {
                state.value = .LoadedAllContent(cells: cells, page: page)
            } else {
                state.value = .Loaded(cells: cells, page: page, lastPageResults: results)
            }
            return
        }
        
        assert(page == 1)
        
        if items.count == 0 {
            state.value = .NoContent
            return
        }
        
        if lastPageDidLoad {
            state.value = .LoadedAllContent(cells: items, page: page)
        } else {
            state.value = .Loaded(cells: items, page: page, lastPageResults: results)
        }
    }
    
    private func observeLoadingState() {
        
        state.asObservable()
            .subscribeNext {[weak self] (status) in
                switch status {
                case .Loaded(let attachments, _, _):
                    self?.refreshViewModelsWithAttachments(attachments)
                case .LoadedAllContent(let attachments, _):
                    self?.refreshViewModelsWithAttachments(attachments)
                default:
                    break
                }
            }
            .addDisposableTo(disposeBag)
    }
    
    private func refreshViewModelsWithAttachments(attachments: [MessageAttachment]) {
        guard let cellViewModels = self.cellViewModels, thumbnailCellViewModels = self.thumbnailCellViewModels else { return }
        let zipped = zip(zip(attachments, cellViewModels), thumbnailCellViewModels).map {($0.0.0, $0.0.1, $0.1)}
        for (attachment, cellViewModel, thumbnailCellViewModel) in zipped {
            cellViewModel.attachment = attachment
            thumbnailCellViewModel.attachment = attachment
        }
    }
}

private extension MessageAttachmentPhotoBrowserViewModel {
    
    private func hydrateCellViewModelsArrayWithNumberOfItems(number: Int) {
        let models = state.value.getCellViewModels() ?? []
        let nilsToAppend = number - models.count
        let nils = [MessageAttachment?](count: nilsToAppend, repeatedValue: nil)
        let hydratedArray = models.map{Optional.Some($0)} + nils
        cellViewModels = hydratedArray.map{MessageAttachmentPhotoBrowserCellViewModel(attachment: $0, isThumbnail: false, parent: self)}
        thumbnailCellViewModels = hydratedArray.map{MessageAttachmentPhotoBrowserCellViewModel(attachment: $0, isThumbnail: true, parent: self)}
    }
}

extension MessageAttachmentPhotoBrowserViewModel: MWPhotoBrowserDelegate {
    
    func numberOfPhotosInPhotoBrowser(photoBrowser: MWPhotoBrowser!) -> UInt {
        return UInt(cellViewModels?.count ?? 0)
    }
    
    func photoBrowser(photoBrowser: MWPhotoBrowser!, photoAtIndex index: UInt) -> MWPhotoProtocol! {
        return cellViewModels?[Int(index)]
    }
    
    func photoBrowser(photoBrowser: MWPhotoBrowser!, thumbPhotoAtIndex index: UInt) -> MWPhotoProtocol! {
        return thumbnailCellViewModels?[Int(index)]
    }
}
