// Copyright 2014 Google Inc. All Rights Reserved.
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

#import <GoogleCast/GCKMediaTrack.h>
#import <UIKit/UIKit.h>

@class GCKMediaInformation;
@class GCKMediaControlChannel;

/**
 *  A simple picker for captions or alternate audio tracks.
 */
@interface TracksTableViewController : UITableViewController

/**
 *  Configure the tracks view with the GCKMediaInformation required and the device controller to
 *  call back to.
 *
 *  @param media            The current media
 *  @param type             The type of tracks to display
 *  @param controlChannel   The device control channel
 */
- (void)setMedia:(GCKMediaInformation *)media
         forType:(GCKMediaTrackType)type
    deviceController:(GCKMediaControlChannel *)controlChannel;

@end
