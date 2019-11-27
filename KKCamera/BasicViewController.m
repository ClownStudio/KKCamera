//
//  BasicViewController.m
//  KKCamera
//
//  Created by Jam Zhang on 2019/11/26.
//  Copyright © 2019 Jam Zhang. All rights reserved.
//

#import "BasicViewController.h"

@interface BasicViewController ()

@end

@implementation BasicViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    CGRect layoutFrame;
    if (@available(iOS 11.0, *)) {
        layoutFrame = self.view.safeAreaLayoutGuide.layoutFrame;
    } else {
        layoutFrame = self.view.frame;
    }
    self.contentView = [[UIView alloc] initWithFrame:layoutFrame];
    [self.contentView setBackgroundColor:[UIColor redColor]];
    [self.view addSubview:self.contentView];
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
