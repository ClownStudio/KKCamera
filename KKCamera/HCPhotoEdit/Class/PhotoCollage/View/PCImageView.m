//
//  PCImageView.m
//  PhotoCollage
//
//  Created by 杜杜 on 16/4/13.
//  Copyright © 2016年 duruochuan. All rights reserved.
//

#import "PCImageView.h"

@implementation PCImageView

- (id)initWithFrame:(CGRect)frame collageInfo:(NSDictionary *)collageInfo
{
    self = [super initWithFrame:frame];
    if (self) {
        _borderWidth = 2.0f;
        _borderColor = [UIColor lightGrayColor];
        
        self.backgroundColor = [UIColor clearColor];
        self.layer.borderColor = _borderColor.CGColor;
        self.layer.borderWidth = _borderWidth;
        
        _collageInfo = collageInfo;
    }
    return self;
}

- (void)drawRect:(CGRect)rect
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetAlpha(context, 1.0f);
    CGContextSetStrokeColorWithColor(context, _borderColor.CGColor);
    CGContextSetLineWidth(context, _borderWidth);
    CGContextSetFillColorWithColor(context, _borderColor.CGColor);
    
    CGSize contentSize = CGSizeFromString([_collageInfo valueForKey:@"contentSize"]);
    CGFloat xScale = rect.size.width/contentSize.width;
    CGFloat yScale = rect.size.height/contentSize.height;
    
    NSArray *points = [_collageInfo valueForKey:@"views"];
    for (int index = 0; index < points.count; index++) {
        NSArray *items = [points objectAtIndex:index];
        //取信息画点
        UIBezierPath *path = [UIBezierPath bezierPath];
        for (int i = 0; i <= items.count; i++) {
            NSDictionary *item = nil;
            if (i == items.count) {
                item = [items objectAtIndex:0];;
            }
            else {
                item = [items objectAtIndex:i];
            }
            
            CGPoint point = CGPointFromString([item valueForKey:@"point"]);
            
            if (0 == i) {
                [path moveToPoint:[self scalePoint:CGPointMake(point.x * xScale, point.y * yScale)]];
            }
            else {
                //control1 control2
                NSString *control1Str = [item valueForKey:@"control1"];
                NSString *control2Str = [item valueForKey:@"control2"];
                if (control1Str) {
                    CGPoint control1 = CGPointFromString(control1Str);
                    [path addQuadCurveToPoint:[self scalePoint:CGPointMake(point.x * xScale, point.y * yScale)] controlPoint:[self scalePoint:CGPointMake(control1.x * xScale, control1.y * yScale)]];
                }
                else if (control2Str) {
                    CGPoint control1 = CGPointFromString(control1Str);
                    CGPoint control2 = CGPointFromString(control2Str);
                    [path addCurveToPoint:[self scalePoint:CGPointMake(point.x * xScale, point.y * yScale)] controlPoint1:[self scalePoint:CGPointMake(control1.x * xScale, control1.y * yScale)] controlPoint2:[self scalePoint:CGPointMake(control2.x * xScale, control2.y * yScale)]];
                }
                else {
                    [path addLineToPoint:[self scalePoint:CGPointMake(point.x * xScale, point.y * yScale)]];
                }
            }
        }
        CGContextBeginPath(context);
        CGContextAddPath(context, path.CGPath);
//        CGContextStrokePath(context);
        CGContextFillPath(context);
//        CGContextClosePath(context);
    }
}

- (CGPoint)scalePoint:(CGPoint)pt
{
    CGFloat width = self.frame.size.width * 0.1f;
    return CGPointMake(pt.x * 0.9 + width/2, pt.y * 0.9 + width/2);
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    self.backgroundColor = [UIColor colorWithHexString:kNavColor];
}

- (void)touchesCancelled:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    self.backgroundColor = [UIColor clearColor];
    
    [self sendActionsForControlEvents:UIControlEventTouchUpOutside];
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    self.backgroundColor = [UIColor clearColor];
    
    [self sendActionsForControlEvents:UIControlEventTouchUpInside];
}

@end
