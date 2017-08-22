//
//  BookmarksCollectionViewController.swift
//  shoutit
//
//  Created by Piotr Bernad on 29/06/16.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import UIKit

final class BookmarksCollectionViewController: ShoutsCollectionViewController {

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.viewModel.reloadContent()
    }
}
