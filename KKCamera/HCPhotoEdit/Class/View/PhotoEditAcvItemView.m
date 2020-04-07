//
//  PhotoEditAcvItemView.m
//  PhotoX
//
//  Created by Leks on 2017/12/19.
//  Copyright © 2017年 idea. All rights reserved.
//

#import "PhotoEditAcvItemView.h"
#import "HCTestFilter.h"
#import "ProManager.h"
#import "AssetBuffer.h"
#import "HCPhotoEditViewController.h"
#import "HCPhotoEditCustomSlider.h"
#import "PhotoXHaloFilter.h"
#import "UIImage+Utility.h"
#import "PhotoXAcvFilter.h"

@interface PhotoEditAcvItemView ()<ProManagerDelegate>

@property (nonatomic, strong) ProManager *proManager;
@property (nonatomic, strong) NSDictionary *tmpParent;
@property (nonatomic, strong) NSDictionary *tmpSub;
@end

@implementation PhotoEditAcvItemView
{
    GPUImagePicture        *pic;
    NSMutableArray         *textureImageNames;
    UISlider                       *_slider;
    HCPhotoEditBaseScrollView *editView;
    UIView                    *configView;
    UIImage                 *currentTexture;
    
    GPUImagePicture        *stillImageSource;
    PhotoXAcvFilter *acvFilter;
}



-(instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.datas = [NSMutableArray array];
        
        [self.datas setArray:[[AssetBuffer sharedInstance] configDataForName:@"Filters"]];
        
        PhotoEditBaseScrollView *scrollView = [[PhotoEditBaseScrollView alloc] initWithFrame:self.bounds bottomTitle:@"" configArray:self.datas];
        scrollView.delegate = self;
        [self addSubview:scrollView];
        self.scrollView = scrollView;
        editView = scrollView;
    }
    return self;
}

- (void)refreshDataPurchaseStatus
{
    for (int i=0; i<self.datas.count; i++) {
        NSMutableDictionary *md = self.datas[i];
        if ([ProManager isProductPaid:md[@"productId"]] || [ProManager isFullPaid])
        {
            md[@"paid"] = @YES;
        }
        else
        {
            md[@"paid"] = @NO;
        }
    }
    
    [self.scrollView reloadDatas:self.datas];
}

+(HCPhotoEditBaseItemView*)showInView:(UIView*)view
{
    CGFloat offset = 0;
    if (Is_iPhoneX) {
        offset = 20;
    }
    PhotoEditAcvItemView *effectView = [[PhotoEditAcvItemView alloc] initWithFrame:CGRectMake(0, view.bounds.size.height - 150 - offset, view.bounds.size.width, 150 + offset)];
    effectView.transform = CGAffineTransformMakeTranslation(0, 150);
    [view addSubview:effectView];
    [UIView animateWithDuration:0.25 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        effectView.transform = CGAffineTransformIdentity;
    } completion:^(BOOL finished) {
        
    }];
    return effectView;
}

-(void)didClickData:(NSDictionary *)data parent:(NSDictionary*)parent
{
    if (!self.oriImage) {
        self.oriImage = self.mainImageView.image;
    }
    
    NSData *acvData = nil;
    if (data[@"acv"]) {
        acvData = [NSData dataWithContentsOfFile:[[NSBundle mainBundle] pathForResource:data[@"acv"] ofType:nil]];
    }
    
    if (!acvData) {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Prompt"  message:@"Data corruption" preferredStyle:UIAlertControllerStyleAlert];
        
        [alert addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        }]];
        
        [self.parentController presentViewController:alert animated:YES completion:^{
            ;
        }];
        return ;
    }
    
    if (!self.oriImage) {
        self.oriImage = self.mainImageView.image;
    }
    
    self.tmpParent = parent;
    self.tmpSub = data;
    
    configView = [self sliderConfigView];
    _slider.value = 1.0;
    UIImage *newImage = [self acvForImage:self.oriImage acvData:acvData mix:1.0];
    if (newImage) {
        self.mainImageView.image = newImage;
    }
}

