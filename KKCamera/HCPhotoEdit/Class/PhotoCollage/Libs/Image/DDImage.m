//
//  DDImage.m
//  DDImage
//
//  Created by 杜若川 on 13-3-15.
//  Copyright (c) 2013年 杜若川. All rights reserved.
//

#import "DDImage.h"

@implementation DDImage
+(UIImage*)imageWithRawData:(GLubyte *)data width:(int)w height:(int)h
{
    int len = w * h * 4;
    
    CGDataProviderRef provider = CGDataProviderCreateWithData(NULL,
                                                              data,
                                                              len,
                                                              NULL);
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGImageRef imageRef = CGImageCreate(w, h, 8, 32, 4 * w,
                                        colorSpace,
                                        (CGBitmapInfo)kCGImageAlphaPremultipliedLast,
                                        provider,
                                        NULL,
                                        NO,
                                        kCGRenderingIntentDefault);
    UIImage * image = [[UIImage imageWithCGImage:imageRef]retain];
    CGDataProviderRelease(provider);
    CGColorSpaceRelease(colorSpace);
    CGImageRelease(imageRef);
    return [image autorelease];
}

+(UIImage*)thumbnailWithImage:(UIImage*)image outputSize:(CGSize)size
{
    UIImage * resultImage = nil;
    @autoreleasepool {
        UIGraphicsBeginImageContext(size);
        [image drawInRect:CGRectMake(0.0f, 0.0f, size.width, size.height)];
        resultImage = [UIGraphicsGetImageFromCurrentImageContext() retain];
        UIGraphicsEndImageContext();
    }
    return [resultImage autorelease];
}

+(UIImage*)scaleThumbnailWithImage:(UIImage *)image outputSize:(CGSize)size
{
    CGFloat scale = size.width/image.size.width;
    scale = scale < size.height/image.size.height?scale:size.height/image.size.height;
    return [DDImage thumbnailWithImage:image outputSize:CGSizeMake(image.size.width * scale, image.size.height * scale)];
}

/**从UIImage得到原始数据
 */
+(GLubyte*)imageDataWithImage:(UIImage*)image
{
    size_t width    = image.size.width;
    size_t height   = image.size.height;
    GLubyte * rawData = calloc(sizeof(GLubyte)*width*height*4, sizeof(GLubyte));
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef context = CGBitmapContextCreate(rawData, width, height, 8, 4 * width, colorSpace, kCGBitmapByteOrderDefault | kCGImageAlphaPremultipliedLast);
    CGContextDrawImage(context, CGRectMake(0.0f, 0.0f, width, height), image.CGImage);
    CGContextRelease(context);
    CGColorSpaceRelease(colorSpace);
    return rawData;
}

+(void)imageDataWithImage:(UIImage*)image data:(GLubyte*)data
{
    NSAssert(data != nil, @"data not alloc");
    size_t width    = image.size.width;
    size_t height   = image.size.height;
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef context = CGBitmapContextCreate(data, width, height, 8, 4 * width, colorSpace, kCGBitmapByteOrderDefault | kCGImageAlphaPremultipliedLast);
    CGContextDrawImage(context, CGRectMake(0.0f, 0.0f, width, height), image.CGImage);
    CGContextRelease(context);
    CGColorSpaceRelease(colorSpace);
}

+ (void)imageDataWithView:(UIView*)view data:(GLubyte*)data
{
    NSAssert(data != nil, @"data not alloc");
    size_t width    = view.frame.size.width;
    size_t height   = view.frame.size.height;
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef context = CGBitmapContextCreate(data, width, height, 8, 4 * width, colorSpace, kCGBitmapByteOrderDefault | kCGImageAlphaPremultipliedLast);
//    CGContextDrawImage(context, CGRectMake(0.0f, 0.0f, width, height), image.CGImage);
    [view.layer renderInContext:context];
    CGContextRelease(context);
    CGColorSpaceRelease(colorSpace);
}

#pragma mark - Rotate
/**绕Y轴转180
 */
+ (UIImage*)imageRotate180Y:(UIImage*)image
{
    UIImage * resultImage = nil;
    @autoreleasepool {
        CGSize size = image.size;
        UIGraphicsBeginImageContext(CGSizeMake(size.width, size.height));
        CGContextRef context = UIGraphicsGetCurrentContext();
        CGContextRotateCTM(context, M_PI);
        CGContextTranslateCTM(context, -size.width, -size.height);
//        CGContextScaleCTM(context, -1.0f, 1.0f);
//        CGContextTranslateCTM(context, -size.width, 0.0f);
        CGContextDrawImage(context, CGRectMake(0, 0, size.width, size.height),image.CGImage);
        resultImage = [UIGraphicsGetImageFromCurrentImageContext() retain];
        UIGraphicsEndImageContext();
    }
    return [resultImage autorelease];
}

@end
