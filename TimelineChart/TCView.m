//
//  TCView.m
//  TimelineChart
//
//  Created by Stanislav Pletnev on 23.03.17.
//  Copyright © 2017 Anobisoft. All rights reserved.
//

#import "TCView.h"
#import "TCGraph.h"

@interface TCView () <TCGraphSource>

@property (nonatomic) CABasicAnimation *lineAnimation;
@property (nonatomic) CABasicAnimation *gradientAnimation;

@property (nonatomic) CAShapeLayer *lineLayer;
@property (nonatomic) CAGradientLayer *gradientLayer;

@property (nonatomic) TCGraph *graph;
@property (nonatomic) NSArray *gradientColorsAnimStart;
@property (nonatomic) NSArray *gradientColors;

@end


@implementation TCView {
    CGFloat screenScale;
}

- (CABasicAnimation *)lineAnimation {
    if (!_lineAnimation) {
        _lineAnimation = [CABasicAnimation animationWithKeyPath:@"strokeEnd"];
        _lineAnimation.duration = 0.6f;
        _lineAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
        [_lineAnimation setAutoreverses:NO];
        [_lineAnimation setFromValue:[NSNumber numberWithInt:0]];
        [_lineAnimation setToValue:[NSNumber numberWithInt:1]];
    }
    return _lineAnimation;
}

- (void)addSublayers {
    self.gradientLayer = [CAGradientLayer layer];
    self.gradientLayer.startPoint = CGPointMake(0.5, 1.0);
    self.gradientLayer.endPoint = CGPointMake(0.5, 0.0);
    [self.layer addSublayer:self.gradientLayer];
    
    self.lineLayer = [CAShapeLayer layer];
    self.lineLayer.strokeColor = self.tintColor.CGColor;
    self.lineLayer.lineWidth = (self.lineWidth ?: 1.0) / screenScale;
    self.lineLayer.lineCap = kCALineCapRound;
    self.lineLayer.lineJoin = kCALineJoinRound;
    self.lineLayer.fillColor = NULL;
    self.lineLayer.rasterizationScale = [UIScreen mainScreen].scale;
    self.lineLayer.shouldRasterize = true;
    
    [self.layer addSublayer:self.lineLayer];
    
    self.lineAnimation.duration = self.lineAnimationDuration ?: 0.6f;
    
    self.gradientAnimation = [CABasicAnimation animationWithKeyPath:@"colors"];
    self.gradientAnimation.duration              = self.gradientAnimationDuration ?: 1.0;
    self.gradientAnimation.removedOnCompletion   = true;
    self.gradientAnimation.fillMode              = kCAFillModeForwards;
    self.gradientAnimation.timingFunction        = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn];
    [self setGradientColors];
}

- (void)setLineAnimationDuration:(CFTimeInterval)lineAnimationDuration {
    self.lineAnimation.duration = self.lineAnimationDuration ?: 1.0;
}

- (CFTimeInterval)lineAnimationDuration {
    return self.lineAnimation.duration;
}

- (void)setGradientAnimationDuration:(CFTimeInterval)gradientAnimationDuration {
    self.gradientAnimation.duration = self.gradientAnimationDuration ?: 1.0;
}

- (CFTimeInterval)gradientAnimationDuration {
    return self.gradientAnimation.duration;
}

- (void)setTintColor:(UIColor *)tintColor {
    [super setTintColor:tintColor];
    self.lineLayer.strokeColor = tintColor.CGColor;
}


- (void)prepareForInterfaceBuilder {
    [super prepareForInterfaceBuilder];
    screenScale = 2;
    [self addSublayers];
    if (self.gradientBottomColor && self.gradientTopColor) {
        self.gradientColors = @[(id)self.gradientBottomColor.CGColor, (id)self.gradientTopColor.CGColor];
    }
    self.graphSource = self;
    [self drawGraphAnimated:NO];
}

- (void)awakeFromNib {
    [super awakeFromNib];
#if !TARGET_INTERFACE_BUILDER
    screenScale = [UIScreen mainScreen].scale;
#endif
    [self addSublayers];
}

- (void)layoutSubviews {
    [super layoutSubviews];
#if !TARGET_INTERFACE_BUILDER
    [self drawGraphAnimated:true];
#else
    [self drawGraphAnimated:NO];
#endif
}

#pragma mark -
#pragma mark - TCGraphSource

- (TCGraph *)graphForView:(TCView *)graphView {
    CGRect rect = CGRectInset(graphView.bounds, 0, graphView.bounds.size.height / 10);
    unsigned int pointsCount = 9;
    double pointsarr[] = {0.5, 0.4, 0.7, 2.5, 1.3, 1.2, 0.2, 1.8, 1.5};
    double minValue = 0.2;
    double maxValue = 2.5;
    
    CGFloat scaleX = (rect.size.width - 1) / (pointsCount - 1);
    CGFloat scaleY = (rect.size.height - 1) / (maxValue - minValue);
    
    NSMutableArray<NSValue *> *pointsMutable = [NSMutableArray array];
    for (NSUInteger i = 0; i < pointsCount; i++) {
        CGPoint point = CGPointMake((double)i * scaleX, rect.origin.y + rect.size.height - (pointsarr[i] - minValue) * scaleY);
        [pointsMutable addObject:[NSValue valueWithCGPoint:point]];
    }
    
    TCGraph *result = [TCGraph new];
    result.graphPoints = pointsMutable.copy;
    result.scale = CGRectMake(1, 1, 0, minValue);
    result.rect = rect;
    
    return result;
}

