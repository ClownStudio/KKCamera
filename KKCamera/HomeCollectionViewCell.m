//
//  HomeCollectionViewCell.m
//  KKCamera
//
//  Created by Jam Zhang on 2019/11/27.
//  Copyright © 2019 Jam Zhang. All rights reserved.
//

#import "HomeCollectionViewCell.h"

@implementation HomeCollectionViewCell{
    UIImageView *_imageView;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _imageView = [[UIImageView alloc] initWithFrame:self.bounds];
        [self addSubview:_imageView];
    }
    return self;
}

-(void)setContentWithData:(NSDictionary *)data{
    [_imageView setImage:[UIImage imageNamed:[data objectForKey:@"picture"]]];
}

@end
