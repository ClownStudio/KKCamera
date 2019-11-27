//
//  PhotoEditBaseScrollView.m
//  PhotoX
//
//  Created by Leks on 2017/11/21.
//  Copyright © 2017年 idea. All rights reserved.
//

#import "PhotoEditBaseScrollView.h"
#import "HCPhotoEditViewController.h"
#import "HCPhotoEditCustomButton.h"
#import "HCPhotoEditBaseItemView.h"
#import "PhotoEditCustomButton.h"
#import "PayViewController.h"
#import "ProManager.h"
#import "AssetBuffer.h"
#import "UIImage+Utility.h"
#import "PhotoEditAcvItemView.h"
#import "GPUImage.h"
#import "PhotoXAcvFilter.h"

@implementation PhotoEditBaseScrollView

{
    HCPhotoEditCustomButton *lastSelectedBtn;
}

- (void)dealloc
{
    for (int i=0; i<self.datas.count; i++)
    {
        NSMutableDictionary *md = self.datas[i];
        md[@"expanded"] = @NO;
    }
}

-(instancetype)initWithFrame:(CGRect)frame  bottomTitle:(NSString*)title  configArray:(NSArray*)images
{
    self = [super initWithFrame:frame];
    if (self) {
        //90 55
        CGFloat offset = 0;
        if (Is_iPhoneX) {
            offset = 20;
        }
        
        self.btns = [NSMutableArray array];
        self.backgroundColor = COLOR_RGB(20, 20, 20);
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, self.bounds.size.height - 45 - offset, self.bounds.size.width, 45)];
        view.backgroundColor = COLOR_RGB(20, 20, 20);
        [self addSubview:view];
        self.bottomView = view;
        
        UIButton *cancelBtn = [UIButton buttonWithType:UIButtonTypeSystem];
        [cancelBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        cancelBtn.titleLabel.font = [UIFont systemFontOfSize:15];
        cancelBtn.titleLabel.textAlignment = NSTextAlignmentCenter;
        cancelBtn.frame = CGRectMake(0, 0, view.bounds.size.height + 20, view.bounds.size.height);
        [cancelBtn setImage:IMAGE_WITHNAME(@"photo_bottom_bar_cancel") forState:UIControlStateNormal];
        [cancelBtn setImage:IMAGE_WITHNAME(@"photo_bottom_bar_cancel_light") forState:UIControlStateNormal];
        cancelBtn.tintColor = [UIColor whiteColor];
        [cancelBtn addTarget:self action:@selector(cancel) forControlEvents:UIControlEventTouchUpInside];
        [view addSubview:cancelBtn];
        
        
        UIButton *finishBtn = [UIButton buttonWithType:UIButtonTypeSystem];
        [finishBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        finishBtn.titleLabel.font = [UIFont systemFontOfSize:15];
        finishBtn.titleLabel.textAlignment = NSTextAlignmentCenter;
        finishBtn.frame = CGRectMake(self.bounds.size.width - view.bounds.size.height - 20, 0, view.bounds.size.height + 20, view.bounds.size.height);
        [finishBtn setImage:IMAGE_WITHNAME(@"photo_bottom_bar_ok") forState:UIControlStateNormal];
        [finishBtn setImage:IMAGE_WITHNAME(@"photo_bottom_bar_ok_light") forState:UIControlStateNormal];
        finishBtn.tintColor = [UIColor whiteColor];
        [finishBtn addTarget:self action:@selector(ok) forControlEvents:UIControlEventTouchUpInside];
        [view addSubview:finishBtn];
        
        
        UILabel  *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(view.bounds.size.width/2 - 50, 0, 100, view.bounds.size.height)];
        titleLabel.font = [UIFont systemFontOfSize:17];
        titleLabel.textColor = [UIColor whiteColor];
        titleLabel.textAlignment = NSTextAlignmentCenter;
        titleLabel.text = title;
        [view addSubview:titleLabel];
        
        self.datas = images;
        
        UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, self.bounds.size.width, self.bounds.size.height - 45)];
        scrollView.showsHorizontalScrollIndicator = NO;
        [self insertSubview:scrollView atIndex:0];
        self.scrollView = scrollView;
        
        [self reloadDatas:images];
    }
    return self;
}

