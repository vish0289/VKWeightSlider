//
//  _VKRulerView.m
//  VKWeighSlider
//
//  Created by Maciej Banasiewicz on 12.12.2014.
//  Copyright (c) 2014 koalapps. All rights reserved.
//

#import "_VKRulerView.h"

@implementation _VKRulerView

- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor clearColor];
        self.clipsToBounds = NO;
        _ticksColor = [UIColor blackColor];
        _numberOfUnits = 4;
        _tickWidth = 1.0f;
        _minorTickCounter = 10;
    }
    return self;
}

- (void)drawRect:(CGRect)rect {
    CGContextRef ctx = UIGraphicsGetCurrentContext();

    // Number ticks that needs to be drawn
    NSInteger totalNumberOfTicks = _numberOfUnits * _minorTickCounter;
    
    // Subtrackt width of ticks
    CGFloat widthLeft = rect.size.width - totalNumberOfTicks * _tickWidth;
    
    // Number of small ticks in this view
    CGFloat spaceBetweenTicks = widthLeft / totalNumberOfTicks;
    
    // Length of ticks
    CGFloat majorTickLength = rect.size.height;
    CGFloat middleTickLength = round(rect.size.height * 0.75f);
    CGFloat minorTickLength = round(rect.size.height * 0.5f);
    
    
    CGContextSetStrokeColorWithColor(ctx, self.ticksColor.CGColor);
    CGContextSetLineWidth(ctx, _tickWidth);
    CGFloat y = 1.0f;
    
    // For each small tick
    for (NSInteger currentTickNumber = 0; currentTickNumber < totalNumberOfTicks; currentTickNumber++) {
        
        NSInteger previousTickIdx = currentTickNumber;
        if (previousTickIdx < 0) {
            previousTickIdx = 0;
        }
        CGFloat previousTicksSpace = (previousTickIdx - 1) * _tickWidth + _tickWidth;
        
        CGFloat x = currentTickNumber * spaceBetweenTicks + previousTicksSpace;
        if (currentTickNumber == 0 || currentTickNumber == totalNumberOfTicks) {
            x += _tickWidth;
        }
        
        // Start drawing at default y
        CGContextMoveToPoint(ctx, x, y);
        
        CGFloat lineEnd = 0.0f;
        if (currentTickNumber % 10 == 0) {
            // Big tick
            lineEnd = y + majorTickLength;
        } else if (currentTickNumber % 5 == 0) {
            // Middle tick
            lineEnd = y + middleTickLength;
        } else {
            // Small tick
            lineEnd = y + minorTickLength;
        }
        
        CGContextAddLineToPoint(ctx, x, lineEnd);
        
    }
    CGContextStrokePath(ctx);
}

#pragma mark - Helpers

- (CGFloat)spaceBetweenTicks {
    // Number ticks that needs to be drawn
    NSInteger totalNumberOfTicks = _numberOfUnits * _minorTickCounter;
    // Subtract width of ticks
    CGFloat widthLeft = self.frame.size.width - totalNumberOfTicks * _tickWidth;
    return widthLeft / totalNumberOfTicks;
}

#pragma mark - Setters

- (void)setNumberOfUnits:(NSInteger)numberOfUnits {
    _numberOfUnits = numberOfUnits;
    [self setNeedsDisplay];
}

- (void)setTickWidth:(CGFloat)tickWidth {
    _tickWidth = tickWidth;
    [self setNeedsDisplay];
}

- (void)setMinorTickCounter:(NSInteger)minorTickCounter {
    _minorTickCounter = minorTickCounter;
    [self setNeedsDisplay];
}

- (void)setTicksColor:(UIColor *)ticksColor {
    _ticksColor = [ticksColor copy];
    [self setNeedsDisplay];
}
@end
