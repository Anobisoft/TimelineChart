//
//  TCScaleView.m
//  TimelineChart
//
//  Created by Stanislav Pletnev on 26.05.17.
//  Copyright © 2017 Anobisoft. All rights reserved.
//

#import "TCScaleView.h"

@implementation TCScaleView {
    CGFloat screenScale;
    UIFont *font;
}

- (void)awakeFromNib {
    [super awakeFromNib];
#if !TARGET_INTERFACE_BUILDER
    screenScale = [UIScreen mainScreen].scale;
#endif
}

- (void)prepareForInterfaceBuilder {
    screenScale = 2;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    [self setNeedsDisplay];
}

- (void)setTintColor:(UIColor *)tintColor {
    [super setTintColor:tintColor];
    [self setNeedsDisplay];
}


@synthesize scale = _scale;
- (void)setScale:(CGRect)scale {
    _scale = scale;
    [self setNeedsDisplay];
}

- (UIColor *)fontColor {
    return _fontColor ?: self.tintColor;
}

- (void)drawStrokes:(CGContextRef)context {
    
}


- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    if (self.tintColor) {
        CGContextSetStrokeColorWithColor(context, self.tintColor.CGColor);
        CGContextSetLineWidth(context, (self.midlineWidth ?: 1) / screenScale);
        CGFloat midY = self.bounds.size.height / 2;
        int c = 0;
        if (self.markDistance > self.midlineWidth * 10) {
            c = (int)(self.bounds.size.width / self.markDistance * 4) + 1;
        } else {
            c = (int)(self.bounds.size.width / (self.midlineWidth ?: 1.0) / 8.0);
        }
        CGFloat w = self.bounds.size.width / (c * 2 - 1);
        
        for (int i = 0; i < c; i++) {
            CGFloat x = w * i * 2;
            CGContextMoveToPoint(context, x, midY);
            CGContextAddLineToPoint(context, x + w, midY);
            CGContextStrokePath(context);
        }
    }
    
    if (self.fontColor) {
        if (!self.fontSize) self.fontSize = self.markDistance /  3.0;
        
        if (self.fontName) {
            font = [UIFont fontWithName:self.fontName size:self.fontSize];
        }
        if (!font) {
            if (@available(iOS 9, *)) {
                font = [UIFont monospacedDigitSystemFontOfSize:self.fontSize weight:UIFontWeightThin];
            } else {
                font = [UIFont systemFontOfSize:self.fontSize];
            }
        }        
        
        int n = (int)(self.bounds.size.height / self.markDistance) - 2;
        CGFloat ypad = (self.bounds.size.height - n * self.markDistance) / 2;
        
        NSMutableParagraphStyle *paragraph =  [[NSMutableParagraphStyle defaultParagraphStyle] mutableCopy];
        paragraph.lineSpacing = 0.0;
        paragraph.paragraphSpacing = 0.0;
        paragraph.paragraphSpacingBefore = 0.0;
        paragraph.firstLineHeadIndent = 0.0;
        paragraph.headIndent = 0.0;
        
        NSMutableDictionary *textAttrs = @{ NSFontAttributeName : font,
                                            NSForegroundColorAttributeName : self.fontColor,
                                            NSParagraphStyleAttributeName : paragraph,
                                            }.mutableCopy;
        
        if (self.shadowColor) {
            NSShadow *shadow = [NSShadow new];
            shadow.shadowOffset = CGSizeMake(1.0 / screenScale, 1.0 / screenScale);
            shadow.shadowColor = self.shadowColor;
            textAttrs[NSShadowAttributeName] = shadow;
        }

        if (self.scale.origin.y != 0.0) {
            NSMutableArray *attrstrings = [NSMutableArray arrayWithCapacity:n+1];
            CGFloat ha[n+1];
            CGFloat wmax = 0;
            for (int i = 0; i <= n; i++) {
                CGFloat y = ypad + i * self.markDistance;
                CGFloat value = (self.graphRect.origin.y + self.graphRect.size.height - y) / self.scale.origin.y + self.scale.size.height;
                NSString *str = [NSString stringWithFormat:@"%.2f", value];
                NSAttributedString *attrstr = [[NSAttributedString alloc] initWithString:str attributes:textAttrs];
                if (wmax < attrstr.size.width) wmax = attrstr.size.width;
                CGFloat h = y - self.fontSize / 2.0 - 2.0;
                if (h < -3) h = -3;
                if (h + self.fontSize + 1 > self.bounds.size.height) h = self.bounds.size.height - self.fontSize - 1;
                ha[i] = h;
                [attrstrings addObject:attrstr];
            }
            int i = 0;
            for (NSAttributedString *attrstr in attrstrings) {
                [attrstr drawInRect:CGRectMake(4.0, ha[i++], wmax, self.fontSize + 1.0)];
            }
        }
    }
}


@end
