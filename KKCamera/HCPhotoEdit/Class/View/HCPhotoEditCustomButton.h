//
//  CHPhotoEditCustomButton.h
//  GPUImageDemo
//
//  Created by chenhao on 16/12/6.
//  Copyright © 2016年 chenhao. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HCPhotoEditCustomButton : UIButton
{
    UIImage  *_image;
    UIImage  *_hightImage;
    NSString *_title;
    float    _imageSize;
}
@property(nonatomic) NSInteger idx;

@property(nonatomic, assign) BOOL  normalState;

-(instancetype)initWithImage:(UIImage*)image  highlightedImage:(UIImage*)hightImage title:(NSString*)title  font:(float)font imageSize:(float)size;

@end
