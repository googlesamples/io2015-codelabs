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

#import <GoogleCast/GCKDeviceManager.h>
#import <UIKit/UIKit.h>

@class GCKMediaInformation;

/**
 *  Additional metadata key for the poster image URL.
 */
extern NSString * const kCastComponentPosterURL;

/**
 * A view that shows the media thumbnail and controls for media playing on the
 * Chromecast device.
 */
@interface CastViewController : UIViewController

/**
 *  The media object being played on Chromecast device. Set this before presenting the view.
 */
@property(strong, nonatomic) GCKMediaInformation* mediaToPlay;

/**
 *  The volume slider control.
 */
@property(strong, nonatomic) IBOutlet UISlider *volumeSlider;

/**
 *  The label in the volume control container.
 */
@property (weak, nonatomic) IBOutlet UILabel *volumeControlLabel;

/**
 *  The entire volume control container, including the label.
 */
@property(strong, nonatomic) IBOutlet UIView *volumeControls;

/**
 *  Set the media object and the start time. This should be called before presenting the view.
 *
 *  @param newMedia  The media to play, contentID should be set to the URL.
 *  @param startTime The start time of the media if casting new content.
 */
- (void)setMediaToPlay:(GCKMediaInformation *)newMedia withStartingTime:(NSTimeInterval)startTime;

/**
 *  Show the slider for a few sections if touched.
 *
 *  @param sender
 */
- (IBAction)showVolumeSlider:(id)sender;

@end