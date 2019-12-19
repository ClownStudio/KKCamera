//
//  FBGlowLabel.m
//  ClassicCamera
//
//  Created by 张文洁 on 2017/11/21.
//  Copyright © 2017年 JamStudio. All rights reserved.
//

#import "FBGlowLabel.h"

@implementation FBGlowLabel

-(id) initWithFrame: (CGRect)frame {
    if ((self = [super initWithFrame:frame])) {

    }
    return self;
}

- (void)drawRect:(CGRect)rect
{
    if (self.strokeWidth > 0) {
        CGSize shadowOffset = self.shadowOffset;
        UIColor *textColor = self.textColor;
        
        CGContextRef c = UIGraphicsGetCurrentContext();
        CGContextSetLineWidth(c, self.strokeWidth);
        CGContextSetLineJoin(c, kCGLineJoinRound);
        //画外边
        CGContextSetTextDrawingMode(c, kCGTextStroke);
        self.textColor = self.strokeColor;
        [super drawTextInRect:rect];
        //画内文字
        CGContextSetTextDrawingMode(c, kCGTextFill);
        self.textColor = textColor;
        self.shadowOffset = CGSizeMake(0, 0);
        [super drawTextInRect:rect];
        self.shadowOffset = shadowOffset;
    } else {
        [super drawTextInRect:rect];
    }
}

@end
