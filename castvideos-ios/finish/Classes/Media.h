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

#import <Foundation/Foundation.h>

#define MEDIA_URL_BASE @"http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/"
#define MEDIA_URL_FILE @"d.json"

/**
 * Defines a media object that can be played back on Chromcast device.
 */
@interface Media : NSObject

@property(nonatomic, copy) NSString *title;
@property(nonatomic, copy) NSString *descrip;
@property(nonatomic, copy) NSString *mimeType;
@property(nonatomic, copy) NSString *subtitle;
@property(nonatomic, strong) NSURL *URL;
@property(nonatomic, strong) NSURL *thumbnailURL;
@property(nonatomic, strong) NSURL *posterURL;
@property(nonatomic, strong) NSArray *tracks;

/**
 *  Creates a Media object given a JSON dictionary.
 *
 *  @param jsonAsDict The media JSON response as an NSDictionary
 *
 *  @return Media
 */
+ (id)mediaFromExternalJSON:(NSDictionary *)jsonAsDict;

@end