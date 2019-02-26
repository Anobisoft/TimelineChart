//
//  TCScaleView.h
//  TimelineChart
//
//  Created by Stanislav Pletnev on 26.05.17.
//  Copyright © 2017 Anobisoft. All rights reserved.
//

#import <UIKit/UIKit.h>

IB_DESIGNABLE

@interface TCScaleView : UIView

@property (nonatomic) IBInspectable CGRect scale;
@property (nonatomic) IBInspectable CGRect graphRect;

@property (nonatomic) IBInspectable CGFloat midlineWidth;
@property (nonatomic) IBInspectable CGFloat markDistance;

@property (nonatomic) IBInspectable NSString *fontName;
@property (nonatomic) IBInspectable CGFloat   fontSize;
@property (nonatomic) IBInspectable UIColor  *fontColor;
@property (nonatomic) IBInspectable UIColor  *shadowColor;

@end
