//
//  PhotoXHalo.h
//  PhotoX
//
//  Created by Leks on 2017/12/11.
//  Copyright © 2017年 idea. All rights reserved.
//

#import "GPUImageFilterGroup.h"
#import "GPUImage.h"

@interface PhotoXHaloFilter : GPUImageTwoInputFilter
{
    GLint mixUniform;
}
-(id)initWithTextureImage:(UIImage*)image;
@property(readwrite, nonatomic) CGFloat mix; 
@end
