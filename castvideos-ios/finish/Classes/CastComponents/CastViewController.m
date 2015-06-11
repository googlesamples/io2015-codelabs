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

#import "AppDelegate.h"
#import "CastViewController.h"
#import "ChromecastDeviceController.h"
#import "SimpleImageFetcher.h"
#import "TracksTableViewController.h"

#import <GoogleCast/GCKDevice.h>
#import <GoogleCast/GCKMediaControlChannel.h>
#import <GoogleCast/GCKMediaInformation.h>
#import <GoogleCast/GCKMediaMetadata.h>
#import <GoogleCast/GCKMediaStatus.h>

static NSString * const kListTracks = @"listTracks";
static NSString * const kListTracksPopover = @"listTracksPopover";
NSString * const kCastComponentPosterURL = @"castComponentPosterURL";

@interface CastViewController () {
  NSTimeInterval _mediaStartTime;
  /* Flag to indicate we are scrubbing - the play position is only updated at the end. */
  BOOL _currentlyDraggingSlider;
  /* Flag to indicate whether we have status from the Cast device and can show the UI. */
  BOOL _readyToShowInterface;
  /* Flag for whether we are reconnecting or playing from scratch. */
  BOOL _joinExistingSession;
  /* The most recent playback time - used for syncing between local and remote playback. */
  NSTimeInterval _lastKnownTime;
}

/* The device manager used for the currently casting media. */
@property(weak, nonatomic) ChromecastDeviceController *castDeviceController;
/* The image of the current media. */
@property IBOutlet UIImageView* thumbnailImage;
/* The label displaying the currently connected device. */
@property IBOutlet UILabel* castingToLabel;
/* The label displaying the currently playing media. */
@property(weak, nonatomic) IBOutlet UILabel* mediaTitleLabel;
/* An activity indicator while the cast is starting. */
@property(weak, nonatomic) IBOutlet UIActivityIndicatorView* castActivityIndicator;
/* A timer to trigger a callback to update the times/slider position. */
@property(weak, nonatomic) NSTimer* updateStreamTimer;
/* A timer to trigger removal of the volume control. */
@property(weak, nonatomic) NSTimer* fadeVolumeControlTimer;

/* The time of the play head in the current video. */
@property(nonatomic) UILabel* currTime;
/* The total time of the video. */
@property(nonatomic) UILabel* totalTime;
/* The tracks selector button (for closed captions primarily in this sample). */
@property(nonatomic) UIButton* cc;
/* The button that brings up the volume control: Apple recommends not overriding the hardware
   volume controls, so we use a separate on-screen UI. */
@property(nonatomic) UIButton* volumeButton;
/* The play icon button. */
@property(nonatomic) UIButton* playButton;
/* A slider for the progress/scrub bar. */
@property(nonatomic) UISlider* slider;

/* A containing view for the toolbar. */
@property(nonatomic) UIView *toolbarView;
/* Views dictionary used for the visual format layout management. */
@property(nonatomic) NSDictionary *viewsDictionary;

/* Play image. */
@property(nonatomic) UIImage *playImage;
/* Pause image. */
@property(nonatomic) UIImage *pauseImage;

/* Whether the viewcontroller is currently visible. */
@property BOOL visible;

@end

@implementation CastViewController

- (void)viewDidLoad {
  [super viewDidLoad];

  self.visible = false;

  self.castDeviceController = [ChromecastDeviceController sharedInstance];

  self.castingToLabel.text = [NSString stringWithFormat:NSLocalizedString(@"Casting to %@", nil),
      _castDeviceController.deviceManager.device.friendlyName];
  self.mediaTitleLabel.text = [self.mediaToPlay.metadata stringForKey:kGCKMetadataKeyTitle];

  self.volumeControlLabel.text = [NSString stringWithFormat:NSLocalizedString(@"%@ Volume", nil),
                                    _castDeviceController.deviceManager.device.friendlyName];
  self.volumeSlider.minimumValue = 0;
  self.volumeSlider.maximumValue = 1.0;
  self.volumeSlider.value = _castDeviceController.deviceManager.deviceVolume ?
      _castDeviceController.deviceManager.deviceVolume : 0.5;
  self.volumeSlider.continuous = NO;
  [self.volumeSlider addTarget:self
                        action:@selector(sliderValueChanged:)
              forControlEvents:UIControlEventValueChanged];

  UIButton *transparencyButton = [[UIButton alloc] initWithFrame:self.view.bounds];
  transparencyButton.autoresizingMask =
      (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight);
  transparencyButton.backgroundColor = [UIColor clearColor];
  [self.view insertSubview:transparencyButton aboveSubview:self.thumbnailImage];
  [transparencyButton addTarget:self
                         action:@selector(showVolumeSlider:)
               forControlEvents:UIControlEventTouchUpInside];
  [self initControls];
}