-(void)didClickButtonAtIndex:(NSInteger)index
{
    if (!self.oriImage) {
        self.oriImage = self.mainImageView.image;
    }
    
    pic = [[GPUImagePicture alloc] initWithImage:self.oriImage];
    HCTestFilter *filter = [[HCTestFilter alloc] initWithTextureImage:[UIImage imageNamed:textureImageNames[index]]];
    [pic addTarget:filter];
    [filter useNextFrameForImageCapture];
    [pic processImage];
    UIImage *newImage = [filter imageFromCurrentFramebuffer];
    if (newImage) {
        
        UIGraphicsBeginImageContextWithOptions(self.oriImage.size, NO, 1.0);
        [self.oriImage drawInRect:CGRectMake(0, 0, self.oriImage.size.width, self.oriImage.size.height)];
        [newImage drawInRect:CGRectMake(0, 0, self.oriImage.size.width, self.oriImage.size.height) blendMode:kCGBlendModePlusLighter alpha:1.0];
        UIImage *newimage2 = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        self.mainImageView.image = newimage2;
    }
}

-(void)okEdit
{
    if (![self.tmpParent[@"paid"] boolValue] && [self.tmpSub[@"isPurchase"] boolValue])
    {
        //未购买
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Prompt"  message:[NSString stringWithFormat:@"Paid function, whether to buy %@？", self.tmpParent[@"name"]] preferredStyle:UIAlertControllerStyleAlert];
        
        [alert addAction:[UIAlertAction actionWithTitle:@"Purchases" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [self showLoading];
            self.proManager = [[ProManager alloc] init];
            self.proManager.managerDelegate = self;
            //先尝试恢复
            [self.proManager restorePro];
        }]];
        
        [alert addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            ;
        }]];
        
        [self.parentController presentViewController:alert animated:YES completion:^{
            ;
        }];
        return ;
    }
    
    [super okEdit];
}

-(void)cancelEdit
{
    [super cancelEdit];
    if (self.oriImage) {
        self.mainImageView.image = self.oriImage;
    }
}

-(void)didSuccessBuyProduct:(NSString*)productId
{
    [self showMessage:@"Purchases successful"];
    [self refreshDataPurchaseStatus];
    self.proManager = nil;
}

-(void)didSuccessRestoreProducts:(NSArray*)productIds
{
    if ([ProManager isFullPaid])
    {
        //全解锁
        [self showMessage:@"Restore successful"];
        [self refreshDataPurchaseStatus];
        self.proManager = nil;
        return ;
    }
    
    for (int i=0; i<productIds.count; i++)
    {
        if ([self.tmpParent[@"productId"] isEqualToString:productIds[i]])
        {
            //已买过
            [self showMessage:@"Restore successful"];
            [self refreshDataPurchaseStatus];
            self.proManager = nil;
            return ;
        }
    }
    
    //未买过，进行支付
    [self.proManager buyProduct:self.tmpParent[@"productId"]];
}
-(void)didFailRestore:(NSString *)reason
{
    [self.proManager buyProduct:self.tmpParent[@"productId"]];
}
-(void)didFailedBuyProduct:(NSString*)productId forReason:(NSString*)reason
{
    [self showMessage:reason];
    self.proManager = nil;
}
-(void)didCancelBuyProduct:(NSString*)productId
{
    [self hideHUD];
    self.proManager = nil;
}

- (void)showMessage:(NSString*)msg
{
    if (self.hud) {
        [self.hud removeFromSuperview];
        self.hud = nil;
    }
    self.hud = [MBProgressHUD showHUDAddedTo:self.parentController.view animated:YES];
    self.hud.mode = MBProgressHUDModeText;
    self.hud.labelText = msg;
    
    [self.hud hide:YES afterDelay:2.f];
}

- (void)showLoading
{
    self.hud = [MBProgressHUD showHUDAddedTo:self.parentController.view animated:YES];
}

- (void)hideHUD
{
    [self.hud hide:YES];
}

