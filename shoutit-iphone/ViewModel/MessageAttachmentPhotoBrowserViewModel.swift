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
        let pageSize = 50
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
        guard let photos = pager.getCellViewModels() else {return nil}
        let mwPhotos = photos.flatMap{$0.mwPhoto()}
        let i = Int(index)
        guard mwPhotos.count < i else { return nil }
        return mwPhotos[i]
    }
    
    func photoBrowser(photoBrowser: MWPhotoBrowser!, thumbPhotoAtIndex index: UInt) -> MWPhotoProtocol! {
        guard let photos = pager.getCellViewModels() else {return nil}
        let mwPhotos = photos.flatMap{$0.thumbnailMwPhoto()}
        let i = Int(index)
        guard mwPhotos.count < i else { return nil }
        return mwPhotos[i]
    }
}
