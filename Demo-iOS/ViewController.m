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

@interface ViewController () <KSOColorPickerViewControllerDelegate>
@property (weak,nonatomic) IBOutlet KSOColorPickerButton *colorPickerButton;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    kstWeakify(self);
    
    self.title = @"KSOColorPicker";
    
    self.navigationItem.rightBarButtonItems = @[[UIBarButtonItem KDI_barButtonItemWithTitle:@"Present" style:UIBarButtonItemStylePlain block:^(__kindof UIBarButtonItem * _Nonnull barButtonItem) {
        kstStrongify(self);
        
        [self.view endEditing:YES];
        
        // using the convenience category method
        [self KSO_presentColorPickerViewController:[[KSOColorPickerViewController alloc] initWithColorPickerView:nil] animated:YES completion:^(UIColor * _Nullable color) {
            if (color != nil) {
                self.colorPickerButton.color = color;
            }
        }];
    }], [UIBarButtonItem KDI_barButtonItemWithTitle:@"Push" style:UIBarButtonItemStylePlain block:^(__kindof UIBarButtonItem * _Nonnull barButtonItem) {
        kstStrongify(self);
        
        [self.view endEditing:YES];
        
        // using normal delegation pattern
        KSOColorPickerViewController *viewController = [[KSOColorPickerViewController alloc] initWithColorPickerView:nil];
        
        viewController.delegate = self;
        viewController.title = @"Custom Title";
        viewController.subtitle = @"Custom subtitle prompt";
        
        [self.navigationController pushViewController:viewController animated:YES];
    }]];
    
    self.colorPickerButton.titleForColorBlock = ^NSString * _Nullable(__kindof KSOColorPickerButton * _Nonnull colorPickerButton, UIColor * _Nullable color) {
        if (color == nil) {
            return @"None";
        }
        else {
            switch (colorPickerButton.colorPickerView.mode) {
                case KSOColorPickerViewModeW:
                case KSOColorPickerViewModeWA: {
                    CGFloat white, alpha;
                    
                    [color getWhite:&white alpha:&alpha];
                    
                    return [NSString stringWithFormat:@"W: %@ A: %@", [colorPickerButton.colorPickerView.RGBNumberFormatter stringFromNumber:@(white)], [colorPickerButton.colorPickerView.percentNumberFormatter stringFromNumber:@(alpha)]];
                }
                case KSOColorPickerViewModeRGB:
                case KSOColorPickerViewModeRGBA: {
                    CGFloat red, green, blue, alpha;
                    
                    [color getRed:&red green:&green blue:&blue alpha:&alpha];
                    
                    return [NSString stringWithFormat:@"R: %@ G: %@ B: %@ A: %@", [colorPickerButton.colorPickerView.RGBNumberFormatter stringFromNumber:@(red)], [colorPickerButton.colorPickerView.RGBNumberFormatter stringFromNumber:@(green)], [colorPickerButton.colorPickerView.RGBNumberFormatter stringFromNumber:@(blue)], [colorPickerButton.colorPickerView.percentNumberFormatter stringFromNumber:@(alpha)]];
                }
                case KSOColorPickerViewModeHSB:
                case KSOColorPickerViewModeHSBA: {
                    CGFloat hue, saturation, brightness, alpha;
                    
                    [color getHue:&hue saturation:&saturation brightness:&brightness alpha:&alpha];
                    
                    return [NSString stringWithFormat:@"H: %@ S: %@ B: %@ A: %@", [colorPickerButton.colorPickerView.hueNumberFormatter stringFromNumber:@(hue)], [colorPickerButton.colorPickerView.percentNumberFormatter stringFromNumber:@(saturation)], [colorPickerButton.colorPickerView.percentNumberFormatter stringFromNumber:@(brightness)], [colorPickerButton.colorPickerView.percentNumberFormatter stringFromNumber:@(alpha)]];
                }
            }
        }
    };
}

- (void)colorPickerViewController:(KSOColorPickerViewController *)viewController didFinishPickingColor:(UIColor *)color {
    self.colorPickerButton.color = color;
}
- (void)colorPickerViewControllerDidCancel:(KSOColorPickerViewController *)viewController {
    KSTLogObject(viewController);
}
- (void)colorPickerViewControllerDidDismiss:(KSOColorPickerViewController *)viewController {
    KSTLogObject(viewController);
}

@end
