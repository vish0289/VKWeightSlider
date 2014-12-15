//
//  VKWeightSlider.m
//  VKWeighSlider
//
//  Created by Maciej Banasiewicz on 12.12.2014.
//  Copyright (c) 2014 koalapps. All rights reserved.
//

#import "VKWeightSlider.h"
#import "_VKRulerView.h"
#import "VKArrowView.h"


CGFloat roundToDecimal(CGFloat num, NSInteger decimals) {
    NSInteger tenpow = 1;
    for (; decimals; tenpow *= 10, decimals--);
    return roundf(tenpow * num) / tenpow;
}

@interface VKWeightSlider () <UIScrollViewDelegate>
@property(nonatomic, strong) NSMutableArray *_rulers; // Rulers (background with ticks)
@property(nonatomic, strong) NSMutableArray *_valueLabels; // Refrence to all labels
@property(nonatomic, strong) NSMutableDictionary *_rulersToLabelsDictionary; // Keeps ref to ruler labels
@property(nonatomic) CGFloat _numberOfUnitsPerRuler; // Now it's set to 4 - number of big ticks per view
@property(nonatomic) CGSize _valueLabelSize; // Size of label
@property(nonatomic) CGFloat _rulerHeight; // Height of ruler
@property(nonatomic) CGFloat _bottomRulerOffset; // Height of ruler
@property(nonatomic) CGFloat initialValue;
@end

// Offset from previous delegate callback
static CGFloat lastOffset = 0.0f;
// Direction flag
static BOOL scrollingRight = NO;

@implementation VKWeightSlider
#pragma mark - Life cycle

- (id)initWithFrame:(CGRect)frame initialValue:(CGFloat)initialValue {
    if (self = [super initWithFrame:frame]) {
        self.initialValue = initialValue;
        [self commonInit];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self commonInit];
    }
    return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    [self commonInit];
}

- (void)commonInit {
    [self configureProperties];
    [self createRulers];
    [self createValueLabels];
    [self _updateLabelsScale:__valueLabels forCurrentContentOffset:CGRectGetMidX(self.frame)];
    
    if (self.initialValue != 0.0f) {
        CGFloat targetOffsetX = [self _offsetForValue:self.initialValue];
        NSInteger numberOfSwaps = targetOffsetX / self.frame.size.width;
        for (NSInteger i = 0; i < numberOfSwaps; i++) {
            [self _moveFirstRulerToEnd];
        }
        [self setContentOffset:CGPointMake(targetOffsetX, 0.0f)
                      animated:NO];
    }

}

- (void)configureProperties {
    // Control values
    _currentValue = self.initialValue;
    _defaultLabelScale = 0.55f;
    _valueBetweenTicks = 0.1f;
    __numberOfUnitsPerRuler = 4.0f;
    __rulerHeight = 80.0f;
    __valueLabelSize = CGSizeMake(100.0f, 50.0f);
    __bottomRulerOffset = 50.0f;

    // Arrays
    __rulers = [NSMutableArray array];
    __valueLabels = [NSMutableArray array];
    __rulersToLabelsDictionary = [NSMutableDictionary dictionary];

    // Self configuration
    self.delegate = self;
    self.decelerationRate = 0.99f;
    self.showsHorizontalScrollIndicator = NO;
    self.backgroundColor = [UIColor whiteColor];
    self.contentSize = CGSizeMake(CGFLOAT_MAX, self.frame.size.height);
}

- (void)createValueLabels {
    for (_VKRulerView *ruler in __rulers) {
        // Create value labels for each ruler
        NSMutableArray *rulerLabels = [NSMutableArray array];

        for (NSInteger unitIdx = 0; unitIdx < __numberOfUnitsPerRuler; unitIdx++) {
            UILabel *label = [[UILabel alloc] init];
            label.textAlignment = NSTextAlignmentCenter;
            label.backgroundColor = [UIColor clearColor];
            label.transform = CGAffineTransformMakeScale(_defaultLabelScale, _defaultLabelScale);
            [rulerLabels addObject:label];
            [self addSubview:label];
        }
        __rulersToLabelsDictionary[@(ruler.rulerID)] = [rulerLabels copy];

        // Sets proper frame for labels
        [self _repositionLabelsForRuler:ruler];
        [__valueLabels addObjectsFromArray:rulerLabels];
    }
}

