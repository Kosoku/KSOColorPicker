//
//  KSOColorPickerView.h
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

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

/**
 Enum for the color picker mode. This controls how many sliders are displayed to the user to choose components.
 */
typedef NS_ENUM(NSInteger, KSOColorPickerViewMode) {
    /**
     White is shown.
     */
    KSOColorPickerViewModeW,
    /**
     White and Alpha are shown.
     */
    KSOColorPickerViewModeWA,
    /**
     Red, Green, and Blue are shown.
     */
    KSOColorPickerViewModeRGB,
    /**
     Red, Green, Blue, and Alpha are shown.
     */
    KSOColorPickerViewModeRGBA,
    /**
     Hue, Saturation, and Brightness are shown.
     */
    KSOColorPickerViewModeHSB,
    /**
     Hue, Saturation, Brightness, and Alpha are shown.
     */
    KSOColorPickerViewModeHSBA,
    /**
     Convenience for the default mode.
     */
    KSOColorPickerViewModeDefault = KSOColorPickerViewModeRGB
};

/**
 Notification that is posted when the a KSOColorPickerView color property changes. The object of the notification is the KSOColorPickerView instance whose color property changed.
 */
FOUNDATION_EXTERN NSNotificationName const KSOColorPickerViewNotificationDidChangeColor;

/**
 KSOColorPickerView manages a number of subviews to facilitate picking colors by the user. It (optionally) displays the possible modes top aligned if the userCanSelectMode property is YES, followed by a swatch view that displays the selected color, and finally by a number of UISlider controls that allow the user to select the necessary color components.
 */
@interface KSOColorPickerView : UIView

/**
 Set and get the color displayed by the receiver.
 
 The default is an appropriate color for the selected mode.
 */
@property (strong,nonatomic,null_resettable) UIColor *color;

/**
 Set and get the mode, which controls how many sliders are displayed to the user.
 
 The default is KSOColorPickerViewModeDefault.
 */
@property (assign,nonatomic) KSOColorPickerViewMode mode;
/**
 Set and get whether the user can select the mode.
 
 The default is NO.
 */
@property (assign,nonatomic) BOOL userCanSelectMode;

/**
 Set and get the color used for the component text aligned to the leading edge of a component slider.
 
 The default is UIColor.blackColor.
 */
@property (strong,nonatomic,null_resettable) UIColor *componentColor UI_APPEARANCE_SELECTOR;
/**
 Set and get the font used for the component text aligned to the leading edge of a component slider.
 
 The default is [UIFont systemFontOfSize:13.0].
 */
@property (strong,nonatomic,null_resettable) UIFont *componentFont UI_APPEARANCE_SELECTOR;
/**
 Set and get the font text style used for the component text aligned to the leading edge of a component slider. This must be non-nil to support dynamic type.
 
 The default is UIFontTextStyleCaption1.
 */
@property (copy,nonatomic,nullable) UIFontTextStyle componentTextStyle UI_APPEARANCE_SELECTOR;

/**
 Set and get the color used to draw the background of the value tooltip when the user interacts with a component slider.
 
 The default is UIColor.blackColor.
 */
@property (strong,nonatomic,null_resettable) UIColor *valueBackgroundColor UI_APPEARANCE_SELECTOR;
/**
 Set and get the color used to draw the foreground (text) of the value tooltip when the user interacts with a component slider.
 
 The default is UIColor.whiteColor.
 */
@property (strong,nonatomic,null_resettable) UIColor *valueForegroundColor UI_APPEARANCE_SELECTOR;
/**
 Set and get the font used to draw the foreground (text) of the value tooltip when the user interacts with a component slider.
 
 The default is [UIFont systemFontOfSize:17.0].
 */
@property (strong,nonatomic,null_resettable) UIFont *valueFont UI_APPEARANCE_SELECTOR;
/**
 Set and get the text style used for the text of the value tooltip when the user interacts with a component slider. This must be non-nil to support dynamic type.
 
 The default is UIFontTextStyleBody.
 */
@property (strong,nonatomic,nullable) UIFontTextStyle valueTextStyle UI_APPEARANCE_SELECTOR;

/**
 Set and get the RGB number formatter that is used to format RGB, and W values while the user is interacting with a slider.
 
 The default is a number formatter configured for decimal display.
 */
@property (strong,nonatomic,null_resettable) NSNumberFormatter *RGBNumberFormatter UI_APPEARANCE_SELECTOR;
/**
 Set and get the Hue number formatter that is used to format H values while the user is interacting with a slider.
 
 The default is a number formatter configured for decimal display with the percent symbol (°) as a suffix.
 */
@property (strong,nonatomic,null_resettable) NSNumberFormatter *hueNumberFormatter UI_APPEARANCE_SELECTOR;
/**
 Set and get the percent number formatter that is used to format SB, and A values while the user is interacting with a slider.
 
 The default is a number formatter configured for percentage display.
 */
@property (strong,nonatomic,null_resettable) NSNumberFormatter *percentNumberFormatter UI_APPEARANCE_SELECTOR;

@end

NS_ASSUME_NONNULL_END
