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

@interface KSOColorPickerSlider ()
@property (readwrite,assign,nonatomic) KSOColorPickerViewComponentType componentType;
@property (weak,nonatomic) KSOColorPickerView *colorPickerView;
@end

@implementation KSOColorPickerSlider

- (void)drawRect:(CGRect)rect {
    CGRect trackRect = [self trackRectForBounds:self.bounds];
    
    for (NSInteger i=(NSInteger)CGRectGetMinX(trackRect); i<(NSInteger)CGRectGetWidth(trackRect); i++) {
        UIColor *color;
        
        switch (self.componentType) {
            case KSOColorPickerViewComponentTypeBrightness:
                color = KDIColorHSB(1.0, 1.0, (CGFloat)i / CGRectGetWidth(trackRect));
                break;
            case KSOColorPickerViewComponentTypeHue:
                color = KDIColorHSB((CGFloat)i / CGRectGetWidth(trackRect), 1.0, 1.0);
                break;
            case KSOColorPickerViewComponentTypeSaturation:
                color = KDIColorHSB(1.0, (CGFloat)i / CGRectGetWidth(trackRect), 1.0);
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
    
    switch (_componentType) {
        case KSOColorPickerViewComponentTypeAlpha:
        case KSOColorPickerViewComponentTypeSaturation:
            self.minimumValue = 0.0;
            self.maximumValue = 1.0;
            break;
        case KSOColorPickerViewComponentTypeWhite:
        case KSOColorPickerViewComponentTypeBlue:
        case KSOColorPickerViewComponentTypeGreen:
        case KSOColorPickerViewComponentTypeRed:
        case KSOColorPickerViewComponentTypeBrightness:
            self.minimumValue = 0.0;
            self.maximumValue = 255.0;
            break;
        case KSOColorPickerViewComponentTypeHue:
            self.minimumValue = 0.0;
            self.maximumValue = 360.0;
            break;
        default:
            break;
    }
    
    return self;
}

@end
