//
//  ModelDelegate.swift
//  shoutit-iphone
//
//  Created by Vishal Thakur on 04/11/15.
//  Copyright © 2015 Shoutit. All rights reserved.
//

import Foundation

protocol ModelDelegate {
    
    func modelDidStartLoad(model: Model) ()
    
    func modelDidFinishLoad(model: Model) ()
    
    func model(model: Model, didFailLoadWithError error: NSErrorPointer) ()
    
    func modelDidMakeProgress(model: Model, progress: Int) ()
    
    func modelDidCancelLoad(model: Model) ()
    /**
    * Informs the delegate that the model has changed in some fundamental way.
    *
    * The change is not described specifically, so the delegate must assume that the entire
    * contents of the model may have changed, and react almost as if it was given a new model.
    */
    func modelDidChange(model: Model) ()
    
    func model(model: Model, didUpdateObject object: AnyObject, atIndexPath indexPath: NSIndexPath) ()
    
    func model(model: Model, didInsertObject object: AnyObject, atIndexPath indexPath: NSIndexPath) ()
    
    func model(model: Model, didDeleteObject object: AnyObject, atIndexPath indexPath: NSIndexPath) ()
    /**
    * Informs the delegate that the model is about to begin a multi-stage update.
    *
    * Models should use this method to condense multiple updates into a single visible update.
    * This avoids having the view update multiple times for each change.  Instead, the user will
    * only see the end result of all of your changes when you call modelDidEndUpdates.
    */
    func modelDidBeginUpdates(model: Model) ()
    
    /**
    * Informs the delegate that the model has completed a multi-stage update.
    *
    * The exact nature of the change is not specified, so the receiver should investigate the
    * new state of the model by examining its properties.
    */
    func modelDidEndUpdates(model: Model) ()
    
    /** 
    * Informs delegates that video uploaded 
    */
    
}