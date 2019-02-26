//
//  TCGraph.m
//  TimelineChart
//
//  Created by Stanislav Pletnev on 02.05.17.
//  Copyright © 2017 Anobisoft. All rights reserved.
//

#import "TCGraph.h"

@implementation NSMutableArray(CGPoint)

- (void)addPoint:(CGPoint)point {
    [self addObject:[NSValue valueWithCGPoint:point]];
}

@end

@interface TCGraphFactory : NSObject

@property (nonatomic) CGRect cachedRect;
@property (nonatomic, weak) NSArray *cachedPoints;
@property (nonatomic) TCGraph *cachedGraph;

+ (instancetype)sharedFactory;

@end

@implementation TCGraphFactory

+ (instancetype)sharedFactory {
    static id singleInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        singleInstance = [self new];
    });
    return singleInstance;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        self.cachedRect = CGRectZero;
    }
    return self;
}

- (TCGraph *)graphInRect:(CGRect)rect
        withOriginPoints:(NSArray<TCPoint *> *)originPoints
                   mindx:(CGFloat)mindx {
    
    if (CGRectEqualToRect(self.cachedRect, rect) && self.cachedPoints == originPoints) {
        return self.cachedGraph;
    }
    
    self.cachedRect = rect;
    self.cachedPoints = originPoints;
    self.cachedGraph = [TCGraph new];
    
    NSMutableArray<TCPoint *> *filteredPoints = [NSMutableArray array];
    
    double minValue = DBL_MAX;
    double maxValue = -DBL_MAX;
    double minTimestamp = originPoints.firstObject.timeviewAskew;
    double maxTimestamp = originPoints.lastObject.timeviewAskew;
    double last = minTimestamp;
    CGFloat scaleX = rect.size.width / (maxTimestamp - minTimestamp);
    NSUInteger skippedMinIndx = 0;
    NSUInteger skippedMaxIndx = 0;
    NSUInteger lastIndx = 0;
    
    for (NSUInteger i = 0; i < originPoints.count; i++) {
        double value = originPoints[i].value;
        double dx = (double)originPoints[i].timeviewAskew - last;
        if (dx < 0) @throw NSInvalidArgumentException;
        if (value < minValue) minValue = value;
        if (value > maxValue) maxValue = value;
        if (i == 0 || i == originPoints.count - 1 || dx * scaleX >= mindx) {
            
            if (i > 0) {
                if (value < originPoints[skippedMinIndx].value) skippedMinIndx = i;
                if (value > originPoints[skippedMaxIndx].value) skippedMaxIndx = i;
                
                if (skippedMinIndx < skippedMaxIndx) {
                    if (skippedMinIndx != lastIndx) {
                        [filteredPoints addObject:originPoints[skippedMinIndx]];
                    }
                    if (skippedMaxIndx != i) {
                        [filteredPoints addObject:originPoints[skippedMaxIndx]];
                    }
                }
                if (skippedMaxIndx < skippedMinIndx ) {
                    if (skippedMaxIndx != lastIndx) {
                        [filteredPoints addObject:originPoints[skippedMaxIndx]];
                    }
                    if (skippedMinIndx != i) {
                        [filteredPoints addObject:originPoints[skippedMinIndx]];
                    }
                }
            }
            
            [filteredPoints addObject:originPoints[i]];
            
            skippedMinIndx = i;
            skippedMaxIndx = i;
            
            last = originPoints[i].timeviewAskew;
            lastIndx = i;
        } else {
            if (value < originPoints[skippedMinIndx].value) skippedMinIndx = i;
            if (value > originPoints[skippedMaxIndx].value) skippedMaxIndx = i;
        }
    }
    
    self.cachedGraph.scale = CGRectMake(scaleX, rect.size.height / (maxValue - minValue), originPoints.firstObject.timestamp, minValue);
    self.cachedGraph.points = filteredPoints.copy;
    self.cachedGraph.rect = rect;
    
    NSMutableArray *graphPoints = [NSMutableArray array];
    for (NSUInteger i = 0; i < self.cachedGraph.points.count; i++) {
        CGFloat x = (self.cachedGraph.points[i].timeviewAskew - minTimestamp) * self.cachedGraph.scale.origin.x + rect.origin.x;
        CGFloat y = rect.size.height - (self.cachedGraph.points[i].value - minValue) * self.cachedGraph.scale.origin.y + rect.origin.y;
        CGPoint point = CGPointMake(x, y);
        [graphPoints addPoint:point];
    }
    self.cachedGraph.graphPoints = graphPoints.copy;
    
    return self.cachedGraph;
}

@end

@implementation TCGraph

+ (instancetype)graphInRect:(CGRect)rect
           withOriginPoints:(NSArray<TCPoint *> *)originPoints
                      mindx:(CGFloat)mindx {
    
    if (!originPoints.count) return nil;
    
    return [[TCGraphFactory sharedFactory] graphInRect:rect
                                      withOriginPoints:originPoints mindx:mindx];
}

@end
