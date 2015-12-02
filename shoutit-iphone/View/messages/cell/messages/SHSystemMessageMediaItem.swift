//
//  SHSystemMessageMediaItem.swift
//  shoutit-iphone
//
//  Created by Vishal Thakur on 02/12/15.
//  Copyright © 2015 Shoutit. All rights reserved.
//

import UIKit
import JSQMessagesViewController

class SHSystemMessageMediaItem: JSQMediaItem {
    
    private var systemMediaView: UIView?
    private var systemMessage: String?
    
    func prepareView (message: String) {
        self.systemMessage = message
        let winFrame = UIApplication.sharedApplication().keyWindow?.frame
        let label = UILabel()
        label.font = UIFont(name: "HelveticaNeue", size: 12)
        label.textAlignment = NSTextAlignment.Center
        label.textColor = UIColor.grayColor()
        label.backgroundColor = UIColor.clearColor()
        
        label.numberOfLines = 2
        label.text = message
        label.sizeToFit()
        if let width = winFrame?.size.width {
            label.frame = CGRectMake(10 + 36, 0, width - 20, label.frame.size.height)
            self.systemMediaView = UIView(frame: CGRectMake(0, 0, width, label.frame.size.height))
        }
        self.systemMediaView?.addSubview(label)
        self.systemMediaView?.backgroundColor = UIColor.clearColor()
        
    }
    
    override func mediaView() -> UIView! {
        return self.systemMediaView
    }
    
    override func mediaViewDisplaySize() -> CGSize {
        if let frame = self.systemMediaView?.frame {
            return frame.size
        }
        return CGSize(width: 10, height: 10)
    }
}
