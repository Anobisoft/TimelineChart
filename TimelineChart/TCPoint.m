//
//  TCPoint.m
//  TimelineChart
//
//  Created by Stanislav Pletnev on 16.05.17.
//  Copyright © 2017 Anobisoft. All rights reserved.
//

#import "TCPoint.h"

@implementation TCPoint

+ (instancetype)pointWithTimestamp:(long)timestamp value:(double)value {
    return [[self alloc] initWithTimestamp:timestamp value:value];
}

- (instancetype)initWithTimestamp:(long)timestamp value:(double)value {
    if (self = [self init]) {
        _timestamp = timestamp;
        _value = value;
    }
    return self;
}

- (NSDate *)date {
    return [NSDate dateWithTimeIntervalSince1970:_timestamp];
}

@end
