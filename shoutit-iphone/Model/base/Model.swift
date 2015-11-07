//
//  Model.swift
//  shoutit-iphone
//
//  Created by Vishal Thakur on 04/11/15.
//  Copyright © 2015 Shoutit. All rights reserved.
//

import Foundation

class Model: NSObject {
    
    
    class func prependUrl(url: NSString, withPrefix prefix: NSString) -> String {
        let baseUrl: NSString = url.substringToIndex(url.rangeOfString(url.lastPathComponent).location)
        let newFilename: String = prefix.stringByAppendingString(url.lastPathComponent)
        return baseUrl.stringByAppendingString(newFilename)

    }
    /**
    * An array of objects that conform to the ModelDelegate protocol.
    */
    var delegates: NSMutableArray = []
    /**
    * An array of objects that conform to the ModelDelegate protocol.
    */
    ///////////////////let isEmpty = Bool()
    /**
    *
    * Adds a modelDelegate to the delegates array
    */
    func addModelDelegate(modelDelegate: ModelDelegate) {
        if(self.delegates.containsObject(modelDelegate as! AnyObject)) {
            self.delegates.addObject(modelDelegate as! AnyObject)
        }
    }
    
    /**
    * Removes a modelDelegate from the delegates array
    */
    func removeModelDelegate(modelDelegate: ModelDelegate) {
        if(self.delegates.containsObject(modelDelegate as! AnyObject)) {
            self.delegates.removeObject(modelDelegate as! AnyObject)
            
        }
    }
    /**
    * Indicates that the data has been loaded.
    *
    * Default implementation returns YES.
    */
    func isLoaded() -> Bool {
        return true
    }
    
    /**
    * Indicates that the data is in the process of loading.
    *
    * Default implementation returns NO.
    */
    func isLoading() -> Bool {
        return false
    }
    
    /**
    * Indicates that the model is of date and should be reloaded as soon as possible.
    *
    * Default implementation returns NO.
    */
    func isOutdated() -> Bool {
        return false
    }
    
    /**
    * Indicates that the model has no data.
    *
    * Default implementation returns YES.
    */
    func isEmpty() -> Bool {
        return true
    }
    
    /**
    * Loads the model.
    *
    * Load the model data
    */
    func load() {
        log.info("Calling Model empty load method")
    }
    
    /**
    * Cancels a load that is in progress.
    *
    * Default implementation does nothing.
    */
    func cancel() {}
    
    /**
    * Invalidates data stored in the cache or optionally erases it.
    *
    * Default implementation does nothing.
    */
    func invalidate(erase: Bool) {}
    
    ////////////////////////////////////////////////////////////
    //
    //  Default implementations of ModelDelegate methods
    //
    ////////////////////////////////////////////////////////////
    
    /**
    * Notifies delegates that the model started to load.
    */
    func didStartLoad() {
        let selector: Selector = "modelDidStartLoad:"
        for delegate: AnyObject in self.delegates {
            if delegate.respondsToSelector(selector) {
               // delegate.modelDidStartLoad(self)
            }
        }

    }
    
    /**
    * Notifies delegates that the model made some progress loading
    */
    func didMakeProgress(progress: Int) {
        let selector: Selector = "modelDidMakeProgress:progress:"
        for delegate: AnyObject in self.delegates {
            if delegate.respondsToSelector(selector) {
               // delegate.modelDidMakeProgress(self, progress: progress)
            }
        }
    
    }
    
    /**
    * Notifies delegates that the model finished loading
    */
    func didFinishLoad() {
        let selector: Selector = "modelDidFinishLoad:"
        for delegate: AnyObject in self.delegates {
            if delegate.respondsToSelector(selector) {
               // delegate.modelDidFinishLoad(self)
            }
        }
    
    }
    
    /**
    * Notifies delegates that the model failed to load.
    */
    func didFailLoadWithError(error: NSErrorPointer) {
        let selector: Selector = "model:didFailLoadWithError:"
        for delegate: AnyObject in self.delegates {
            if delegate.respondsToSelector(selector) {
               // delegate.model(self, didFailLoadWithError: error)
            }
        }
    
    }
    
