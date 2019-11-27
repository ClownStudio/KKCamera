//
//  DDImageMerger.m
//  DDImageMerger
//
//  Created by 杜若川 on 12-11-9.
//  Copyright (c) 2012年 杜若川. All rights reserved.
//

#import "DDImageMerger.h"

@implementation DDImageMerger
#pragma mark - Method
+(UIImage*)imageFromView:(UIView*)originView
{
    UIImage * image = nil;
    @autoreleasepool {
        UIGraphicsBeginImageContext(originView.frame.size);
        [originView.layer renderInContext:UIGraphicsGetCurrentContext()];
        image = [UIGraphicsGetImageFromCurrentImageContext() retain];
        UIGraphicsEndImageContext();
    }
    return [image autorelease];
}

+(UIImage*)imageFromView2:(UIView*)originView
{
    UIImage * image = nil;
    @autoreleasepool {
        CGFloat scale = [UIScreen mainScreen].scale;
        UIGraphicsBeginImageContext(CGSizeMake(originView.frame.size.width * scale, originView.frame.size.height * scale));
//        UIGraphicsBeginImageContext(originView.frame.size);
        CGContextRef context = UIGraphicsGetCurrentContext();
        CGContextScaleCTM(context, scale, scale);
        [originView.layer renderInContext:UIGraphicsGetCurrentContext()];
        image = [UIGraphicsGetImageFromCurrentImageContext() retain];
        UIGraphicsEndImageContext();
    }
    return [image autorelease];
}

#pragma mark - Merger

//把一张图片添加到另一张图片上
+(UIImage*)mergerBackground:(UIImageView*)background withImage:(UIImage*)image atRect:(CGRect)rect
{
    UIImage * outputImage = nil;
    @autoreleasepool {
        UIGraphicsBeginImageContext(background.frame.size);
        [background.layer renderInContext:UIGraphicsGetCurrentContext()];
        [image drawInRect:rect];
        outputImage = [UIGraphicsGetImageFromCurrentImageContext() retain];
        UIGraphicsEndImageContext();
    }
    return [outputImage autorelease];
}
//把多张图片添加到另一张图片上
+(UIImage*)mergerBackground:(UIImageView*)background withImages:(NSArray*)images atRect:(NSArray*)rects
{
    if ([images count] != [rects count]) {
        return nil;
    }
    UIImage * outputImage = nil;
    @autoreleasepool {
        UIGraphicsBeginImageContext(background.frame.size);
        [background.layer renderInContext:UIGraphicsGetCurrentContext()];
        for (int index = 0; index < [images count]; index++) {
            UIImage * image = [images objectAtIndex:index];
            CGRect rect = [[rects objectAtIndex:index]CGRectValue];//NSValue
            [image drawInRect:rect];
        }
        outputImage = [UIGraphicsGetImageFromCurrentImageContext() retain];
        UIGraphicsEndImageContext();
    }
    return [outputImage autorelease];
}

//把一张图片添加到另一张图片上添加UIImageView可以加入旋转信息
+(UIImage*)mergerBackground:(UIImageView*)background withImage:(UIImageView*)imageView
{
    CGFloat base = 2.0f;
    UIImage * outputImage = nil;
    @autoreleasepool {
        UIView * outputView = [[[UIView alloc]initWithFrame:CGRectMake(0, 0, background.frame.size.width * base, background.frame.size.height * base)]autorelease];
        outputView.layer.contents = (id)background.image.CGImage;

        CGAffineTransform transform = imageView.transform;
        imageView.transform = CGAffineTransformMake(transform.a * base, transform.b * base, transform.c * base, transform.d * base, transform.tx * base, transform.ty * base);
        imageView.center = CGPointMake(imageView.center.x * base, imageView.center.y * base);
        [outputView addSubview:imageView];

        outputImage = [[DDImageMerger imageFromView:outputView]retain];
//        UIImageWriteToSavedPhotosAlbum(outputImage, nil, nil, nil);
    }
    return [outputImage autorelease];
}

//把多张图片添加到另一张图片上
+(UIImage*)mergerBackground:(UIImageView *)background withImages:(NSArray *)images
{
    CGFloat base = 2.0f;
    UIImage * outputImage = nil;
    @autoreleasepool {
        UIView * outputView = [[[UIView alloc]initWithFrame:CGRectMake(0, 0, CGRectGetWidth(background.frame) * base, CGRectGetHeight(background.frame) * base)]autorelease];
        outputView.layer.contents = (id)background.image.CGImage;

        for (int index = 0; index < [images count]; index++) {
            UIImageView * imageView =(UIImageView*)[images objectAtIndex:index];
            CGAffineTransform transform = imageView.transform;
            imageView.transform = CGAffineTransformMake(transform.a * base, transform.b * base, transform.c * base, transform.d * base, transform.tx * base, transform.ty * base);
            imageView.center = CGPointMake(imageView.center.x * base, imageView.center.y * base);
            [outputView addSubview:imageView];
        }

        outputImage = [[DDImageMerger imageFromView:outputView]retain];
//        UIImageWriteToSavedPhotosAlbum(outputImage, nil, nil, nil);
    }
    return [outputImage autorelease];
}