- (void)viewWillAppear:(BOOL)animated {
  [super viewWillAppear:animated];

  // Listen for volume change notifications.
  [[NSNotificationCenter defaultCenter] addObserver:self
                                           selector:@selector(volumeDidChange)
                                               name:@"castVolumeChanged"
                                             object:nil];

  [[NSNotificationCenter defaultCenter] addObserver:self
                                           selector:@selector(didReceiveMediaStateChange)
                                               name:@"castMediaStatusChange"
                                             object:nil];

  // Add the cast icon to our nav bar.
  [[ChromecastDeviceController sharedInstance] decorateViewController:self];

  // Make the navigation bar transparent.
  self.navigationController.navigationBar.translucent = YES;
  [self.navigationController.navigationBar setBackgroundImage:[UIImage new]
                                                forBarMetrics:UIBarMetricsDefault];
  self.navigationController.navigationBar.shadowImage = [UIImage new];

  self.toolbarView.hidden = YES;
  [self.playButton setImage:self.playImage forState:UIControlStateNormal];

  [self resetInterfaceElements];

  if (_joinExistingSession == YES) {
    [self mediaNowPlaying];
  }

  [self configureView];
}

- (void)viewDidAppear:(BOOL)animated {
  [super viewDidAppear:animated];
  self.visible = true;
  if (_castDeviceController.deviceManager.applicationConnectionState
      != GCKConnectionStateConnected) {
    // If we're not connected, exit.
    [self maybePopController];
  }
}

- (void)viewWillDisappear:(BOOL)animated {
  // I think we can safely stop the timer here
  [self.updateStreamTimer invalidate];
  self.updateStreamTimer = nil;

  // We no longer want to be delegate.
  [[NSNotificationCenter defaultCenter] removeObserver:self];

  [self.navigationController.navigationBar setBackgroundImage:nil
                                                forBarMetrics:UIBarMetricsDefault];
}

- (void)viewDidDisappear:(BOOL)animated {
  self.visible = false;
  [super viewDidDisappear:animated];
}

- (IBAction)sliderValueChanged:(id)sender {
    UISlider *slider = (UISlider *) sender;
    NSLog(@"Got new slider value: %.2f", slider.value);
    [_castDeviceController.deviceManager setVolume:slider.value];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
  if (!_castDeviceController) {
    self.castDeviceController = [ChromecastDeviceController sharedInstance];
  }
  if ([segue.identifier isEqualToString:kListTracks] ||
      [segue.identifier isEqualToString:kListTracksPopover]) {
    UITabBarController *controller;
    controller = (UITabBarController *)[(UINavigationController *)[segue destinationViewController] visibleViewController];
    TracksTableViewController *trackController  = controller.viewControllers[0];
    [trackController setMedia:self.mediaToPlay
                      forType:GCKMediaTrackTypeText
             deviceController:_castDeviceController.mediaControlChannel];
    TracksTableViewController *audioTrackController  = controller.viewControllers[1];
    [audioTrackController setMedia:self.mediaToPlay
                           forType:GCKMediaTrackTypeAudio
                  deviceController:_castDeviceController.mediaControlChannel];
  }
}

- (IBAction)unwindToCastView:(UIStoryboardSegue *)segue; {
  if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
    [self dismissViewControllerAnimated:YES completion:nil];
  }
}

- (void)maybePopController {
  // Only take action if we're visible.
  if (self.visible) {
    self.mediaToPlay = nil; // Forget media.
    [self.navigationController popViewControllerAnimated:YES];
  }
}

#pragma mark - Managing the detail item

