//
//  MyPageCellConfigurator.swift
//  shoutit
//
//  Created by Łukasz Kasperek on 24.06.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import Foundation

class MyPageCellConfigurator {
    
    unowned let controller: UIViewController
    unowned let viewModel: MyPagesViewModel
    
    init(viewModel: MyPagesViewModel, controller: UIViewController) {
        self.viewModel = viewModel
        self.controller = controller
    }
    
    func configureCell(cell: MyPageTableViewCell, withViewModel viewModel: MyPagesCellViewModel) {
        cell.titleLabel.text = viewModel.profile.name
        cell.detaiLabel.text = viewModel.detailTextString()
        cell.listenersCountLabel.text = viewModel.listeningCountString()
        cell.thumbnailImageView.sh_setImageWithURL(viewModel.profile.imagePath?.toURL(), placeholderImage: UIImage.profilePlaceholderImage())
        cell.badgeLabel.hidden = viewModel.notificationsCountString() == nil
        cell.badgeLabel.text = viewModel.notificationsCountString()
    }
}
