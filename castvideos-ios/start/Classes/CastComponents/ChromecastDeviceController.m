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

#import "CastMiniController.h"
#import "CastIconButton.h"
#import "CastInstructionsViewController.h"
#import "CastViewController.h"
#import "ChromecastDeviceController.h"
#import "DeviceTableViewController.h"

#import <GoogleCast/GoogleCast.h>

/**
 *  Constant for the storyboard ID for the device table view controller.
 */
static NSString * const kDeviceTableViewController = @"deviceTableViewController";

/**
 *  Constant for the storyboard ID for the expanded view Cast controller.
 */
NSString * const kCastViewController = @"castViewController";

@interface ChromecastDeviceController() <
    CastMiniControllerDelegate,
    DeviceTableViewControllerDelegate,
    GCKDeviceManagerDelegate,
    GCKMediaControlChannelDelegate
>

/**
 *  The core storyboard containing the UI for the Cast components.
 */
@property(nonatomic, readwrite) UIStoryboard *storyboard;

/**
 *  The (optional) view controller that we are managing.
 */
@property(nonatomic) UIViewController *controller;

/**
 *  The Cast Icon Button controlled by this class.
 */
@property(nonatomic) CastIconBarButtonItem *castIconButton;

/**
 *  The Cast Mini Controller controlled by this class.
 */
@property(nonatomic) CastMiniController *castMiniController;

/**
 *  Whehter we are automatically adding the toolbar.
 */
@property(nonatomic) BOOL manageToolbar;

@end

@implementation ChromecastDeviceController

#pragma mark - Lifecycle

+ (instancetype)sharedInstance {
  static dispatch_once_t p = 0;
  __strong static id _sharedDeviceController = nil;

  dispatch_once(&p, ^{
    _sharedDeviceController = [[self alloc] init];
  });

  return _sharedDeviceController;
}

- (instancetype)init {
  self = [super init];
  if (self) {
    // Initialize UI controls for navigation bar and tool bar.
    [self initControls];

    // Load the storyboard for the Cast component UI.
    self.storyboard = [UIStoryboard storyboardWithName:@"CastComponents" bundle:nil];
  }
  return self;
}


# pragma mark - Acessors

- (GCKMediaPlayerState)playerState {
  return _mediaControlChannel.mediaStatus.playerState;
}

- (NSTimeInterval)streamDuration {
  return _mediaInformation.streamDuration;
}

- (NSTimeInterval)streamPosition {
  return [_mediaControlChannel approximateStreamPosition];
}

- (void)setPlaybackPercent:(float)newPercent {
  newPercent = MAX(MIN(1.0, newPercent), 0.0);
  NSTimeInterval newTime = newPercent * self.streamDuration;
  if (newTime > 0 && _deviceManager.applicationConnectionState == GCKConnectionStateConnected) {
    [self.mediaControlChannel seekToTimeInterval:newTime];
  }
}

# pragma mark - UI Management

- (void)chooseDevice:(id)sender {
  BOOL showPicker = YES;
  if (_delegate && [_delegate respondsToSelector:@selector(shouldDisplayModalDeviceController)]) {
    showPicker = [_delegate shouldDisplayModalDeviceController];
  }
  if (self.controller) {
    UINavigationController *dtvc = (UINavigationController *)[_storyboard instantiateViewControllerWithIdentifier:kDeviceTableViewController];
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
      dtvc.modalPresentationStyle = UIModalPresentationFormSheet;
    }
    ((DeviceTableViewController *)dtvc.viewControllers[0]).delegate = self;
    [self.controller presentViewController:dtvc animated:YES completion:nil];
  }
}

- (void)dismissDeviceTable {
  [self.controller dismissViewControllerAnimated:YES completion:nil];
}

- (void)updateCastIconButtonStates {
  if (self.deviceScanner.devices.count == 0) {
    _castIconButton.status = CIBCastUnavailable;
  } else if (self.deviceManager.applicationConnectionState == GCKConnectionStateConnecting) {
    _castIconButton.status = CIBCastConnecting;
  } else if (self.deviceManager.applicationConnectionState == GCKConnectionStateConnected) {
    _castIconButton.status = CIBCastConnected;
  } else {
    _castIconButton.status = CIBCastAvailable;
    // Show cast icon. If this is the first time the cast icon is appearing, show an overlay with
    // instructions highlighting the cast icon.
    if (self.controller) {
      [CastInstructionsViewController showIfFirstTimeOverViewController:self.controller];
    }
  }
}

- (void)initControls {
  self.castIconButton = [CastIconBarButtonItem barButtonItemWithTarget:self
                                                              selector:@selector(chooseDevice:)];
  self.castMiniController = [[CastMiniController alloc] initWithDelegate:self];
}

- (void)displayCurrentlyPlayingMedia {
  if (self.controller) {
    CastViewController *vc =
        [_storyboard instantiateViewControllerWithIdentifier:kCastViewController];
    [vc setMediaToPlay:self.mediaInformation];
    [self.controller.navigationController pushViewController:vc animated:YES];
  }
}

# pragma mark - GCKDeviceManagerDelegate

- (void)deviceManager:(GCKDeviceManager *)deviceManager
    volumeDidChangeToLevel:(float)volumeLevel
                   isMuted:(BOOL)isMuted {
  [[NSNotificationCenter defaultCenter] postNotificationName:@"castVolumeChanged" object:self];
}

# pragma mark - GCKDeviceScannerListener

# pragma mark - Device & Media Management

- (void)connectToDevice:(GCKDevice *)device {
  
}

- (BOOL)loadMedia:(GCKMediaInformation *)media
        startTime:(NSTimeInterval)startTime
         autoPlay:(BOOL)autoPlay {
  return NO;
}

- (void)decorateViewController:(UIViewController *)controller {
  self.controller = controller;
  if (_controller) {

  }
}

@end
