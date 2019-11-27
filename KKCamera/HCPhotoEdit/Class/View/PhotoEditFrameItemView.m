//
//  PhotoEditFrameItemView.m
//  PhotoX
//
//  Created by Leks on 2017/11/23.
//  Copyright © 2017年 idea. All rights reserved.
//

#import "PhotoEditFrameItemView.h"
#import "ProManager.h"
#import "AssetBuffer.h"

@interface PhotoEditFrameItemView ()<ProManagerDelegate>

@property (nonatomic, strong) ProManager *proManager;
@property (nonatomic, strong) NSDictionary *tmpParent;
@property (nonatomic, strong) NSDictionary *tmpSub;
@end

@implementation PhotoEditFrameItemView
{

}


-(instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.datas = [NSMutableArray array];
        [self.datas setArray:[[AssetBuffer sharedInstance] configDataForName:@"Border"]];
        
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
    
    PhotoEditFrameItemView *effectView = [[PhotoEditFrameItemView alloc] initWithFrame:CGRectMake(0, view.bounds.size.height - 150 - offset, view.bounds.size.width, 150 + offset)];
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
        NSString *name = [data[@"source"] firstObject];
        texture = [UIImage imageNamed:name];
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
    
    self.tmpParent = parent;
    self.tmpSub = data;
    
    UIGraphicsBeginImageContext(self.oriImage.size);
    [self.oriImage drawInRect:CGRectMake(0, 0, self.oriImage.size.width, self.oriImage.size.height)];
    [texture drawInRect:CGRectMake(0, 0, self.oriImage.size.width, self.oriImage.size.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    self.mainImageView.image = newImage;
    
}

-(void)didClickButtonAtIndex:(NSInteger)index
{
    if (!self.oriImage) {
        self.oriImage = self.mainImageView.image;
    }
    
    NSArray *images = @[@"blend_normal_border_1",@"blend_normal_border_2",@"blend_normal_border_3",@"blend_normal_border_4",@"blend_normal_border_5",@"blend_normal_border_6",@"blend_normal_border_7",@"blend_normal_border_8",@"blend_normal_border_9",@"blend_normal_border_10"];
    NSString *aBundleSourcePath = [[NSBundle mainBundle] pathForResource:@"CHPhotoEditResource" ofType:@"bundle"];
    NSBundle *bundle = [NSBundle bundleWithPath:aBundleSourcePath];
    NSString *path = [bundle pathForResource:images[index] ofType:@"png" inDirectory:[NSString stringWithFormat:@"texture/%@",images[index]]];
    UIImage *image = [UIImage imageWithContentsOfFile:path];
    
    
    UIGraphicsBeginImageContext(self.oriImage.size);
    [self.oriImage drawInRect:CGRectMake(0, 0, self.oriImage.size.width, self.oriImage.size.height)];
    [image drawInRect:CGRectMake(0, 0, self.oriImage.size.width, self.oriImage.size.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    self.mainImageView.image = newImage;
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

@end