- (void)setMediaToPlay:(GCKMediaInformation *)newDetailItem {
  [self setMediaToPlay:newDetailItem withStartingTime:0];
}

- (void)setMediaToPlay:(GCKMediaInformation *)newMedia withStartingTime:(NSTimeInterval)startTime {
  _mediaStartTime = startTime;
  if (_mediaToPlay != newMedia) {
    _mediaToPlay = newMedia;
  }
}

- (void)resetInterfaceElements {
  self.totalTime.text = @"";
  self.currTime.text = @"";
  [self.slider setValue:0];
  [self.castActivityIndicator startAnimating];
  _currentlyDraggingSlider = NO;
  self.toolbarView.hidden = YES;
  _readyToShowInterface = NO;
}

- (IBAction)showVolumeSlider:(id)sender {
  if(self.volumeControls.hidden) {
    self.volumeControls.hidden = NO;
    [self.volumeControls setAlpha:0];

    [UIView animateWithDuration:0.5
                     animations:^{
                       self.volumeControls.alpha = 1.0;
                     }
                     completion:^(BOOL finished){
                       NSLog(@"Done!");
                     }];

  }
  // Do this so if a user taps the screen or plays with the volume slider, it resets the timer
  // for fading the volume controls
  if(self.fadeVolumeControlTimer != nil) {
    [self.fadeVolumeControlTimer invalidate];
  }
  self.fadeVolumeControlTimer = [NSTimer scheduledTimerWithTimeInterval:3.0
                                                                 target:self
                                                               selector:@selector(fadeVolumeSlider:)
                                                               userInfo:nil repeats:NO];
}

- (void)fadeVolumeSlider:(NSTimer *)timer {
  [self.volumeControls setAlpha:1.0];

  [UIView animateWithDuration:0.5
                   animations:^{
                     self.volumeControls.alpha = 0.0;
                   }
                   completion:^(BOOL finished){
                     self.volumeControls.hidden = YES;
                   }];
}


- (void)mediaNowPlaying {
  _readyToShowInterface = YES;
  [self updateInterfaceFromCast:nil];
  self.toolbarView.hidden = NO;
}

- (void)updateInterfaceFromCast:(NSTimer*)timer {
  if (!_readyToShowInterface)
    return;

  if (_castDeviceController.playerState != GCKMediaPlayerStateBuffering) {
    [self.castActivityIndicator stopAnimating];
  } else {
    [self.castActivityIndicator startAnimating];
  }

  if (_castDeviceController.streamDuration > 0 && !_currentlyDraggingSlider) {
    _lastKnownTime = _castDeviceController.streamPosition;
    self.currTime.text = [self getFormattedTime:_castDeviceController.streamPosition];
    self.totalTime.text = [self getFormattedTime:_castDeviceController.streamDuration];
    [self.slider
        setValue:(_castDeviceController.streamPosition / _castDeviceController.streamDuration)
        animated:YES];
  }
  [self updateToolbarControls];
}


- (void)updateToolbarControls {
  if (_castDeviceController.playerState == GCKMediaPlayerStatePaused ||
      _castDeviceController.playerState == GCKMediaPlayerStateIdle) {
    [self.playButton setImage:self.playImage forState:UIControlStateNormal];
  } else if (_castDeviceController.playerState == GCKMediaPlayerStatePlaying ||
             _castDeviceController.playerState == GCKMediaPlayerStateBuffering) {
    [self.playButton setImage:self.pauseImage forState:UIControlStateNormal];
  }
}

// Little formatting option here
- (NSString*)getFormattedTime:(NSTimeInterval)timeInSeconds {
  int seconds = round(timeInSeconds);
  int hours = seconds / (60 * 60);
  seconds %= (60 * 60);

  int minutes = seconds / 60;
  seconds %= 60;

  if (hours > 0) {
    return [NSString stringWithFormat:@"%d:%02d:%02d", hours, minutes, seconds];
  } else {
    return [NSString stringWithFormat:@"%d:%02d", minutes, seconds];
  }
}

