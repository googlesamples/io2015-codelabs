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
    GCKLoggerDelegate,
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

/**
 *  Whether or not we are attempting reconnect.
 */
@property(nonatomic) BOOL isReconnecting;

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
  // Enable the logger.
  [[GCKLogger sharedInstance] setDelegate:self];
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

  if (self.manageToolbar) {
    [self updateToolbarForViewController:self.controller];
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

- (void)deviceManagerDidConnect:(GCKDeviceManager *)deviceManager {
  if(!self.isReconnecting
     || ![deviceManager.applicationMetadata.applicationID isEqualToString:_applicationID]) {
    [self.deviceManager launchApplication:_applicationID];
  } else {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString* lastSessionID = [defaults valueForKey:@"lastSessionID"];
    [self.deviceManager joinApplication:_applicationID sessionID:lastSessionID];
  }
  [self updateCastIconButtonStates];
}

- (void)deviceManager:(GCKDeviceManager *)deviceManager
    didConnectToCastApplication:(GCKApplicationMetadata *)applicationMetadata
            sessionID:(NSString *)sessionID
  launchedApplication:(BOOL)launchedApplication {
  self.mediaControlChannel = [[GCKMediaControlChannel alloc] init];
  self.mediaControlChannel.delegate = self;
  [self.deviceManager addChannel:self.mediaControlChannel];
  [self.mediaControlChannel requestStatus];
  [self updateCastIconButtonStates];
  [[NSNotificationCenter defaultCenter] postNotificationName:@"castApplicationConnected"
                                                      object:self];

  self.isReconnecting = NO;
  // Store sessionID in case of restart
  NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
  [defaults setObject:sessionID forKey:@"lastSessionID"];
  [defaults setObject:deviceManager.device.deviceID forKey:@"lastDeviceID"];
  [defaults synchronize];
}

- (void)deviceManager:(GCKDeviceManager *)deviceManager
    didFailToConnectToApplicationWithError:(NSError *)error {
  [self updateCastIconButtonStates];
}

- (void)deviceManager:(GCKDeviceManager *)deviceManager
    didFailToConnectWithError:(GCKError *)error {
  [self updateCastIconButtonStates];
  [self clearPreviousSession];
}

- (void)deviceManager:(GCKDeviceManager *)deviceManager didDisconnectWithError:(GCKError *)error {
  NSLog(@"Received notification that device disconnected");

  _mediaInformation = nil;
  [self updateCastIconButtonStates];

  if (error) {
    if (error.code == GCKErrorCodeDeviceAuthenticationFailure ||
        error.code == GCKErrorCodeDisconnected ||
        error.code == GCKErrorCodeApplicationNotFound) {
      [self clearPreviousSession];
    }
  }
}

- (void)deviceManager:(GCKDeviceManager *)deviceManager
  didDisconnectFromApplicationWithError:(NSError *)error {
  NSLog(@"Received notification that app disconnected");

  if (error) {
    NSLog(@"Application disconnected with error: %@", error);
  }

  [self updateCastIconButtonStates];
}

# pragma mark - GCKDeviceScannerListener

- (void)deviceDidComeOnline:(GCKDevice *)device {
  NSLog(@"device found - %@", device.friendlyName);

  [[NSNotificationCenter defaultCenter] postNotificationName:@"castScanStatusUpdated" object:self];
  [self updateCastIconButtonStates];

  NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
  NSString* lastDeviceID = [defaults objectForKey:@"lastDeviceID"];
  if(lastDeviceID != nil
     && [[device deviceID] isEqualToString:lastDeviceID]){
    self.isReconnecting = YES;
    [self connectToDevice:device];
  }
}

- (void)deviceDidGoOffline:(GCKDevice *)device {
  NSLog(@"device went offline - %@", device.friendlyName);
  [[NSNotificationCenter defaultCenter] postNotificationName:@"castScanStatusUpdated" object:self];
  [self updateCastIconButtonStates];
}

- (void)deviceDidChange:(GCKDevice *)device {
  [[NSNotificationCenter defaultCenter] postNotificationName:@"castScanStatusUpdated" object:self];
}

# pragma mark - Device & Media Management

- (void)connectToDevice:(GCKDevice *)device {
  NSLog(@"Connecting to device address: %@:%d", device.ipAddress, (unsigned int) device.servicePort);

  NSDictionary *info = [[NSBundle mainBundle] infoDictionary];
  NSString *appIdentifier = [info objectForKey:@"CFBundleIdentifier"];
  self.deviceManager =
  [[GCKDeviceManager alloc] initWithDevice:device clientPackageName:appIdentifier];
  self.deviceManager.delegate = self;
  [self.deviceManager connect];

  // Start animating the cast connect images.
  self.castIconButton.status = CIBCastConnecting;
}

- (BOOL)loadMedia:(GCKMediaInformation *)media
        startTime:(NSTimeInterval)startTime
         autoPlay:(BOOL)autoPlay {
  if (!self.deviceManager || self.deviceManager.connectionState != GCKConnectionStateConnected ) {
    return NO;
  }

  _mediaInformation = media;
  [self.mediaControlChannel loadMedia:media autoplay:autoPlay playPosition:startTime];

  return YES;
}

- (void)decorateViewController:(UIViewController *)controller {
  self.controller = controller;
  if (_controller) {
    self.manageToolbar = false;
    _controller.navigationItem.rightBarButtonItem = _castIconButton;
  }
}

- (void)updateToolbarForViewController:(UIViewController *)viewController {
  self.manageToolbar = YES;
  [self.castMiniController updateToolbarStateIn:viewController
                            forMediaInformation:self.mediaInformation
                                    playerState:self.playerState];
}

#pragma mark - GCKMediaControlChannelDelegate methods

- (void)mediaControlChannelDidUpdateStatus:(GCKMediaControlChannel *)mediaControlChannel {
  NSLog(@"Media control channel status changed");
  _mediaInformation = mediaControlChannel.mediaStatus.mediaInformation;
  [[NSNotificationCenter defaultCenter] postNotificationName:@"castMediaStatusChange" object:self];
  [self updateCastIconButtonStates];
}

- (void)mediaControlChannelDidUpdateMetadata:(GCKMediaControlChannel *)mediaControlChannel {
  NSLog(@"Media control channel metadata changed");
  [[NSNotificationCenter defaultCenter] postNotificationName:@"castMediaStatusChange" object:self];
}

# pragma mark - Reconnection

- (void)clearPreviousSession {
  NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
  [defaults removeObjectForKey:@"lastDeviceID"];
  [defaults synchronize];
}

#pragma mark - GCKLoggerDelegate implementation

- (void)logFromFunction:(const char *)function message:(NSString *)message {
  // Send SDK’s log messages directly to the console, as an example.
  NSLog(@"%s  %@", function, message);
}

@end
