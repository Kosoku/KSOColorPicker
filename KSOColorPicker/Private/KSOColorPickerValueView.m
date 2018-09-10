//
//  KSOColorPickerValueView.m
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

#import "KSOColorPickerValueView.h"
#import "KSOColorPickerView.h"
#import "KSOColorPickerSlider.h"

#import <Ditko/Ditko.h>

@interface KSOColorPickerValueView ()
@property (strong,nonatomic) UILabel *label;

@property (weak,nonatomic) KSOColorPickerSlider *colorPickerSlider;
@property (weak,nonatomic) KSOColorPickerView *colorPickerView;

- (void)_updateLabelText;
@end

@implementation KSOColorPickerValueView
#pragma mark *** Public Methods ***
- (instancetype)initWithColorPickerSlider:(KSOColorPickerSlider *)colorPickerSlider colorPickerView:(KSOColorPickerView *)colorPickerView {
    if (!(self = [super initWithFrame:CGRectZero]))
        return nil;
    
    self.backgroundColor = UIColor.blackColor;
    self.KDI_cornerRadius = 5.0;
    
    _colorPickerSlider = colorPickerSlider;
    _colorPickerView = colorPickerView;
    
    _label = [[UILabel alloc] initWithFrame:CGRectZero];
    _label.translatesAutoresizingMaskIntoConstraints = NO;
    _label.textColor = UIColor.whiteColor;
    _label.font = [UIFont systemFontOfSize:17.0];
    [self addSubview:_label];
    
    [self _updateLabelText];
    
    [NSLayoutConstraint activateConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-[view]-|" options:0 metrics:nil views:@{@"view": _label}]];
    [NSLayoutConstraint activateConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-[view]-|" options:0 metrics:nil views:@{@"view": _label}]];
    
    [_colorPickerSlider addTarget:self action:@selector(_sliderValueChanged:) forControlEvents:UIControlEventValueChanged];
    
    return self;
}
#pragma mark *** Private Methods ***
- (void)_updateLabelText; {
    switch (self.colorPickerSlider.componentType) {
        case KSOColorPickerViewComponentTypeRed:
        case KSOColorPickerViewComponentTypeBlue:
        case KSOColorPickerViewComponentTypeGreen:
            self.label.text = [self.colorPickerView.RGBNumberFormatter stringFromNumber:@(self.colorPickerSlider.value * 255.0)];
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