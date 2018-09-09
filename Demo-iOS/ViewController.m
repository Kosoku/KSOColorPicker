//
//  ViewController.m
//  Demo-iOS
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

#import "ViewController.h"

#import <KSOColorPicker/KSOColorPicker.h>
#import <Ditko/Ditko.h>
#import <Stanley/Stanley.h>

@interface ColorPickerViewMode : NSObject <KDIPickerViewButtonRow>
@property (assign,nonatomic) KSOColorPickerViewMode mode;
+ (instancetype)colorPickerViewMode:(KSOColorPickerViewMode)mode;
@end

@interface ViewController ()
@property (weak,nonatomic) IBOutlet KDIPickerViewButton *modePickerViewButton;
@property (weak,nonatomic) IBOutlet KSOColorPickerView *colorPickerView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.modePickerViewButton KDI_setPickerViewButtonRows:@[[ColorPickerViewMode colorPickerViewMode:KSOColorPickerViewModeW], [ColorPickerViewMode colorPickerViewMode:KSOColorPickerViewModeWA], [ColorPickerViewMode colorPickerViewMode:KSOColorPickerViewModeRGB], [ColorPickerViewMode colorPickerViewMode:KSOColorPickerViewModeRGBA], [ColorPickerViewMode colorPickerViewMode:KSOColorPickerViewModeHSB], [ColorPickerViewMode colorPickerViewMode:KSOColorPickerViewModeHSBA]] titleForSelectedRowBlock:^NSString *(id<KDIPickerViewButtonRow>  _Nonnull row) {
        return [NSString stringWithFormat:@"Mode: %@",row.pickerViewButtonRowTitle];
    } didSelectRowBlock:^(ColorPickerViewMode * _Nonnull row) {
        self.colorPickerView.mode = row.mode;
    }];
    
    [self.modePickerViewButton selectRow:[self.modePickerViewButton.KDI_pickerViewButtonRows indexOfObjectPassingTest:^BOOL(ColorPickerViewMode * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        return obj.mode == KSOColorPickerViewModeDefault;
    }] inComponent:0];
}

@end

@implementation ColorPickerViewMode
+ (instancetype)colorPickerViewMode:(KSOColorPickerViewMode)mode; {
    ColorPickerViewMode *retval = [[ColorPickerViewMode alloc] init];
    
    retval.mode = mode;
    
    return retval;
}
- (NSString *)pickerViewButtonRowTitle {
    switch (self.mode) {
        case KSOColorPickerViewModeWA:
            return @"White, Alpha";
        case KSOColorPickerViewModeW:
            return @"White";
        case KSOColorPickerViewModeHSB:
            return @"Hue, Saturation, Brightness";
        case KSOColorPickerViewModeHSBA:
            return @"Hue, Saturation, Brightness, Alpha";
        case KSOColorPickerViewModeRGB:
            return @"Red, Green, Blue";
        case KSOColorPickerViewModeRGBA:
            return @"Red, Green, Blue, Alpha";
    }
}
@end
