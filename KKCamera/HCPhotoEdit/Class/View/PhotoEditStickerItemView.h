//
//  PhotoEditStickerItemView.h
//  PhotoX
//
//  Created by leks on 2017/12/3.
//  Copyright © 2017年 idea. All rights reserved.
//

#import "HCPhotoEditBaseItemView.h"
#import "PhotoEditBaseScrollView.h"
#import <MBProgressHUD.h>

@interface PhotoEditStickerItemView : HCPhotoEditBaseItemView<PhotoEditBaseScrollViewDelegate>

@property (nonatomic, strong) NSMutableArray     *datas;
@property (nonatomic, weak) PhotoEditBaseScrollView *scrollView;
@property (nonatomic, weak) UIViewController *parentController;
@property (nonatomic, strong) MBProgressHUD *hud;
@property (nonatomic, strong) NSMutableArray *tmpStickerViews;
@property (nonatomic, strong) NSMutableArray *tmpStickerDatas;
@end
