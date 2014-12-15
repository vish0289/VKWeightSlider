//
//  _VKRulerView.h
//  VKWeighSlider
//
//  Created by Maciej Banasiewicz on 12.12.2014.
//  Copyright (c) 2014 koalapps. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface _VKRulerView : UIView
@property(nonatomic, assign) NSInteger numberOfUnits; // Number of big ticks
@property(nonatomic, assign) CGFloat tickWidth; // Width of a single line
@property(nonatomic, assign) NSInteger minorTickCounter; // Number of smaller ticks between bigger ones
@property(nonatomic, assign) NSInteger rulerID; // Custom ruler ID, for labels swapping
@property(nonatomic, copy) UIColor *ticksColor;

- (CGFloat)spaceBetweenTicks;
@end
