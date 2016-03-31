//
//  TWCCameraCapturer.h
//  TwilioConversationsClient
//
//  Copyright (c) 2015 Twilio Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreMedia/CoreMedia.h>

#import "TWCVideoCapturer.h"

@class TWCCameraPreviewView;
@class TWCLocalVideoTrack;

/**
 *  The smallest possible size, yielding a 1.22:1 aspect ratio useful for multi-party.
 */
extern CMVideoDimensions const TWCVideoConstraintsSize352x288;

/**
 *  Medium quality video in a 4:3 aspect ratio.
 */
extern CMVideoDimensions const TWCVideoConstraintsSize480x360;

/**
 *  High quality 640x480 video in a 4:3 aspect ratio.
 */
extern CMVideoDimensions const TWCVideoConstraintsSize640x480;

/**
 *  540p Quarter HD video in a 16:9 aspect ratio.
 */
extern CMVideoDimensions const TWCVideoConstraintsSize960x540;

/**
 *  720p HD video in a 16:9 aspect ratio.
 */
extern CMVideoDimensions const TWCVideoConstraintsSize1280x720;

/**
 *  HD quality 1280x960 video in a 4:3 aspect ratio.
 */
extern CMVideoDimensions const TWCVideoConstraintsSize1280x960;

/**
 *  Default 30fps video, giving a smooth video look.
 */
extern NSUInteger const TWCVideoConstraintsFrameRate30;

/**
 *  Cinematic 24 fps video. Not yet recommended for iOS recipients using `TWCVideoViewRenderer`, since it operates on a 30 hz timer.
 */
extern NSUInteger const TWCVideoConstraintsFrameRate24;

/**
 *  Battery efficient 20 fps video. Not yet recommended for iOS recipients using `TWCVideoViewRenderer`, since it operates on a 30 hz timer.
 */
extern NSUInteger const TWCVideoConstraintsFrameRate20;

/**
 *  Battery efficient 15 fps video. This setting can be useful if you prefer spatial to temporal resolution.
 */
extern NSUInteger const TWCVideoConstraintsFrameRate15;

/**
 *  Battery saving 10 fps video.
 */
extern NSUInteger const TWCVideoConstraintsFrameRate10;

@class TWCCameraCapturer;

/**
 *  The camera capturer delegate receives important lifecycle events related to the capturer.
 *  By implementing these methods you can override default behaviour, or handle errors that may occur.
 */
@protocol TWCCameraCapturerDelegate <NSObject>

@optional

/**
 *  The camera capturer has started capturing live video.
 *
 *  @discussion By default `TWCCameraCapturer` mirrors (only) `TWCVideoViewRenderer` views when the source
 *  is `TWCVideoCaptureSourceFrontCamera`. If you respond to this delegate method then it is your 
 *  responsibility to apply mirroring as you see fit.
 *
 *  @note At the moment, this method is synchronized with capture output and not the renderers.
 *
 *  @param capturer The capturer which started.
 *  @param source   The source which is now being captured.
 */
- (void)cameraCapturer:(nonnull TWCCameraCapturer *)capturer
    didStartWithSource:(TWCVideoCaptureSource)source;

/**
 *  The camera capturer was temporarily interrupted. Respond to this method to override the default behaviour.
 *  @discussion By default `TWCCameraCapturer` will pause the video track in response to an interruption.
 *  This is a good opportunity to update your UI, and/or take some sort of action.
 *
 *  @param capturer The capture which was interrupted.
 */
- (void)cameraCapturerWasInterrupted:(nonnull TWCCameraCapturer *)capturer;

/**
 *  The camera capturer stopped running with a fatal error.
 *
 *  @param capturer The capturer which stopped.
 *  @param error    The error which caused the capturer to stop.
 */
- (void)cameraCapturer:(nonnull TWCCameraCapturer *)capturer
didStopRunningWithError:(nonnull NSError *)error;

@end

@interface TWCCameraCapturer : NSObject <TWCVideoCapturer>

/** Sets/obtains the camera that is being shared.

 One of:

 - TWCVideoCaptureSourceFrontCamera
 - TWCVideoCaptureSourceBackCamera
 */
@property (nonatomic, assign) TWCVideoCaptureSource camera;

/**
 *  Indicates that video capture (including preview) is active.
 *  @discussion While interrupted, this property will return `NO`.
 */
@property (atomic, assign, readonly, getter = isCapturing) BOOL capturing;

/**
 *  The capturer's delegate.
 */
@property (nonatomic, weak, nullable) id<TWCCameraCapturerDelegate> delegate;

/**
 *  The dimensions of the preview feed, in the frame of reference specified by the view's `orientation`.
 *  @discussion With default constraints the dimensions would be 640x480 in landscape, and 480x640 in portrait.
 *  If capture is not started then 0x0 will be returned.
 */
@property (nonatomic, assign, readonly) CMVideoDimensions previewDimensions;

/**
 *  A view which allows you to preview the camera source. Available after calling startPreview.
 */
@property (nonatomic, strong, readonly, nullable) TWCCameraPreviewView *previewView;

/**
 *  The capturer's local video track.
 */
@property (nonatomic, weak, nullable) TWCLocalVideoTrack *videoTrack;

/**
 *  Returns `YES` if the capturer is currently interrupted, and `NO` otherwise.
 */
@property (nonatomic, assign, readonly, getter=isInterrupted) BOOL interrupted;

/**
 *  Creates the capturer with a source.
 *
 *  @param source The `TWCVideoCaptureSource` to select.
 *
 *  @return A camera capturer which can be used to create a `TWCLocalVideoTrack`.
 */
- (nonnull instancetype)initWithSource:(TWCVideoCaptureSource)source;

/**
 *  Creates the capturer with a source and delegate.
 *
 *  @param delegate The delegate which will receive callbacks from the capturer.
 *  @param source   The `TWCVideoCaptureSource` to select.
 *
 *  @return A camera capturer which can be used to create a `TWCLocalVideoTrack`.
 */
- (nonnull instancetype)initWithDelegate:(nullable id<TWCCameraCapturerDelegate>)delegate
                                  source:(TWCVideoCaptureSource)source;

/**
 *  Starts previewing the camera.
 *  @note The preview view is available after startPreview has been called.
 *
 *  @return 'YES' if preview started, 'NO' if it failed.
 */
- (BOOL)startPreview;

/**
 *  Stops previewing the camera.
 *
 *  @return 'YES' if preview stopped, 'NO' if it failed.
 */
- (BOOL)stopPreview;

/**
 *  Flips the capturer's camera source.
 */
- (void)flipCamera;

@end
