//
//  UIViewController+KSOColorPickerExtensions.h
//  KSOColorPicker-iOS
//
//  Created by William Towe on 9/10/18.
//  Copyright © 2018 Kosoku Interactive, LLC. All rights reserved.
//
//  Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:
//
//  1. Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
//
//  2. Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
//
//  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

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
