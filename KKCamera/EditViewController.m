//
//  EditViewController.m
//  KKCamera
//
//  Created by Jam Zhang on 2019/11/29.
//  Copyright © 2019 Jam Zhang. All rights reserved.
//

#import "EditViewController.h"

@interface EditViewController ()

@end

@implementation EditViewController{
    UIImage *_oriImage;
}

- (void)viewDidLoad {
    [super viewDidLoad];
}

-(void)setOriginImage:(UIImage *)originImage{
    _oriImage = originImage;
}

@end
