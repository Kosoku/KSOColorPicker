//
//  KSOColorPickerViewController.m
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

#import "KSOColorPickerViewController.h"
#import "KSOColorPicker.h"
#import "NSBundle+KSOColorPickerPrivateExtensions.h"

#import <Ditko/Ditko.h>
#import <Stanley/Stanley.h>

@interface KSOColorPickerViewController ()
@property (strong,nonatomic) KDINavigationBarTitleView *titleView;
@property (strong,nonatomic) KSOColorPickerView *colorPickerView;

@property (assign,nonatomic) BOOL dismissalTriggeredBySelf;

@property (class,readonly,nonatomic) NSString *defaultTitle;
@property (class,readonly,nonatomic) NSString *defaultSubtitle;
@end

@implementation KSOColorPickerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    kstWeakify(self);
    
    self.view.backgroundColor = UIColor.whiteColor;
    
    if (self.colorPickerView == nil) {
        self.colorPickerView = [[KSOColorPickerView alloc] initWithFrame:CGRectZero];
        self.colorPickerView.userCanSelectMode = YES;
    }
    self.colorPickerView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:self.colorPickerView];
    
    [NSLayoutConstraint activateConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[view]|" options:0 metrics:nil views:@{@"view": self.colorPickerView}]];
    [NSLayoutConstraint activateConstraints:@[[self.colorPickerView.topAnchor constraintEqualToSystemSpacingBelowAnchor:self.view.safeAreaLayoutGuide.topAnchor multiplier:1.0], [self.view.safeAreaLayoutGuide.bottomAnchor constraintGreaterThanOrEqualToSystemSpacingBelowAnchor:self.colorPickerView.bottomAnchor multiplier:1.0]]];
    
    if (self.presentingViewController != nil) {
        UIBarButtonItem *cancelItem = [UIBarButtonItem KDI_barButtonSystemItem:UIBarButtonSystemItemCancel block:^(__kindof UIBarButtonItem * _Nonnull barButtonItem) {
            kstStrongify(self);
            
            self.dismissalTriggeredBySelf = YES;
            
            if ([self.delegate respondsToSelector:@selector(colorPickerViewControllerDidCancel:)]) {
                [self.delegate colorPickerViewControllerDidCancel:self];
            }
            
            [self.presentingViewController dismissViewControllerAnimated:YES completion:^{
                if ([self.delegate respondsToSelector:@selector(colorPickerViewControllerDidDismiss:)]) {
                    [self.delegate colorPickerViewControllerDidDismiss:self];
                }
            }];
        }];
        
        self.navigationItem.leftBarButtonItems = @[cancelItem];
    }
    
    UIBarButtonItem *doneItem = [UIBarButtonItem KDI_barButtonSystemItem:UIBarButtonSystemItemDone block:^(__kindof UIBarButtonItem * _Nonnull barButtonItem) {
        kstStrongify(self);
        void(^completion)(void) = ^{
            if ([self.delegate respondsToSelector:@selector(colorPickerViewControllerDidDismiss:)]) {
                [self.delegate colorPickerViewControllerDidDismiss:self];
            }
        };
        
        self.dismissalTriggeredBySelf = YES;
        
        if ([self.delegate respondsToSelector:@selector(colorPickerViewController:didFinishPickingColor:)]) {
            [self.delegate colorPickerViewController:self didFinishPickingColor:self.colorPickerView.color];
        }
        
        if (self.presentingViewController == nil) {
            [self.navigationController KDI_popViewControllerAnimated:YES completion:completion];
        }
        else {
            [self.presentingViewController dismissViewControllerAnimated:YES completion:completion];
        }
    }];
    
    self.navigationItem.rightBarButtonItems = @[doneItem];
}
- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    if (!self.dismissalTriggeredBySelf) {
        if ([self.delegate respondsToSelector:@selector(colorPickerViewControllerDidCancel:)]) {
            [self.delegate colorPickerViewControllerDidCancel:self];
        }
    }
}
- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    
    if (!self.dismissalTriggeredBySelf) {
        if ([self.delegate respondsToSelector:@selector(colorPickerViewControllerDidDismiss:)]) {
            [self.delegate colorPickerViewControllerDidDismiss:self];
        }
    }
}

- (void)setTitle:(NSString *)title {
    [super setTitle:title];
    
    self.titleView.title = self.title;
}
- (void)setSubtitle:(NSString *)subtitle {
    _subtitle = subtitle;
    
    self.titleView.subtitle = _subtitle;
}

- (instancetype)initWithColorPickerView:(KSOColorPickerView *)colorPickerView {
    if (!(self = [super initWithNibName:nil bundle:nil]))
        return nil;
    
    _colorPickerView = colorPickerView;
    
    self.title = KSOColorPickerViewController.defaultTitle;
    _subtitle = KSOColorPickerViewController.defaultSubtitle;
    
    _titleView = [[KDINavigationBarTitleView alloc] initWithFrame:CGRectZero];
    _titleView.title = self.title;
    _titleView.subtitle = _subtitle;
    
    self.navigationItem.titleView = _titleView;
    
    return self;
}

+ (NSString *)defaultTitle {
    return NSLocalizedStringWithDefaultValue(@"color-picker.title", nil, NSBundle.KSO_colorPickerFrameworkBundle, @"Choose Color", @"color picker title");
}
+ (NSString *)defaultSubtitle {
    return NSLocalizedStringWithDefaultValue(@"color-picker.subtitle", nil, NSBundle.KSO_colorPickerFrameworkBundle, @"Adjust components using the sliders", @"color picker subtitle");
}

@end
