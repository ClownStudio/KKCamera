//
//  SettingViewController.m
//  KKCamera
//
//  Created by Jam Zhang on 2019/11/28.
//  Copyright © 2019 Jam Zhang. All rights reserved.
//

#import "SettingViewController.h"
#import "SettingModel.h"
#import "Macro.h"
#import <CGXPickerView.h>
#import <MessageUI/MessageUI.h>
#import "MBProgressHUD+RJHUD.h"
#import "Macro.h"
#import <GoogleMobileAds/GoogleMobileAds.h>

#define Is_iPhoneX ([UIScreen mainScreen].bounds.size.height == 812 || [UIScreen mainScreen].bounds.size.height == 896)

@interface SettingViewController () <GADBannerViewDelegate>

@end

@implementation SettingViewController{
    GADBannerView *_bannerView;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.view setBackgroundColor:[UIColor whiteColor]];
    [self.contentView setHidden:YES];
    if (@available(iOS 13.0, *)) {
        self.overrideUserInterfaceStyle = UIUserInterfaceStyleLight;
    }
    
    [self.btn1 setOn:[[SettingModel sharedInstance] isStamp]];
    [self.btn2 setOn:[[SettingModel sharedInstance] isRandom]];
    [self.btn3 setTitle:[[SettingModel sharedInstance] customDate] forState:UIControlStateNormal];
    [self.btn8 setOn:[[SettingModel sharedInstance] isSound]];
    
    
    for (UIView *view in self.view.subviews) {
        if([view isMemberOfClass:[UIScrollView class]]){
            [(UIScrollView *)view setContentSize:CGSizeMake(0, 565)];
            if ([@"0" isEqualToString:IS_AD_VERSION] && !([ProManager isProductPaid:AD_PRODUCT_ID] || [ProManager isFullPaid] || [ProManager isProductPaid:YEAR_ID] || [ProManager isProductPaid:MONTH_ID])) {
                CGFloat height = 50;
                if(Is_iPhoneX){
                    height = 85;
                }
                CGRect temp = view.frame;
                temp.size.height = view.frame.size.height - height;
                view.frame = temp;
                
                _bannerView = [self createAndLoadBannerView];
                [self.view addSubview:_bannerView];
            }
        }
    }
}

- (GADBannerView *)createAndLoadBannerView{
    GADBannerView *bannerView = [[GADBannerView alloc] initWithAdSize:kGADAdSizeSmartBannerPortrait];
    bannerView.hidden = YES;
    bannerView.rootViewController = self;
    [bannerView setAdUnitID:AD_BANNER_ID];
    bannerView.delegate = self;
    [bannerView loadRequest:[GADRequest request]];
    return bannerView;
}

- (void)adViewDidReceiveAd:(GADBannerView *)bannerView{
    if ([ProManager isProductPaid:AD_PRODUCT_ID] || [ProManager isFullPaid] || [ProManager isProductPaid:YEAR_ID] || [ProManager isProductPaid:MONTH_ID]) {
        bannerView.hidden = YES;
    }else{
        CGFloat height = 50;
        if(Is_iPhoneX){
            height = 85;
        }
        CGRect bannerTemp = _bannerView.frame;
        bannerTemp.origin.y = self.view.frame.size.height - height;
        _bannerView.frame = bannerTemp;
        bannerView.hidden = NO;
    }
}

- (void)adView:(GADBannerView *)adView didFailToReceiveAdWithError:(GADRequestError *)error {
    NSLog(@"adView:didFailToReceiveAdWithError: %@", error.localizedDescription);
}

- (IBAction)onClose:(id)sender{
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)onAddStamp:(id)sender{
    [[SettingModel sharedInstance] setIsStamp:![[SettingModel sharedInstance] isStamp]];
}

- (IBAction)onRadom:(id)sender{
    [[SettingModel sharedInstance] setIsRandom:![[SettingModel sharedInstance] isRandom]];
}

- (IBAction)onSound:(id)sender{
    [[SettingModel sharedInstance] setIsSound:![[SettingModel sharedInstance] isSound]];
}

- (IBAction)onCustomDate:(id)sender{
    CGXPickerViewManager *manager = [[CGXPickerViewManager alloc] init];
    [manager setLeftBtnBGColor:[UIColor whiteColor]];
    [manager setLeftBtnTitleColor:[UIColor blackColor]];
    [manager setLeftBtnBorderWidth:0];
    [manager setLeftBtnTitle:NSLocalizedString(@"Cancel", nil)];
    [manager setRightBtnTitle:NSLocalizedString(@"OK", nil)];
    [manager setRightBtnBGColor:[UIColor whiteColor]];
    [manager setRightBtnTitleColor:[UIColor blackColor]];
    [manager setRightBtnBorderWidth:0];
    [CGXPickerView showDatePickerWithTitle:@"" DateType:UIDatePickerModeDate DefaultSelValue:[[SettingModel sharedInstance] customDate] MinDateStr:nil MaxDateStr:nil IsAutoSelect:YES Manager:manager ResultBlock:^(NSString *selectValue) {
        NSLog(@"%@",selectValue);
        [[SettingModel sharedInstance] setCustomDate:selectValue];
        [self.btn3 setTitle:[[SettingModel sharedInstance] customDate] forState:UIControlStateNormal];
    }];
}

- (IBAction)onRate:(id)sender{
    [self layoutRateAlert];
}

- (void)layoutRateAlert{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Tip", nil) message:NSLocalizedString(@"Evaluate", nil) preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", nil) style:UIAlertActionStyleCancel handler:nil];
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"OK", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 11.0) {
            [self goToAppStore];
        }else{
            NSString *urlStr = [NSString stringWithFormat:@"itms-apps://itunes.apple.com/WebObjects/MZStore.woa/wa/viewContentsUserReviews?type=Purple+Software&id=%@&pageNumber=0&sortOrdering=2&mt=8", APP_ID];
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:urlStr]];
        }
    }];
    [alertController addAction:cancelAction];
    [alertController addAction:okAction];
    [self presentViewController:alertController animated:YES completion:nil];
}

-(void)goToAppStore{
    NSString *itunesurl = [NSString stringWithFormat:@"itms-apps://itunes.apple.com/cn/app/id%@?mt=8&action=write-review",APP_ID];;
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:itunesurl]];
}

- (IBAction)onRestore:(id)sender{
    [self onRestore];
}

- (IBAction)onFeedback:(id)sender{
    [self onFeedback];
}

- (IBAction)onFollow:(id)sender{
    NSString *urlText = [NSString stringWithFormat:@"https://www.instagram.com"];
    [[UIApplication sharedApplication]openURL:[NSURL URLWithString:urlText]];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    if ([ProManager isProductPaid:AD_PRODUCT_ID] || [ProManager isFullPaid] || [ProManager isProductPaid:YEAR_ID] || [ProManager isProductPaid:MONTH_ID]){
        if (_bannerView) {
            [_bannerView removeFromSuperview];
            _bannerView.delegate = nil;
            _bannerView = nil;
        }
    }
}

@end
