//
//  SubscriberViewController.m
//  KKCamera
//
//  Created by Jam Zhang on 2019/12/4.
//  Copyright © 2019 Jam Zhang. All rights reserved.
//

#import "SubscriberViewController.h"

@interface SubscriberViewController ()

@end

@implementation SubscriberViewController{
    UIImageView *_imageView;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIImage *image = [UIImage imageNamed:[self getAssetWithName:@"kk_unlock"]];
    CGSize size = [self getSizeWithImage:image];
    
    _imageView = [[UIImageView alloc] initWithFrame:CGRectMake((self.contentView.bounds.size.width - size.width)/2, (self.contentView.bounds.size.height - size.height)/2, size.width, size.height)];
    [_imageView setImage:image];
    [_imageView.layer setMasksToBounds:YES];
    _imageView.layer.cornerRadius = 5;
    [_imageView setContentMode:UIViewContentModeScaleAspectFit];
    [self.contentView addSubview:_imageView];
}

-(CGSize)getSizeWithImage:(UIImage *)image{
    CGFloat imageWidth;
    CGFloat imageHeight;
    
    if (image.size.width/self.contentView.bounds.size.width * self.contentView.bounds.size.height > image.size.height) {
        imageWidth = self.contentView.bounds.size.width;
        imageHeight = imageWidth/self.contentView.bounds.size.width * self.contentView.bounds.size.height;
    }else{
        imageHeight = self.contentView.bounds.size.height;
        imageWidth = imageHeight/self.contentView.bounds.size.height * self.contentView.bounds.size.width;
    }
    return CGSizeMake(imageWidth, imageHeight);
}

-(void)viewSafeAreaInsetsDidChange{
    [super viewSafeAreaInsetsDidChange];
    UIImage *image = [UIImage imageNamed:[self getAssetWithName:@"kk_unlock"]];
    CGSize size = [self getSizeWithImage:image];
    [_imageView setFrame:CGRectMake((self.contentView.bounds.size.width - size.width)/2, (self.contentView.bounds.size.height - size.height)/2, size.width, size.height)];
}

- (NSString *)getAssetWithName:(NSString *)name{
    if (IS_PAD) {
        return [NSString stringWithFormat:@"%@_pad",name];
    }else{
        return name;
    }
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
