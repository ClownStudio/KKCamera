//
//  AppManager.h
//  PhotoCollage
//
//  Created by 杜杜 on 16/4/19.
//  Copyright © 2016年 duruochuan. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AppManager : NSObject {
    
}

@property(nonatomic,strong)NSDictionary *collageInfo;
@property(nonatomic,strong)NSArray      *selectImages;

+ (AppManager *)sharedManager;

@end
