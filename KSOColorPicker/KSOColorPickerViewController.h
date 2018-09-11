//
//  KSOColorPickerViewController.h
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
