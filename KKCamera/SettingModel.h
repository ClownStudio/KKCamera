//
//  SettingModel.h
//  FTCamera
//
//  Created by 张文洁 on 2018/8/1.
//  Copyright © 2018年 JamStudio. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SettingModel : NSObject

+ (id)sharedInstance;

@property (nonatomic,assign) BOOL isStamp;
@property (nonatomic,assign) BOOL isRandom;
@property (nonatomic,assign) BOOL isSound;
@property (nonatomic,strong) NSString *customDate;

@end
