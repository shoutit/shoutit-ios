//
//  MessageAttachmentPhotoBrowserCellViewModel.swift
//  shoutit-iphone
//
//  Created by Łukasz Kasperek on 17.05.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import Foundation
import MWPhotoBrowser

struct MessageAttachmentPhotoBrowserCellViewModel {
    let attachment: MessageAttachment
    
    func mwPhoto() -> MWPhoto? {
        guard let type = attachment.type() else { return nil }
        switch type {
        case .ImageAttachment(let path):
            return MWPhoto(URL: path.toURL())
        case .VideoAttachment(let video):
            return MWPhoto(videoURL: video.path.toURL())
        default:
            return nil
        }
    }
    
    func thumbnailMwPhoto() -> MWPhoto? {
        guard let type = attachment.type() else { return nil }
        switch type {
        case .ImageAttachment(let path):
            return MWPhoto(URL: path.toURL()?.imageUrlByAppendingVaraitionComponent(.Small))
        case .VideoAttachment(let video):
            return MWPhoto(videoURL: video.thumbnailPath.toURL()?.imageUrlByAppendingVaraitionComponent(.Small))
        default:
            return nil
        }
    }
}
