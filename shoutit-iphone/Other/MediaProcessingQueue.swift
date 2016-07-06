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
    
    var status : Variable<MediaProcessingQueueStatus> = Variable(.NotRunning)
    
    init(media: MediaAttachment, tasks: [MediaProcessingTask], presentingSubject : PublishSubject<UIViewController?>, errorSubject : PublishSubject<ErrorType?>) {
        self.media = media
        self.tasks = tasks
        self.presentingSubject = presentingSubject
        self.errorSubject = errorSubject
    }
    
    func run() {
        status.value = .Running
        
        guard let firstTask = self.tasks.first else {
            errorWithMessage(NSLocalizedString("No tasks provided for MediaProcessingQueue", comment: ""))
            return
        }
        
        runTask(firstTask)
    }
    
    func runTask(task: MediaProcessingTask) {
        let taskCopy = task
        
        if let nextTask = nextTaskForTask(taskCopy) {
            taskCopy.finish = {
                self.runTask(nextTask)
            }
        } else {
            taskCopy.finish = {
                self.allTasksFinished()
            }
        }
        
        taskCopy.presentingSubject = presentingSubject
        taskCopy.errorSubject = errorSubject
        taskCopy.runWithMedia(self.media)
    }
    
    func nextTaskForTask(task: MediaProcessingTask) -> MediaProcessingTask? {
        guard let idx = self.tasks.indexOf(task) else {
            return nil
        }
        
        let nextIdx = idx + 1
        
        if nextIdx < self.tasks.count {
            return self.tasks[nextIdx]
        }
        
        return nil
    }
    
    func allTasksFinished() {
        status.value = .Finished
    }
    
    func error(error: ErrorType?) {
        status.value = .Error
        
        self.errorSubject.onNext(error)
    }
    
    func errorWithMessage(message: String) {
        self.errorSubject.onNext(NSError(domain: "com.shoutit.mediaProcessing", code: 3002, userInfo: [NSLocalizedDescriptionKey: message]))
    }
}