- (void)createRulers {
    // Ruler bottom offset
    CGFloat rulerY = self.bounds.size.height - __rulerHeight - __bottomRulerOffset;

    // Create rulers
    for (NSInteger i = 0; i < 3; i++) {
        CGRect rulerFrame = self.bounds;

        rulerFrame.size.height = __rulerHeight;
        rulerFrame.origin.x += i * self.bounds.size.width;
        rulerFrame.origin.y = rulerY;


        _VKRulerView *ruler = [[_VKRulerView alloc] initWithFrame:rulerFrame];
        ruler.numberOfUnits = (NSInteger) __numberOfUnitsPerRuler;
        ruler.tag = i;
        ruler.rulerID = i;
        [self addSubview:ruler];
        [__rulers addObject:ruler];
    }
}

#pragma mark - Scroll view delegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    // Check scrolling direction
    CGFloat currentOffset = scrollView.contentOffset.x;
    scrollingRight = lastOffset < currentOffset;
    lastOffset = currentOffset;

    // This is center of current scroll view bounds
    CGFloat currentScrollViewCenter = [self _currentScrollViewCenter:scrollView];
    self.currentValue = [self _valueForOffset:currentScrollViewCenter];
    [self _updateLabelsScale:__valueLabels forCurrentContentOffset:currentScrollViewCenter];
    [self repositionRulersInScrollView:scrollView currentScrollViewCenter:currentScrollViewCenter];


}

- (void)repositionRulersInScrollView:(UIScrollView *)scrollView currentScrollViewCenter:(CGFloat)currentScrollViewCenter {
    // Add offset depending on direction
    // this is used for changing rulers frame
    if (scrollingRight) {
        currentScrollViewCenter -= 0.25f * scrollView.frame.size.width;
    } else {
        currentScrollViewCenter += 0.15f * scrollView.frame.size.width;
    }


    // References to background views
    _VKRulerView *secondRuler = __rulers[1];


    // Check if we need to move first page to the end
    // or last to the front
    if (currentScrollViewCenter >= secondRuler.center.x && scrollingRight) {
        [self _moveFirstRulerToEnd];
    } else if (currentScrollViewCenter < secondRuler.center.x && !scrollingRight) {
        [self _moveLastRulerToFront];
    }
}

/**
* Snapping scroll view center to ruler tick
*/
- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView
                     withVelocity:(CGPoint)velocity
              targetContentOffset:(inout CGPoint *)targetContentOffset {
    
    // Space between smaller ticks
    CGFloat smallUnitsSpacing = self.bounds.size.width / (__numberOfUnitsPerRuler * 10.0f);

    // Current target
    CGFloat target = 0.0f;
    CGFloat systemTarget = targetContentOffset->x;


    CGFloat integral = 0.0f;
    CGFloat modulus = modff(systemTarget / smallUnitsSpacing, &integral);
    
    if (modulus < 0.5f) {
        systemTarget -= smallUnitsSpacing;
    }
    
    if ((systemTarget / smallUnitsSpacing) == 0.0f) {
        targetContentOffset->x = target;
        return;
    }
    
    while (target <= systemTarget) {
        target += smallUnitsSpacing;
    }
    targetContentOffset->x = target;
}

#pragma mark - Helper methods (Private)

/**
* Update ticks color
*/
- (void)setTicksColor:(UIColor *)ticksColor {
    _ticksColor = [ticksColor copy];
    for (_VKRulerView *rulerView in __rulers) {
        rulerView.ticksColor = ticksColor;
    }
}

/**
* Repositioning background views
*/
- (void)_moveFirstRulerToEnd {
    _VKRulerView *firstRuler = __rulers[0];
    _VKRulerView *thirdRuler = __rulers[2];
    CGRect newFrame = firstRuler.frame;
    newFrame.origin.x = thirdRuler.frame.origin.x + newFrame.size.width;
    [firstRuler setFrame:newFrame];
    [self _repositionLabelsForRuler:firstRuler];
    [__rulers exchangeObjectAtIndex:0
                  withObjectAtIndex:2];
    [__rulers exchangeObjectAtIndex:1
                  withObjectAtIndex:0];
}

/**
* Repositioning background views
*/
- (void)_moveLastRulerToFront {
    _VKRulerView *firstRuler = __rulers[0];
    _VKRulerView *thirdRuler = __rulers[2];
    CGRect newFrame = thirdRuler.frame;
    newFrame.origin.x = firstRuler.frame.origin.x - newFrame.size.width;
    [thirdRuler setFrame:newFrame];
    [self _repositionLabelsForRuler:thirdRuler];
    [__rulers exchangeObjectAtIndex:2
                  withObjectAtIndex:0];
    [__rulers exchangeObjectAtIndex:0
                  withObjectAtIndex:1];
}