-(void)reloadDatas:(NSArray*)images
{
    CGFloat offset = 0;
    CGFloat width = 90;
    CGFloat size = 55;
    if (Is_iPhoneX) {
        offset = 3;
    }

    NSMutableArray *removeList = [NSMutableArray array];
    
    for (int i=0; i<self.btns.count; i++)
    {
        PhotoEditCustomButton *b = self.btns[i];
        if (![b.data[@"isParent"] boolValue])
        {
            [removeList addObject:b];
        }
    }
    [self.btns removeObjectsInArray:removeList];
    
    BOOL isCollapse = YES;
    int j = 0;
    for (int index = 0; index < images.count; index++)
    {
        NSDictionary *parent = images[index];
        
        PhotoEditCustomButton *btn = [self btnExists:parent];
        if (btn)
        {
            btn.destFrame = CGRectMake(j * width, 0, width - 1, self.scrollView.bounds.size.height);
            j++;
        }
        else
        {
            btn = [[PhotoEditCustomButton alloc]
                   initWithData:parent parent:nil];
//            btn = [[AssetBuffer sharedInstance] dequeButtonWithData:parent parent:nil];
            btn.tag = index;
            btn.idx = index;
            [btn removeTarget:self action:@selector(buttonClick:) forControlEvents:UIControlEventTouchUpInside];
            [btn addTarget:self action:@selector(buttonClick:) forControlEvents:UIControlEventTouchUpInside];
            btn.frame = CGRectMake(j * width, 0, width - 1, self.scrollView.bounds.size.height);
            btn.destFrame = CGRectMake(j * width, 0, width - 1, self.scrollView.bounds.size.height);
            [self.scrollView addSubview:btn];
            j++;
            
            [self.btns addObject:btn];
            
            if (parent[@"isPurchase"] && ![parent[@"paid"] boolValue]) {
                [btn addProMask];
            }
        }
        
        if ([parent[@"expanded"] boolValue])
        {
            isCollapse = NO;
            self.destContentOffset = CGPointMake(index * width, 0);
            NSArray *sub_items = parent[@"sub_items"];
            
            UIImage *tmpImage = nil;
            for (int k=0; k<sub_items.count; k++)
            {
                NSMutableDictionary *sub = sub_items[k];
                if (sub[@"acv"]) {
                    if (!tmpImage) {
                        PhotoEditAcvItemView *acvCtrl = (PhotoEditAcvItemView*)self.parentController;
                        tmpImage = [acvCtrl.mainImageView.image resize:CGSizeMake(128, 128)];
                    }
                    sub[@"acvImage"] = [self loadFilterImage:sub sourceImage:tmpImage];
                }
                PhotoEditCustomButton *sub_btn = [[PhotoEditCustomButton alloc]
                                              initWithData:sub parent:parent];
//                PhotoEditCustomButton *sub_btn = [[AssetBuffer sharedInstance] dequeButtonWithData:sub parent:parent];
                
                sub_btn.parentBtn = btn;
                sub_btn.tag = index + 10000;
                sub_btn.idx = k;
                [sub_btn removeTarget:self action:@selector(buttonClick:) forControlEvents:UIControlEventTouchUpInside];
                [sub_btn addTarget:self action:@selector(buttonClick:) forControlEvents:UIControlEventTouchUpInside];
                sub_btn.frame = btn.frame;
                sub_btn.destFrame = CGRectMake(j * width, 0, width - 1, self.scrollView.bounds.size.height);
                [self.scrollView insertSubview:sub_btn belowSubview:btn];
                sub_btn.alpha = 0;

                if ([sub[@"isPurchase"] boolValue] && ![parent[@"paid"] boolValue]) {
                    [sub_btn addProMask];
                }
                [self.btns insertObject:sub_btn atIndex:index + k];
                j++;
            }
        }
    }

    if (![self hasBuyBtn])
    {
        PhotoEditCustomButton *buy_btn = [self buyAllBtn];
        buy_btn.frame = CGRectMake(j * width, 0, width - 1, self.scrollView.bounds.size.height);
        buy_btn.destFrame = CGRectMake(j * width, 0, width - 1, self.scrollView.bounds.size.height);
        buy_btn.tag = self.btns.count;
        buy_btn.idx = self.btns.count;
        [self.scrollView addSubview:buy_btn];
        [self.btns addObject:buy_btn];
        j++;
    }
    else
    {
        PhotoEditCustomButton *buy_btn = [self.btns lastObject];
        buy_btn.destFrame = CGRectMake(j * width, 0, width - 1, self.scrollView.bounds.size.height);
        j++;
    }
    
    if (isCollapse) {
        self.destContentOffset = self.scrollView.contentOffset;
    }
    for (int i=0; i<removeList.count; i++) {
        PhotoEditCustomButton *btn = removeList[i];
        btn.destFrame = btn.parentBtn.destFrame;
    }
    [self.scrollView setContentSize:CGSizeMake(width * (self.btns.count + removeList.count), 0)];
    
    if (self.destContentOffset.x + self.scrollView.frame.size.width > width * self.btns.count)
    {
        self.destContentOffset = CGPointMake(width * self.btns.count - self.scrollView.frame.size.width, 0);
    }
    
    [self startAnimation:self.destContentOffset removeList:removeList];
}

- (PhotoEditCustomButton*)btnExists:(NSDictionary*)d
{
    for (int i=0; i<self.btns.count; i++) {
        PhotoEditCustomButton *b = self.btns[i];
        if (b.data == d) {
            return b;
        }
    }
    
    return nil;
}

-(void)cancel
{
    if ([self.delegate respondsToSelector:@selector(cancelEdit)]) {
        [self.delegate cancelEdit];
    }
}

