//
//  DDImage.h
//  DDImage
//
//  Created by 杜若川 on 13-3-15.
//  Copyright (c) 2013年 杜若川. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <OpenGLES/ES2/gl.h>
#import <OpenGLES/ES2/glext.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import <AVFoundation/AVFoundation.h>

@interface DDImage : NSObject{

}

/**从原始rgba数据得到UIImage
 */
+(UIImage*)imageWithRawData:(GLubyte *)data width:(int)w height:(int)h;

/**从一张图片得到指定尺寸的缩略图尺寸
 */
+(UIImage*)thumbnailWithImage:(UIImage*)image outputSize:(CGSize)size;
+(UIImage*)scaleThumbnailWithImage:(UIImage *)image outputSize:(CGSize)size;

/**从UIImage得到原始数据 data数据返回
 */
+(void)imageDataWithImage:(UIImage*)image data:(GLubyte*)data;

+(void)imageDataWithView:(UIView*)view data:(GLubyte*)data;

#pragma mark - Rotate
/**绕Y轴转180
 */
+ (UIImage*)imageRotate180Y:(UIImage*)image;

@end