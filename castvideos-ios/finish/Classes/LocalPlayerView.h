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


#import "Media.h"
#import <UIKit/UIKit.h>

/* Navigation Bar styles/ */
typedef NS_ENUM(NSUInteger, LPVNavBarStyle) {
  LPVNavBarTransparent,
  LPVNavBarDefault
};

/* Protocol for callbacks from the LocalPlayerView. */
@protocol LocalPlayerDelegate <NSObject>
/* Signal the requested style for the view. */
- (void)setNavigationBarStyle:(LPVNavBarStyle)style;
/* Request the navigation bar to be hidden or shown. */
- (void)hideNavigationBar:(BOOL)hide;

@optional

/* Play has beeen pressed in the LocalPlayerView.
 * Return NO to halt default actions, YES to continue as normal.
 */
- (BOOL)continueAfterPlayButtonClicked;

/* Play has beeen pressed in the LocalPlayerView.
 * Return NO to halt default actions, YES to continue as normal.
 */
- (BOOL)continueAfterPauseButtonClicked;
@end

/* UIView for displaying a local player or splash screen. */
@interface LocalPlayerView : UIView

/* Delegate to use for callbacks for play/pause presses while in Cast mode. */
@property(nonatomic, assign) id<LocalPlayerDelegate> delegate;
/* Local player elapsed time. */
@property(nonatomic) NSInteger playbackTime;
/* YES if the video is playing or paused in the local player. */
@property(nonatomic,readonly) BOOL playingLocally;
/* YES if the video is fullscreen. */
@property(nonatomic,readonly) BOOL fullscreen;

/* Set the media to be displayed and played. */
- (void)setMedia:(Media *)media;

/* Signal an orientation change has occurred. */
- (void)orientationChanged;

/* Pause local playback. */
- (void)pause;

/* Reset the state of the player to show the splash screen. */
- (void)showSplashScreen;

@end
