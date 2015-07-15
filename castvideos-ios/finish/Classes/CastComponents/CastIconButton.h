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

#import <UIKit/UIKit.h>

/**
 *  The possible states for the Cast button.
 */
typedef NS_ENUM(NSUInteger, CastIconButtonState){
  /**
   *  No cast devices available - hide the icon.
   */
  CIBCastUnavailable,
  /**
   *  Cast devices discovered.
   */
  CIBCastAvailable,
  /**
   *  Currently connecting to a device.
   */
  CIBCastConnecting,
  /**
   *  Connected.
   */
  CIBCastConnected
};

/**
 *  The CastIconButton is a Chromecast icon button that supports displaying connected,
 *  animating, and disconnected states. It will be hidden if no devices are available.
 */
@interface CastIconButton : UIButton

/**
 *  The displayed state of the button.
 */
@property(nonatomic) CastIconButtonState status;

/**
 *  Create a CastIconButton for the given frame
 *
 *  @param frame Display rectangle
 *
 *  @return A new button
 */
+ (CastIconButton *)buttonWithFrame:(CGRect)frame;

@end

/**
 *  Convenience wrapper for a UIBarButtonItem containing a CastIconButton.
 */
@interface CastIconBarButtonItem : UIBarButtonItem

/**
 *  Proxy for the underlying CastIconButton status.
 */
@property(nonatomic) CastIconButtonState status;

/**
 *  Return a UIBarButtonItem containing a CastIconButton
 *
 *  @param target   The target for the touchupinside event on the CastIconButton
 *  @param selector The selector to call for the above event
 *
 *  @return A new UIBarButtonItem
 */
+ (CastIconBarButtonItem *)barButtonItemWithTarget:(id)target selector:(SEL)selector;

@end
