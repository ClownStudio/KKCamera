//
//  PCCollageItem.h
//  PhotoCollage
//
//  Created by 杜杜 on 16/4/22.
//  Copyright © 2016年 duruochuan. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol PCCollageItemDelegate;

@interface PCCollageItem : UIView <UIGestureRecognizerDelegate>{
    @private
    UIView      *_mainView;
    UIImageView *_imageView;
    UIButton    *_deleteButton;
    
    CGRect       _mainFrame;
    CGAffineTransform _selfTransform;
    UILabel     *_label;
    UIImageView *rView;
}

@property(nonatomic,readwrite)CGFloat maxScale;
@property(nonatomic,readwrite)CGSize  mainScreenSize;//控制移动的范围
@property(nonatomic,readwrite)BOOL selected;
@property(nonatomic,assign)id<PCCollageItemDelegate> delegate;

- (void)addImageViewWithImage:(UIImage *)image;
- (void)addLabel:(UILabel *)label;

@end

@protocol PCCollageItemDelegate <NSObject>
@optional
- (void)collageItemDidDeleteAction:(PCCollageItem *)item;
- (void)collageItemDidTapAction:(PCCollageItem *)item;
@end
