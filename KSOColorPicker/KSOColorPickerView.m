//
//  KSOColorPickerView.m
//  KSOColorPicker-iOS
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

#import "KSOColorPickerView.h"
#import "KSOColorPickerViewPrivate.h"
#import "KSOColorPickerSlider.h"
#import "KSOColorPickerSwatchView.h"
#import "NSBundle+KSOColorPickerPrivateExtensions.h"

#import <Stanley/Stanley.h>
#import <Ditko/Ditko.h>

NSNotificationName const KSOColorPickerViewNotificationDidChangeColor = @"KSOColorPickerViewNotificationDidChangeColor";
NSNotificationName const KSOColorPickerViewNotificationDidChangeMode = @"KSOColorPickerViewNotificationDidChangeMode";
NSNotificationName const KSOColorPickerViewNotificationDidBeginTrackingComponent = @"KSOColorPickerViewNotificationDidBeginTrackingComponent";
NSNotificationName const KSOColorPickerViewNotificationDidEndTrackingComponent = @"KSOColorPickerViewNotificationDidEndTrackingComponent";

@interface KSOColorPickerView () <UIDragInteractionDelegate, UIDropInteractionDelegate>
@property (strong,nonatomic) KSOColorPickerSwatchView *swatchView;
@property (strong,nonatomic) UIStackView *stackView;
@property (strong,nonatomic) UISegmentedControl *segmentedControl;
@property (copy,nonatomic) NSArray<KSOColorPickerSlider *> *sliders;
@property (copy,nonatomic) NSArray<UILabel *> *componentLabels;

@property (copy,nonatomic) NSArray<NSNumber *> *userSelectableModes;

@property (assign,nonatomic) BOOL shouldUpdateSlidersColor;

@property (class,readonly,nonatomic) UIColor *defaultComponentColor;
@property (class,readonly,nonatomic) UIFont *defaultComponentFont;
@property (class,readonly,nonatomic) UIFontTextStyle defaultComponentTextStyle;

@property (class,readonly,nonatomic) UIColor *defaultValueBackgroundColor;
@property (class,readonly,nonatomic) UIColor *defaultValueForegroundColor;
@property (class,readonly,nonatomic) UIFont *defaultValueFont;
@property (class,readonly,nonatomic) UIFontTextStyle defaultValueTextStyle;

@property (class,readonly,nonatomic) NSNumberFormatter *defaultRGBNumberFormatter;
@property (class,readonly,nonatomic) NSNumberFormatter *defaultHueNumberFormatter;
@property (class,readonly,nonatomic) NSNumberFormatter *defaultPercentNumberFormatter;

- (void)setColor:(UIColor *)color notify:(BOOL)notify;

- (void)_KSOColorPickerViewInit;
- (void)_updateSliderControls;
- (KSOColorPickerSlider *)_createSliderControlForComponentType:(KSOColorPickerViewComponentType)type;
- (UILabel *)_createLabelForComponentType:(KSOColorPickerViewComponentType)type;

+ (UIColor *)_defaultColorForMode:(KSOColorPickerViewMode)mode;
+ (NSString *)_userSelectableTitleForMode:(KSOColorPickerViewMode)mode;
@end

