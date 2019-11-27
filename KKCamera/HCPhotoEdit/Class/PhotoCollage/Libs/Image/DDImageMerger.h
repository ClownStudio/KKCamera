//
//  DDImageMerger.h
//  DDImageMerger
//
//  Created by 杜若川 on 12-11-9.
//  Copyright (c) 2012年 杜若川. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <QuartzCore/QuartzCore.h>

@interface DDImageMerger : NSObject

#pragma mark - v1.0
+(UIImage*)imageFromView:(UIView*)originView;
+(UIImage*)imageFromView2:(UIView*)originView;
//把一张图片添加到另一张图片上
+(UIImage*)mergerBackground:(UIImageView*)background withImage:(UIImage*)image atRect:(CGRect)rect;
//把多张图片添加到另一张图片上
+(UIImage*)mergerBackground:(UIImageView*)background withImages:(NSArray*)images atRect:(NSArray*)rects;
//把一张图片添加到另一张图片上添加UIImageView可以加入旋转信息
+(UIImage*)mergerBackground:(UIImageView*)background withImage:(UIImageView*)image;
//把多张图片添加到另一张图片上 images (UIImageView Object)
+(UIImage*)mergerBackground:(UIImageView *)background withImages:(NSArray *)images;
+(UIImage*)mergerBackground:(UIImageView *)background withImages:(NSArray *)images outPutSize:(CGSize)outputSize;

#pragma mark - v1.1
+(UIImage*)mergerImage:(UIImage*)image atImage:(UIImage*)baseImage;
+(UIImage*)mergerImage:(UIImage*)image withMask:(UIImage*)maskImage inSize:(CGSize)size;

#pragma mark - v1.2
/**拼接图片
 */
+(UIImage*)mergerImages:(NSArray*)images atRect:(NSArray*)rects screenSize:(CGSize)size;
/**把图片放到某个指定的区域内，不压缩，使用裁剪的方案
 */
+(UIImage*)mergerImage:(UIImage*)image inRect:(CGRect)rect outputSize:(CGSize)size;
@end
