//
//  SettingModel.m
//  FTCamera
//
//  Created by 张文洁 on 2018/8/1.
//  Copyright © 2018年 JamStudio. All rights reserved.
//

#import "SettingModel.h"

@implementation SettingModel

+ (id)sharedInstance{
    static SettingModel *instance = nil;
    static dispatch_once_t predicate;
    dispatch_once(&predicate, ^{
        instance = [[self alloc] init];
    });
    return instance;
}

- (instancetype)init{
    self = [super init];
    if (self) {
        self.isStamp = YES;
        self.isRandom = YES;
        self.isSound = YES;
        NSDate *date = [NSDate date];
        NSDateFormatter *dateFormat = [[NSDateFormatter alloc]init];
        [dateFormat setDateFormat:@"yyyy / MM / dd"];
        NSString* dateString = [dateFormat stringFromDate:date];
        self.customDate = dateString;
    }
    return self;
}

@end
