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

#import <CommonCrypto/CommonDigest.h>
#import "SimpleImageFetcher.h"

@implementation SimpleImageFetcher

+ (UIImage *)scaleImage:(UIImage *)image toSize:(CGSize)newSize {
  CGSize scaledSize = newSize;
  float scaleFactor = 1.0;
  if (image.size.width > image.size.height) {
    scaleFactor = image.size.width / image.size.height;
    scaledSize.width = newSize.width;
    scaledSize.height = newSize.height / scaleFactor;
  } else {
    scaleFactor = image.size.height / image.size.width;
    scaledSize.height = newSize.height;
    scaledSize.width = newSize.width / scaleFactor;
  }

  UIGraphicsBeginImageContextWithOptions(scaledSize, NO, 0.0);
  CGRect scaledImageRect = CGRectMake(0.0, 0.0, scaledSize.width, scaledSize.height);
  [image drawInRect:scaledImageRect];
  UIImage *scaledImage = UIGraphicsGetImageFromCurrentImageContext();
  UIGraphicsEndImageContext();

  return scaledImage;
}

+ (NSData *)getDataFromImageURL:(NSURL *)urlToFetch {
  NSFileManager *fileManager = [NSFileManager defaultManager];

  NSString *cacheFileName = [self sha1HashForString:[urlToFetch absoluteString]];
  NSURL *cacheDirectory =
      [[[fileManager URLsForDirectory:NSCachesDirectory inDomains:NSUserDomainMask] lastObject]
          URLByAppendingPathComponent:@"thumbnails"];
  NSURL *cacheFileURL = [cacheDirectory URLByAppendingPathComponent:cacheFileName];

  if ([fileManager fileExistsAtPath:[cacheFileURL path]]) {
    // Cache hit!
    return [[NSData alloc] initWithContentsOfURL:cacheFileURL];
  } else {
    // Retrieve the data from the internet
    NSData *imageData = [[NSData alloc] initWithContentsOfURL:urlToFetch];

    // Create the cache directory, if needed
    NSError *error;
    if (![fileManager fileExistsAtPath:[cacheDirectory path]]) {
      [fileManager createDirectoryAtURL:cacheDirectory
            withIntermediateDirectories:YES
                             attributes:nil
                                  error:&error];
      if (error) {
        NSLog(@"Received an error trying to create a directory %@", [error localizedDescription]);
      }
    }
    error = nil;

    // Write the image to our cache
    [imageData writeToURL:cacheFileURL options:NSDataWritingAtomic error:&error];
    if (error) {
      NSLog(@"Received an error trying to save a cached file %@", [error localizedDescription]);
    }
    return imageData;
  }

}

+ (NSString *)sha1HashForString: (NSString *) input {
  NSData *data = [input dataUsingEncoding:NSUTF8StringEncoding];

  uint8_t digest[CC_SHA1_DIGEST_LENGTH];

  CC_SHA1([data bytes], (CC_LONG)[data length], digest);

  NSMutableString *hash = [NSMutableString stringWithCapacity:40];
  for (int i = 0; i < CC_SHA1_DIGEST_LENGTH; i++)
    [hash appendFormat:@"%02x", digest[i]];
  
  return hash;
}

@end