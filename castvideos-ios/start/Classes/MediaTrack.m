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
#import "MediaTrack.h"

#define KEY_TRACK_ID @"id"
#define KEY_TRACK_TYPE @"type"
#define KEY_TRACK_SUBTYPE @"subtype"
#define KEY_TRACK_URL @"contentId"
#define KEY_TRACK_NAME @"name"
#define KEY_TRACK_MIME @"name"
#define KEY_TRACK_LANGUAGE @"language"

@implementation MediaTrack

+ (id)trackFromExternalJSON:(NSDictionary *)jsonAsDict {
  MediaTrack *newMedia = [[MediaTrack alloc] initWithExternalJSON:jsonAsDict];
  return newMedia;
}

- (instancetype)init {
  return [self initWithExternalJSON:[NSDictionary dictionary]];
}

- (instancetype)initWithExternalJSON:(NSDictionary *)jsonAsDict {
  self = [super init];
  if (self) {
    self.identifier = [[jsonAsDict objectForKey:KEY_TRACK_ID] integerValue];
    self.type = [jsonAsDict objectForKey:KEY_TRACK_TYPE];
    self.subtype = [jsonAsDict objectForKey:KEY_TRACK_SUBTYPE];
    self.url = [NSURL URLWithString:[jsonAsDict objectForKey:KEY_TRACK_URL]];
    self.name = [jsonAsDict objectForKey:KEY_TRACK_NAME];
    self.language = [jsonAsDict objectForKey:KEY_TRACK_LANGUAGE];
  }
  return self;
}

@end

