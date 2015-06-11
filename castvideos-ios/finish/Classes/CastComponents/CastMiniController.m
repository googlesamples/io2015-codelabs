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
#import <GoogleCast/GoogleCast.h>
#import "SimpleImageFetcher.h"

@interface CastMiniController ()

@property(nonatomic,weak) id<CastMiniControllerDelegate> delegate;
@property(nonatomic) NSArray *idleStateToolbarButtons;
@property(nonatomic) NSArray *playStateToolbarButtons;
@property(nonatomic) NSArray *pauseStateToolbarButtons;
@property(nonatomic) UIImageView *toolbarThumbnailImage;
@property(nonatomic) NSURL *toolbarThumbnailURL;
@property(nonatomic) UILabel *toolbarTitleLabel;
@property(nonatomic) UILabel *toolbarSubTitleLabel;

@end

@implementation CastMiniController

- (instancetype)init {
  return [self initWithDelegate:nil];
}

- (instancetype)initWithDelegate:(id<CastMiniControllerDelegate>)delegate {
  self = [super init];
  if (self) {
    self.delegate = delegate;

    // Create toolbar buttons for the mini player.
    CGRect frame = CGRectMake(0, 0, 49, 37);
    _toolbarThumbnailImage =
      [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"video_thumb_mini.png"]];
    _toolbarThumbnailImage.frame = frame;
    _toolbarThumbnailImage.contentMode = UIViewContentModeScaleAspectFit;
    UIButton *someButton = [[UIButton alloc] initWithFrame:frame];
    [someButton addSubview:_toolbarThumbnailImage];
    [someButton addTarget:self
                   action:@selector(showMedia)
         forControlEvents:UIControlEventTouchUpInside];
    [someButton setShowsTouchWhenHighlighted:YES];
    UIBarButtonItem *thumbnail = [[UIBarButtonItem alloc] initWithCustomView:someButton];

    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    [btn setFrame:CGRectMake(0, 0, 200, 45)];
    _toolbarTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 185, 30)];
    _toolbarTitleLabel.backgroundColor = [UIColor clearColor];
    _toolbarTitleLabel.font = [UIFont systemFontOfSize:17];
    _toolbarTitleLabel.text = @"This is the title";
    _toolbarTitleLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    _toolbarTitleLabel.textColor = [UIColor blackColor];
    [btn addSubview:_toolbarTitleLabel];

    _toolbarSubTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 15, 185, 30)];
    _toolbarSubTitleLabel.backgroundColor = [UIColor clearColor];
    _toolbarSubTitleLabel.font = [UIFont systemFontOfSize:14];
    _toolbarSubTitleLabel.text = @"This is the sub";
    _toolbarSubTitleLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    _toolbarSubTitleLabel.textColor = [UIColor grayColor];
    [btn addSubview:_toolbarSubTitleLabel];
    [btn addTarget:self action:@selector(showMedia) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *titleBtn = [[UIBarButtonItem alloc] initWithCustomView:btn];

    UIBarButtonItem *flexibleSpaceLeft =
    [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
                                                  target:nil
                                                  action:nil];

    UIBarButtonItem *playButton =
    [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemPlay
                                                  target:self
                                                  action:@selector(playMedia)];
    playButton.tintColor = [UIColor blackColor];

    UIBarButtonItem *pauseButton =
    [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemPause
                                                  target:self
                                                  action:@selector(pauseMedia)];
    pauseButton.tintColor = [UIColor blackColor];

    _idleStateToolbarButtons =
        [NSArray arrayWithObjects:thumbnail, titleBtn, flexibleSpaceLeft, nil];
    _playStateToolbarButtons =
        [NSArray arrayWithObjects:thumbnail, titleBtn, flexibleSpaceLeft, pauseButton, nil];
    _pauseStateToolbarButtons =
        [NSArray arrayWithObjects:thumbnail, titleBtn, flexibleSpaceLeft, playButton, nil];
  }
  return self;
}

# pragma mark - Actions

- (void)showMedia {
  if (self.delegate) {
    [self.delegate displayCurrentlyPlayingMedia];
  }
}

- (void)playMedia {
  if ([_delegate mediaControlChannel]) {
    [[_delegate mediaControlChannel] play];
  }
}

- (void)pauseMedia {
  if ([_delegate mediaControlChannel]) {
    [[_delegate mediaControlChannel] pause];
  }
}

# pragma mark - Implementation

- (void)updateToolbarStateIn:(UIViewController *)viewController
         forMediaInformation:(GCKMediaInformation *)info
                 playerState:(GCKMediaPlayerState)state {
  // Ignore this view controller if it is not visible.
  if (!(viewController.isViewLoaded && viewController.view.window)) {
    return;
  }

  // If we have no data, hide the toolbar.
  if (!info || ![info.metadata stringForKey:kGCKMetadataKeyTitle]){
    viewController.navigationController.toolbarHidden = YES;
    return;
  } else {
    viewController.navigationController.toolbarHidden = NO;
  }

  // Update the play/pause state.
  if (state == GCKMediaPlayerStateUnknown || state == GCKMediaPlayerStateIdle) {
    viewController.toolbarItems = self.idleStateToolbarButtons;
  } else {
    BOOL playing = (state == GCKMediaPlayerStatePlaying ||
                    state == GCKMediaPlayerStateBuffering);
    if (playing) {
      viewController.toolbarItems = self.playStateToolbarButtons;
    } else {
      viewController.toolbarItems = self.pauseStateToolbarButtons;
    }
  }

  // Update the title.
  self.toolbarTitleLabel.text = [info.metadata stringForKey:kGCKMetadataKeyTitle];
  self.toolbarSubTitleLabel.text = [info.metadata stringForKey:kGCKMetadataKeySubtitle];

  // Update the image.
  GCKImage *img = [info.metadata.images objectAtIndex:0];
  if ([img.URL isEqual:self.toolbarThumbnailURL]) {
    return;
  }

  //Loading thumbnail async
  dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
    UIImage *image = [UIImage imageWithData:[SimpleImageFetcher getDataFromImageURL:img.URL]];

    dispatch_async(dispatch_get_main_queue(), ^{
      self.toolbarThumbnailURL = img.URL;
      self.toolbarThumbnailImage.image = image;
    });
  });
}

@end
