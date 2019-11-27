//
//  PayViewController.h
//  PhotoX
//
//  Created by Leks on 2017/11/21.
//  Copyright © 2017年 idea. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <StoreKit/StoreKit.h>
#import "ProManager.h"
#import <MBProgressHUD.h>

@interface PayViewController : UIViewController <ProManagerDelegate>

@property (nonatomic, strong) IBOutlet UIImageView *img;
@property (nonatomic, strong) IBOutlet UIButton *btn;
@property (nonatomic, strong) IBOutlet UIButton *closeBtn;

@property (nonatomic, strong) ProManager *proManager;
@end
