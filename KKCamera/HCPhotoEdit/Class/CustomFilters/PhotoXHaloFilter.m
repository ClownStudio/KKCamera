//
//  PhotoXHalo.m
//  PhotoX
//
//  Created by Leks on 2017/12/11.
//  Copyright © 2017年 idea. All rights reserved.
//

#import "PhotoXHaloFilter.h"
#import "HCPhotoEditViewController.h"

NSString *const PhotoXHaloShaderString = SHADER_STRING
(
 varying highp vec2 textureCoordinate;
 varying highp vec2 textureCoordinate2;
 
 uniform sampler2D inputImageTexture;
 uniform sampler2D inputImageTexture2;
 
 uniform lowp float mixturePercent;
 
 void main()
 {
     lowp vec4 textureColor = texture2D(inputImageTexture, textureCoordinate);
     lowp vec4 textureColor2 = texture2D(inputImageTexture2, textureCoordinate2);
     
     textureColor2 = textureColor2 * mixturePercent;
     gl_FragColor = vec4(min(vec3(1), textureColor.rgb + textureColor2.rgb), textureColor.a);
 }
 );


@implementation PhotoXHaloFilter
- (id)init;
{
    if (!(self = [super initWithFragmentShaderFromString:PhotoXHaloShaderString]))
    {
        return nil;
    }
    
    mixUniform = [filterProgram uniformIndex:@"mixturePercent"];
    self.mix = 0.5;
    
    return self;
}


#pragma mark -
#pragma mark Accessors

- (void)setMix:(CGFloat)newValue;
{
    _mix = newValue;
    
    [self setFloat:_mix forUniform:mixUniform program:filterProgram];
}
@end
