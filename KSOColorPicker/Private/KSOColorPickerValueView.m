//
//  KSOColorPickerValueView.m
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

#import "KSOColorPickerValueView.h"
#import "KSOColorPickerView.h"
#import "KSOColorPickerSlider.h"

#import <Ditko/Ditko.h>
#import <Stanley/Stanley.h>

static CGFloat const kCornerRadius = 5.0;
static CGFloat const kLabelBottomMargin = 8.0;
static CGSize const kTriangleSize = {.width=12.0, .height=8.0};

@interface KSOColorPickerValueView ()
@property (strong,nonatomic) UILabel *label;

@property (weak,nonatomic) KSOColorPickerSlider *colorPickerSlider;
@property (weak,nonatomic) KSOColorPickerView *colorPickerView;

- (void)_updateLabelText;
@end

@implementation KSOColorPickerValueView
#pragma mark *** Subclass Overrides ***
- (BOOL)isOpaque {
    return NO;
}
- (void)drawRect:(CGRect)rect {
    [self.colorPickerView.valueBackgroundColor setFill];
    [[UIBezierPath bezierPathWithRoundedRect:CGRectMake(0, 0, CGRectGetWidth(self.bounds), CGRectGetHeight(self.bounds) - kTriangleSize.height) cornerRadius:kCornerRadius] fill];
    
    UIBezierPath *path = [UIBezierPath bezierPath];
    CGRect triangleRect = KSTCGRectCenterInRectHorizontally(CGRectMake(0, CGRectGetHeight(self.bounds) - kTriangleSize.height, kTriangleSize.width, kTriangleSize.height), self.bounds);
    
    [path moveToPoint:CGPointMake(CGRectGetMinX(triangleRect), CGRectGetMinY(triangleRect))];
    [path addLineToPoint:CGPointMake(CGRectGetMaxX(triangleRect), CGRectGetMinY(triangleRect))];
    [path addLineToPoint:CGPointMake(CGRectGetMidX(triangleRect), CGRectGetMaxY(triangleRect))];
    [path addLineToPoint:CGPointMake(CGRectGetMinX(triangleRect), CGRectGetMinY(triangleRect))];
    [path fill];
}
#pragma mark *** Public Methods ***
- (instancetype)initWithColorPickerSlider:(KSOColorPickerSlider *)colorPickerSlider colorPickerView:(KSOColorPickerView *)colorPickerView {
    if (!(self = [super initWithFrame:CGRectZero]))
        return nil;
    
    self.backgroundColor = UIColor.clearColor;
    
    _colorPickerSlider = colorPickerSlider;
    _colorPickerView = colorPickerView;
    
    _label = [[UILabel alloc] initWithFrame:CGRectZero];
    _label.translatesAutoresizingMaskIntoConstraints = NO;
    _label.textColor = _colorPickerView.valueForegroundColor;
    _label.font = _colorPickerView.valueFont;
    _label.KDI_dynamicTypeTextStyle = _colorPickerView.valueTextStyle;
    [self addSubview:_label];
    
    [self _updateLabelText];
    
    [NSLayoutConstraint activateConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-[view]-|" options:0 metrics:nil views:@{@"view": _label}]];
    [NSLayoutConstraint activateConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-[view]-bottom-|" options:0 metrics:@{@"bottom": @(kTriangleSize.height + kLabelBottomMargin)} views:@{@"view": _label}]];
    
    [_colorPickerSlider addTarget:self action:@selector(_sliderValueChanged:) forControlEvents:UIControlEventValueChanged];
    
    return self;
}
#pragma mark *** Private Methods ***
- (void)_updateLabelText; {
    switch (self.colorPickerSlider.componentType) {
        case KSOColorPickerViewComponentTypeRed:
        case KSOColorPickerViewComponentTypeBlue:
        case KSOColorPickerViewComponentTypeGreen:
        case KSOColorPickerViewComponentTypeWhite:
            self.label.text = [self.colorPickerView.RGBNumberFormatter stringFromNumber:@(self.colorPickerSlider.value * 255.0)];
            break;
        case KSOColorPickerViewComponentTypeHue:
            self.label.text = [self.colorPickerView.hueNumberFormatter stringFromNumber:@(self.colorPickerSlider.value * 360.0)];
            break;
        case KSOColorPickerViewComponentTypeSaturation:
        case KSOColorPickerViewComponentTypeBrightness:
        case KSOColorPickerViewComponentTypeAlpha:
            self.label.text = [self.colorPickerView.percentNumberFormatter stringFromNumber:@(self.colorPickerSlider.value)];
            break;
        default:
            break;
    }
}
#pragma mark Actions
- (IBAction)_sliderValueChanged:(id)sender {
    [self _updateLabelText];
}

@end
