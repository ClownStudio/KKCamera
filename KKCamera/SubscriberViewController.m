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
    UIButton *_closeBtn;
    UIButton *_monthBtn;
    UIButton *_yearBtn;
    UIButton *_confirmBtn;
    UIButton *_restoreBtn;
    UIButton *_termsBtn;
    UIButton *_policyBtn;
    NSString *_subId;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIImage *image = [UIImage imageNamed:[self getAssetWithName:@"kk_unlock"]];
    CGSize size = [self getSizeWithImage:image];
    
    _imageView = [[UIImageView alloc] initWithFrame:CGRectMake((self.view.bounds.size.width - size.width)/2, (self.view.bounds.size.height - size.height)/2, size.width, size.height)];
    [_imageView setImage:image];
    [_imageView.layer setMasksToBounds:YES];
    [_imageView setUserInteractionEnabled:YES];
    _imageView.layer.cornerRadius = 5;
    [self.view addSubview:_imageView];
    
    _closeBtn = [[UIButton alloc] initWithFrame:CGRectMake(_imageView.frame.origin.x + _imageView.frame.size.width * 0.05, _imageView.frame.origin.y + _imageView.frame.size.height * 0.08, 35, 35)];
    [_closeBtn setImage:[UIImage imageNamed:@"kk_iap_close"] forState:UIControlStateNormal];
    [_closeBtn setContentMode:UIViewContentModeScaleAspectFit];
    [_closeBtn addTarget:self action:@selector(onClose:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_closeBtn];
    
    UIImage *monthImage = [UIImage imageNamed:[self getAssetWithName:@"kk_month"]];
    UIImage *monthImageSelected = [UIImage imageNamed:[self getAssetWithName:@"kk_month_selected"]];
    _monthBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, _imageView.bounds.size.height * 0.63, _imageView.bounds.size.width/2, _imageView.bounds.size.width/2/monthImage.size.width*monthImage.size.height)];
    [_monthBtn setImage:monthImage forState:UIControlStateNormal];
    [_monthBtn setImage:monthImageSelected forState:UIControlStateSelected];
    [_monthBtn addTarget:self action:@selector(onSelectMonth:) forControlEvents:UIControlEventTouchUpInside];
    [_monthBtn setSelected:YES];
    _subId = MONTH_ID;
    [_imageView addSubview:_monthBtn];
    
    UIImage *yearImage = [UIImage imageNamed:[self getAssetWithName:@"kk_year"]];
    UIImage *yearImageSelected = [UIImage imageNamed:[self getAssetWithName:@"kk_year_selected"]];
    _yearBtn = [[UIButton alloc] initWithFrame:CGRectMake(_imageView.bounds.size.width/2, _imageView.bounds.size.height * 0.63, _imageView.bounds.size.width/2, _imageView.bounds.size.width/2/yearImage.size.width*yearImage.size.height)];
    [_yearBtn setImage:yearImage forState:UIControlStateNormal];
    [_yearBtn setImage:yearImageSelected forState:UIControlStateSelected];
    [_yearBtn addTarget:self action:@selector(onSelectYear:) forControlEvents:UIControlEventTouchUpInside];
    [_imageView addSubview:_yearBtn];
    
    UIImage *confirmImage;
    if ([ProManager isProductPaid:MONTH_ID]) {
        confirmImage = [UIImage imageNamed:[self getAssetWithName:@"kk_sub"]];
    }else{
        confirmImage = [UIImage imageNamed:[self getAssetWithName:@"kk_trial"]];
    }
    
    _confirmBtn = [[UIButton alloc] initWithFrame:CGRectMake(20, _monthBtn.frame.origin.y + _monthBtn.frame.size.height + 10, _imageView.frame.size.width - 40, (_imageView.frame.size.width - 40)/confirmImage.size.width * confirmImage.size.height)];
    [_confirmBtn setImage:confirmImage forState:UIControlStateNormal];
    [_confirmBtn addTarget:self action:@selector(onConfirm:) forControlEvents:UIControlEventTouchUpInside];
    [_imageView addSubview:_confirmBtn];
    
    _restoreBtn = [[UIButton alloc] initWithFrame:CGRectMake(_imageView.bounds.size.width * 0.17, _imageView.bounds.size.height * 0.93, _imageView.bounds.size.width * 0.26, _imageView.bounds.size.height * 0.05)];
    [_restoreBtn addTarget:self action:@selector(onRestore) forControlEvents:UIControlEventTouchUpInside];
    [_imageView addSubview:_restoreBtn];
    
    _termsBtn = [[UIButton alloc] initWithFrame:CGRectMake(_imageView.bounds.size.width * 0.43, _restoreBtn.frame.origin.y, _imageView.bounds.size.width * 0.19, _imageView.bounds.size.height * 0.05)];
    [_termsBtn addTarget:self action:@selector(onTerms:) forControlEvents:UIControlEventTouchUpInside];
    [_imageView addSubview:_termsBtn];
    
    _policyBtn = [[UIButton alloc] initWithFrame:CGRectMake(_imageView.bounds.size.width * 0.62, _restoreBtn.frame.origin.y, _imageView.bounds.size.width * 0.2, _imageView.bounds.size.height * 0.05)];
    [_policyBtn addTarget:self action:@selector(onPolicy:) forControlEvents:UIControlEventTouchUpInside];
    [_imageView addSubview:_policyBtn];
}

-(IBAction)onConfirm:(id)sender{
    [self.proManager buyProduct:_subId];
}

-(IBAction)onTerms:(id)sender{
    [[UIApplication sharedApplication]openURL:[NSURL URLWithString:TERMS_OF_USE]];
}

-(IBAction)onPolicy:(id)sender{
    [[UIApplication sharedApplication]openURL:[NSURL URLWithString:PRIVACY_POLICY]];
}

-(IBAction)onSelectMonth:(id)sender{
    [_monthBtn setSelected:YES];
    [_yearBtn setSelected:NO];
    _subId = MONTH_ID;
    [self refreshConfirmBtn];
}

-(IBAction)onSelectYear:(id)sender{
    [_monthBtn setSelected:NO];
    [_yearBtn setSelected:YES];
    _subId = YEAR_ID;
    [self refreshConfirmBtn];
}

-(void)refreshConfirmBtn{
    UIImage *confirmImage;
    if ([ProManager isProductPaid:_subId]) {
        confirmImage = [UIImage imageNamed:[self getAssetWithName:@"kk_sub"]];
    }else{
        confirmImage = [UIImage imageNamed:[self getAssetWithName:@"kk_trial"]];
    }
    [_confirmBtn setImage:confirmImage forState:UIControlStateNormal];
}

-(IBAction)onClose:(id)sender{
    [self.navigationController popViewControllerAnimated:YES];
}

-(CGSize)getSizeWithImage:(UIImage *)image{
    CGFloat imageWidth;
    CGFloat imageHeight;
    
    if (image.size.width/self.view.bounds.size.width * self.view.bounds.size.height > image.size.height) {
        imageWidth = self.view.bounds.size.width;
        imageHeight = imageWidth/image.size.width * image.size.height;
    }else{
        imageHeight = self.view.bounds.size.height;
        imageWidth = imageHeight/image.size.height * image.size.width;
    }
    return CGSizeMake(imageWidth, imageHeight);
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
