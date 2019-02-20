//
//  UIViewController+KSOColorPickerExtensions.m
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

#import "UIViewController+KSOColorPickerExtensions.h"
#import "KSOColorPickerViewController.h"

#import <objc/runtime.h>

@interface KSOColorPickerViewControllerDelegateWrapper : NSObject <KSOColorPickerViewControllerDelegate>
@property (weak,nonatomic) UIViewController *viewController;
@property (weak,nonatomic) KSOColorPickerViewController *colorPickerViewController;
@property (assign,nonatomic) BOOL animated;
@property (copy,nonatomic) KSOColorPickerViewControllerCompletionBlock completion;

- (instancetype)initWithViewController:(UIViewController *)viewController colorPickerViewController:(KSOColorPickerViewController *)colorPickerViewController animated:(BOOL)animated completion:(KSOColorPickerViewControllerCompletionBlock)completion;

- (void)present;
- (void)push;
@end

@interface UIViewController (KSOColorPickerPrivateExtensions)
@property (strong,nonatomic) KSOColorPickerViewControllerDelegateWrapper *KSO_colorPickerViewControllerDelegateWrapper;
@end

@implementation UIViewController (KSOColorPickerExtensions)

- (void)KSO_presentColorPickerViewController:(KSOColorPickerViewController *)viewController animated:(BOOL)animated completion:(KSOColorPickerViewControllerCompletionBlock)completion {
    viewController.KSO_colorPickerViewControllerDelegateWrapper = [[KSOColorPickerViewControllerDelegateWrapper alloc] initWithViewController:self colorPickerViewController:viewController animated:animated completion:completion];
    
    [viewController.KSO_colorPickerViewControllerDelegateWrapper present];
}
- (void)KSO_pushColorPickerViewController:(KSOColorPickerViewController *)viewController animated:(BOOL)animated completion:(KSOColorPickerViewControllerCompletionBlock)completion {
    viewController.KSO_colorPickerViewControllerDelegateWrapper = [[KSOColorPickerViewControllerDelegateWrapper alloc] initWithViewController:self colorPickerViewController:viewController animated:animated completion:completion];
    
    [viewController.KSO_colorPickerViewControllerDelegateWrapper push];
}

@end

@implementation UIViewController (KSOColorPickerPrivateExtensions)

static void const *kKSO_colorPickerViewControllerDelegateWrapperKey = &kKSO_colorPickerViewControllerDelegateWrapperKey;
- (KSOColorPickerViewControllerDelegateWrapper *)KSO_colorPickerViewControllerDelegateWrapper {
    return objc_getAssociatedObject(self, kKSO_colorPickerViewControllerDelegateWrapperKey);
}
- (void)setKSO_colorPickerViewControllerDelegateWrapper:(KSOColorPickerViewControllerDelegateWrapper *)KSO_colorPickerViewControllerDelegateWrapper {
    objc_setAssociatedObject(self, kKSO_colorPickerViewControllerDelegateWrapperKey, KSO_colorPickerViewControllerDelegateWrapper, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

@end

@implementation KSOColorPickerViewControllerDelegateWrapper

- (void)colorPickerViewController:(KSOColorPickerViewController *)viewController didFinishPickingColor:(UIColor *)color {
    self.completion(color);
}
- (void)colorPickerViewControllerDidCancel:(KSOColorPickerViewController *)viewController {
    self.completion(nil);
}

- (instancetype)initWithViewController:(UIViewController *)viewController colorPickerViewController:(KSOColorPickerViewController *)colorPickerViewController animated:(BOOL)animated completion:(KSOColorPickerViewControllerCompletionBlock)completion {
    if (!(self = [super init]))
        return nil;
    
    _viewController = viewController;
    _colorPickerViewController = colorPickerViewController;
    _colorPickerViewController.delegate = self;
    _animated = animated;
    _completion = [completion copy];
    
    return self;
}

- (void)present; {
    [self.viewController presentViewController:[[UINavigationController alloc] initWithRootViewController:self.colorPickerViewController] animated:self.animated completion:nil];
}
- (void)push; {
    [self.viewController.navigationController pushViewController:self.colorPickerViewController animated:self.animated];
}

@end
