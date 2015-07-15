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

#import <GoogleCast/GCKMediaControlChannel.h>
#import <GoogleCast/GCKMediaInformation.h>
#import <GoogleCast/GCKMediaStatus.h>
#import <GoogleCast/GCKMediaTrack.h>

#import "TracksTableViewController.h"

@interface TracksTableViewController ()

@property(nonatomic) UIStatusBarStyle statusBarStyle;
@property(weak, nonatomic) GCKMediaControlChannel *controlChannel;
@property(weak, nonatomic) GCKMediaInformation* media;
@property(strong, nonatomic) NSMutableArray* tracks;
@property(nonatomic) GCKMediaTrackType type;
@property(nonatomic) BOOL toolbarWasShowing;
@property(nonatomic) NSNumber *currSelected;
@property(nonatomic) NSNumber *currSelectedRow;
@end

@implementation TracksTableViewController

- (void)viewWillAppear:(BOOL)animated {
  [super viewWillAppear:animated];
  if (!self.navigationController.toolbarHidden) {
    self.toolbarWasShowing = true;
    [self.navigationController setToolbarHidden:YES animated:animated];
  }
  NSString *title = self.type == GCKMediaTrackTypeAudio ? @"Audio Tracks" : @"Subtitles";
  [self.tabBarController.navigationItem setTitle:title];
  self.statusBarStyle = [UIApplication sharedApplication].statusBarStyle;
  [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
}

- (void)viewWillDisappear:(BOOL)animated {
  [super viewWillDisappear:animated];
  if (self.toolbarWasShowing) {
    [self.navigationController setToolbarHidden:NO animated:animated];
  }
  [[UIApplication sharedApplication] setStatusBarStyle:_statusBarStyle];
}

- (void)viewDidAppear:(BOOL)animated {
  [super viewDidAppear:animated];
  NSIndexPath *indexPath = [NSIndexPath indexPathForRow:[self.currSelectedRow integerValue]
                                              inSection:0];
  [self.tableView selectRowAtIndexPath:indexPath animated:YES
                        scrollPosition:UITableViewScrollPositionTop];
}

- (void)setMedia:(GCKMediaInformation *)media
         forType:(GCKMediaTrackType)type
    deviceController:(GCKMediaControlChannel *)controlChannel {
  self.tracks = [[NSMutableArray alloc] init];
  self.type = type;
  self.controlChannel = controlChannel;
  NSInteger i = 1;
  NSArray *activeTracks = _controlChannel.mediaStatus.activeTrackIDs;
  for(GCKMediaTrack *track in media.mediaTracks) {
    if (track.type == type) {
      NSNumber *trackId = [NSNumber numberWithInteger:track.identifier];
      if (activeTracks && [activeTracks containsObject:trackId]) {
        self.currSelected = trackId;
        self.currSelectedRow = @(i);
      }
      [self.tracks addObject:track];
      i++;
    }
  }
  [self.tableView reloadData];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
  return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
  return [self.tracks count] + 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
  UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"trackcell"
                                                          forIndexPath:indexPath];
  if (!cell) {
    cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                  reuseIdentifier:@"trackcell"];
  }
  NSInteger row = indexPath.row;
  if(row == 0) {
    cell.textLabel.text = self.type == GCKMediaTrackTypeText ? @"None" : @"Default";
  } else {
    row--;
    GCKMediaTrack *track = self.tracks[row];
    cell.textLabel.text = track.name;
  }

  return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
  NSMutableArray *tracks = [NSMutableArray arrayWithArray:_controlChannel.mediaStatus.activeTrackIDs];
  NSInteger row = indexPath.row;
  if (self.currSelected) {
    [tracks removeObjectIdenticalTo:self.currSelected];
  }
  if (row > 0) {
    row--;
    GCKMediaTrack *track = self.tracks[row];
    NSNumber *trackIdentifier  = [NSNumber numberWithInteger:track.identifier];
    [tracks addObject:trackIdentifier];
    self.currSelected = trackIdentifier;
  } else {
    self.currSelected = nil;
  }
  [_controlChannel setActiveTrackIDs:tracks];
}

@end
