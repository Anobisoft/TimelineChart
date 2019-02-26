//
//  TCGraph.h
//  TimelineChart
//
//  Created by Stanislav Pletnev on 02.05.17.
//  Copyright © 2017 Anobisoft. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <TimelineChart/TCPoint.h>

@interface TCGraph : NSObject

+ (instancetype)graphInRect:(CGRect)rect
           withOriginPoints:(NSArray<TCPoint *> *)originPoints
                      mindx:(CGFloat)mindx;

@property (nonatomic) NSArray<TCPoint *> *points;
@property (nonatomic) NSArray<NSValue *> *graphPoints;
@property (nonatomic) CGRect scale;
@property (nonatomic) CGRect rect;

@end