- (void)configureView {
  if (self.mediaToPlay && _castDeviceController.deviceManager.applicationConnectionState 
  		== GCKConnectionStateConnected) {
    NSURL* url = self.mediaToPlay.customData;
    NSString *title = [_mediaToPlay.metadata stringForKey:kGCKMetadataKeyTitle];
    self.castingToLabel.text =
        [NSString stringWithFormat:@"Casting to %@",
            _castDeviceController.deviceManager.device.friendlyName];
    self.mediaTitleLabel.text = title;

    NSLog(@"Casting movie %@ at starting time %f", url, _mediaStartTime);

    //Loading thumbnail async
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
      NSString *posterURL = [_mediaToPlay.metadata stringForKey:kCastComponentPosterURL];
      if (posterURL) {
        UIImage* image = [UIImage
            imageWithData:[SimpleImageFetcher getDataFromImageURL:[NSURL URLWithString:posterURL]]];

        dispatch_async(dispatch_get_main_queue(), ^{
          NSLog(@"Loaded thumbnail image");
          self.thumbnailImage.image = image;
          [self.view setNeedsLayout];
        });
      }
    });

    self.cc.enabled = [self.mediaToPlay.mediaTracks count] > 0;

    NSString *cur = [_castDeviceController.mediaInformation.metadata
                        stringForKey:kGCKMetadataKeyTitle];
    // If the newMedia is already playing, join the existing session.
    if (![title isEqualToString:cur] ||
          _castDeviceController.playerState == GCKMediaPlayerStateIdle) {
      //Cast the movie!
      [_castDeviceController loadMedia:self.mediaToPlay
                             startTime:_mediaStartTime
                              autoPlay:YES];
      _joinExistingSession = NO;
    } else {
      _joinExistingSession = YES;
      [self mediaNowPlaying];
    }

    // Start the timer
    if (self.updateStreamTimer) {
      [self.updateStreamTimer invalidate];
      self.updateStreamTimer = nil;
    }

    self.updateStreamTimer =
        [NSTimer scheduledTimerWithTimeInterval:1.0
                                         target:self
                                       selector:@selector(updateInterfaceFromCast:)
                                       userInfo:nil
                                        repeats:YES];

  }
}

#pragma mark - On - screen UI elements
- (IBAction)playButtonClicked:(id)sender {
  if (_castDeviceController.playerState == GCKMediaPlayerStatePaused) {
    [_castDeviceController.mediaControlChannel play];
  } else {
    [_castDeviceController.mediaControlChannel pause];
  }
}

- (IBAction)subtitleButtonClicked:(id)sender {
  if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
    [self performSegueWithIdentifier:kListTracksPopover sender:self];
  } else {
    [self performSegueWithIdentifier:kListTracks sender:self];
  }
}

- (IBAction)onTouchDown:(id)sender {
  _currentlyDraggingSlider = YES;
}

// This is continuous, so we can update the current/end time labels
- (IBAction)onSliderValueChanged:(id)sender {
  float pctThrough = [self.slider value];
  if (_castDeviceController.streamDuration > 0) {
    self.currTime.text =
        [self getFormattedTime:(pctThrough * _castDeviceController.streamDuration)];
  }
}
// This is called only on one of the two touch up events
- (void)touchIsFinished {
  [_castDeviceController setPlaybackPercent:[self.slider value]];
  _currentlyDraggingSlider = NO;
}

- (IBAction)onTouchUpInside:(id)sender {
  NSLog(@"Touch up inside");
  [self touchIsFinished];

}
- (IBAction)onTouchUpOutside:(id)sender {
  NSLog(@"Touch up outside");
  [self touchIsFinished];
}

#pragma mark - ChromecastControllerDelegate

/**
 * Called when connection to the device was closed.
 */
- (void)didDisconnect {
  [self maybePopController];
}

/**
 * Called when the playback state of media on the device changes.
 */
- (void)didReceiveMediaStateChange {
  NSString *currentlyPlayingMediaTitle = [_castDeviceController.mediaInformation.metadata
                                          stringForKey:kGCKMetadataKeyTitle];
  NSString *title = [_mediaToPlay.metadata stringForKey:kGCKMetadataKeyTitle];

  if (currentlyPlayingMediaTitle &&
      ![title isEqualToString:currentlyPlayingMediaTitle]) {
    // The state change is related to old media, so ignore it.
    NSLog(@"Got message for media %@ while on %@", currentlyPlayingMediaTitle, title);
    return;
  }

  if (_castDeviceController.playerState == GCKMediaPlayerStateIdle && _mediaToPlay) {
    [self maybePopController];
    return;
  }

  _readyToShowInterface = YES;
  if ([self isViewLoaded] && self.view.window) {
    // Display toolbar if we are current view.
    self.toolbarView.hidden = NO;
  }
}

