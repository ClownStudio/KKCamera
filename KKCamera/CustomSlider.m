//
//  CustomSlider.m
//  KKCamera
//
//  Created by Jam Zhang on 2019/12/16.
//  Copyright © 2019 Jam Zhang. All rights reserved.
//

#import "CustomSlider.h"

@implementation CustomSlider

- (CGRect)thumbRectForBounds:(CGRect)bounds trackRect:(CGRect)rect value:(float)value{
    rect.origin.x = rect.origin.x - 10 ;
    rect.size.width = rect.size.width +20;
    return CGRectInset ([super thumbRectForBounds:bounds trackRect:rect value:value], 10 , 10);
}

@end
