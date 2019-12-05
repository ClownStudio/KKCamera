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
    
    CGFloat imageWidth;
    CGFloat imageHeight;
    if (IS_PAD) {
        
    }else{
        
    }
    
    _imageView = [[UIImageView alloc] initWithFrame:self.bounds];
    [_imageView.layer setMasksToBounds:YES];
    _imageView.layer.cornerRadius = 5;
    [self.contentView addSubview:_imageView];
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
