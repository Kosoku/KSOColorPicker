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
#import "KSOColorPickerSwatchView.h"

#import <Stanley/Stanley.h>
#import <Ditko/Ditko.h>

NSNotificationName const KSOColorPickerViewNotificationDidChangeColor = @"KSOColorPickerViewNotificationDidChangeColor";

@interface KSOColorPickerView ()
@property (strong,nonatomic) KSOColorPickerSwatchView *swatchView;
@property (strong,nonatomic) UIStackView *stackView;
@property (readonly,nonatomic) NSArray<KSOColorPickerSlider *> *sliders;

@property (assign,nonatomic) BOOL shouldUpdateSlidersColor;

- (void)setColor:(UIColor *)color notify:(BOOL)notify;

- (void)_KSOColorPickerViewInit;
- (void)_updateSliderControls;
- (KSOColorPickerSlider *)_createSliderControlForComponentType:(KSOColorPickerViewComponentType)type;

+ (UIColor *)_defaultColorForMode:(KSOColorPickerViewMode)mode;
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

- (void)setColor:(UIColor *)color {
    [self setColor:color notify:NO];
}
- (void)setColor:(UIColor *)color notify:(BOOL)notify; {
    [self willChangeValueForKey:@kstKeypath(self,color)];
    
    _color = color;
    
    [self didChangeValueForKey:@kstKeypath(self,color)];
    
    self.swatchView.color = _color;
    
    if (self.shouldUpdateSlidersColor) {
        for (KSOColorPickerSlider *slider in self.sliders) {
            slider.color = _color;
        }
    }
    
    if (notify) {
        [NSNotificationCenter.defaultCenter postNotificationName:KSOColorPickerViewNotificationDidChangeColor object:self];
    }
}

- (void)setMode:(KSOColorPickerViewMode)mode {
    if (_mode == mode) {
        return;
    }
    
    _mode = mode;
    
    [self _updateSliderControls];
}

- (void)_KSOColorPickerViewInit; {
    _mode = KSOColorPickerViewModeDefault;
    _color = [KSOColorPickerView _defaultColorForMode:_mode];
    
    _shouldUpdateSlidersColor = YES;
    
    _swatchView = [[KSOColorPickerSwatchView alloc] initWithFrame:CGRectZero];
    _swatchView.translatesAutoresizingMaskIntoConstraints = NO;
    _swatchView.color = _color;
    [self addSubview:_swatchView];
    
    _stackView = [[UIStackView alloc] initWithFrame:CGRectZero];
    _stackView.translatesAutoresizingMaskIntoConstraints = NO;
    _stackView.axis = UILayoutConstraintAxisVertical;
    _stackView.alignment = UIStackViewAlignmentLeading;
    _stackView.spacing = 8.0;
    [self addSubview:_stackView];
    
    [self _updateSliderControls];
    
    [NSLayoutConstraint activateConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[view]|" options:0 metrics:nil views:@{@"view": _swatchView}]];
    [NSLayoutConstraint activateConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[view(==height)]" options:0 metrics:@{@"height": @44.0} views:@{@"view": _swatchView}]];
    
    [NSLayoutConstraint activateConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[view]|" options:0 metrics:nil views:@{@"view": _stackView}]];
    [NSLayoutConstraint activateConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[top]-[view]|" options:0 metrics:nil views:@{@"view": _stackView, @"top": _swatchView}]];
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
    
    [retval addTarget:self action:@selector(_sliderValueChanged:) forControlEvents:UIControlEventValueChanged];
    [retval addTarget:self action:@selector(_sliderTouchDown:) forControlEvents:UIControlEventTouchDown];
    [retval addTarget:self action:@selector(_sliderTouchUp:) forControlEvents:UIControlEventTouchUpInside|UIControlEventTouchUpOutside|UIControlEventTouchCancel];
    
    return retval;
}

+ (UIColor *)_defaultColorForMode:(KSOColorPickerViewMode)mode; {
    UIColor *retval;
    
    switch (mode) {
        case KSOColorPickerViewModeRGBA:
            retval = KDIColorRGBA(0.0, 0.0, 0.0, 1.0);
            break;
        case KSOColorPickerViewModeW:
            retval = KDIColorW(0.0);
            break;
        case KSOColorPickerViewModeWA:
            retval = KDIColorWA(0.0, 1.0);
            break;
        case KSOColorPickerViewModeHSB:
            retval = KDIColorHSB(0.0, 0.0, 0.0);
            break;
        case KSOColorPickerViewModeRGB:
            retval = KDIColorRGB(0.0, 0.0, 0.0);
            break;
        case KSOColorPickerViewModeHSBA:
            retval = KDIColorHSBA(0.0, 0.0, 0.0, 1.0);
            break;
        default:
            break;
    }
    
    return retval;
}

- (IBAction)_sliderValueChanged:(KSOColorPickerSlider *)sender {
    switch (self.mode) {
        case KSOColorPickerViewModeRGB:
            [self setColor:KDIColorRGB(self.sliders[0].value / self.sliders[0].maximumValue, self.sliders[1].value / self.sliders[1].maximumValue, self.sliders[2].value / self.sliders[2].maximumValue) notify:YES];
            break;
        case KSOColorPickerViewModeRGBA:
            [self setColor:KDIColorRGBA(self.sliders[0].value / self.sliders[0].maximumValue, self.sliders[1].value / self.sliders[1].maximumValue, self.sliders[2].value / self.sliders[2].maximumValue, self.sliders[3].value / self.sliders[3].maximumValue) notify:YES];
            break;
        default:
            break;
    }
    
    [NSNotificationCenter.defaultCenter postNotificationName:KSOColorPickerViewNotificationDidChangeColor object:self];
}
- (IBAction)_sliderTouchDown:(id)sender {
    self.shouldUpdateSlidersColor = NO;
}
- (IBAction)_sliderTouchUp:(id)sender {
    self.shouldUpdateSlidersColor = YES;
}

- (NSArray<KSOColorPickerSlider *> *)sliders {
    return self.stackView.arrangedSubviews;
}

@end