#pragma mark - implementation.
- (void)initControls {

  // Play/Pause images.
  self.playImage = [UIImage imageNamed:@"media_play"];
  self.pauseImage = [UIImage imageNamed:@"media_pause"];

  // Toolbar.
  self.toolbarView = [[UIView alloc] initWithFrame:self.navigationController.toolbar.frame];
  self.toolbarView.translatesAutoresizingMaskIntoConstraints = NO;
  // Hide the nav controller toolbar - we are managing our own to get autolayout.
  self.navigationController.toolbarHidden = YES;

  // Play/Pause button.
  self.playButton = [UIButton buttonWithType:UIButtonTypeSystem];
  [self.playButton setFrame:CGRectMake(0, 0, 40, 40)];
  if (_castDeviceController.playerState == GCKMediaPlayerStatePaused) {
    [self.playButton setImage:self.playImage forState:UIControlStateNormal];
  } else {
    [self.playButton setImage:self.pauseImage forState:UIControlStateNormal];
  }
  [self.playButton addTarget:self
                      action:@selector(playButtonClicked:)
            forControlEvents:UIControlEventTouchUpInside];
  self.playButton.tintColor = [UIColor whiteColor];
  NSLayoutConstraint *constraint =[NSLayoutConstraint
                                   constraintWithItem:self.playButton
                                   attribute:NSLayoutAttributeHeight
                                   relatedBy:NSLayoutRelationEqual
                                   toItem:self.playButton
                                   attribute:NSLayoutAttributeWidth
                                   multiplier:1.0
                                   constant:0.0f];
  [self.playButton addConstraint:constraint];
  self.playButton.translatesAutoresizingMaskIntoConstraints = NO;

  // Current time.
  self.currTime = [[UILabel alloc] init];
  self.currTime.clearsContextBeforeDrawing = YES;
  self.currTime.text = @"00:00";
  [self.currTime setFont:[UIFont fontWithName:@"Helvetica" size:14.0]];
  [self.currTime setTextColor:[UIColor whiteColor]];
  self.currTime.tintColor = [UIColor whiteColor];
  self.currTime.translatesAutoresizingMaskIntoConstraints = NO;

  // Total time.
  self.totalTime = [[UILabel alloc] init];
  self.totalTime.clearsContextBeforeDrawing = YES;
  self.totalTime.text = @"00:00";
  [self.totalTime setFont:[UIFont fontWithName:@"Helvetica" size:14.0]];
  [self.totalTime setTextColor:[UIColor whiteColor]];
  self.totalTime.tintColor = [UIColor whiteColor];
  self.totalTime.translatesAutoresizingMaskIntoConstraints = NO;

  // Volume control.
  self.volumeButton = [UIButton buttonWithType:UIButtonTypeSystem];
  [self.volumeButton setFrame:CGRectMake(0, 0, 40, 40)];
  [self.volumeButton setImage:[UIImage imageNamed:@"icon_volume3"] forState:UIControlStateNormal];
  [self.volumeButton addTarget:self
                      action:@selector(showVolumeSlider:)
            forControlEvents:UIControlEventTouchUpInside];
  self.volumeButton.tintColor = [UIColor whiteColor];
  constraint =[NSLayoutConstraint
                                   constraintWithItem:self.volumeButton
                                   attribute:NSLayoutAttributeHeight
                                   relatedBy:NSLayoutRelationEqual
                                   toItem:self.volumeButton
                                   attribute:NSLayoutAttributeWidth
                                   multiplier:1.0
                                   constant:0.0f];
  [self.volumeButton addConstraint:constraint];
  self.volumeButton.translatesAutoresizingMaskIntoConstraints = NO;

  // Tracks selector.
  self.cc = [UIButton buttonWithType:UIButtonTypeSystem];
  [self.cc setFrame:CGRectMake(0, 0, 40, 40)];
  [self.cc setImage:[UIImage imageNamed:@"closed_caption_white.png.png"] forState:UIControlStateNormal];
  [self.cc addTarget:self
                        action:@selector(subtitleButtonClicked:)
              forControlEvents:UIControlEventTouchUpInside];
  self.cc.tintColor = [UIColor whiteColor];
  constraint =[NSLayoutConstraint
               constraintWithItem:self.cc
               attribute:NSLayoutAttributeHeight
               relatedBy:NSLayoutRelationEqual
               toItem:self.cc
               attribute:NSLayoutAttributeWidth
               multiplier:1.0
               constant:0.0f];
  [self.cc addConstraint:constraint];
  self.cc.translatesAutoresizingMaskIntoConstraints = NO;

  // Slider.
  self.slider = [[UISlider alloc] init];
  UIImage *thumb = [UIImage imageNamed:@"thumb.png"];
  [self.slider setThumbImage:thumb forState:UIControlStateNormal];
  [self.slider setThumbImage:thumb forState:UIControlStateHighlighted];
  [self.slider addTarget:self
                  action:@selector(onSliderValueChanged:)
        forControlEvents:UIControlEventValueChanged];
  [self.slider addTarget:self
                  action:@selector(onTouchDown:)
        forControlEvents:UIControlEventTouchDown];
  [self.slider addTarget:self
                  action:@selector(onTouchUpInside:)
        forControlEvents:UIControlEventTouchUpInside];
  [self.slider addTarget:self
                  action:@selector(onTouchUpOutside:)
        forControlEvents:UIControlEventTouchCancel];
  [self.slider addTarget:self
                  action:@selector(onTouchUpOutside:)
        forControlEvents:UIControlEventTouchUpOutside];
  self.slider.autoresizingMask = UIViewAutoresizingFlexibleWidth;
  self.slider.minimumValue = 0;
  self.slider.minimumTrackTintColor = [UIColor yellowColor];
  self.slider.translatesAutoresizingMaskIntoConstraints = NO;

  [self.view addSubview:self.toolbarView];
  [self.toolbarView addSubview:self.playButton];
  [self.toolbarView addSubview:self.volumeButton];
  [self.toolbarView addSubview:self.currTime];
  [self.toolbarView addSubview:self.slider];
  [self.toolbarView addSubview:self.totalTime];
  [self.toolbarView addSubview:self.cc];

  // Round the corners on the volume pop up.
  self.volumeControls.layer.cornerRadius = 5;
  self.volumeControls.layer.masksToBounds = YES;

  // Layout.
  NSString *hlayout =
  @"|-(<=5)-[playButton(==35)]-[volumeButton(==30)]-[currTime]-[slider(>=90)]-[totalTime]-[ccButton(==playButton)]-(<=5)-|";
  self.viewsDictionary = @{ @"slider" : self.slider,
                            @"currTime" : self.currTime,
                            @"totalTime" :  self.totalTime,
                            @"playButton" : self.playButton,
                            @"volumeButton" : self.volumeButton,
                            @"ccButton" : self.cc
                            };
  [self.toolbarView addConstraints:
   [NSLayoutConstraint constraintsWithVisualFormat:hlayout
                                           options:NSLayoutFormatAlignAllCenterY
                                           metrics:nil views:self.viewsDictionary]];

   NSString *vlayout = @"V:[slider(==35)]-|";
  [self.toolbarView addConstraints:
   [NSLayoutConstraint constraintsWithVisualFormat:vlayout
                                           options:0
                                           metrics:nil views:self.viewsDictionary]];

  // Autolayout toolbar.
  NSString *toolbarVLayout = @"V:[toolbar(==44)]|";
  NSString *toolbarHLayout = @"|[toolbar]|";
  [self.view addConstraints:
   [NSLayoutConstraint constraintsWithVisualFormat:toolbarVLayout
                                           options:0
                                           metrics:nil views:@{@"toolbar" : self.toolbarView}]];
  [self.view addConstraints:
   [NSLayoutConstraint constraintsWithVisualFormat:toolbarHLayout
                                           options:0
                                           metrics:nil views:@{@"toolbar" : self.toolbarView}]];
}

#pragma mark Volume listener.

- (void)volumeDidChange {
  self.volumeSlider.value = _castDeviceController.deviceManager.deviceVolume;
}

@end