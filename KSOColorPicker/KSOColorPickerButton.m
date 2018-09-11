//
//  KSOColorPickerButton.m
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

- (BOOL)canBecomeFirstResponder {
    return YES;
}
- (BOOL)becomeFirstResponder {
    [self willChangeValueForKey:@kstKeypath(self,isFirstResponder)];
    
    BOOL retval = [super becomeFirstResponder];
    
    [self didChangeValueForKey:@kstKeypath(self,isFirstResponder)];
    
    UIAccessibilityPostNotification(UIAccessibilityLayoutChangedNotification, self.inputView);
    
    return retval;
}
- (BOOL)resignFirstResponder {
    [self willChangeValueForKey:@kstKeypath(self,isFirstResponder)];
    
    BOOL retval = [super resignFirstResponder];
    
    [self didChangeValueForKey:@kstKeypath(self,isFirstResponder)];
    
    UIAccessibilityPostNotification(UIAccessibilityLayoutChangedNotification, nil);
    
    return retval;
}

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

+ (KSOColorPickerView *)defaultColorPickerView {
    KSOColorPickerView *retval = [[KSOColorPickerView alloc] initWithFrame:CGRectZero];
    
    retval.userCanSelectMode = YES;
    
    return retval;
}

@end
