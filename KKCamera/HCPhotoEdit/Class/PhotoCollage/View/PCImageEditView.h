//
//  PCImageEditView.h
//  PhotoCollage
//
//  Created by 杜杜 on 16/4/20.
//  Copyright © 2016年 duruochuan. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol PCImageEditViewDelegate;

@interface PCImageEditView : UIView {
    
}

@property(nonatomic,assign)id<PCImageEditViewDelegate> delegate;
@property(nonatomic,strong)UIBezierPath *maskPath;
@property(nonatomic,strong)UIImage *image;
@property(nonatomic,strong)UIImage *filterImage;
@property(nonatomic,readwrite)BOOL selected;

@end

@protocol PCImageEditViewDelegate <NSObject>

@optional
- (void)imageEditViewDidTapAction:(PCImageEditView *)imageEditView;
- (void)imageEditViewDidSelectedChange:(PCImageEditView *)imageEditView;
- (void)imageEditViewDidImageChange:(PCImageEditView *)imageEditView;

@end