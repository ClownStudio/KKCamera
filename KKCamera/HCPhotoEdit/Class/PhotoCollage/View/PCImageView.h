//
//  PCImageView.h
//  PhotoCollage
//
//  Created by 杜杜 on 16/4/13.
//  Copyright © 2016年 duruochuan. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PCImageView : UIControl {
    CGFloat _borderWidth;
    UIColor *_borderColor;
}

@property(nonatomic,readonly)NSDictionary *collageInfo;

- (id)initWithFrame:(CGRect)frame collageInfo:(NSDictionary *)collageInfo;

@end
