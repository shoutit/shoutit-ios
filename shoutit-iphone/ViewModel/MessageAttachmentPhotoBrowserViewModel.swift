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
    

    let conversation: Conversation
    let pager: NumberedPagePager<MessageAttachmentPhotoBrowserCellViewModel, MessageAttachment>
    
    init(conversation: Conversation) {
        let pageSize = 30
        self.conversation = conversation
        self.pager = NumberedPagePager(
            itemToCellViewModelBlock: {MessageAttachmentPhotoBrowserCellViewModel(attachment: $0)},
            cellViewModelToItemBlock: {$0.attachment},
            fetchItemObservableFactory: { (page) -> Observable<PagedResults<MessageAttachment>> in
                return APIChatsService.getAttachmentsForConversationWithId(conversation.id, params: PageParams(page: page, pageSize: pageSize))
            },
            pageSize: pageSize
        )
        super.init()
        pager.itemExclusionRule = {($0.images ?? []).count == 0 && ($0.videos ?? []).count == 0}
    }
}

extension MessageAttachmentPhotoBrowserViewModel: MWPhotoBrowserDelegate {
    
    func numberOfPhotosInPhotoBrowser(photoBrowser: MWPhotoBrowser!) -> UInt {
        return UInt(pager.numberOfResults ?? 0)
    }
    
    func photoBrowser(photoBrowser: MWPhotoBrowser!, photoAtIndex index: UInt) -> MWPhotoProtocol! {
        return photoWithCellViewModels(Int(index)) {$0.mwPhoto()}
    }
    
    func photoBrowser(photoBrowser: MWPhotoBrowser!, thumbPhotoAtIndex index: UInt) -> MWPhotoProtocol! {
        return photoWithCellViewModels(Int(index)) {$0.thumbnailMwPhoto()}
    }
    
    func photoBrowser(photoBrowser: MWPhotoBrowser!, didDisplayPhotoAtIndex index: UInt) {
        print("DISPLAYED INDEX: \(index)")
    }
    
    private func photoWithCellViewModels(index: Int, block: (MessageAttachmentPhotoBrowserCellViewModel -> MWPhoto?)) -> MWPhoto? {
        guard let photos = pager.getCellViewModels() else { return nil }
        let mwPhotos = photos.flatMap(block)
        guard mwPhotos.count > index else {
            //pager.fetchNextPage()
            return nil
        }
        return mwPhotos[index]
    }
}
