// Copyright 2015 Google Inc. All Rights Reserved.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

#import <Foundation/Foundation.h>
#import <GoogleCast/GCKMediaStatus.h>

@class GCKMediaControlChannel;

@protocol CastMiniControllerDelegate <NSObject>

/**
 *  Display the media currently being cast.
 */
- (void)displayCurrentlyPlayingMedia;

/**
 *  The media control channel for the currently playing media, if any.
 *
 *  @return Control channel for the currently cast media.
 */
- (GCKMediaControlChannel *)mediaControlChannel;

@end

/**
 *  Manages the contents of a UIToolbar in order to provide a minicontroller with current
 *  media display and controls.
 */
@interface CastMiniController : NSObject

/**
 *  Designated initializer.
 *
 *  @param delegate Delegate for control flow
 *
 *  @return A new CastMiniController
 */
- (instancetype)initWithDelegate:(id<CastMiniControllerDelegate>)delegate NS_DESIGNATED_INITIALIZER;

/**
 *  Update the state of the minicontroller in a given viewcontroller.
 *
 *  @param viewController UIViewController with a UIToolbar available.
 *  @param info GCKMediaInformation for the currently playing media.
 *  @param state GCKMediaPlayerState for the current status of playback.
 */
- (void)updateToolbarStateIn:(UIViewController *)viewController
         forMediaInformation:(GCKMediaInformation *)info
                 playerState:(GCKMediaPlayerState)state;

@end
