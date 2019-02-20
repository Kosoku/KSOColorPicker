//
//  KSOColorPickerButton.h
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
