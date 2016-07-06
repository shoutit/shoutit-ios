//
//  MediaProcessingQueue.swift
//  shoutit
//
//  Created by Piotr Bernad on 06.07.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import Foundation
import RxSwift

enum MediaProcessingQueueStatus {
    case NotRunning
    case Running
    case Finished
    case Error
}

class MediaProcessingQueue {
    
    var media : MediaAttachment
    var tasks : [MediaProcessingTask]
    
    var presentingSubject : PublishSubject<UIViewController?>
    var errorSubject : PublishSubject<ErrorType?>
    
    var status : MediaProcessingQueueStatus = .NotRunning
    
    init(media: MediaAttachment, tasks: [MediaProcessingTask], presentingSubject : PublishSubject<UIViewController?>, errorSubject : PublishSubject<ErrorType?>) {
        self.media = media
        self.tasks = tasks
        self.presentingSubject = presentingSubject
        self.errorSubject = errorSubject
    }
    
    func run() {
        status = .Running
        
        guard let firstTask = self.tasks.first else {
            errorWithMessage(NSLocalizedString("No tasks provided for MediaProcessingQueue", comment: ""))
            return
        }
        
        runTask(firstTask)
    }
    
    func runTask(task: MediaProcessingTask) {
        
    }
    
    func nextTaskForTask(task: MediaProcessingTask) -> MediaProcessingTask? {
        
    }
    
    func allTasksFinished() {
        status = .Finished
    }
    
    func error(error: ErrorType?) {
        status = .Error
        
        self.errorSubject.onNext(error)
    }
    
    func errorWithMessage(message: String) {
        self.errorSubject.onNext(NSError(domain: "com.shoutit.mediaProcessing", code: 3002, userInfo: [NSLocalizedDescriptionKey: message]))
    }
}