    /**
    * Notifies delegates that the model canceled its load.
    */
    func didCancelLoad() {
        let selector: Selector = "modelDidCancelLoad:"
        for delegate: AnyObject in self.delegates {
            if delegate.respondsToSelector(selector) {
              //  delegate.modelDidCancelLoad(self)
            }
        }

    
    }
    
    /**
    * Notifies delegates that the model has begun making multiple updates.
    */
    func beginUpdates() {
        let selector: Selector = "modelDidBeginUpdates:"
        for delegate: AnyObject in self.delegates {
            if delegate.respondsToSelector(selector) {
               // delegate.modelDidBeginUpdates(self)
            }
        }

    
    }
    
    /**
    * Notifies delegates that the model has completed its updates.
    */
    func endUpdates() {
        let selector: Selector = "modelDidEndUpdates:"
        for delegate: AnyObject in self.delegates {
            if delegate.respondsToSelector(selector) {
               // delegate.modelDidEndUpdates(self)
            }
        }

    }
    
    /**
    * Notifies delegates that an object was updated.
    */
    func didUpdateObject(object: AnyObject, atIndexPath indexPath: NSIndexPath) {
        let selector: Selector = "model:didUpdateObject:atIndexPath:"
        for delegate: AnyObject in self.delegates {
            if delegate.respondsToSelector(selector) {
               // delegate.model(self, didUpdateObject: object, atIndexPath: indexPath)
            }
        }
    }
    
    /**
    * Notifies delegates that an object was inserted.
    */
    func didInsertObject(object: AnyObject, atIndexPath indexPath: NSIndexPath) {
        let selector: Selector = "model:didInsertObject:atIndexPath:"
        for delegate: AnyObject in self.delegates {
            if delegate.respondsToSelector(selector) {
                //delegate.model(self, didInsertObject: object, atIndexPath: indexPath)
            }
        }
    }
    
    /**
    * Notifies delegates that an object was deleted.
    */
    func didDeleteObject(object: AnyObject, atIndexPath indexPath: NSIndexPath) {
        let selector: Selector = "model:didDeleteObject:atIndexPath:"
        for delegate: AnyObject in self.delegates {
            if delegate.respondsToSelector(selector) {
               // delegate.model(self, didDeleteObject: object, atIndexPath: indexPath)
            }
        }
    }
    
    /**
    * Notifies delegates that the model changed in some fundamental way.
    */
    func didChange() {
        let selector: Selector = "modelDidChange:"
        for delegate: AnyObject in self.delegates {
            if delegate.respondsToSelector(selector) {
                //delegate.modelDidChange(self)
            }
        }
    
    }
    
    func didPresentGoogleLoginViewController(googleLoginViewController: UIViewController) {
        let selector: Selector = "didPresentGoogleLoginViewController:"
        for delegate: AnyObject in self.delegates {
            if delegate.respondsToSelector(selector) {
                delegate.didPresentGoogleLoginViewController(googleLoginViewController)
            }
        }

    }
    ///////// Error handling
    //
    ///**
    // * A message representing an error loading or formatting the data in this model.
    // * This message may be read from a server response, or generated locally.
    // */
    var errorMessage = String()
    
    /** Create an NSError object with domain API_URL, code 0, and a dictionary
    * containing an error message suitable for use with the rest of the error
    * handling code in this class
    */
    
    class func errorWithMessage(errorMessage: String) -> NSError {
        return NSError(domain: "https://api.shoutit.com/", code: 0, userInfo: NSDictionary.dictionaryWithValuesForKeys([errorMessage]))
    }
    
    /**
    * Sets the model into an unexpected error state.  Use when there is no error information
    * available and the model should be presented to the user in as gentle a way possible.
    */
    func setUnexpectedError() {}
    
    /**
    * Explicitly declare getter
    */
    func getErrorMessage() -> String {
        return errorMessage
    }
    
    /**
    *   Report whether the model is currently in an error state.
    */
//    func isError() -> Bool {}
    

    deinit {
        delegates.removeAllObjects()
    }
}
