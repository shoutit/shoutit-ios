//
//  ConversationViewController+CellConfiguration.swift
//  shoutit
//
//  Created by Łukasz Kasperek on 20.06.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import Foundation
import MapKit
import RxSwift
import RxCocoa

extension ConversationViewController {
    
    func hydrateCell(cell: ConversationCell, withMessage message: Message, previousMessage: Message?) {
        
        doUniversalHydrationWithCell(cell, message: message, previousMessage: previousMessage)
        
        switch cell {
        case let cell as ConversationTextCell:
            cell.urlHandler = { [weak self] path in
                guard let url = NSURL(string: path) else { return }
                if UIApplication.sharedApplication().canOpenURL(url) {
                    UIApplication.sharedApplication().openURL(url)
                }
            }
            cell.messageLabel.text = message.text
            // override issue where url highlighting appears after cell reloads
            cell.messageLabel.setNeedsLayout()
            cell.messageLabel.layoutIfNeeded()
            cell.messageLabel.enabled = true
        case let cell as ConversationPictureCell:
            setThumbWithMessageAttachment(message.attachment(), onCell: cell)
        case let cell as ConversationShoutCell:
            setThumbWithMessageAttachment(message.attachment(), onCell: cell)
            guard let shout = message.attachment()?.shout else {
                cell.pictureImageView.image = nil
                return
            }
            cell.titleLabel.text = shout.title
            cell.subtitleLabel?.text = shout.user?.name
            cell.priceLabel.text = NumberFormatters.priceStringWithPrice(shout.price, currency: shout.currency)
        case let cell as ConversationVideoCell:
            setThumbWithMessageAttachment(message.attachment(), onCell: cell)
        case let cell as ConversationLocationCell:
            cell.activityIndicator?.startAnimating()
            cell.showLabel?.hidden = true
            guard let latitude = message.attachment()?.location?.latitude, longitude = message.attachment()?.location?.longitude else {
                return
            }
            let coordinates = CLLocationCoordinate2DMake(latitude, longitude)
            hydrateLocationCell(cell, withSnapshotAtCoordinates: coordinates)
        case let cell as ConversationProfileCell:
            guard let profile = message.attachment()?.profile else {
                cell.pictureImageView.image = nil
                return
            }
            cell.titleLabel.text = profile.name
            cell.subtitleLabel?.text = String.localizedStringWithFormat(NSLocalizedString("%@ Listeners", comment: ""), NumberFormatters.numberToShortString(profile.listenersCount))
            setThumbWithProfile(profile, onCell: cell)
        default:
            break
        }
    }
}

private extension ConversationViewController {
    
    func doUniversalHydrationWithCell(cell: ConversationCell, message: Message, previousMessage: Message?) {
        if let imageView = cell.avatarImageView {
            cell.hydrateAvatarImageView(imageView, withAvatarPath: message.user?.imagePath)
            if let profile = message.user {
                cell.avatarButton?
                    .rx_tap
                    .asDriver().driveNext{ [weak self] in
                        self?.flowDelegate?.showProfile(profile)
                    }
                    .addDisposableTo(cell.reuseDisposeBag)
            }
        }
        
        if message.isSameSenderAs(previousMessage) {
            cell.hideImageView()
        }
        
        cell.timeLabel?.text = DateFormatters.sharedInstance.hourStringFromEpoch(message.createdAt)
    }
}

private extension ConversationViewController {
    
    func hydrateLocationCell(cell: ConversationLocationCell, withSnapshotAtCoordinates coordinates: CLLocationCoordinate2D) {
        let options = MKMapSnapshotOptions()
        options.size = cell.locationSnapshot.frame.size
        options.region = MKCoordinateRegionMakeWithDistance(coordinates, 1000, 1000)
        let snapshooter = MKMapSnapshotter(options: options)
        snapshooter.startWithCompletionHandler { [weak cell] (snapshot, error) in
            cell?.locationSnapshot.image = snapshot?.image
            cell?.activityIndicator?.stopAnimating()
            cell?.activityIndicator?.hidden = true
            cell?.showLabel?.hidden = false
        }
    }
    
    func setThumbWithMessageAttachment(attachment: MessageAttachment?, onCell cell: ThumbedConversationCell) {
        setThumbWithPath(attachment?.imagePath(), onCell: cell, placeholderImage: UIImage.shoutsPlaceholderImage())
    }
    
    func setThumbWithProfile(profile: Profile, onCell cell: ThumbedConversationCell) {
        setThumbWithPath(profile.imagePath, onCell: cell, placeholderImage: UIImage.profilePlaceholderImage())
    }
    
    func setThumbWithPath(path: String?, onCell cell: ThumbedConversationCell, placeholderImage: UIImage) {
        guard let imagePath = path, let url = NSURL(string: imagePath) where imagePath.utf16.count > 0 else {
            cell.activityIndicator?.stopAnimating()
            cell.activityIndicator?.hidden = true
            cell.pictureImageView.image = UIImage.shoutsPlaceholderImage()
            return
        }
        
        cell.activityIndicator?.startAnimating()
        cell.activityIndicator?.hidden = false
        
        cell.pictureImageView.sh_setImageWithURL(url, placeholderImage: UIImage.shoutsPlaceholderImage(), optionsInfo: nil) {[weak cell] (image, error, cacheType, imageURL) in
            cell?.activityIndicator?.stopAnimating()
            cell?.activityIndicator?.hidden = true
        }
    }
}
