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

@interface SimpleImageFetcher : NSObject

/**
 *  Retrieve an image from the network or local cache.
 *
 *  @param urlToFetch URL of an image.
 *
 *  @return The bytes ready for decoding into a UIImage.
 */
+ (NSData *)getDataFromImageURL:(NSURL *)urlToFetch;

/**
 *  Resize a given image to the desired width and height.
 *
 *  @param image   the image to resize
 *  @param newSize the width and height of the new image
 *
 *  @return a separate resized version of the image.
 */
+ (UIImage *)scaleImage:(UIImage *)image toSize:(CGSize)newSize;

@end