//
//  ViewController.m
//  KKCamera
//
//  Created by Jam Zhang on 2019/11/26.
//  Copyright © 2019 Jam Zhang. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    NSString *homePageFilePath = [[NSBundle mainBundle] pathForResource:@"homePage" ofType:@"plist"];
    NSArray *homePageContent = [NSArray arrayWithContentsOfFile:homePageFilePath];
}


@end