- (CGFloat)_currentScrollViewCenter:(UIScrollView *)scrollView {
    CGFloat currentScrollViewCenter = scrollView.contentOffset.x + (scrollView.frame.size.width / 2.0f);
    return currentScrollViewCenter;
}

- (CGFloat)_valueForOffset:(CGFloat)offset {
    CGFloat offsetWithDiff = offset - self.frame.size.width / 2.0f;
    if (offsetWithDiff <= 0.0f) {
        return 0.0f;
    }
    // Space between smaller ticks
    CGFloat smallUnitsSpacing = self.bounds.size.width / (__numberOfUnitsPerRuler * 10.0f);
    
    CGFloat numberOfSmallUnits = offsetWithDiff / smallUnitsSpacing;
    
    return roundToDecimal(numberOfSmallUnits * _valueBetweenTicks, 1);
}

- (CGFloat)_offsetForValue:(CGFloat)value {
    return (value / _valueBetweenTicks) * (self.frame.size.width / (__numberOfUnitsPerRuler * 10.0f));
}

/**
* Updating labels scale
*/
- (void)_updateLabelsScale:(NSArray *)labels forCurrentContentOffset:(CGFloat)offset {

    // Distance from current scroll view center
    // for which items are updated
    CGFloat threshold = 100.0f;

    // Value that we need to update
    CGFloat labelScaleDifference = 1.0f - _defaultLabelScale;

    for (UILabel *label in labels) {

        // Distance from center for current label
        // value that we are interested in is 0.0 - 1.0
        CGFloat diff = ABS(offset - CGRectGetMidX(label.frame)) / threshold;

        if (diff <= 1.0f) {
            CGFloat percentageScaleUpdate = labelScaleDifference * (1.0f - diff);
            label.transform = CGAffineTransformMakeScale(_defaultLabelScale + percentageScaleUpdate, _defaultLabelScale + percentageScaleUpdate);
        } else {
            label.transform = CGAffineTransformMakeScale(_defaultLabelScale, _defaultLabelScale);
        }
    }

}

/**
* Returns ruler view for current scroll view offset
*/
- (_VKRulerView *)_closestRulerToPoint:(CGFloat)point {
    for (_VKRulerView *rulerView in __rulers) {
        if (CGRectContainsPoint(rulerView.frame, CGPointMake(point, CGRectGetMidY(rulerView.frame)))) {
            return rulerView;
            break;
        }
    }
    return nil;
}

/**
* Space between big ticks
*/
- (CGFloat)_spaceBetweenBigTicks {
    return self.frame.size.width / __numberOfUnitsPerRuler;
}

- (CGFloat)_rulerY {
    return self.bounds.size.height - __bottomRulerOffset;
}

/**
* Updates label text
*/
- (void)updateValueLabelText:(UILabel *)label {
    CGFloat labelX = label.frame.origin.x - self._spaceBetweenBigTicks;
    if (labelX < 1.0f) {
        label.text = @"";
        return;
    }

    CGFloat labelCenter = CGRectGetMidX(label.frame);
    label.text = [NSString stringWithFormat:@"%@", @([self _valueForOffset:labelCenter])];
}

/**
* Change position of value labels for given ruler
*/
- (void)_repositionLabelsForRuler:(_VKRulerView *)ruler {
    NSParameterAssert(ruler);
    NSArray *labelsForRuler = __rulersToLabelsDictionary[@(ruler.rulerID)];
    CGFloat spaceBetweenBigTicks = self._spaceBetweenBigTicks;

    // Iterate over each big tick position
    for (NSInteger unitIdx = 0; unitIdx < __numberOfUnitsPerRuler; unitIdx++) {
        UILabel *label = labelsForRuler[unitIdx];
        CGFloat newLabelX = ruler.frame.origin.x - __valueLabelSize.width / 2.0f + (unitIdx * spaceBetweenBigTicks);
        CGRect currentLabelFrame = CGRectMake(newLabelX, self._rulerY, __valueLabelSize.width, __valueLabelSize.height);
        [label setFrame:currentLabelFrame];
        [self updateValueLabelText:label];
    }
}

@end