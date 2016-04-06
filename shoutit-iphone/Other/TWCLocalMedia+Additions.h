//
//  TWCLocalMedia+Additions.h
//  shoutit-iphone
//
//  Created by Piotr Bernad on 30/03/16.
//  Copyright © 2016 Shoutit. All rights reserved.
//

#import <TwilioConversationsClient/TwilioConversationsClient.h>

@interface TWCLocalMedia (Additions)

- (BOOL)sh_addTrack:(nonnull TWCVideoTrack *)track error:(NSError * _Nullable * _Nullable)error;
- (nullable TWCCameraCapturer *)sh_addCameraTrack:(NSError * _Nullable * _Nullable)error;

@end
