//
//  KSOColorPickerView.m
//  KSOColorPicker-iOS
//
//  Created by William Towe on 9/9/18.
//  Copyright © 2018 Kosoku Interactive, LLC. All rights reserved.
//
//  Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:
//
//  1. Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
//
//  2. Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
//
//  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

#import "KSOColorPickerView.h"
#import "KSOColorPickerViewPrivate.h"
#import "KSOColorPickerSlider.h"

#import <Stanley/Stanley.h>
#import <Ditko/Ditko.h>

NSNotificationName const KSOColorPickerViewNotificationDidChangeColor = @"KSOColorPickerViewNotificationDidChangeColor";

@interface KSOColorPickerView ()
@property (strong,nonatomic) UIStackView *stackView;
@property (readonly,nonatomic) NSArray<KSOColorPickerSlider *> *sliders;

- (void)_KSOColorPickerViewInit;
- (void)_updateSliderControls;
- (KSOColorPickerSlider *)_createSliderControlForComponentType:(KSOColorPickerViewComponentType)type;
@end

@implementation KSOColorPickerView

- (instancetype)initWithFrame:(CGRect)frame {
    if (!(self = [super initWithFrame:frame]))
        return nil;
    
    [self _KSOColorPickerViewInit];
    
    return self;
}
- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (!(self = [super initWithCoder:aDecoder]))
        return nil;
    
    [self _KSOColorPickerViewInit];
    
    return self;
}

- (void)_KSOColorPickerViewInit; {
    _mode = KSOColorPickerViewModeDefault;
    
    _stackView = [[UIStackView alloc] initWithFrame:CGRectZero];
    _stackView.translatesAutoresizingMaskIntoConstraints = NO;
    _stackView.axis = UILayoutConstraintAxisVertical;
    _stackView.alignment = UIStackViewAlignmentLeading;
    _stackView.spacing = 8.0;
    [self addSubview:_stackView];
    
    [self _updateSliderControls];
    
    [NSLayoutConstraint activateConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[view]|" options:0 metrics:nil views:@{@"view": _stackView}]];
    [NSLayoutConstraint activateConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[view]|" options:0 metrics:nil views:@{@"view": _stackView}]];
}
- (void)_updateSliderControls; {
    NSArray *componentTypes;
    
    switch (self.mode) {
        case KSOColorPickerViewModeRGB:
            componentTypes = @[@(KSOColorPickerViewComponentTypeRed), @(KSOColorPickerViewComponentTypeGreen), @(KSOColorPickerViewComponentTypeBlue)];
            break;
        case KSOColorPickerViewModeHSB:
            componentTypes = @[@(KSOColorPickerViewComponentTypeHue), @(KSOColorPickerViewComponentTypeSaturation), @(KSOColorPickerViewComponentTypeBrightness)];
            break;
        case KSOColorPickerViewModeW:
            componentTypes = @[@(KSOColorPickerViewComponentTypeWhite)];
            break;
        case KSOColorPickerViewModeWA:
            componentTypes = @[@(KSOColorPickerViewComponentTypeWhite), @(KSOColorPickerViewComponentTypeAlpha)];
            break;
        case KSOColorPickerViewModeHSBA:
            componentTypes = @[@(KSOColorPickerViewComponentTypeHue), @(KSOColorPickerViewComponentTypeSaturation), @(KSOColorPickerViewComponentTypeBrightness), @(KSOColorPickerViewComponentTypeAlpha)];
            break;
        case KSOColorPickerViewModeRGBA:
            componentTypes = @[@(KSOColorPickerViewComponentTypeRed), @(KSOColorPickerViewComponentTypeGreen), @(KSOColorPickerViewComponentTypeBlue), @(KSOColorPickerViewComponentTypeAlpha)];
            break;
        default:
            break;
    }
    
    for (UIView *view in self.stackView.subviews) {
        [view removeFromSuperview];
    }
    
    for (NSNumber *type in componentTypes) {
        UISlider *slider = [self _createSliderControlForComponentType:type.integerValue];
        
        [self.stackView addArrangedSubview:slider];
        
        [NSLayoutConstraint activateConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[view]|" options:0 metrics:nil views:@{@"view": slider}]];
    }
}
- (KSOColorPickerSlider *)_createSliderControlForComponentType:(KSOColorPickerViewComponentType)type; {
    KSOColorPickerSlider *retval = [[KSOColorPickerSlider alloc] initWithComponentType:type colorPickerView:self];
    
    retval.translatesAutoresizingMaskIntoConstraints = NO;
    
    [retval addTarget:self action:@selector(_sliderAction:) forControlEvents:UIControlEventValueChanged];
    
    return retval;
}

- (IBAction)_sliderAction:(KSOColorPickerSlider *)sender {
    switch (self.mode) {
        case KSOColorPickerViewModeRGB:
            self.color = KDIColorRGB(self.sliders[0].value / self.sliders[0].maximumValue, self.sliders[1].value / self.sliders[1].maximumValue, self.sliders[2].value / self.sliders[2].maximumValue);
            break;
        default:
            break;
    }
    
    [NSNotificationCenter.defaultCenter postNotificationName:KSOColorPickerViewNotificationDidChangeColor object:self];
}

- (NSArray<KSOColorPickerSlider *> *)sliders {
    return self.stackView.arrangedSubviews;
}

@end
