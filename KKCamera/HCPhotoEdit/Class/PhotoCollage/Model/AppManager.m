//
//  AppManager.m
//  PhotoCollage
//
//  Created by 杜杜 on 16/4/19.
//  Copyright © 2016年 duruochuan. All rights reserved.
//

#import "AppManager.h"

AppManager *_globalAppManager;

@implementation AppManager

+ (AppManager *)sharedManager
{
    @synchronized (self) {
        if (!_globalAppManager) {
            _globalAppManager = [[AppManager alloc]init];
        }
    }
    return _globalAppManager;
}

@end
