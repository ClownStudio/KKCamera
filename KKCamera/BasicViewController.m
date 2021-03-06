//
//  BasicViewController.m
//  KKCamera
//
//  Created by Jam Zhang on 2019/11/26.
//  Copyright © 2019 Jam Zhang. All rights reserved.
//

#import "BasicViewController.h"
#import <MessageUI/MessageUI.h>
#import "MBProgressHUD+RJHUD.h"
#import <GoogleMobileAds/GoogleMobileAds.h>
#import "Macro.h"

@interface BasicViewController ()<MFMailComposeViewControllerDelegate,ProManagerDelegate,GADInterstitialDelegate>

@end

@implementation BasicViewController{
    GADInterstitial *_interstitial;
    NSTimer *_timer;
}

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

- (UIStatusBarStyle)preferredStatusBarStyle{
    return UIStatusBarStyleLightContent;
}

-(void)viewSafeAreaInsetsDidChange{
    [super viewSafeAreaInsetsDidChange];
    UIEdgeInsets safeAreaInsets = self.view.safeAreaInsets;
    [self.contentView setFrame:CGRectMake(0, safeAreaInsets.top, self.view.bounds.size.width, self.view.bounds.size.height - safeAreaInsets.bottom - safeAreaInsets.top)];
}

- (void)onFeedback{
    if ([MFMailComposeViewController canSendMail]) { // 用户已设置邮件账户
        
    }else{
        [MBProgressHUD showError:NSLocalizedString(@"NoMailAccount", nil)];
        return;
    }
    if ([MFMessageComposeViewController canSendText] == YES) {
        MFMailComposeViewController *mailCompose = [[MFMailComposeViewController alloc]init];
        mailCompose.mailComposeDelegate = self;
        [mailCompose setSubject:@""];
        NSArray *arr = @[@"samline228@yahoo.com"];
        //收件人
        [mailCompose setToRecipients:arr];
        [self presentViewController:mailCompose animated:YES completion:nil];
    }else{
        [MBProgressHUD showError:NSLocalizedString(@"NoSupportMail", nil)];
    }
}

- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(nullable NSError *)error{
    if (result) {
        NSLog(@"Result : %ld",(long)result);
    }
    if (error) {
        NSLog(@"Error : %@",error);
    }
    switch (result)
    {
        case MFMailComposeResultCancelled: // 用户取消编辑
            NSLog(@"Mail send canceled...");
            break;
        case MFMailComposeResultSaved: // 用户保存邮件
            NSLog(@"Mail saved...");
            break;
        case MFMailComposeResultSent: // 用户点击发送
            NSLog(@"Mail sent...");
            break;
        case MFMailComposeResultFailed: // 用户尝试保存或发送邮件失败
            NSLog(@"Mail send errored: %@...", [error localizedDescription]);
            break;
    }
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)onRestore{
    [MBProgressHUD showWaitingWithText:NSLocalizedString(@"Loading", nil)];
    self.proManager = [[ProManager alloc] init];
    self.proManager.managerDelegate = self;
    //先尝试恢复
    [self.proManager restorePro];
}

-(void)didSuccessBuyProduct:(NSString*)productId
{
    self.proManager = nil;
    dispatch_async(dispatch_get_main_queue(), ^{
        [MBProgressHUD hide];
        [MBProgressHUD showSuccess:NSLocalizedString(@"PurchaseSuccess", nil)];
    });
    [[NSNotificationCenter defaultCenter] postNotificationName:PURCHASE_TRANSACTION object:nil];
}

-(void)didSuccessRestoreProducts:(NSArray*)productIds
{
    self.proManager = nil;
    dispatch_async(dispatch_get_main_queue(), ^{
        [MBProgressHUD hide];
        [MBProgressHUD showSuccess:NSLocalizedString(@"RestoreSuccess", nil)];
    });
    if ([ProManager isFullPaid] || [ProManager isProductPaid:AD_PRODUCT_ID] || [ProManager isProductPaid:MONTH_ID] || [ProManager isProductPaid:YEAR_ID])
    {
        return ;
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:RESTORE_TRANSACTION object:nil];
}

-(void)didFailRestore:(NSString *)reason
{
    self.proManager = nil;
    dispatch_async(dispatch_get_main_queue(), ^{
        [MBProgressHUD hide];
        [MBProgressHUD showError:reason];
    });
}

-(void)didFailedBuyProduct:(NSString*)productId forReason:(NSString*)reason
{
    self.proManager = nil;
    dispatch_async(dispatch_get_main_queue(), ^{
        [MBProgressHUD hide];
        [MBProgressHUD showError:reason];
    });
}

-(void)didCancelBuyProduct:(NSString*)productId
{
    self.proManager = nil;
    [MBProgressHUD hide];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    if ([ProManager isFullPaid] || [ProManager isProductPaid:AD_PRODUCT_ID] || [ProManager isProductPaid:MONTH_ID] || [ProManager isProductPaid:YEAR_ID]) {
        if (_timer) {
            [_timer invalidate];
            _timer = nil;
        }
    }else{
        if ([@"0" isEqualToString:IS_AD_VERSION]) {
            [self startAd];
        }
    }
    // 在所有需要隐藏导航栏的页面加上这两行代码，所有需要显示导航栏的页面不做任何操作即可
    self.fd_prefersNavigationBarHidden = YES;
    [self.navigationController setNavigationBarHidden:YES animated:NO];
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    if (_timer) {
        [_timer invalidate];
        _timer = nil;
    }
}

- (void)startAd{
    if ([_interstitial isReady] == NO) {
        _interstitial = [self createAndLoadInterstitial];
    }
    
    _timer = [NSTimer scheduledTimerWithTimeInterval:CameraShowAdTime target:self selector:@selector(showInterstitialAds) userInfo:nil repeats:YES];
}

- (GADInterstitial *)createAndLoadInterstitial{
    GADInterstitial *interstitial = [[GADInterstitial alloc] initWithAdUnitID:AD_INTERSTITIAL_ID];
    interstitial.delegate = self;
    [interstitial loadRequest:[GADRequest request]];
    return interstitial;
}

- (void)interstitialDidDismissScreen:(GADInterstitial *)ad{
    _interstitial = [self createAndLoadInterstitial];
}

- (void)showInterstitialAds{
    NSLog(@"计时器");
    if ([_interstitial isReady] && !([ProManager isProductPaid:AD_PRODUCT_ID] || [ProManager isFullPaid] || [ProManager isProductPaid:MONTH_ID] || [ProManager isProductPaid:YEAR_ID])) {
        [_interstitial presentFromRootViewController:self];
    }
}

@end
