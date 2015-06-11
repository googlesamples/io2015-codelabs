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

#import "CastIconButton.h"

/**
 *  How long the Cast connecting animation should take to loop.
 */
static const int kCastIconButtonAnimationDuration = 2;

@interface CastIconButton ()

/**
 *  The image containing the empty cast icon.
 */
@property(nonatomic) UIImage* castOff;
/**
 *  The image with the filled cast icon.
 */
@property(nonatomic) UIImage* castOn;
/**
 *  The loop of images for animating.
 */
@property(nonatomic) NSArray* castConnecting;

@end

@implementation CastIconButton

/**
 *  Convenience method for creating a button.
 *
 *  @param frame The frame rectangle for the button.
 *
 *  @return A ready to use CastIconButton.
 */
+ (CastIconButton *)buttonWithFrame:(CGRect)frame {
  return [[CastIconButton alloc] initWithFrame:frame ];
}

/**
 *  Designated initialiser. Create a new CastIconButton within the given frame.
 *
 *  @param frame Frame rectangle
 *
 *  @return a new CastIconButton
 */
- (instancetype)initWithFrame:(CGRect)frame{
  self = [super initWithFrame:frame];
  if (self) {
    self.castOff = [[UIImage imageNamed:@"cast_off"]
                    imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    self.castOn = [[UIImage imageNamed:@"cast_on"]
                   imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    self.castConnecting = @[
                              [[UIImage imageNamed:@"cast_on0"]
                                imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate],
                              [[UIImage imageNamed:@"cast_on1"]
                                 imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate],
                              [[UIImage imageNamed:@"cast_on2"]
                                 imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate],
                              [[UIImage imageNamed:@"cast_on1"]
                                 imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate]];
    self.imageView.animationImages = self.castConnecting;
    self.imageView.animationDuration = kCastIconButtonAnimationDuration;
    self.status = CIBCastUnavailable;
  }
  return self;
}

/**
 *  Update the display of the button based on the status.
 *
 *  @param status The current status of the cast devices.
 */
- (void)setStatus:(CastIconButtonState)status {
  _status = status;
  switch(status) {
    case CIBCastUnavailable:
      [self.imageView stopAnimating];
      [self setHidden:YES];
      break;
    case CIBCastAvailable:
      [self setHidden:NO];
      [self.imageView stopAnimating];
      [self setImage:self.castOff forState:UIControlStateNormal];
      [self setTintColor:self.superview.tintColor];
      break;
    case CIBCastConnecting:
      [self setHidden:NO];
      [self.imageView startAnimating];
      [self setTintColor:self.superview.tintColor];
      break;
    case CIBCastConnected:
      [self setHidden:NO];
      [self.imageView stopAnimating];
      [self setImage:self.castOn forState:UIControlStateNormal];
      [self setTintColor:[UIColor yellowColor]];
      break;
  }
}

@end

@interface CastIconBarButtonItem ()

/**
 *  Convenience reference to the backing CastIconButton.
 */
@property(nonatomic) CastIconButton *button;

@end

@implementation CastIconBarButtonItem

/**
 *  Return a UIBarButtonItem which wraps a CastIconButton.
 *
 *  @param target   The target object for the touch event.
 *  @param selector The target selector for the touch event.
 *
 *  @return UIBarButtonItem containing a CastIconButton.
 */
+ (CastIconBarButtonItem *)barButtonItemWithTarget:(id)target
                                    selector:(SEL)selector {
  CastIconButton *button = [CastIconButton buttonWithFrame:CGRectMake(0, 0, 29, 22)];
  [button addTarget:target action:selector forControlEvents:UIControlEventTouchUpInside];
  CastIconBarButtonItem *barButton = [[self alloc] initWithCustomView:button];
  barButton.button = button;
  return barButton;
}

/**
 *  Set the CastIconButton status.
 *
 *  @param status Current Cast device status.
 */
- (void)setStatus:(CastIconButtonState)status {
  self.button.status = status;
}

/**
 *  Retrieve the current Cast Icon Button status.
 *
 *  @return The currently understood status.
 */
- (CastIconButtonState)status {
  return self.button.status;
}

@end