-(void)ok
{
    if ([self.delegate respondsToSelector:@selector(okEdit)]) {
        [self.delegate okEdit];
    }
}

-(void)buttonClick:(HCPhotoEditCustomButton*)btn
{
    if (!self.ignoreButtonSelect) {
        if (btn != lastSelectedBtn && lastSelectedBtn) {
            lastSelectedBtn.normalState = YES;
        }
        lastSelectedBtn.selected = NO;
        lastSelectedBtn = btn;
        lastSelectedBtn.selected = YES;
    }

    if (btn.tag >= 10000)
    {
        NSInteger parent_idx = btn.tag - 10000;
        NSDictionary *parent = self.datas[parent_idx];
        NSDictionary *sub_item = parent[@"sub_items"][btn.idx];
        
        if ([self.delegate respondsToSelector:@selector(didClickData:parent:)]) {
            [self.delegate didClickData:sub_item parent:parent];
        }
    }
    else
    {
        NSInteger last_index = 0;
        for (int i=0; i<self.datas.count; i++) {
            NSMutableDictionary *parent = self.datas[i];
            if ([parent[@"expanded"] boolValue])
            {
                last_index = i;
                break;
            }
        }
        
        if (last_index != btn.tag) {
            self.datas[last_index][@"expanded"] = @NO;
//            [self collapse:self.datas[last_index]];
//            return ;
        }
        
        NSMutableDictionary *parent = self.datas[btn.tag];
        if ([parent[@"expanded"] boolValue])
        {
            parent[@"expanded"] = @NO;
        }
        else
        {
            parent[@"expanded"] = @YES;
        }
        
        [self reloadDatas:self.datas];
    }
}

- (void)startAnimation:(CGPoint)scrollViewOffset removeList:(NSArray*)removeList
{
    [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        for (int i=0; i<self.btns.count; i++) {
            PhotoEditCustomButton *btn = self.btns[i];
            btn.frame = btn.destFrame;
            btn.alpha = 1;
        }
        
        for (int i=0; i<removeList.count; i++) {
            PhotoEditCustomButton *btn = removeList[i];
            btn.frame = btn.destFrame;
            btn.alpha = 0;
        }
        self.scrollView.contentOffset = scrollViewOffset;
    } completion:^(BOOL finished) {
        for (int i=0; i<removeList.count; i++) {
            PhotoEditCustomButton *btn = removeList[i];
            [btn removeFromSuperview];
        }
        [[AssetBuffer sharedInstance] recycleButtons:removeList];
        [self.btns removeObjectsInArray:removeList];
        self.scrollView.contentSize = CGSizeMake(self.btns.count*90, self.scrollView.frame.size.height);
    }];
}

- (BOOL)hasBuyBtn
{
    for (int i=0; i<self.btns.count; i++)
    {
        PhotoEditCustomButton *btn = self.btns[i];
        if ([btn.data[@"isPurchaseBtn"] boolValue]) {
            return YES;
        }
    }
    
    return NO;
}

- (PhotoEditCustomButton*)buyAllBtn
{
    NSDictionary *d = @{@"isParent":@YES,
                        @"icon":@"All_purchases_cover.png",
                        @"name":@"GET MORE",
                        @"isPurchaseBtn":@YES
                        };
    
    PhotoEditCustomButton *btn = [[PhotoEditCustomButton alloc] initWithData:d parent:nil];
    [btn addTarget:self action:@selector(showPurchase) forControlEvents:UIControlEventTouchUpInside];
    return btn;
}

- (void)showPurchase
{
    if ([ProManager isProductPaid:kProDeluxeId]) {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:@"You have unlocked all the features" preferredStyle:UIAlertControllerStyleAlert];
        [alert addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            ;
        }]];
        
        [self.parentController presentViewController:alert animated:YES completion:^{
            ;
        }];
        return ;
    }
    
    [self purchase];
}

- (void)purchase
{
    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    PayViewController *vc = [sb instantiateViewControllerWithIdentifier:@"PayViewController"];
    vc.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    vc.modalPresentationStyle = UIModalPresentationOverCurrentContext;
    [self.parentController presentViewController:vc animated:YES completion:^{
        ;
    }];
}

- (UIImage*)loadFilterImage:(NSDictionary*)data sourceImage:(UIImage*)sourceImage
{
    

    NSData *acvData = [NSData dataWithContentsOfFile:[[NSBundle mainBundle] pathForResource:data[@"acv"] ofType:nil]];
    if (!acvData) {
        return nil;
    }
    
    GPUImagePicture *picture = [[GPUImagePicture alloc]initWithImage:sourceImage];
    GPUImageToneCurveFilter *filter = [[GPUImageToneCurveFilter alloc]initWithACVData:acvData];
    [picture addTarget:filter];
    
    [filter useNextFrameForImageCapture];
    [picture processImage];
    return [filter imageFromCurrentFramebufferWithOrientation:0];
}
@end
