//
//  PCMenuViewController.m
//  PhotoCollage
//
//  Created by 杜杜 on 16/4/22.
//  Copyright © 2016年 duruochuan. All rights reserved.
//

#import "PCMenuViewController.h"
#import "iRate.h"
#import "DDPurchase.h"

@interface PCMenuViewController ()<DDPurchaseDelegate> {
    BOOL _isAnimation;
}

@end

@implementation PCMenuViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.menuView.translatesAutoresizingMaskIntoConstraints = YES;
    self.menuView.frame = CGRectMake(-300.0f, 0.0f, 300.0f, self.screenSize.height);
    
    self.bgImageView.alpha = 0.0f;
    self.bgImageView.userInteractionEnabled = YES;
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(hidden)];
    [self.bgImageView addGestureRecognizer:tapGesture];
    
    [DDPurchase purchase].delegate = self;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (void)show
{
    if (_isAnimation) {
        return;
    }
    _isAnimation = YES;
    self.view.frame = CGRectMake(0, 0, self.screenSize.width, self.screenSize.height);
    self.view.backgroundColor = [UIColor clearColor];
    
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    [window addSubview:self.view];
    [window.rootViewController addChildViewController:self];
    
    [UIView animateWithDuration:0.4f animations:^{
        self.bgImageView.alpha = 1.0f;
        self.menuView.frame = CGRectMake(0.0, 0.0, 300.0f, self.screenSize.height);
    } completion:^(BOOL finished) {
        _isAnimation = NO;
    }];
}

- (void)hidden
{
    if (_isAnimation) {
        return;
    }
    _isAnimation = YES;
    
    [UIView animateWithDuration:0.3f animations:^{
        self.menuView.frame = CGRectMake(-300.0f, 0.0f, 300.0f, self.screenSize.height);
        self.bgImageView.alpha = 0.0f;
    } completion:^(BOOL finished) {
        _isAnimation = NO;
        [self.view removeFromSuperview];
        [self removeFromParentViewController];
    }];
}

#pragma mark - IBAction
- (IBAction)professionalAction:(id)sender
{
    if ([[DDPurchase purchase]isProductPurchased:kProfessionalIdentifier]) {
        UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"Notice" message:@"You have already purchased!" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alertView show];
    }
    else {
//        [[DDWaitingView sharedView]setText:@"Waiting..."];
//        [[DDWaitingView sharedView]startAnimation];
        [[DDPurchase purchase]validateProductIdentifiers:@[kProfessionalIdentifier]];
    }
}

- (IBAction)reviewAction:(id)sender
{
    [[iRate sharedInstance]promptForRating];
}

- (IBAction)restoreAction:(id)sender
{
    [self professionalAction:sender];
}

- (IBAction)supportAction:(id)sender
{
    [self hidden];
    
    if ([self.delegate respondsToSelector:@selector(menuViewControllerDidMailSendAction:)]) {
        [self.delegate menuViewControllerDidMailSendAction:self];
    }
}

- (IBAction)moreAppAction:(id)sender
{
    [[UIApplication sharedApplication]openURL:[NSURL URLWithString:@"https://itunes.apple.com/cn/app/id1291776269"]];
}

- (IBAction)closeAction:(id)sender
{
    [self hidden];
}

#pragma mark - DDPurchaseDelegate
- (void)purchaseDidFail:(DDPurchase *)purchase
{
//    [[DDWaitingView sharedView]stopAnimation];
    [[TKAlertCenter defaultCenter]postAlertWithMessage:@"Purchase failed!"];
}

- (void)purchaseDidSuccess:(DDPurchase *)purchase
{
//    [[DDWaitingView sharedView]stopAnimation];
    [[TKAlertCenter defaultCenter]postAlertWithMessage:@"Purchase successfully!"];
}

- (void)purchaseDidGetProductInfo:(DDPurchase *)purchase
{
    if (purchase.products.count > 0) {
        SKProduct *product = [purchase.products objectAtIndex:0];
        [[DDPurchase purchase]payForProduct:product];
    }
    else {
        [self purchaseDidFail:purchase];
    }
}

@end
