//
//  HomeStackView.swift
//  shoutit
//
//  Created by Piotr Bernad on 29/08/16.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import UIKit

class HomeStackView: UIScrollView {

    @IBOutlet var mainStackView : UIStackView!

    @IBOutlet var navigationStackView : UIStackView!
    
    // discover
    @IBOutlet var discoverHeaderStack : UIStackView!
    @IBOutlet var discoverCollectionView : UICollectionView!
    
    // pages
    @IBOutlet var pagesHeaderStack : UIStackView!
    @IBOutlet var pagesCollectionView : UICollectionView!
    
    // chats
    @IBOutlet var chatsHeaderStack : UIStackView!
    @IBOutlet var chatsCollectionView : UICollectionView!
    
    // trending shouts
    @IBOutlet var trendingHeaderStack : UIStackView!
    @IBOutlet var trendingCollectionView : UICollectionView!
    
    // search
    @IBOutlet var searchTextField : UITextField!
    
    
}
