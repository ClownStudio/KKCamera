//
//  PCFilterView.h
//  PhotoCollage
//
//  Created by 杜杜 on 16/4/21.
//  Copyright © 2016年 duruochuan. All rights reserved.
//

#import "GPUImageView.h"

@protocol PCFilterViewDelegate;

@interface PCFilterView : UIView {
    
}

@property(nonatomic,strong)GPUImageView *imageView;
@property(nonatomic,strong)UILabel *titleLabel;
@property(nonatomic,readwrite)BOOL selected;
@property(nonatomic,assign)id<PCFilterViewDelegate> delegate;
@property(nonatomic,copy)NSString *filterName;

@end

@protocol PCFilterViewDelegate <NSObject>
@optional
- (void)filterViewDidSelectedStatusChange:(PCFilterView *)filterView;

@end
