//
//  UIViewController+KSOColorPickerExtensions.h
//  KSOColorPicker-iOS
//
//  Created by William Towe on 9/10/18.
//  Copyright © 2018 Kosoku Interactive, LLC. All rights reserved.
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//  http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

/**
 Block that is invoked when the user has chosen a color or cancelled the interaction.
 
 @param color The color that was chosen or nil
 */
typedef void(^KSOColorPickerViewControllerCompletionBlock)(UIColor * _Nullable color);

@class KSOColorPickerViewController;

/**
 Convenience category methods to present or push a KSOColorPickerViewController instance and invoke a completion block when the user finishes interacting with the view controller.
 */
@interface UIViewController (KSOColorPickerExtensions)

/**
 Presents the *viewController* instance, optionally *animated*, and invokes the *completion* block when the interaction is finished.
 
 @param viewController The view controller to present
 @param animated Whether to animate the presentation
 @param completion The block to invoke when the interaction is finished
 */
- (void)KSO_presentColorPickerViewController:(KSOColorPickerViewController *)viewController animated:(BOOL)animated completion:(KSOColorPickerViewControllerCompletionBlock)completion;
/**
 Pushes the *viewController* on the receiver's *navigationController* stack, optionally *animated*, and invokes the *completion* block when the interaction is finished.
 
 @param viewController The view controller to push
 @param animated Whether to animate the push
 @param completion The block to invoke when the interaction is finished
 */
- (void)KSO_pushColorPickerViewController:(KSOColorPickerViewController *)viewController animated:(BOOL)animated completion:(KSOColorPickerViewControllerCompletionBlock)completion;

@end

NS_ASSUME_NONNULL_END
