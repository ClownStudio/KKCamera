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
        layoutFrame = CGRectMake(0, self.view.safeAreaInsets.top, self.view.bounds.size.width, self.view.bounds.size.height - self.view.safeAreaInsets.bottom - self.view.safeAreaInsets.top);
    } else {
        layoutFrame = self.view.frame;
    }
    self.contentView = [[UIView alloc] initWithFrame:self.view.frame];
    [self.view addSubview:self.contentView];
    [self.view setBackgroundColor:[UIColor blackColor]];
}

-(void)viewSafeAreaInsetsDidChange{
    [super viewSafeAreaInsetsDidChange];
    UIEdgeInsets safeAreaInsets = self.view.safeAreaInsets;
    [self.contentView setFrame:CGRectMake(0, safeAreaInsets.top, self.view.bounds.size.width, self.view.bounds.size.height - safeAreaInsets.bottom - safeAreaInsets.top)];
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
