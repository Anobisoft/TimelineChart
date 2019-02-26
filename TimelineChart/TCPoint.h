//
//  TCPoint.h
//  TimelineChart
//
//  Created by Stanislav Pletnev on 16.05.17.
//  Copyright © 2017 Anobisoft. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TCPoint : NSObject

+ (instancetype)pointWithTimestamp:(long)timestamp value:(double)value;

@property (nonatomic) double value;
@property (nonatomic) long timestamp;
@property (nonatomic) long timeviewAskew;
@property (readonly) NSDate *date;

@end
