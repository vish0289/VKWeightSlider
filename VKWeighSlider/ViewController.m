//
//  ViewController.m
//  VKWeighSlider
//
//  Created by Maciej Banasiewicz on 12.12.2014.
//  Copyright (c) 2014 koalapps. All rights reserved.
//

#import "ViewController.h"
#import "VKWeightSlider.h"
#import "VKArrowView.h"

@interface ViewController ()

@end

@implementation ViewController {
    VKWeightSlider *slider;
    VKArrowView *_arrowView;
    UILabel *valueLabel;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    CGSize sliderSize = self.view.bounds.size;
    sliderSize.height = 100.0f;
    slider = [[VKWeightSlider alloc] initWithFrame:CGRectMake(0.0f, self.view.center.y - sliderSize.height / 2.0f, sliderSize.width, sliderSize.height) initialValue:10.0f];
    slider.ticksColor = [UIColor redColor];
    [self.view addSubview:slider];

    [slider addObserver:self
             forKeyPath:@"currentValue"
                options:NSKeyValueObservingOptionNew
                context:nil];

    CGSize arrowSize = CGSizeMake(100.0f, 150.0f);
    CGRect arrowViewFrame = CGRectMake(CGRectGetMidX(slider.frame) - arrowSize.width / 2.0f, CGRectGetMaxY(slider.frame) - arrowSize.height - 50.0f, arrowSize.width, arrowSize.height);
    _arrowView = [[VKArrowView alloc] initWithFrame:arrowViewFrame];
    _arrowView.userInteractionEnabled = NO;
    _arrowView.lineWidth = 5.0f;
    _arrowView.verticalInset = 5.0f;
    _arrowView.triangleHeight = 20.0f;
    _arrowView.triangleWidth = 40.0f;
    _arrowView.arrowColor = [UIColor grayColor];
    [self.view addSubview:_arrowView];
    
    valueLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, self.view.bounds.size.height - 100.0f, self.view.bounds.size.width, 100.0f)];
    [self.view addSubview:valueLabel];
}


- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    NSNumber *newValue = change[@"new"];
    valueLabel.text = [NSString stringWithFormat:@"Current value: %@", newValue.stringValue];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
