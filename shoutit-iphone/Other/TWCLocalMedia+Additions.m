//
//  TWCLocalMedia+Additions.m
//  shoutit-iphone
//
//  Created by Piotr Bernad on 30/03/16.
//  Copyright © 2016 Shoutit. All rights reserved.
//

#import "TWCLocalMedia+Additions.h"

@implementation TWCLocalMedia (Additions)

- (BOOL)sh_addTrack:(nonnull TWCVideoTrack *)track error:(NSError * _Nullable * _Nullable)error {
    return [self addTrack:track error:error];
}

- (nullable TWCCameraCapturer *)sh_addCameraTrack:(NSError * _Nullable * _Nullable)error {
    return [self addCameraTrack:error];
}

@end
