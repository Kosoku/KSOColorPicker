//
//  KSOColorPickerButton.m
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

#import "KSOColorPickerButton.h"
#import "KSOColorPickerView.h"

#import <Stanley/Stanley.h>
#import <Ditko/Ditko.h>
#import <KSOFontAwesomeExtensions/KSOFontAwesomeExtensions.h>

static void *kObservingContext = &kObservingContext;

@interface KSOColorPickerButton ()
@property (readwrite,nonatomic) UIView *inputView;
@property (readwrite,nonatomic) UIView *inputAccessoryView;

@property (class,readonly,nonatomic) KSOColorPickerView *defaultColorPickerView;

- (void)_KSOColorPickerButtonInit;
- (void)_reloadColorPickerView;
- (void)_reloadTitleAndImageFromColorPickerViewColor;
- (void)_reloadTitleFromColorPickerViewColor;
- (void)_reloadImageFromColorPickerViewColor;
@end

@implementation KSOColorPickerButton
#pragma mark *** Subclass Overrides ***
- (void)dealloc {
    [NSNotificationCenter.defaultCenter removeObserver:self];
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (!(self = [super initWithFrame:frame]))
        return nil;
    
    [self _KSOColorPickerButtonInit];
    
    return self;
}
- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (!(self = [super initWithCoder:aDecoder]))
        return nil;
    
    [self _KSOColorPickerButtonInit];
    
    return self;
}
#pragma mark -
- (BOOL)canBecomeFirstResponder {
    return YES;
}
- (BOOL)becomeFirstResponder {
    [self willChangeValueForKey:@kstKeypath(self,isFirstResponder)];
    
    BOOL retval = [super becomeFirstResponder];
    
    [self didChangeValueForKey:@kstKeypath(self,isFirstResponder)];
    
    [self firstResponderDidChange];
    
    [NSNotificationCenter.defaultCenter postNotificationName:KDIUIResponderNotificationDidBecomeFirstResponder object:self];
    
    UIAccessibilityPostNotification(UIAccessibilityLayoutChangedNotification, self.inputView);
    
    return retval;
}
- (BOOL)resignFirstResponder {
    [self willChangeValueForKey:@kstKeypath(self,isFirstResponder)];
    
    BOOL retval = [super resignFirstResponder];
    
    [self didChangeValueForKey:@kstKeypath(self,isFirstResponder)];
    
    [self firstResponderDidChange];
    
    [NSNotificationCenter.defaultCenter postNotificationName:KDIUIResponderNotificationDidResignFirstResponder object:self];
    
    UIAccessibilityPostNotification(UIAccessibilityLayoutChangedNotification, nil);
    
    return retval;
}

