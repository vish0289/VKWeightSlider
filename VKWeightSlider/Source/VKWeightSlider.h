//
//  VKWeightSlider.h
//  VKWeighSlider
//
//  Created by Maciej Banasiewicz on 12.12.2014.
//  Copyright (c) 2014 koalapps. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface VKWeightSlider : UIScrollView
@property (nonatomic) CGFloat currentValue; // Current value
@property (nonatomic) CGFloat defaultLabelScale; // Default scale of value label - 0.75 default
@property (nonatomic) CGFloat valueBetweenTicks; // Value represented by single tick, default is 0.1
@property (nonatomic, copy) UIColor *ticksColor;
- (id)initWithFrame:(CGRect)frame initialValue:(CGFloat)initialValue;
@end
