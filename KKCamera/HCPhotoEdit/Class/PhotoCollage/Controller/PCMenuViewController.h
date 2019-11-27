//
//  PCMenuViewController.h
//  PhotoCollage
//
//  Created by 杜杜 on 16/4/22.
//  Copyright © 2016年 duruochuan. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol PCMenuViewControllerDelegate;

@interface PCMenuViewController : PCViewController {
    
}

@property(nonatomic,assign)id<PCMenuViewControllerDelegate> delegate;
@property(nonatomic,weak)IBOutlet UIImageView *bgImageView;
@property(nonatomic,weak)IBOutlet UIView      *menuView;

- (void)show;
- (void)hidden;

@end

@protocol PCMenuViewControllerDelegate <NSObject>

@optional
- (void)menuViewControllerDidMailSendAction:(PCMenuViewController *)viewController;

@end
