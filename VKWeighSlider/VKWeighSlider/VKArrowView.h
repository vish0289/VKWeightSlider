//
//  VKArrowView.h
//  VKWeighSlider
//
//  Created by Maciej Banasiewicz on 12/12/14.
//  Copyright (c) 2014 koalapps. All rights reserved.
//

#import <UIKit/UIKit.h>

IB_DESIGNABLE
@interface VKArrowView : UIView
@property(nonatomic, strong) IBInspectable UIColor *arrowColor;
@property(nonatomic, assign) IBInspectable CGFloat lineWidth;
@property(nonatomic, assign) IBInspectable CGFloat verticalInset;
@property(nonatomic, assign) IBInspectable CGFloat triangleHeight;
@property(nonatomic, assign) IBInspectable CGFloat triangleWidth;
@end