-(UIView*)sliderConfigView
{
    UIView *view = [[UIView alloc] initWithFrame:self.bounds];
    view.backgroundColor = COLOR_RGB(32, 32, 32);
    [self addSubview:view];
    HCPhotoEditCustomSlider  *slider = [[HCPhotoEditCustomSlider alloc] initWithFrame:CGRectMake(30, 40, self.bounds.size.width - 60, 40)];
    [view addSubview:slider];
    [slider addTarget:self action:@selector(sliderValueChanged:) forControlEvents:UIControlEventValueChanged];
    _slider = slider;
    
    //bottomView
    UIView *bottomView = [[UIView alloc] initWithFrame:editView.bottomView.frame];
    bottomView.backgroundColor = COLOR_RGB(32, 32, 32);
    [view addSubview:bottomView];
    
    HCPhotoEditCustomButton *btn1 = [[HCPhotoEditCustomButton alloc] initWithImage:IMAGE_WITHNAME(@"photo_bottom_bar_cancel")  highlightedImage:IMAGE_WITHNAME(@"photo_bottom_bar_cancel_light") title:nil font:0 imageSize:0];
    btn1.frame = CGRectMake(0, 0, bottomView.bounds.size.width/2.0 - 1, bottomView.bounds.size.height);
    [bottomView addSubview:btn1];
    
    HCPhotoEditCustomButton *btn2 = [[HCPhotoEditCustomButton alloc] initWithImage:IMAGE_WITHNAME(@"photo_bottom_bar_ok")  highlightedImage:IMAGE_WITHNAME(@"photo_bottom_bar_ok_light") title:nil font:0 imageSize:0];
    btn2.frame = CGRectMake(bottomView.bounds.size.width/2.0, 0, bottomView.bounds.size.width/2.0, bottomView.bounds.size.height);
    [bottomView addSubview:btn2];
    [btn1 addTarget:self action:@selector(cancel) forControlEvents:UIControlEventTouchUpInside];
    [btn2 addTarget:self action:@selector(ok) forControlEvents:UIControlEventTouchUpInside];
    view.transform = CGAffineTransformMakeTranslation(0, view.bounds.size.height);
    [UIView animateWithDuration:0.25 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        view.transform = CGAffineTransformIdentity;
        editView.alpha = 0;
    } completion:^(BOOL finished) {
        
    }];
    
    slider.maximumValue = 1.5;
    slider.minimumValue = 0.5;
    slider.value = 1;
    
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:self.mainImageView.bounds];
    titleLabel.tag = 1010;
    titleLabel.numberOfLines = 0;
    titleLabel.transform = CGAffineTransformMakeTranslation(0, -30);
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.backgroundColor = [UIColor clearColor];
    titleLabel.font = [UIFont boldSystemFontOfSize:23];
    titleLabel.textColor = [UIColor whiteColor];
    [self.mainImageView addSubview:titleLabel];
    
    [slider setTouchEndedBlock:^{
        [UIView animateWithDuration:0.2 animations:^{
            titleLabel.alpha = 0;
        } completion:^(BOOL finished) {
            titleLabel.hidden = YES;
        }];
    }];
    
    return view;
}

-(void)hideSliderView
{
    [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        configView.alpha = 0.4;
        configView.transform = CGAffineTransformMakeTranslation(0, configView.bounds.size.height);
        editView.alpha = 1;
    } completion:^(BOOL finished) {
        [configView removeFromSuperview];
        configView = nil;
    }];
}

-(void)cancel
{
    [self hideSliderView];
    if (self.oriImage) {
        self.mainImageView.image = self.oriImage;
    }
    [[self.mainImageView viewWithTag:1010] removeFromSuperview];
}

-(void)ok
{
    [acvFilter useNextFrameForImageCapture];
    
    [stillImageSource processImage];
    
    UIImage *newImage = [acvFilter imageFromCurrentFramebufferWithOrientation:0];
    self.mainImageView.image = newImage;
    
    stillImageSource = nil;
    acvFilter = nil;
    
    [self hideSliderView];
    [[self.mainImageView viewWithTag:1010] removeFromSuperview];
}

-(void)sliderValueChanged:(UISlider*)slider
{
    acvFilter.mix = slider.value;
    [acvFilter useNextFrameForImageCapture];
    
    [stillImageSource processImage];
    
    UIImage *newImage = [acvFilter imageFromCurrentFramebufferWithOrientation:0];
    if (newImage) {
        self.mainImageView.image = newImage;
    }
    
}

- (UIImage*)acvForImage:(UIImage*)image acvData:(NSData*)acvData mix:(CGFloat)mix
{
    if (!stillImageSource) {
        stillImageSource = [[GPUImagePicture alloc]initWithImage:image];
    }
    
    [stillImageSource removeAllTargets];
    acvFilter = [[PhotoXAcvFilter alloc]initWithACVData:acvData];
    acvFilter.mix = mix;
    [stillImageSource addTarget:acvFilter];
    
    [acvFilter useNextFrameForImageCapture];
    [stillImageSource processImage];
    return [acvFilter imageFromCurrentFramebufferWithOrientation:0];
}
@end
