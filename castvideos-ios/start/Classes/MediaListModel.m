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

#import "MediaListModel.h"

@implementation MediaListModel {
  /** Storage for the list of Media objects. */
  NSArray *_medias;
}

- (void)loadMedia:(void (^)(void))callbackBlock {
  // Asynchronously load the media json
  NSOperationQueue *queue = [[NSOperationQueue alloc] init];

  NSURL *mediaURL = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@", MEDIA_URL_BASE, MEDIA_URL_FILE]];
  NSURLRequest *request = [NSURLRequest requestWithURL:mediaURL];
  [NSURLConnection sendAsynchronousRequest:request
                  queue:queue
      completionHandler:^(NSURLResponse *response, NSData *jsonData, NSError *connectionError) {
        if (connectionError) {
          // Handle error here.
          NSLog(@"Media list fetch error! %@", [connectionError localizedDescription]);
          return;
        }
        NSError *error;
        NSDictionary *mediaData;

        NSMutableArray *mediaBuilder = [[NSMutableArray alloc] initWithCapacity:10];
        if (jsonData) {
          mediaData =
          [NSJSONSerialization JSONObjectWithData:jsonData options:kNilOptions error:&error];
        } else {
          NSLog(@"Media data was nil - maybe a problem contacting the server.");
        }
        if (error) {
          // Handle error here
          NSLog(@"Oh no! We got an error loading up our media data! %@",
                [error localizedDescription]);
        } else {
          if (mediaData && [mediaData isKindOfClass:[NSDictionary class]]) {
            NSArray *categories = [mediaData objectForKey:@"categories"];
            if (categories && [categories isKindOfClass:[NSArray class]]) {
              for (NSDictionary *category in categories) {
                NSArray *mediaList = [category objectForKey:@"videos"];
                if (mediaList && [mediaList isKindOfClass:[NSArray class]]) {
                  self.mediaTitle = [category objectForKey:@"name"];
                  for (NSDictionary *mediaObjectAsDict in mediaList) {
                    Media *nextMedia = [Media mediaFromExternalJSON:mediaObjectAsDict];
                    [mediaBuilder addObject:nextMedia];
                  }
                  break;
                }
              }
            }
          }
        }
        _medias = [mediaBuilder copy];

        // Call the callback!
        dispatch_async(dispatch_get_main_queue(), ^{
          callbackBlock();
        });
      }];
}

- (int)numberOfMediaLoaded {
  return (int)[_medias count];
}

- (Media *)mediaAtIndex:(int)index {
  return (Media *)[_medias objectAtIndex:index];
}

- (int)indexOfMediaByTitle:(NSString *)title {
  for (int i = 0; i < self.numberOfMediaLoaded; i++) {
    Media *media = [self mediaAtIndex:i];
    if ([media.title isEqualToString:title]) {
      return i;
    }
  }
  return -1;
}

@end