//
//  UIViewController+KSOColorPickerExtensions.m
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
