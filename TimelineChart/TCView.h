//
//  TCView.h
//  TimelineChart
//
//  Created by Stanislav Pletnev on 23.03.17.
//  Copyright © 2017 Anobisoft. All rights reserved.
//

// @see TCGraphSource

#import <UIKit/UIKit.h>
#import <TimelineChart/TCGraph.h>

@class TCView;

@protocol TCGraphSource
@required
- (TCGraph *)graphForView:(TCView *)graphView;
@end

IB_DESIGNABLE

@interface TCView : UIView

@property (nonatomic, weak) IBOutlet id<TCGraphSource> graphSource;

@property (nonatomic) IBInspectable CGFloat lineWidth;
@property (nonatomic) IBInspectable CGFloat pointRadius;

@property (nonatomic) IBInspectable UIColor *pointColor;
@property (nonatomic) IBInspectable UIColor *gradientBottomColor;
@property (nonatomic) IBInspectable UIColor *gradientTopColor;

@property (nonatomic) IBInspectable CFTimeInterval lineAnimationDuration;
@property (nonatomic) IBInspectable CFTimeInterval gradientAnimationDuration;

- (void)clear;
- (void)drawGraphAnimated:(BOOL)animated;

@end
