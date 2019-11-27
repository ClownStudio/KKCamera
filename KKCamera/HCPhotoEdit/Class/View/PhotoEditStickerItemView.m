//
//  PhotoEditStickerItemView.m
//  PhotoX
//
//  Created by leks on 2017/12/3.
//  Copyright © 2017年 idea. All rights reserved.
//

#import "PhotoEditStickerItemView.h"
#import "HCTestFilter.h"
#import "ProManager.h"
#import "AssetBuffer.h"
#import "StickerView.h"

@interface PhotoEditStickerItemView ()<ProManagerDelegate, StickerViewDelegate>

@property (nonatomic, strong) ProManager *proManager;
@property (nonatomic, strong) NSDictionary *tmpParent;
@property (nonatomic, strong) NSDictionary *tmpSub;

@end
@implementation PhotoEditStickerItemView


{
    GPUImagePicture        *pic;
    NSMutableArray         *textureImageNames;
}


-(instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.datas = [NSMutableArray array];
        self.tmpStickerViews = [NSMutableArray array];
        self.tmpStickerDatas = [NSMutableArray array];
        [self.datas setArray:[[AssetBuffer sharedInstance] configDataForName:@"Sticker"]];
        
        PhotoEditBaseScrollView *scrollView = [[PhotoEditBaseScrollView alloc] initWithFrame:self.bounds bottomTitle:@"" configArray:self.datas];
        scrollView.delegate = self;
        [self addSubview:scrollView];
        self.scrollView = scrollView;
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
    PhotoEditStickerItemView *effectView = [[PhotoEditStickerItemView alloc] initWithFrame:CGRectMake(0, view.bounds.size.height - 150 - offset, view.bounds.size.width, 150 + offset)];
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
    
    UIImage *texture = nil;
    
    if ([data[@"source"] count] > 0) {
        texture = [UIImage imageNamed:[data[@"source"] firstObject]];
    }
    
    if (!texture) {
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
    
    StickerView *view = [[StickerView alloc] initWithImage:texture];
    view.delegate = self;
    CGFloat ratio = MIN( (0.3 * self.mainImageView.width) / view.width, (0.3 * self.mainImageView.height) / view.height);
    [view setScale:ratio];
    view.center = CGPointMake(self.mainImageView.width/2, self.mainImageView.height/2);
    
    [self.mainImageView addSubview:view];
    [StickerView setActiveStickerView:view];
    
    int aniTime = 0.5;
    view.alpha = 0.2;
    [UIView animateWithDuration:aniTime
                     animations:^{
                         view.alpha = 1;
                     }
     ];
    [self.tmpStickerViews addObject:view];
    [self.tmpStickerDatas addObject:data];
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
    for (int i=0; i<self.tmpStickerDatas.count; i++)
    {
        NSDictionary *sub = self.tmpStickerDatas[i];
        NSDictionary *parent = sub[@"parent"];
        if (![parent[@"paid"] boolValue] && [sub[@"isPurchase"] boolValue])
        {
            //未购买
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Prompt"  message:[NSString stringWithFormat:@"Paid function, whether to buy %@？", parent[@"name"]] preferredStyle:UIAlertControllerStyleAlert];
            
            [alert addAction:[UIAlertAction actionWithTitle:@"Purchases" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                [self showLoading];
                self.proManager = [[ProManager alloc] init];
                self.proManager.delegate = self;
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
    }
    
    for (int i=0; i<self.tmpStickerViews.count; i++) {
        StickerView *v = self.tmpStickerViews[i];
        v.delegate = nil;
    }
    [self.tmpStickerDatas removeAllObjects];
    [self.tmpStickerViews removeAllObjects];
    [StickerView setActiveStickerView:nil];
    [super okEdit];
}

-(void)cancelEdit
{
    for (int i=0; i<self.tmpStickerViews.count; i++) {
        StickerView *v = self.tmpStickerViews[i];
        v.delegate = nil;
        [v removeFromSuperview];
    }
    [self.tmpStickerViews removeAllObjects];
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
    
    [self.hud hide:YES afterDelay:3.f];
}

- (void)showLoading
{
    self.hud = [MBProgressHUD showHUDAddedTo:self.parentController.view animated:YES];
}

- (void)hideHUD
{
    [self.hud hide:YES];
}

-(void)willDeleteStickerView:(StickerView*)sv
{
    NSInteger idx = [self.tmpStickerViews indexOfObject:sv];
    [self.tmpStickerDatas removeObjectAtIndex:idx];
    [self.tmpStickerViews removeObject:sv];
}
@end
