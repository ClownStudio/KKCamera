//
//  PhotoEditFrameItemView.h
//  PhotoX
//
//  Created by Leks on 2017/11/23.
//  Copyright © 2017年 idea. All rights reserved.
//

#import "HCPhotoEditBaseItemView.h"
#import "PhotoEditBaseScrollView.h"
#import <MBProgressHUD.h>

@interface PhotoEditFrameItemView : HCPhotoEditBaseItemView<PhotoEditBaseScrollViewDelegate>

@property (nonatomic, strong) NSMutableArray     *datas;
@property (nonatomic, weak) PhotoEditBaseScrollView *scrollView;
@property (nonatomic, weak) UIViewController *parentController;
@property (nonatomic, strong) MBProgressHUD *hud;

@end