@implementation KSOColorPickerView
#pragma mark *** Subclass Overrides ***
- (instancetype)initWithFrame:(CGRect)frame {
    if (!(self = [super initWithFrame:frame]))
        return nil;
    
    [self _KSOColorPickerViewInit];
    
    return self;
}
- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (!(self = [super initWithCoder:aDecoder]))
        return nil;
    
    [self _KSOColorPickerViewInit];
    
    return self;
}
#pragma mark -
+ (BOOL)requiresConstraintBasedLayout {
    return YES;
}
- (void)updateConstraints {
    NSMutableArray *temp = [[NSMutableArray alloc] init];
    
    if (self.segmentedControl != nil) {
        [temp addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-[view]-|" options:0 metrics:nil views:@{@"view": self.segmentedControl}]];
        [temp addObject:[self.segmentedControl.topAnchor constraintEqualToSystemSpacingBelowAnchor:self.safeAreaLayoutGuide.topAnchor multiplier:1.0]];
    }
    
    [temp addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-[view]-|" options:0 metrics:nil views:@{@"view": self.swatchView}]];
    
    CGFloat swatchViewHeight = 32.0;
    
    if (self.segmentedControl == nil) {
        [temp addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[view(==height)]" options:0 metrics:@{@"height": @(swatchViewHeight)} views:@{@"view": self.swatchView}]];
        [temp addObject:[self.swatchView.topAnchor constraintGreaterThanOrEqualToSystemSpacingBelowAnchor:self.safeAreaLayoutGuide.topAnchor multiplier:1.0]];
    }
    else {
        [temp addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[top]-[view(==height)]" options:0 metrics:@{@"height": @(swatchViewHeight)} views:@{@"view": self.swatchView, @"top": self.segmentedControl}]];
    }
    
    [temp addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-[view]-|" options:0 metrics:nil views:@{@"view": self.stackView}]];
    [temp addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[top]-[view]" options:0 metrics:nil views:@{@"view": self.stackView, @"top": self.swatchView}]];
    [temp addObject:[self.safeAreaLayoutGuide.bottomAnchor constraintGreaterThanOrEqualToSystemSpacingBelowAnchor:self.stackView.bottomAnchor multiplier:1.0]];
    
    self.KDI_customConstraints = temp;
    
    [super updateConstraints];
}
#pragma mark UIDragInteractionDelegate
- (NSArray<UIDragItem *> *)dragInteraction:(UIDragInteraction *)interaction itemsForBeginningSession:(id<UIDragSession>)session {
    NSItemProvider *provider = [[NSItemProvider alloc] initWithObject:self.color];
    UIDragItem *item = [[UIDragItem alloc] initWithItemProvider:provider];
    
    item.localObject = self.color;
    
    return @[item];
}
- (void)dragInteraction:(UIDragInteraction *)interaction sessionWillBegin:(id<UIDragSession>)session {
    session.localContext = self;
}
#pragma mark UIDropInteractionDelegate
- (BOOL)dropInteraction:(UIDropInteraction *)interaction canHandleSession:(id<UIDropSession>)session {
    if (session.localDragSession.localContext == self) {
        return NO;
    }
    
    return [session canLoadObjectsOfClass:UIColor.class];
}
- (UIDropProposal *)dropInteraction:(UIDropInteraction *)interaction sessionDidUpdate:(id<UIDropSession>)session {
    UIDropOperation operation = UIDropOperationCancel;
    
    if (CGRectContainsPoint(self.swatchView.frame, [session locationInView:self])) {
        operation = UIDropOperationCopy;
    }
    
    return [[UIDropProposal alloc] initWithDropOperation:operation];
}
- (void)dropInteraction:(UIDropInteraction *)interaction performDrop:(id<UIDropSession>)session {
    [session loadObjectsOfClass:UIColor.class completion:^(NSArray<UIColor *> * _Nonnull objects) {
        self.color = objects.firstObject;
    }];
}
#pragma mark *** Public Methods ***
#pragma mark Properties
- (void)setColor:(UIColor *)color {
    [self setColor:color notify:NO];
}
- (void)setColor:(UIColor *)color notify:(BOOL)notify; {
    [self willChangeValueForKey:@kstKeypath(self,color)];
    
    _color = color ?: [KSOColorPickerView _defaultColorForMode:self.mode];
    
    [self didChangeValueForKey:@kstKeypath(self,color)];
    
    self.swatchView.color = _color;
    
    if (self.shouldUpdateSlidersColor) {
        for (KSOColorPickerSlider *slider in self.sliders) {
            [slider updateWithColorPickerViewColor];
        }
    }
    
    if (notify) {
        [NSNotificationCenter.defaultCenter postNotificationName:KSOColorPickerViewNotificationDidChangeColor object:self];
    }
}
#pragma mark -
- (void)setMode:(KSOColorPickerViewMode)mode {
    if (_mode == mode) {
        return;
    }
    
    _mode = mode;
    
    [self _updateSliderControls];
    
    [NSNotificationCenter.defaultCenter postNotificationName:KSOColorPickerViewNotificationDidChangeMode object:self];
}
- (void)setUserCanSelectMode:(BOOL)userCanSelectMode {
    if (_userCanSelectMode == userCanSelectMode) {
        return;
    }
    
    _userCanSelectMode = userCanSelectMode;
    
    if (_userCanSelectMode) {
        if (self.segmentedControl == nil) {
            self.segmentedControl = [[UISegmentedControl alloc] initWithFrame:CGRectZero];
            self.segmentedControl.translatesAutoresizingMaskIntoConstraints = NO;
            [self.segmentedControl removeAllSegments];
            [self.userSelectableModes enumerateObjectsUsingBlock:^(NSNumber * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                [self.segmentedControl insertSegmentWithTitle:[KSOColorPickerView _userSelectableTitleForMode:obj.integerValue] atIndex:idx animated:NO];
            }];
            self.segmentedControl.selectedSegmentIndex = [self.userSelectableModes indexOfObjectPassingTest:^BOOL(NSNumber * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                return obj.integerValue == self.mode;
            }];
            [self.segmentedControl addTarget:self action:@selector(_segmentedControlAction:) forControlEvents:UIControlEventValueChanged];
            [self.segmentedControl setContentCompressionResistancePriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisVertical];
            [self addSubview:self.segmentedControl];
        }
        
        [self setNeedsUpdateConstraints];
    }
    else {
        [self.segmentedControl removeFromSuperview];
        self.segmentedControl = nil;
        
        [self setNeedsUpdateConstraints];
    }
}
#pragma mark -
- (void)setComponentColor:(UIColor *)componentColor {
    _componentColor = componentColor ?: KSOColorPickerView.defaultComponentColor;
    
    for (UILabel *label in self.componentLabels) {
        label.textColor = _componentColor;
    }
}
- (void)setComponentFont:(UIFont *)componentFont {
    _componentFont = componentFont ?: KSOColorPickerView.defaultComponentFont;
    
    for (UILabel *label in self.componentLabels) {
        label.font = _componentFont;
    }
}
- (void)setComponentTextStyle:(UIFontTextStyle)componentTextStyle {
    _componentTextStyle = componentTextStyle;
    
    for (UILabel *label in self.componentLabels) {
        label.KDI_dynamicTypeTextStyle = _componentTextStyle;
    }
}
#pragma mark -
- (void)setValueBackgroundColor:(UIColor *)valueBackgroundColor {
    _valueBackgroundColor = valueBackgroundColor ?: KSOColorPickerView.defaultValueBackgroundColor;
}
- (void)setValueForegroundColor:(UIColor *)valueForegroundColor {
    _valueForegroundColor = valueForegroundColor ?: KSOColorPickerView.defaultValueForegroundColor;
}
- (void)setValueFont:(UIFont *)valueFont {
    _valueFont = valueFont ?: KSOColorPickerView.defaultValueFont;
}
#pragma mark -
- (void)setRGBNumberFormatter:(NSNumberFormatter *)RGBNumberFormatter {
    _RGBNumberFormatter = RGBNumberFormatter ?: KSOColorPickerView.defaultRGBNumberFormatter;
}
- (void)setHueNumberFormatter:(NSNumberFormatter *)hueNumberFormatter {
    _hueNumberFormatter = hueNumberFormatter ?: KSOColorPickerView.defaultHueNumberFormatter;
}
- (void)setPercentNumberFormatter:(NSNumberFormatter *)percentNumberFormatter {
    _percentNumberFormatter = percentNumberFormatter ?: KSOColorPickerView.defaultPercentNumberFormatter;
}
#pragma mark *** Private Methods ***
- (void)_KSOColorPickerViewInit; {
    _mode = KSOColorPickerViewModeDefault;
    _color = [KSOColorPickerView _defaultColorForMode:_mode];
    
    _componentColor = KSOColorPickerView.defaultComponentColor;
    _componentFont = KSOColorPickerView.defaultComponentFont;
    _componentTextStyle = KSOColorPickerView.defaultComponentTextStyle;
    
    _valueBackgroundColor = KSOColorPickerView.defaultValueBackgroundColor;
    _valueForegroundColor = KSOColorPickerView.defaultValueForegroundColor;
    _valueFont = KSOColorPickerView.defaultValueFont;
    _valueTextStyle = KSOColorPickerView.defaultValueTextStyle;
    
    _RGBNumberFormatter = KSOColorPickerView.defaultRGBNumberFormatter;
    _hueNumberFormatter = KSOColorPickerView.defaultHueNumberFormatter;
    _percentNumberFormatter = KSOColorPickerView.defaultPercentNumberFormatter;
    
    _userSelectableModes = @[@(KSOColorPickerViewModeW), @(KSOColorPickerViewModeWA), @(KSOColorPickerViewModeRGB), @(KSOColorPickerViewModeRGBA), @(KSOColorPickerViewModeHSB), @(KSOColorPickerViewModeHSBA)];
    
    _shouldUpdateSlidersColor = YES;
    
    _swatchView = [[KSOColorPickerSwatchView alloc] initWithFrame:CGRectZero];
    _swatchView.translatesAutoresizingMaskIntoConstraints = NO;
    _swatchView.color = _color;
    
    UIDragInteraction *drag = [[UIDragInteraction alloc] initWithDelegate:self];
    
    drag.enabled = YES;
    
    [_swatchView addInteraction:drag];
    [_swatchView addInteraction:[[UIDropInteraction alloc] initWithDelegate:self]];
    [self addSubview:_swatchView];
    
    _stackView = [[UIStackView alloc] initWithFrame:CGRectZero];
    _stackView.translatesAutoresizingMaskIntoConstraints = NO;
    _stackView.axis = UILayoutConstraintAxisVertical;
    _stackView.alignment = UIStackViewAlignmentLeading;
    _stackView.distribution = UIStackViewDistributionEqualSpacing;
    _stackView.spacing = 8.0;
    [self addSubview:_stackView];
    
    [self _updateSliderControls];
}
#pragma mark -
- (void)_updateSliderControls; {
    NSArray *componentTypes;
    
    switch (self.mode) {
        case KSOColorPickerViewModeRGB:
            componentTypes = @[@(KSOColorPickerViewComponentTypeRed), @(KSOColorPickerViewComponentTypeGreen), @(KSOColorPickerViewComponentTypeBlue)];
            break;
        case KSOColorPickerViewModeHSB:
            componentTypes = @[@(KSOColorPickerViewComponentTypeHue), @(KSOColorPickerViewComponentTypeSaturation), @(KSOColorPickerViewComponentTypeBrightness)];
            break;
        case KSOColorPickerViewModeW:
            componentTypes = @[@(KSOColorPickerViewComponentTypeWhite)];
            break;
        case KSOColorPickerViewModeWA:
            componentTypes = @[@(KSOColorPickerViewComponentTypeWhite), @(KSOColorPickerViewComponentTypeAlpha)];
            break;
        case KSOColorPickerViewModeHSBA:
            componentTypes = @[@(KSOColorPickerViewComponentTypeHue), @(KSOColorPickerViewComponentTypeSaturation), @(KSOColorPickerViewComponentTypeBrightness), @(KSOColorPickerViewComponentTypeAlpha)];
            break;
        case KSOColorPickerViewModeRGBA:
            componentTypes = @[@(KSOColorPickerViewComponentTypeRed), @(KSOColorPickerViewComponentTypeGreen), @(KSOColorPickerViewComponentTypeBlue), @(KSOColorPickerViewComponentTypeAlpha)];
            break;
        default:
            break;
    }
    
    for (UIView *view in self.stackView.subviews) {
        [view removeFromSuperview];
    }
    
    NSMutableArray *sliders = [[NSMutableArray alloc] init];
    NSMutableArray *labels = [[NSMutableArray alloc] init];
    
    for (NSNumber *type in componentTypes) {
        UIStackView *horizontalStackView = [[UIStackView alloc] initWithFrame:CGRectZero];
        
        horizontalStackView.translatesAutoresizingMaskIntoConstraints = NO;
        horizontalStackView.axis = UILayoutConstraintAxisHorizontal;
        horizontalStackView.spacing = 8.0;
        horizontalStackView.alignment = UIStackViewAlignmentCenter;
        
        [self.stackView addArrangedSubview:horizontalStackView];
        
        [NSLayoutConstraint activateConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[view]|" options:0 metrics:nil views:@{@"view": horizontalStackView}]];
        
        UILabel *label = [self _createLabelForComponentType:type.integerValue];
        
        [label setContentHuggingPriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
        
        [labels addObject:label];
        [horizontalStackView addArrangedSubview:label];
        
        UISlider *slider = [self _createSliderControlForComponentType:type.integerValue];
        
        [horizontalStackView addArrangedSubview:slider];
        [sliders addObject:slider];
    }
    
    self.componentLabels = labels;
    self.sliders = sliders;
}
#pragma mark -
- (KSOColorPickerSlider *)_createSliderControlForComponentType:(KSOColorPickerViewComponentType)type; {
    KSOColorPickerSlider *retval = [[KSOColorPickerSlider alloc] initWithComponentType:type colorPickerView:self];
    
    retval.translatesAutoresizingMaskIntoConstraints = NO;
    
    [retval addTarget:self action:@selector(_sliderValueChanged:) forControlEvents:UIControlEventValueChanged];
    [retval addTarget:self action:@selector(_sliderTouchDown:) forControlEvents:UIControlEventTouchDown];
    [retval addTarget:self action:@selector(_sliderTouchUp:) forControlEvents:UIControlEventTouchUpInside|UIControlEventTouchUpOutside|UIControlEventTouchCancel];
    
    return retval;
}
- (UILabel *)_createLabelForComponentType:(KSOColorPickerViewComponentType)type; {
    UILabel *retval = [[UILabel alloc] initWithFrame:CGRectZero];
    
    retval.translatesAutoresizingMaskIntoConstraints = NO;
    retval.font = self.componentFont;
    retval.textColor = self.componentColor;
    retval.KDI_dynamicTypeTextStyle = self.componentTextStyle;
    
    switch (type) {
        case KSOColorPickerViewComponentTypeBrightness:
            retval.text = NSLocalizedStringWithDefaultValue(@"label.brightness", nil, NSBundle.KSO_colorPickerFrameworkBundle, @"Brightness", @"brightness label");
            break;
        case KSOColorPickerViewComponentTypeSaturation:
            retval.text = NSLocalizedStringWithDefaultValue(@"label.saturation", nil, NSBundle.KSO_colorPickerFrameworkBundle, @"Saturation", @"saturation label");
            break;
        case KSOColorPickerViewComponentTypeHue:
            retval.text = NSLocalizedStringWithDefaultValue(@"label.hue", nil, NSBundle.KSO_colorPickerFrameworkBundle, @"Hue", @"hue label");
            break;
        case KSOColorPickerViewComponentTypeRed:
            retval.text = NSLocalizedStringWithDefaultValue(@"label.red", nil, NSBundle.KSO_colorPickerFrameworkBundle, @"Red", @"red label");
            break;
        case KSOColorPickerViewComponentTypeGreen:
            retval.text = NSLocalizedStringWithDefaultValue(@"label.green", nil, NSBundle.KSO_colorPickerFrameworkBundle, @"Green", @"green label");
            break;
        case KSOColorPickerViewComponentTypeBlue:
            retval.text = NSLocalizedStringWithDefaultValue(@"label.blue", nil, NSBundle.KSO_colorPickerFrameworkBundle, @"Blue", @"blue label");
            break;
        case KSOColorPickerViewComponentTypeAlpha:
            retval.text = NSLocalizedStringWithDefaultValue(@"label.alpha", nil, NSBundle.KSO_colorPickerFrameworkBundle, @"Alpha", @"alpha label");
            break;
        case KSOColorPickerViewComponentTypeWhite:
            retval.text = NSLocalizedStringWithDefaultValue(@"label.white", nil, NSBundle.KSO_colorPickerFrameworkBundle, @"White", @"white label");
            break;
    }
    
    return retval;
}
#pragma mark -
+ (UIColor *)_defaultColorForMode:(KSOColorPickerViewMode)mode; {
    UIColor *retval;
    
    switch (mode) {
        case KSOColorPickerViewModeRGB:
        case KSOColorPickerViewModeRGBA:
            retval = KDIColorRGBA(0.0, 0.0, 0.0, 1.0);
            break;
        case KSOColorPickerViewModeW:
        case KSOColorPickerViewModeWA:
            retval = KDIColorWA(0.0, 1.0);
            break;
        case KSOColorPickerViewModeHSB:
        case KSOColorPickerViewModeHSBA:
            retval = KDIColorHSBA(0.0, 1.0, 1.0, 1.0);
            break;
        default:
            break;
    }
    
    return retval;
}
+ (NSString *)_userSelectableTitleForMode:(KSOColorPickerViewMode)mode; {
    switch (mode) {
        case KSOColorPickerViewModeHSBA:
            return NSLocalizedStringWithDefaultValue(@"label.hsba", nil, NSBundle.KSO_colorPickerFrameworkBundle, @"HSBA", @"hsba label");
        case KSOColorPickerViewModeRGBA:
            return NSLocalizedStringWithDefaultValue(@"label.rgba", nil, NSBundle.KSO_colorPickerFrameworkBundle, @"RGBA", @"rgba label");
        case KSOColorPickerViewModeWA:
            return NSLocalizedStringWithDefaultValue(@"label.wa", nil, NSBundle.KSO_colorPickerFrameworkBundle, @"WA", @"wa label");
        case KSOColorPickerViewModeW:
            return NSLocalizedStringWithDefaultValue(@"label.w", nil, NSBundle.KSO_colorPickerFrameworkBundle, @"W", @"w label");
        case KSOColorPickerViewModeHSB:
            return NSLocalizedStringWithDefaultValue(@"label.hsb", nil, NSBundle.KSO_colorPickerFrameworkBundle, @"HSB", @"hsb label");
        case KSOColorPickerViewModeRGB:
            return NSLocalizedStringWithDefaultValue(@"label.rgb", nil, NSBundle.KSO_colorPickerFrameworkBundle, @"RGB", @"rgb label");
    }
}
#pragma mark Actions
- (IBAction)_sliderValueChanged:(KSOColorPickerSlider *)sender {
    switch (self.mode) {
        case KSOColorPickerViewModeRGB:
            [self setColor:KDIColorRGB(self.sliders[0].value, self.sliders[1].value, self.sliders[2].value) notify:YES];
            break;
        case KSOColorPickerViewModeRGBA:
            [self setColor:KDIColorRGBA(self.sliders[0].value, self.sliders[1].value, self.sliders[2].value, self.sliders[3].value) notify:YES];
            break;
        case KSOColorPickerViewModeHSBA:
            [self setColor:KDIColorHSBA(self.sliders[0].value, self.sliders[1].value, self.sliders[2].value, self.sliders[3].value) notify:YES];
            break;
        case KSOColorPickerViewModeHSB:
            [self setColor:KDIColorHSB(self.sliders[0].value, self.sliders[1].value, self.sliders[2].value) notify:YES];
            break;
        case KSOColorPickerViewModeW:
            [self setColor:KDIColorW(self.sliders[0].value) notify:YES];
            break;
        case KSOColorPickerViewModeWA:
            [self setColor:KDIColorWA(self.sliders[0].value, self.sliders[1].value) notify:YES];
            break;
        default:
            break;
    }
}
- (IBAction)_sliderTouchDown:(id)sender {
    self.shouldUpdateSlidersColor = NO;
}
- (IBAction)_sliderTouchUp:(id)sender {
    self.shouldUpdateSlidersColor = YES;
}
- (IBAction)_segmentedControlAction:(id)sender {
    self.mode = self.userSelectableModes[self.segmentedControl.selectedSegmentIndex].integerValue;
}
#pragma mark Properties
+ (UIColor *)defaultComponentColor {
    return UIColor.blackColor;
}
+ (UIFont *)defaultComponentFont {
    return [UIFont systemFontOfSize:13.0];
}
+ (UIFontTextStyle)defaultComponentTextStyle {
    return UIFontTextStyleCaption1;
}
#pragma mark -
+ (UIColor *)defaultValueBackgroundColor {
    return UIColor.blackColor;
}
+ (UIColor *)defaultValueForegroundColor {
    return UIColor.whiteColor;
}
+ (UIFont *)defaultValueFont {
    return [UIFont systemFontOfSize:17.0];
}
+ (UIFontTextStyle)defaultValueTextStyle {
    return UIFontTextStyleBody;
}
#pragma mark -
+ (NSNumberFormatter *)defaultRGBNumberFormatter {
    NSNumberFormatter *retval = [[NSNumberFormatter alloc] init];
    
    retval.maximumFractionDigits = 2;
    
    return retval;
}
+ (NSNumberFormatter *)defaultHueNumberFormatter {
    NSNumberFormatter *retval = [[NSNumberFormatter alloc] init];
    
    retval.maximumFractionDigits = 2;
    retval.positiveSuffix = NSLocalizedStringWithDefaultValue(@"format.positive-suffix.hue", nil, NSBundle.KSO_colorPickerFrameworkBundle, @"°", @"format positive suffix hue (e.g. 270°)");
    
    return retval;
}
+ (NSNumberFormatter *)defaultPercentNumberFormatter {
    NSNumberFormatter *retval = [[NSNumberFormatter alloc] init];
    
    retval.numberStyle = NSNumberFormatterPercentStyle;
    retval.maximumFractionDigits = 2;
    
    return retval;
}

@end
