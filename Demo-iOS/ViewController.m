//
//  ViewController.m
//  Demo-iOS
//
//  Created by William Towe on 9/9/18.
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