- (void)firstResponderDidChange {
    
}
#pragma mark *** Public Methods ***
#pragma mark Properties
- (void)setColor:(UIColor *)color {
    _color = color;
    
    self.colorPickerView.color = _color;
    
    [self _reloadTitleAndImageFromColorPickerViewColor];
}
- (void)setColorPickerView:(KSOColorPickerView *)colorPickerView {
    _colorPickerView = colorPickerView ?: KSOColorPickerButton.defaultColorPickerView;
    
    [self _reloadColorPickerView];
}
- (void)setImageForColorBlock:(KSOColorPickerButtonImageForColorBlock)imageForColorBlock {
    _imageForColorBlock = [imageForColorBlock copy];
    
    [self _reloadImageFromColorPickerViewColor];
}
- (void)setTitleForColorBlock:(KSOColorPickerButtonTitleForColorBlock)titleForColorBlock {
    _titleForColorBlock = [titleForColorBlock copy];
    
    [self _reloadTitleFromColorPickerViewColor];
}
#pragma mark *** Private Methods ***
- (void)_KSOColorPickerButtonInit; {
    kstWeakify(self);
    
    _colorPickerView = KSOColorPickerButton.defaultColorPickerView;
    
    [self _reloadColorPickerView];
    
    UIBarButtonItem *clearItem = [UIBarButtonItem KDI_barButtonItemWithTitle:@"Clear" style:UIBarButtonItemStylePlain block:^(__kindof UIBarButtonItem * _Nonnull barButtonItem) {
        kstStrongify(self);
        self.color = nil;
    }];
    
    KDINextPreviousInputAccessoryView *inputAccessoryView = [[KDINextPreviousInputAccessoryView alloc] initWithFrame:CGRectZero responder:self];
    
    inputAccessoryView.toolbarItems = @[inputAccessoryView.previousItem, inputAccessoryView.nextItem, [UIBarButtonItem KDI_flexibleSpaceBarButtonItem], clearItem, inputAccessoryView.doneItem];
    
    self.inputAccessoryView = inputAccessoryView;
    
    [self KDI_addBlock:^(__kindof UIControl * _Nonnull control, UIControlEvents controlEvents) {
        kstStrongify(self);
        if (self.isFirstResponder) {
            [self resignFirstResponder];
        }
        else {
            [self becomeFirstResponder];
        }
    } forControlEvents:UIControlEventTouchUpInside];
    
    [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(_colorPickerViewDidEndTrackingComponent:) name:KSOColorPickerViewNotificationDidEndTrackingComponent object:nil];
}
#pragma mark -
- (void)_reloadColorPickerView; {
    self.colorPickerView.translatesAutoresizingMaskIntoConstraints = NO;
    
    [self _reloadTitleAndImageFromColorPickerViewColor];
    
    UIInputView *inputView = [[UIInputView alloc] initWithFrame:CGRectZero inputViewStyle:UIInputViewStyleKeyboard];
    
    inputView.translatesAutoresizingMaskIntoConstraints = NO;
    inputView.allowsSelfSizing = YES;
    
    [inputView addSubview:self.colorPickerView];
    
    [NSLayoutConstraint activateConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[view]|" options:0 metrics:nil views:@{@"view": self.colorPickerView}]];
    [NSLayoutConstraint activateConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[view]|" options:0 metrics:nil views:@{@"view": self.colorPickerView}]];
    
    self.inputView = inputView;
}
- (void)_reloadTitleAndImageFromColorPickerViewColor; {
    [self _reloadImageFromColorPickerViewColor];
    [self _reloadTitleFromColorPickerViewColor];
}
- (void)_reloadTitleFromColorPickerViewColor; {
    if (self.titleForColorBlock != nil) {
        NSString *title = self.titleForColorBlock(self, self.color);
        
        if (!KSTIsEmptyObject(title)) {
            [self setTitle:title forState:UIControlStateNormal];
        }
    }
}
- (void)_reloadImageFromColorPickerViewColor; {
    CGFloat height = ceil(self.titleLabel.font.lineHeight);
    CGSize size = CGSizeMake(height, height);
    UIImage *image = nil;
    
    if (self.imageForColorBlock != nil) {
        image = self.imageForColorBlock(self, self.color, size);
    }
    
    if (image == nil) {
        if (self.color == nil) {
            // the cancel image
            image = [UIImage KSO_fontAwesomeSolidImageWithString:@"\uf05e" size:size].KDI_templateImage;
        }
        else {
            CGRect rect = CGRectMake(0, 0, size.width, size.height);
            UIGraphicsBeginImageContextWithOptions(size, NO, 0.0);
            
            UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:rect cornerRadius:5.0];
            
            [self.color setFill];
            [path fill];
            
            [UIColor.blackColor setStroke];
            [path KDI_strokeInside];
            
            image = UIGraphicsGetImageFromCurrentImageContext().KDI_originalImage;
            
            UIGraphicsEndImageContext();
        }
    }
    
    [self setImage:image forState:UIControlStateNormal];
}
#pragma mark Notifications
- (void)_colorPickerViewDidEndTrackingComponent:(NSNotification *)note {
    if (![note.object isEqual:self.colorPickerView]) {
        return;
    }
    
    [self willChangeValueForKey:@kstKeypath(self,color)];
    
    _color = self.colorPickerView.color;
    
    [self sendActionsForControlEvents:UIControlEventValueChanged];
    
    [self didChangeValueForKey:@kstKeypath(self,color)];
    
    [self _reloadTitleAndImageFromColorPickerViewColor];
}
#pragma mark Properties
+ (KSOColorPickerView *)defaultColorPickerView {
    KSOColorPickerView *retval = [[KSOColorPickerView alloc] initWithFrame:CGRectZero];
    
    retval.userCanSelectMode = YES;
    
    return retval;
}

@end