+(UIImage*)mergerBackground:(UIImageView *)background withImages:(NSArray *)images outPutSize:(CGSize)outputSize
{
    CGFloat wBase = outputSize.width/CGRectGetWidth(background.frame);
    CGFloat hBase = outputSize.height/CGRectGetHeight(background.frame);
    UIImage * outputImage = nil;
    @autoreleasepool {
        UIView * outputView = [[[UIView alloc]initWithFrame:CGRectMake(0, 0, outputSize.width, outputSize.height)]autorelease];
        outputView.layer.contents = (id)background.image.CGImage;

        for (int index = 0; index < [images count]; index++) {
            UIImageView * imageView =(UIImageView*)[images objectAtIndex:index];
            imageView.transform = CGAffineTransformScale(imageView.transform, wBase, hBase);
            imageView.center = CGPointMake(imageView.center.x * wBase, imageView.center.y * hBase);
            [outputView addSubview:imageView];
        }

        outputImage = [[DDImageMerger imageFromView:outputView]retain];
        //        UIImageWriteToSavedPhotosAlbum(outputImage, nil, nil, nil);
    }
    return [outputImage autorelease];
}

#pragma mark - Merger Image
+(UIImage*)mergerImage:(UIImage*)image atImage:(UIImage*)baseImage
{
    UIImage * resultImage = nil;
    @autoreleasepool {
        CGSize size = baseImage.size;
        CGRect rect = CGRectMake(0.0f, 0.0f, size.width, size.height);
        UIGraphicsBeginImageContext(CGSizeMake(size.width, size.height));
        CGContextRef context = UIGraphicsGetCurrentContext();
        CGContextRotateCTM(context, M_PI);
        CGContextTranslateCTM(context, -size.width, -size.height);
        CGContextScaleCTM(context, -1.0f, 1.0f);
        CGContextTranslateCTM(context, -size.width, 0.0f);
        CGContextDrawImage(context, rect, baseImage.CGImage);//底图
        CGContextDrawImage(context, rect, image.CGImage);//上面的图
        resultImage = [UIGraphicsGetImageFromCurrentImageContext() retain];
        UIGraphicsEndImageContext();
    }
    return [resultImage autorelease];
}

+(UIImage*)mergerImage:(UIImage*)image withMask:(UIImage*)maskImage inSize:(CGSize)size
{
    UIImage * resultImage = nil;
    @autoreleasepool {
        UIGraphicsBeginImageContext(CGSizeMake(size.width, size.height));
        CGContextRef context = UIGraphicsGetCurrentContext();
        CGContextRotateCTM(context, M_PI);
        CGContextTranslateCTM(context, -size.width, -size.height);
        CGContextScaleCTM(context, -1.0f, 1.0f);
        CGContextTranslateCTM(context, -size.width, 0.0f);
        CGContextClipToMask(context, CGRectMake(0, 0, size.width, size.height), maskImage.CGImage);
        CGContextDrawImage(context, CGRectMake(0, 0, size.width, size.height),image.CGImage);
        resultImage = [UIGraphicsGetImageFromCurrentImageContext() retain];
        UIGraphicsEndImageContext();
    }
    return [resultImage autorelease];
}

/**拼接图片
 */
+(UIImage*)mergerImages:(NSArray*)images atRect:(NSArray*)rects screenSize:(CGSize)size
{
    NSAssert([images count] == [rects count], @"images's item need equal to rects");
    UIImage * resultImage = nil;
    @autoreleasepool {
        UIGraphicsBeginImageContext(size);
        CGContextRef context = UIGraphicsGetCurrentContext();
        CGContextRotateCTM(context, M_PI);
        CGContextTranslateCTM(context, -size.width, -size.height);
        CGContextScaleCTM(context, -1.0f, 1.0f);
        CGContextTranslateCTM(context, -size.width, 0.0f);
        
        for (int index = 0; index < [images count]; index++) {
            UIImage * image = [images objectAtIndex:index];
            CGRect    rect  = [[rects objectAtIndex:index]CGRectValue];
            
            CGContextDrawImage(context, rect, image.CGImage);
        }
        
        resultImage = [UIGraphicsGetImageFromCurrentImageContext() retain];
        UIGraphicsEndImageContext();
    }
    return [resultImage autorelease];
}

/**把图片放到某个指定的区域内，不压缩，使用裁剪的方案
 */
+(UIImage*)mergerImage:(UIImage*)image inRect:(CGRect)rect outputSize:(CGSize)size
{
    UIImage * resultImage = nil;
    @autoreleasepool {
        UIGraphicsBeginImageContext(size);
        CGContextRef context = UIGraphicsGetCurrentContext();
        CGContextRotateCTM(context, M_PI);
        CGContextTranslateCTM(context, -size.width, -size.height);
        CGContextScaleCTM(context, -1.0f, 1.0f);
        CGContextTranslateCTM(context, -size.width, 0.0f);
        
        CGContextDrawImage(context, rect, image.CGImage);
        
        resultImage = [UIGraphicsGetImageFromCurrentImageContext() retain];
        UIGraphicsEndImageContext();
    }
    return [resultImage autorelease];
}
@end
