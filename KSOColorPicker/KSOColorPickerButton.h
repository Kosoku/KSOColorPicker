//
//  KSOColorPickerButton.h
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

#import <Ditko/KDIButton.h>
#import <Ditko/KDIUIResponder.h>

NS_ASSUME_NONNULL_BEGIN

@class KSOColorPickerButton;

/**
 Block that is invoked to determine the image to display for the provided *color*. Returning nil will use the default image.
 
 @param colorPickerButton The color picker button whose color changed
 @param color The new color
 @param defaultImageSize The size at which the default image will be drawn
 @return The custom image or nil
 */
typedef UIImage* _Nullable (^KSOColorPickerButtonImageForColorBlock)(__kindof KSOColorPickerButton *colorPickerButton, UIColor * _Nullable color, CGSize defaultImageSize);
/**
 Block that is invoked to determine the title to display for the provided *color*. Returning nil will leave the title as is.
 
 @param colorPickerButton The color picker button whose color changed
 @param color The new color
 @return The custom title or nil
 */
typedef NSString* _Nullable (^KSOColorPickerButtonTitleForColorBlock)(__kindof KSOColorPickerButton *colorPickerButton, UIColor * _Nullable color);

@class KSOColorPickerView;

/**
 KSOColorPickerButton is a KDIButton subclass that manages a KDIColorPickerView as its inputView.
 */
@interface KSOColorPickerButton : KDIButton <KDIUIResponder>

/**
 Set and get the color displayed by the receiver. Whenever the color property of the backing KSOColorPickerView changes, this property will also update.
 
 The default is nil.
 */
@property (strong,nonatomic,nullable) UIColor *color;

/**
 Set and get the KSOColorPickerView that is used as the receiver's inputView.
 */
@property (strong,nonatomic,null_resettable) KSOColorPickerView *colorPickerView;

/**
 Set and get the block that is used to determine the image the receiver should display whenever it's color property changes.
 
 The default is nil.
 
 @see KSOColorPickerButtonImageForColorBlock
 */
@property (copy,nonatomic,nullable) KSOColorPickerButtonImageForColorBlock imageForColorBlock;
/**
 Set and get the block that is used to determine the title the receiver should display whenever it's color property changes.
 
 The default is nil.
 
 @see KSOColorPickerButtonTitleForColorBlock
 */
@property (copy,nonatomic,nullable) KSOColorPickerButtonTitleForColorBlock titleForColorBlock;

@end

NS_ASSUME_NONNULL_END
