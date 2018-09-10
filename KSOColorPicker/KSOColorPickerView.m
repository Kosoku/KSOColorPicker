//
//  KSOColorPickerView.m
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

#import "KSOColorPickerView.h"
#import "KSOColorPickerViewPrivate.h"
#import "KSOColorPickerSlider.h"
#import "KSOColorPickerSwatchView.h"

#import <Stanley/Stanley.h>
#import <Ditko/Ditko.h>

NSNotificationName const KSOColorPickerViewNotificationDidChangeColor = @"KSOColorPickerViewNotificationDidChangeColor";

@interface KSOColorPickerView () <UIDragInteractionDelegate, UIDropInteractionDelegate>
@property (strong,nonatomic) KSOColorPickerSwatchView *swatchView;
@property (strong,nonatomic) UIStackView *stackView;
@property (strong,nonatomic) UISegmentedControl *segmentedControl;
@property (copy,nonatomic) NSArray<KSOColorPickerSlider *> *sliders;

@property (copy,nonatomic) NSArray<NSNumber *> *userSelectableModes;

@property (assign,nonatomic) BOOL shouldUpdateSlidersColor;

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
        [temp addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-[view]" options:0 metrics:nil views:@{@"view": self.segmentedControl, @"top": self.swatchView}]];
    }
    
    [temp addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-[view]-|" options:0 metrics:nil views:@{@"view": self.swatchView}]];
    
    CGFloat swatchViewHeight = 32.0;
    
    if (self.segmentedControl == nil) {
        [temp addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-[view(==height)]" options:0 metrics:@{@"height": @(swatchViewHeight)} views:@{@"view": self.swatchView}]];
    }
    else {
        [temp addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[top]-[view(==height)]" options:0 metrics:@{@"height": @(swatchViewHeight)} views:@{@"view": self.swatchView, @"top": self.segmentedControl}]];
    }
    
    [temp addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-[view]-|" options:0 metrics:nil views:@{@"view": self.stackView}]];
    [temp addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[top]-[view]-|" options:0 metrics:nil views:@{@"view": self.stackView, @"top": self.swatchView}]];
    
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
        
        [horizontalStackView addArrangedSubview:label];
        
        UISlider *slider = [self _createSliderControlForComponentType:type.integerValue];
        
        [horizontalStackView addArrangedSubview:slider];
        [sliders addObject:slider];
    }
    
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
    retval.font = [UIFont systemFontOfSize:13.0];
    retval.textColor = UIColor.blackColor;
    
    switch (type) {
        case KSOColorPickerViewComponentTypeBrightness:
            retval.text = @"Brightness";
            break;
        case KSOColorPickerViewComponentTypeSaturation:
            retval.text = @"Saturation";
            break;
        case KSOColorPickerViewComponentTypeHue:
            retval.text = @"Hue";
            break;
        case KSOColorPickerViewComponentTypeRed:
            retval.text = @"Red";
            break;
        case KSOColorPickerViewComponentTypeGreen:
            retval.text = @"Green";
            break;
        case KSOColorPickerViewComponentTypeBlue:
            retval.text = @"Blue";
            break;
        case KSOColorPickerViewComponentTypeAlpha:
            retval.text = @"Alpha";
            break;
        case KSOColorPickerViewComponentTypeWhite:
            retval.text = @"White";
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
            return @"HSBA";
        case KSOColorPickerViewModeRGBA:
            return @"RGBA";
        case KSOColorPickerViewModeWA:
            return @"WA";
        case KSOColorPickerViewModeW:
            return @"W";
        case KSOColorPickerViewModeHSB:
            return @"HSB";
        case KSOColorPickerViewModeRGB:
            return @"RGB";
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
+ (NSNumberFormatter *)defaultRGBNumberFormatter {
    NSNumberFormatter *retval = [[NSNumberFormatter alloc] init];
    
    retval.maximumFractionDigits = 2;
    
    return retval;
}
+ (NSNumberFormatter *)defaultHueNumberFormatter {
    NSNumberFormatter *retval = [[NSNumberFormatter alloc] init];
    
    retval.maximumFractionDigits = 2;
    retval.positiveSuffix = @"°";
    
    return retval;
}
+ (NSNumberFormatter *)defaultPercentNumberFormatter {
    NSNumberFormatter *retval = [[NSNumberFormatter alloc] init];
    
    retval.numberStyle = NSNumberFormatterPercentStyle;
    retval.maximumFractionDigits = 2;
    
    return retval;
}

@end
