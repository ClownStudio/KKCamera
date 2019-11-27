//
//  PCViewController.h
//  PhotoCollage
//
//  Created by 杜杜 on 16/4/11.
//  Copyright © 2016年 duruochuan. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PCViewController : UIViewController {
    
}

@property(nonatomic,readonly)BOOL isPhone;
@property(nonatomic,readonly)CGSize screenSize;

+ (id)viewControllerFromMainStoryboard:(NSString *)identifier;

@end