#pragma mark -



- (void)clear {
    self.gradientLayer.colors = nil;
    self.gradientLayer.mask = nil;
    for (CALayer *sl in self.lineLayer.sublayers.copy) {
        [sl removeFromSuperlayer];
    }
    self.lineLayer.path = nil;
}

- (UIBezierPath *)plotBezierPath {
    UIBezierPath *bezierPath = [UIBezierPath bezierPath];
    CGPoint prevPoint = self.graph.graphPoints.firstObject.CGPointValue;
    [bezierPath moveToPoint:prevPoint];

    for (NSUInteger i = 1; i < self.graph.graphPoints.count; i++) {
        CGPoint newPoint = self.graph.graphPoints[i].CGPointValue;

        [bezierPath addLineToPoint:newPoint];

        prevPoint = newPoint;
        
    }
    return bezierPath;
}

- (void)drawPoints {
    for (NSUInteger i = 0; i < self.graph.graphPoints.count; i++) {
        CGPoint point = self.graph.graphPoints[i].CGPointValue;
        [self drawPoint:point withColor:self.pointColor];
    }
}

- (CGFloat)pointRadius {
    return _pointRadius ?: self.lineWidth;
}

- (void)drawPoint:(CGPoint)point withColor:(UIColor *)color {
    CAShapeLayer *pointLayer = [CAShapeLayer new];
    CGRect rect = CGRectMake(point.x - self.pointRadius / screenScale,
                             point.y - self.pointRadius / screenScale,
                             self.pointRadius * 2 / screenScale,
                             self.pointRadius * 2 / screenScale);
    pointLayer.path = [UIBezierPath bezierPathWithOvalInRect:rect].CGPath;
    pointLayer.fillColor = color.CGColor;
    [self.lineLayer addSublayer:pointLayer];
}

- (void)drawGraphAnimated:(BOOL)animated {
    if (self.graphSource) {
        self.graph = [self.graphSource graphForView:self];
    } else {
        return ;
    }
    
    for (CALayer *sl in self.lineLayer.sublayers.copy) {
        [sl removeFromSuperlayer];
    }
    
    if (self.graph.graphPoints.count == 0) {
        return ;
    }
    
    if (self.graph.graphPoints.count == 1) {
        CGPoint point = CGPointMake(self.bounds.origin.x + self.bounds.size.width / 2, self.bounds.origin.y + self.bounds.size.height / 2);
        [self drawPoint:point withColor:self.tintColor];
        self.gradientLayer.colors = nil;
        return ;
    }
    
    UIBezierPath *bezierPath = [self plotBezierPath];
    self.lineLayer.path = bezierPath.CGPath;
    
    if (animated) {
        [self.lineLayer addAnimation:self.lineAnimation forKey:@"animatePath"];
    }
    
    if (self.pointColor) {
        [self drawPoints];
    }
    
    if (self.graph.graphPoints.count && self.gradientColors.count == 2) {
        self.gradientLayer.frame = CGRectMake(0, 0, self.bounds.size.width, self.bounds.size.height);
        CAShapeLayer *gradientMask = [CAShapeLayer layer];
        [bezierPath addLineToPoint:CGPointMake(self.bounds.size.width, self.bounds.size.height)];
        [bezierPath addLineToPoint:CGPointMake(0, self.bounds.size.height)];
        [bezierPath closePath];
        gradientMask.path = bezierPath.CGPath;
        gradientMask.fillColor = [UIColor blackColor].CGColor;
        
        self.gradientLayer.mask = gradientMask;
        
        if (animated) {
            [self.gradientLayer addAnimation:self.gradientAnimation forKey:@"animateGradient"];
        }
        
        self.gradientLayer.colors = self.gradientColors;
    } else {
        self.gradientLayer.colors = nil;
    }
}

- (void)setGradientColorTo:(UIColor *)gradientTopColor {
    _gradientTopColor = gradientTopColor;
    [self setGradientColors];
}

- (void)setGradientColorFrom:(UIColor *)gradientBottomColor {
    _gradientBottomColor = gradientBottomColor;
    [self setGradientColors];
}

- (void)setGradientColors {
    if (!_gradientBottomColor) _gradientBottomColor = _gradientTopColor;
    if (!_gradientTopColor) _gradientTopColor = _gradientBottomColor;
    if (!_gradientTopColor) _gradientTopColor = _gradientBottomColor = [UIColor clearColor];
    self.gradientColors = @[(id)self.gradientBottomColor.CGColor, (id)self.gradientTopColor.CGColor];
    self.gradientLayer.colors = self.gradientColors;
    self.gradientColorsAnimStart = @[(id)[self.gradientBottomColor colorWithAlphaComponent:0].CGColor,
                                     (id)[self.gradientTopColor colorWithAlphaComponent:0].CGColor];
    self.gradientAnimation.fromValue = self.gradientColorsAnimStart;
    self.gradientAnimation.toValue = self.gradientColors;
}


@end
