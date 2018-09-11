//
//  KSOColorPickerSlider.m
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

#import "KSOColorPickerSlider.h"
#import "KSOColorPickerView.h"
#import "KSOColorPickerValueView.h"

#import <Ditko/Ditko.h>
#import <Stanley/Stanley.h>

static CGFloat const kValueViewBottomMargin = 4.0;
static NSTimeInterval const kValueViewShowAnimationDuration = 0.5;
static NSTimeInterval const kValueViewHideAnimationDuration = 0.33;

@interface KSOColorPickerSlider ()
@property (strong,nonatomic) KSOColorPickerValueView *valueView;

@property (readwrite,assign,nonatomic) KSOColorPickerViewComponentType componentType;
@property (weak,nonatomic) KSOColorPickerView *colorPickerView;

- (void)_updateValue;
@end

@implementation KSOColorPickerSlider
#pragma mark *** Subclass Overrides ***
- (void)dealloc {
    [NSNotificationCenter.defaultCenter removeObserver:self];
}
#pragma mark -
- (void)drawRect:(CGRect)rect {
    CGRect trackRect = [self trackRectForBounds:self.bounds];
    
    for (NSInteger i=(NSInteger)CGRectGetMinX(trackRect); i<(NSInteger)CGRectGetWidth(trackRect); i++) {
        UIColor *color;
        
        switch (self.componentType) {
            case KSOColorPickerViewComponentTypeBrightness: {
                CGFloat hue, saturation;
                
                [self.colorPickerView.color getHue:&hue saturation:&saturation brightness:NULL alpha:NULL];
                
                color = KDIColorHSB(hue, saturation, (CGFloat)i / CGRectGetWidth(trackRect));
            }
                break;
            case KSOColorPickerViewComponentTypeHue:
                color = KDIColorHSB((CGFloat)i / CGRectGetWidth(trackRect), 1.0, 1.0);
                break;
            case KSOColorPickerViewComponentTypeSaturation: {
                CGFloat hue, brightness;
                
                [self.colorPickerView.color getHue:&hue saturation:NULL brightness:&brightness alpha:NULL];
                
                color = KDIColorHSB(hue, (CGFloat)i / CGRectGetWidth(trackRect), brightness);
            }
                break;
            case KSOColorPickerViewComponentTypeRed:
                color = KDIColorRGB((CGFloat)i / CGRectGetWidth(trackRect), 0.0, 0.0);
                break;
            case KSOColorPickerViewComponentTypeBlue:
                color = KDIColorRGB(0.0, 0.0, (CGFloat)i / CGRectGetWidth(trackRect));
                break;
            case KSOColorPickerViewComponentTypeGreen:
                color = KDIColorRGB(0.0, (CGFloat)i / CGRectGetWidth(trackRect), 0.0);
                break;
            case KSOColorPickerViewComponentTypeWhite:
                color = KDIColorW((CGFloat)i / CGRectGetWidth(trackRect));
                break;
            case KSOColorPickerViewComponentTypeAlpha:
                color = [self.colorPickerView.color colorWithAlphaComponent:(CGFloat)i / CGRectGetWidth(trackRect)];
                break;
            default:
                break;
        }
        
        [color setFill];
        UIRectFill(CGRectMake(i, CGRectGetMinY(trackRect), 1.0, CGRectGetHeight(trackRect)));
    }
}
#pragma mark -
- (void)layoutSubviews {
    [super layoutSubviews];
    
    if (self.valueView != nil) {
        CGSize size = [self.valueView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize];
        CGRect thumbRect = [self thumbRectForBounds:self.bounds trackRect:[self trackRectForBounds:self.bounds] value:self.value];
        
        self.valueView.frame = KSTCGRectCenterInRectHorizontally(CGRectMake(0, CGRectGetMinY(thumbRect) - size.height - kValueViewBottomMargin, size.width, size.height), thumbRect);
    }
}
#pragma mark -
- (BOOL)beginTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event {
    BOOL retval = [super beginTrackingWithTouch:touch withEvent:event];
    
    if (retval) {
        [NSNotificationCenter.defaultCenter postNotificationName:KSOColorPickerViewNotificationDidBeginTrackingComponent object:self.colorPickerView];
        
        if (self.valueView == nil) {
            self.valueView = [[KSOColorPickerValueView alloc] initWithColorPickerSlider:self colorPickerView:self.colorPickerView];
            self.valueView.translatesAutoresizingMaskIntoConstraints = NO;
            self.valueView.alpha = 0.0;
            [self addSubview:self.valueView];
            [self setNeedsLayout];
            [self layoutIfNeeded];
        }
        
        self.valueView.transform = CGAffineTransformMakeScale(0.5, 0.5);
        [UIView animateWithDuration:kValueViewShowAnimationDuration delay:0.0 usingSpringWithDamping:0.5 initialSpringVelocity:0.0 options:UIViewAnimationOptionBeginFromCurrentState animations:^{
            self.valueView.alpha = 1.0;
            self.valueView.transform = CGAffineTransformIdentity;
        } completion:nil];
    }
    
    return retval;
}
- (void)endTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event {
    [super endTrackingWithTouch:touch withEvent:event];
    
    [NSNotificationCenter.defaultCenter postNotificationName:KSOColorPickerViewNotificationDidEndTrackingComponent object:self.colorPickerView];
    
    [UIView animateWithDuration:kValueViewHideAnimationDuration delay:0.0 options:UIViewAnimationOptionBeginFromCurrentState animations:^{
        self.valueView.alpha = 0.0;
    } completion:^(BOOL finished) {
        if (finished) {
            [self.valueView removeFromSuperview];
            self.valueView = nil;
        }
    }];
}
#pragma mark *** Public Methods ***
- (instancetype)initWithComponentType:(KSOColorPickerViewComponentType)componentType colorPickerView:(KSOColorPickerView *)colorPickerView {
    if (!(self = [super initWithFrame:CGRectZero]))
        return nil;
    
    _componentType = componentType;
    _colorPickerView = colorPickerView;
    
    self.minimumTrackTintColor = UIColor.clearColor;
    self.maximumTrackTintColor = UIColor.clearColor;
    self.minimumValue = 0.0;
    self.maximumValue = 1.0;
    
    [self _updateValue];
    
    [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(_colorPickerViewDidChangeColor:) name:KSOColorPickerViewNotificationDidChangeColor object:_colorPickerView];
    
    return self;
}
#pragma mark -
- (void)updateWithColorPickerViewColor; {
    [self _updateValue];
}
#pragma mark *** Private Methods ***
- (void)_updateValue; {
    CGFloat red = 0.0, green = 0.0, blue = 0.0, hue = 0.0, saturation = 0.0, brightness = 0.0, white = 0.0, alpha = 0.0;
    
    switch (self.colorPickerView.mode) {
        case KSOColorPickerViewModeHSBA:
        case KSOColorPickerViewModeHSB:
            [self.colorPickerView.color getHue:&hue saturation:&saturation brightness:&brightness alpha:&alpha];
            break;
        case KSOColorPickerViewModeRGB:
        case KSOColorPickerViewModeRGBA:
            [self.colorPickerView.color getRed:&red green:&green blue:&blue alpha:&alpha];
            break;
        case KSOColorPickerViewModeW:
        case KSOColorPickerViewModeWA:
            [self.colorPickerView.color getWhite:&white alpha:&alpha];
            break;
        default:
            break;
    }
    
    switch (self.componentType) {
        case KSOColorPickerViewComponentTypeAlpha:
            self.value = alpha;
            break;
        case KSOColorPickerViewComponentTypeSaturation:
            self.value = saturation;
            break;
        case KSOColorPickerViewComponentTypeWhite:
            self.value = white;
            break;
        case KSOColorPickerViewComponentTypeBlue:
            self.value = blue;
            break;
        case KSOColorPickerViewComponentTypeGreen:
            self.value = green;
            break;
        case KSOColorPickerViewComponentTypeRed:
            self.value = red;
            break;
        case KSOColorPickerViewComponentTypeBrightness:
            self.value = brightness;
            break;
        case KSOColorPickerViewComponentTypeHue:
            self.value = hue;
            break;
        default:
            break;
    }
}
#pragma mark Notifications
- (void)_colorPickerViewDidChangeColor:(NSNotification *)note {
    switch (self.componentType) {
        case KSOColorPickerViewComponentTypeAlpha:
        case KSOColorPickerViewComponentTypeSaturation:
        case KSOColorPickerViewComponentTypeBrightness:
            [self setNeedsDisplay];
            break;
        default:
            break;
    }
}

@end
