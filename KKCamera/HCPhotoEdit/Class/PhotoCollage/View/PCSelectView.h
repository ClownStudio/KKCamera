//
//  PCSelectView.h
//  PhotoCollage
//
//  Created by 杜杜 on 16/4/19.
//  Copyright © 2016年 duruochuan. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol PCSelectViewDelegate;

@interface PCSelectView : UIView {
    UIButton *_deleteButton;
    UIImageView *_imageView;
}

@property(nonatomic,assign)id<PCSelectViewDelegate> delegate;

- (id)initWithFrame:(CGRect)frame image:(UIImage *)image;

@end

@protocol PCSelectViewDelegate <NSObject>

@optional
- (void)selectViewDidDeleteAction:(PCSelectView *)selectView;

@end
