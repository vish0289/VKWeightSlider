//
//  VKArrowView.m
//  VKWeighSlider
//
//  Created by Maciej Banasiewicz on 12/12/14.
//  Copyright (c) 2014 koalapps. All rights reserved.
//

#import "VKArrowView.h"


@implementation VKArrowView

- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.arrowColor = [UIColor greenColor];
        self.backgroundColor = [UIColor clearColor];
        self.lineWidth = 2.0f;
        self.verticalInset = 2.0f;
        self.triangleHeight = frame.size.height * 0.5f;
        self.triangleWidth = frame.size.width;
        self.opaque = YES;
    }
    return self;
}

- (void)setArrowColor:(UIColor *)arrowColor {
    _arrowColor = arrowColor;
    [self setNeedsDisplay];
}

- (void)setLineWidth:(CGFloat)lineWidth {
    _lineWidth = lineWidth;
    [self setNeedsDisplay];
}


- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];
    
    CGRect rectWithInsets = rect;
    
    // Origin mixup
    // Those are corrent values when we flip origin
    // below
    rectWithInsets.size.height -=  _verticalInset;
    rectWithInsets.origin.y -= 2.0f * _verticalInset;
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    
    CGContextSaveGState(ctx);
    CGAffineTransform flipVertical = CGAffineTransformMake(1, 0, 0, -1, 0, rect.size.height);
    CGContextConcatCTM(ctx, flipVertical);
    
    CGContextSetAllowsAntialiasing(ctx, true);
    CGPoint pathStartingPoint = CGPointMake(CGRectGetMidX(rectWithInsets), CGRectGetMinY(rectWithInsets));
    CGPoint pathEndingPoint = CGPointMake(CGRectGetMidX(rectWithInsets), CGRectGetMaxY(rectWithInsets));
    
    CGFloat triangleWidthHalf = _triangleHeight / 2.0f;
    
    [self.arrowColor setStroke];
    [self.arrowColor setFill];
    

    CGContextSetLineWidth(ctx, _lineWidth);
    CGContextBeginPath(ctx);

    // Start drawing at default y
    CGContextMoveToPoint(ctx, pathStartingPoint.x, pathStartingPoint.y);
    CGContextAddLineToPoint(ctx, pathEndingPoint.x, pathEndingPoint.y - _triangleHeight);

    CGContextMoveToPoint(ctx, pathEndingPoint.x, pathEndingPoint.y - _triangleHeight);
    CGContextAddLineToPoint(ctx, pathEndingPoint.x - triangleWidthHalf, pathEndingPoint.y - _triangleHeight);
    CGContextAddLineToPoint(ctx, pathEndingPoint.x, pathEndingPoint.y);
    CGContextAddLineToPoint(ctx, pathEndingPoint.x + triangleWidthHalf, pathEndingPoint.y - _triangleHeight);
    CGContextAddLineToPoint(ctx, pathEndingPoint.x, pathEndingPoint.y - _triangleHeight);
    CGContextDrawPath(ctx, kCGPathFillStroke);

    CGContextRestoreGState(ctx);
}

@end
