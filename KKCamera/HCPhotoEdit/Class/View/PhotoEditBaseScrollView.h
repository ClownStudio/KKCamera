//
//  PhotoEditBaseScrollView.h
//  PhotoX
//
//  Created by Leks on 2017/11/21.
//  Copyright © 2017年 idea. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol PhotoEditBaseScrollViewDelegate <NSObject>
@optional
-(void)didClickData:(NSDictionary*)data parent:(NSDictionary*)parent;
-(void)didClickButtonAtIndex:(NSInteger)index;
-(void)didClickButtonAtIndex:(NSInteger)index  button:(UIButton*)btn;
-(void)cancelEdit;
-(void)okEdit;

@end

@interface PhotoEditBaseScrollView : UIView

@property(nonatomic, assign) BOOL  ignoreButtonSelect;
@property(nonatomic, weak) id<PhotoEditBaseScrollViewDelegate> delegate;
@property(nonatomic, strong) UIView  *bottomView;
@property(nonatomic, strong) UIScrollView  *scrollView;
@property(nonatomic, strong) NSArray *datas;
@property(nonatomic) CGPoint destContentOffset;
@property (nonatomic, assign) UIViewController *parentController;

-(instancetype)initWithFrame:(CGRect)frame  bottomTitle:(NSString*)title  configArray:(NSArray*)images;

-(void)reloadDatas:(NSArray*)images;

@property (nonatomic, strong) NSMutableArray *btns;
- (void)purchase;
@end
