//
//  BasicViewController.h
//  KKCamera
//
//  Created by Jam Zhang on 2019/11/26.
//  Copyright © 2019 Jam Zhang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ProManager.h"

NS_ASSUME_NONNULL_BEGIN

@interface BasicViewController : UIViewController

@property (nonatomic,strong) UIView *contentView;
@property (nonatomic, strong) ProManager *proManager;

- (void)onFeedback;
- (void)onRestore;

@end

NS_ASSUME_NONNULL_END
