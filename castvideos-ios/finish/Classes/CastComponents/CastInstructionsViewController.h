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

#import <UIKit/UIKit.h>

/**
 *  A overlay "cling" that describes how to use Cast for new users.
 *  Generally shown the first time the Cast icon appears in the application.
 */
@interface CastInstructionsViewController : UIViewController

/**
 *  Helper class method for deciding whether to show instructions or not
 *
 *  @param viewController The UIViewController to overlay.
 */
+(void)showIfFirstTimeOverViewController:(UIViewController *)viewController;

/**
 *  Whether the instructions cling will appear or not.
 *
 *  @return YES if the user has seen the cling.
 */
+(BOOL)hasSeenInstructions;

/**
 *  Represents the entire overlay with instructions for first time Cast users.
 */
@property(nonatomic, strong) IBOutlet UIView *overlayView;

/**
 *  Dismisses the entire overlay
 *
 *  @param sender Message sender
 */
- (IBAction)dismissOverlay:(id)sender;

@end
