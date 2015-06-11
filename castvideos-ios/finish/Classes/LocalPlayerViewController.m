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
#import "GCKMediaInformation+LocalMedia.h"
#import "LocalPlayerViewController.h"


#import <GoogleCast/GoogleCast.h>

@interface LocalPlayerViewController ()

/* Whether to reset the edges on disappearing. */
@property(nonatomic) BOOL resetEdgesOnDisappear;

@end

@implementation LocalPlayerViewController

#pragma mark - ViewController lifecycle

- (void)viewWillAppear:(BOOL)animated {
  [super viewWillAppear:animated];
  [self.playerView setMedia:_mediaToPlay];
  _resetEdgesOnDisappear = YES;

  // Listen to orientation changes.
  [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
  [[NSNotificationCenter defaultCenter] addObserver:self
                                           selector:@selector(deviceOrientationDidChange:)
                                               name:UIDeviceOrientationDidChangeNotification
                                             object:nil];
  _playerView.delegate = self;
  [self syncTextToMedia];
  if (self.playerView.fullscreen) {
    [self hideNavigationBar:YES];
  }

  [[ChromecastDeviceController sharedInstance]
   decorateViewController:self];

  [[NSNotificationCenter defaultCenter]
      addObserver:self
      selector:@selector(didConnectToDevice)
      name:@"castApplicationConnected"
      object:nil];
}

- (void)viewWillDisappear:(BOOL)animated {
  [[NSNotificationCenter defaultCenter] removeObserver:self];
  if (_playerView.playingLocally) {
    [_playerView pause];
  }
  if (_resetEdgesOnDisappear) {
    [self setNavigationBarStyle:LPVNavBarDefault];
  }
  [super viewWillDisappear:animated];
}

- (void)viewDidAppear:(BOOL)animated {
  [super viewDidAppear:animated];
  [[ChromecastDeviceController sharedInstance] updateToolbarForViewController:self];
}

- (void)deviceOrientationDidChange:(NSNotification *)notification {
  [self.playerView orientationChanged];

  UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
  if (!UIInterfaceOrientationIsLandscape(orientation) || !self.playerView.playingLocally) {
    [self setNavigationBarStyle:LPVNavBarDefault];
  }
}

/* Prefer hiding the status bar if we're full screen. */
- (BOOL)prefersStatusBarHidden {
  return self.playerView.fullscreen;
}

#pragma mark - Managing the detail item

- (void)setMediaToPlay:(id)newMediaToPlay {
  if (_mediaToPlay != newMediaToPlay) {
    _mediaToPlay = newMediaToPlay;
    [self syncTextToMedia];
  }
}

- (void)syncTextToMedia {
  self.mediaTitle.text = self.mediaToPlay.title;
  self.mediaSubtitle.text = self.mediaToPlay.subtitle;
  self.mediaDescription.text = self.mediaToPlay.descrip;
}

#pragma mark - LocalPlayerController

/* Signal the requested style for the view. */
- (void)setNavigationBarStyle:(LPVNavBarStyle)style {
  if (style == LPVNavBarDefault) {
    self.edgesForExtendedLayout = UIRectEdgeAll;
    [self hideNavigationBar:NO];
    [self.navigationController.navigationBar setBackgroundImage:nil
                                                  forBarMetrics:UIBarMetricsDefault];
    self.navigationController.navigationBar.shadowImage = nil;
    [[UIApplication sharedApplication] setStatusBarHidden:NO
                                            withAnimation:UIStatusBarAnimationFade];
    self.navigationController.interactivePopGestureRecognizer.enabled = YES;
    _resetEdgesOnDisappear = NO;
  } else if(style == LPVNavBarTransparent) {
    self.edgesForExtendedLayout = UIRectEdgeNone;
    [self.navigationController.navigationBar setBackgroundImage:[UIImage new]
                                                  forBarMetrics:UIBarMetricsDefault];
    self.navigationController.navigationBar.shadowImage = [UIImage new];
    [[UIApplication sharedApplication] setStatusBarHidden:YES
                                            withAnimation:UIStatusBarAnimationFade];
    // Disable the swipe gesture if we're fullscreen.
    self.navigationController.interactivePopGestureRecognizer.enabled = NO;
    _resetEdgesOnDisappear = YES;
  }
}

/* Request the navigation bar to be hidden or shown. */
- (void)hideNavigationBar:(BOOL)hide {
  [self.navigationController.navigationBar setHidden:hide];
}

/* Play has been pressed in the LocalPlayerView. */
- (BOOL)continueAfterPlayButtonClicked {
  ChromecastDeviceController *controller = [ChromecastDeviceController sharedInstance];
  if (controller.deviceManager.applicationConnectionState == GCKConnectionStateConnected) {
    [self castCurrentMedia:0];
    return NO;
  }
  return YES;
}

- (void)castCurrentMedia:(NSTimeInterval)from {
  if (from < 0) {
    from = 0;
  }
  ChromecastDeviceController *controller = [ChromecastDeviceController sharedInstance];
  GCKMediaInformation *media =
  [GCKMediaInformation mediaInformationFromLocalMedia:self.mediaToPlay];
  CastViewController *vc = [controller.storyboard
                            instantiateViewControllerWithIdentifier:kCastViewController];
  [vc setMediaToPlay:media withStartingTime:from];
  [self.navigationController pushViewController:vc animated:YES];
}

/**
 * Called when connection to the device was established.
 */
- (void)didConnectToDevice {
  if (_playerView.playingLocally) {
    [_playerView pause];
    [self castCurrentMedia:_playerView.playbackTime];
  }

  [_playerView showSplashScreen];
}
@end