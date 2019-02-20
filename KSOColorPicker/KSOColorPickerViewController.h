//
//  KSOColorPickerViewController.h
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

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class KSOColorPickerView;
@protocol KSOColorPickerViewControllerDelegate;

/**
 KSOColorPickerViewController is a UIViewController subclass that hosts a KSOColorPickerView and can be presented modally or pushed onto an existing navigation stack. It will display a Done bar button item so the user can confirm the color they have chosen as well as a Cancel bar button item to cancel selection when presented modally. The default title is @"Choose Color" and localized.
 */
@interface KSOColorPickerViewController : UIViewController

/**
 Set and get the delegate of the receiver.
 
 The default is nil.
 
 @see KSOColorPickerViewControllerDelegate
 */
@property (weak,nonatomic,nullable) id<KSOColorPickerViewControllerDelegate> delegate;

/**
 Set and get the subtitle of the receiver, which is displayed below the title in the navigation bar.
 
 The default is @"Adjust components using the sliders" and localized.
 */
@property (copy,nonatomic,nullable) NSString *subtitle;

/**
 Create and return an instance that will host the provided *colorPickerView*. Passing nil uses a default instance of KSOColorPickerView.
 
 @param colorPickerView The color picker view to host, or nil to use a default instance
 @return The initialized instance
 */
- (instancetype)initWithColorPickerView:(nullable KSOColorPickerView *)colorPickerView NS_DESIGNATED_INITIALIZER;

- (instancetype)initWithNibName:(nullable NSString *)nibNameOrNil bundle:(nullable NSBundle *)nibBundleOrNil NS_UNAVAILABLE;
- (nullable instancetype)initWithCoder:(NSCoder *)aDecoder NS_UNAVAILABLE;

@end

@protocol KSOColorPickerViewControllerDelegate <NSObject>
@optional
/**
 Called when the user taps the Done bar button item to select a color.
 
 @param viewController The sender of the message
 @param color The color that was selected by the user
 */
- (void)colorPickerViewController:(KSOColorPickerViewController *)viewController didFinishPickingColor:(UIColor *)color;
/**
 Called when the user taps the Cancel bar button item.
 
 @param viewController The sender of the message
 */
- (void)colorPickerViewControllerDidCancel:(KSOColorPickerViewController *)viewController;
/**
 Called the view controller has finished the dismissal or pop animation.
 
 @param viewController The sender of the message
 */
- (void)colorPickerViewControllerDidDismiss:(KSOColorPickerViewController *)viewController;
@end

NS_ASSUME_NONNULL_END
