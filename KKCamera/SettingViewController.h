//
//  SettingViewController.h
//  KKCamera
//
//  Created by Jam Zhang on 2019/11/28.
//  Copyright © 2019 Jam Zhang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BasicViewController.h"

NS_ASSUME_NONNULL_BEGIN

@interface SettingViewController : BasicViewController

@property (nonatomic, strong) IBOutlet UIButton *closeBtn;

@property (nonatomic, strong) IBOutlet UISwitch *btn1;
@property (nonatomic, strong) IBOutlet UISwitch *btn2;
@property (nonatomic, strong) IBOutlet UIButton *btn3;
@property (nonatomic, strong) IBOutlet UIButton *btn4;
@property (nonatomic, strong) IBOutlet UIButton *btn5;
@property (nonatomic, strong) IBOutlet UIButton *btn6;
@property (nonatomic, strong) IBOutlet UIButton *btn7;
@property (nonatomic, strong) IBOutlet UISwitch *btn8;

@end

NS_ASSUME_NONNULL_END
