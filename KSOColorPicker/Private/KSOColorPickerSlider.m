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

#import <Ditko/Ditko.h>
#import <Stanley/Stanley.h>

@interface KSOColorPickerSlider ()
@property (readwrite,assign,nonatomic) KSOColorPickerViewComponentType componentType;
@property (weak,nonatomic) KSOColorPickerView *colorPickerView;

- (void)_updateValue;
@end

@implementation KSOColorPickerSlider

- (void)dealloc {
    [NSNotificationCenter.defaultCenter removeObserver:self];
}

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

@dynamic color;
- (UIColor *)color {
    return self.colorPickerView.color;
}
- (void)setColor:(UIColor *)color {
    [self _updateValue];
}

@end
