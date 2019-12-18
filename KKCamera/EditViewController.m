//
//  EditViewController.m
//  KKCamera
//
//  Created by Jam Zhang on 2019/11/29.
//  Copyright © 2019 Jam Zhang. All rights reserved.
//

#import "EditViewController.h"
#import "SettingViewController.h"
#import <Masonry.h>
#import "SubscriberViewController.h"
#import "EffectSliderView.h"
#import "EffectItemView.h"

@interface EditViewController () <UIScrollViewDelegate>

@end

@implementation EditViewController{
    UIImage *_oriImage;
    UIButton *_backBtn;
    UIButton *_settingBtn;
    UIButton *_iapBtn;
    UIButton *_nextBtn;
    UIButton *_resetBtn;
    UIView *_editorView;
    UIScrollView *_imageScrollView;
    UIImageView *_imageView;
    UIScrollView *_itemScrollView;
    NSArray *_effectContent;
    UIView *_groupView;
    UIView *_toolView;
    UIScrollView *_topScrollView;
    UIScrollView *_middleScrollView;
    NSArray *_selectedMiddleContent;
    NSArray *_selectedContent;
    NSString *_selectedType;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.fd_interactivePopDisabled = YES;
    
    NSString *effectFilePath = [[NSBundle mainBundle] pathForResource:@"Effect" ofType:@"plist"];
    _effectContent = [NSArray arrayWithContentsOfFile:effectFilePath];
    
    _backBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 40, 40)];
    [_backBtn setImage:[UIImage imageNamed:@"kk_back"] forState:UIControlStateNormal];
    [_backBtn addTarget:self action:@selector(onBack:) forControlEvents:UIControlEventTouchUpInside];
    [self.contentView addSubview:_backBtn];
    
    _settingBtn = [[UIButton alloc] initWithFrame:CGRectMake(50, 0, 40, 40)];
    [_settingBtn setImage:[UIImage imageNamed:@"kk_edit_setting"] forState:UIControlStateNormal];
    [_settingBtn addTarget:self action:@selector(onSetting:) forControlEvents:UIControlEventTouchUpInside];
    [self.contentView addSubview:_settingBtn];
    
    _iapBtn = [[UIButton alloc] initWithFrame:CGRectMake(self.contentView.bounds.size.width - 90, 0, 40, 40)];
    [_iapBtn setImage:[UIImage imageNamed:@"kk_iap"] forState:UIControlStateNormal];
    [_iapBtn addTarget:self action:@selector(onIap:) forControlEvents:UIControlEventTouchUpInside];
    [self.contentView addSubview:_iapBtn];
    
    _nextBtn = [[UIButton alloc] initWithFrame:CGRectMake(self.contentView.bounds.size.width - 40, 0, 40, 40)];
    [_nextBtn setImage:[UIImage imageNamed:@"kk_next"] forState:UIControlStateNormal];
    [self.contentView addSubview:_nextBtn];
    
    _resetBtn = [[UIButton alloc] initWithFrame:CGRectMake((self.contentView.bounds.size.width - 100)/2, 5, 100, 30)];
    [_resetBtn setTitle:@"RESET" forState:UIControlStateNormal];
    [_resetBtn.titleLabel setFont:[UIFont systemFontOfSize:11]];
    [_resetBtn.layer setMasksToBounds:YES];
    [_resetBtn.layer setBorderWidth:1];
    [_resetBtn.layer setBorderColor:[UIColor whiteColor].CGColor];
    [_resetBtn.layer setCornerRadius:15];
    [self.contentView addSubview:_resetBtn];
    
    int distance = 10;
    int gap = 5;
    CGFloat itemHeight = (self.contentView.bounds.size.width - 7 * distance)/6;
    _editorView = [[UIView alloc] init];
    [_editorView setBackgroundColor:[UIColor colorWithRed:0.114 green:0.133 blue:0.137 alpha:1.000]];
    [self.contentView addSubview:_editorView];
    [_editorView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.equalTo(self.contentView);
        make.size.mas_equalTo(itemHeight + gap * 2);
    }];
    
    _itemScrollView = [[UIScrollView alloc] init];
    [_editorView addSubview:_itemScrollView];
    [_itemScrollView setShowsVerticalScrollIndicator:NO];
    [_itemScrollView setShowsHorizontalScrollIndicator:NO];
    [_itemScrollView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.bottom.equalTo(self->_editorView).offset(5);
        make.left.right.equalTo(self->_editorView);
    }];

    _middleScrollView = [[UIScrollView alloc] init];
    [self.contentView addSubview:_middleScrollView];
    [_middleScrollView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.contentView);
        make.bottom.equalTo(_editorView.mas_top);
        make.size.mas_equalTo(100);
    }];
    
    _groupView = [[UIView alloc] init];
    [_groupView setBackgroundColor:[UIColor blackColor]];
    [self.contentView addSubview:_groupView];
    [_groupView setUserInteractionEnabled:YES];
    [_groupView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.contentView);
        make.bottom.equalTo(_middleScrollView.mas_top);
        make.size.mas_equalTo(70);
    }];
    
    _topScrollView = [[UIScrollView alloc]init];
    [self.contentView addSubview:_topScrollView];
    [_topScrollView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.contentView);
        make.bottom.equalTo(_groupView.mas_top);
        make.size.mas_equalTo(30);
    }];
    
    _imageScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, _settingBtn.bounds.size.height, self.contentView.frame.size.width, self.contentView.frame.size.height - (itemHeight + gap * 2 + 100) - _settingBtn.bounds.size.height)];
    [self.contentView addSubview:_imageScrollView];
    if (@available(iOS 11.0, *)) {
        _imageScrollView.contentInsetAdjustmentBehavior =  UIScrollViewContentInsetAdjustmentNever;
    }
    _imageScrollView.delegate = self;
    _imageScrollView.minimumZoomScale = 1.0f;
    _imageScrollView.maximumZoomScale = 3.0f;
    _imageScrollView.showsVerticalScrollIndicator = NO;
    _imageScrollView.showsHorizontalScrollIndicator = NO;
    
    _imageView = [[UIImageView alloc] initWithFrame:_imageScrollView.bounds];
    [_imageScrollView addSubview:_imageView];
    _imageView.contentMode = UIViewContentModeScaleAspectFit;
    _imageView.userInteractionEnabled = YES;
    _imageView.clipsToBounds = YES;
    [_imageView setImage:_oriImage];
    
    [self.contentView insertSubview:_groupView aboveSubview:_imageScrollView];
    [self.contentView insertSubview:_topScrollView aboveSubview:_imageScrollView];
    
    int position = 0;
    int tag = 1;
    for (NSDictionary *dict in _effectContent) {
        NSString *name = [dict objectForKey:@"icon"];
        position += distance;
        UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(position, gap, itemHeight, itemHeight)];
        [button setImage:[UIImage imageNamed:[NSString stringWithFormat:@"%@",name]] forState:UIControlStateNormal];
        [button setImage:[UIImage imageNamed:[NSString stringWithFormat:@"%@_selected",name]] forState:UIControlStateSelected];
        button.tag = tag;
        [button addTarget:self action:@selector(onSelectEditorItem:) forControlEvents:UIControlEventTouchUpInside];
        [_itemScrollView addSubview:button];
        tag++;
        position += itemHeight;
    }
    [_itemScrollView setContentSize:CGSizeMake(position + distance, 0)];
    [self selectEditorItemWithIndex:0];
}

-(IBAction)onIap:(id)sender{
    SubscriberViewController *subViewController = [[SubscriberViewController alloc] init];
    subViewController.modalPresentationStyle = UIModalPresentationFullScreen;
    [self.navigationController pushViewController:subViewController animated:YES];
}

#pragma mark -- UIScrollViewDelegate

//返回需要缩放的视图控件 缩放过程中
- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return _imageView;
}

//开始缩放
- (void)scrollViewWillBeginZooming:(UIScrollView *)scrollView withView:(UIView *)view{
    NSLog(@"开始缩放");
}
//结束缩放
- (void)scrollViewDidEndZooming:(UIScrollView *)scrollView withView:(UIView *)view atScale:(CGFloat)scale{
    NSLog(@"结束缩放");
}

//缩放中
- (void)scrollViewDidZoom:(UIScrollView *)scrollView {
    // 延中心点缩放
    CGFloat imageScaleWidth = scrollView.zoomScale * _imageScrollView.bounds.size.width;
    CGFloat imageScaleHeight = scrollView.zoomScale * _imageScrollView.bounds.size.height;
    CGFloat imageX = 0;
    CGFloat imageY = 0;
    if (imageScaleWidth < _imageScrollView.bounds.size.width) {
        imageX = floorf((_imageScrollView.bounds.size.width - imageScaleWidth) / 2.0);
    }
    if (imageScaleHeight < _imageScrollView.bounds.size.height) {
        imageY = floorf((_imageScrollView.bounds.size.height - imageScaleHeight) / 2.0);
    }
    _imageView.frame = CGRectMake(imageX, imageY, imageScaleWidth, imageScaleHeight);
}

- (IBAction)onSelectEditorItem:(UIButton *)sender{
    [self selectEditorItemWithIndex:(int)sender.tag - 1];
}

- (void)selectEditorItemWithIndex:(int)index{
    for (UIButton *button in _itemScrollView.subviews) {
        if ([button isMemberOfClass:[UIButton class]] == NO) {
            continue;
        }
        if (index + 1 == button.tag) {
            [button setSelected:YES];
        }else{
            [button setSelected:NO];
        }
    }
    [self refreshMainScrollViewWithIndex:index];
}

-(void)refreshMainScrollViewWithIndex:(int)index{
    for (UIView * view in _topScrollView.subviews) {
        [view removeFromSuperview];
    }
    _selectedType = [[_effectContent objectAtIndex:index] objectForKey:@"type"];
    _selectedContent = [[_effectContent objectAtIndex:index] objectForKey:_selectedType];
    if ([@"cut" isEqualToString:_selectedType]) {
        [_topScrollView setHidden:YES];
        [_groupView setHidden:YES];
    }else if ([@"edit" isEqualToString:_selectedType]){
        [self refreshGroupViewWithRandom:NO];
        [_topScrollView setHidden:YES];
        [_groupView setHidden:NO];
    }else{
        [self refreshGroupViewWithRandom:YES];
        [_topScrollView setHidden:NO];
        [_groupView setHidden:NO];
        CGFloat position = 0;
        int tag = 1;
        for (NSDictionary *dict in _selectedContent) {
            NSString *title = [dict objectForKey:@"title"];
            UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(position, 0, 80, _topScrollView.bounds.size.height)];
            [button setBackgroundColor:[UIColor colorWithWhite:0 alpha:0.7]];
            [button setTitle:title forState:UIControlStateNormal];
            [button.titleLabel setFont:[UIFont systemFontOfSize:10]];
            [button addTarget:self action:@selector(onSelectTop:) forControlEvents:UIControlEventTouchUpInside];
            button.tag = tag;
            [_topScrollView addSubview:button];
            position += 80;
            tag ++;
        }
        [_topScrollView setContentSize:CGSizeMake(position, 0)];
        [self selectTopScrollViewWithIndex:0];
    }
}

-(void)refreshGroupViewWithRandom:(BOOL)isRandom{
    for (UIView * view in _groupView.subviews) {
        [view removeFromSuperview];
    }
    if(isRandom){
        
    }else{
        UIView *_sliderView = [self getSliderView];
        [_groupView addSubview:_sliderView];
    }
}

-(UIView *)getSliderView{
    EffectSliderView *view = [[EffectSliderView alloc] initWithFrame:CGRectMake((_groupView.bounds.size.width - 230)/2, (_groupView.bounds.size.height - 35)/2, 230, 35)];
    return view;
}

-(IBAction)onSelectTop:(UIButton *)sender{
    [self selectTopScrollViewWithIndex:(int)sender.tag - 1];
}

-(void)selectTopScrollViewWithIndex:(int)index{
    for (UIButton *button in _topScrollView.subviews) {
        if ([button isMemberOfClass:[UIButton class]]) {
            if (button.tag == index + 1) {
                [button setBackgroundColor:[UIColor colorWithWhite:0 alpha:1]];
            }else{
                [button setBackgroundColor:[UIColor colorWithWhite:0 alpha:0.5]];
            }
        }
    }
    NSArray *middleContent = [[_selectedContent objectAtIndex:index] objectForKey:@"effects"];
    int position = 0;
    int distance = 5;
    int tag = 1;
    for (NSDictionary *dict in middleContent) {
        position += distance;
        EffectItemView *button = [[EffectItemView alloc] initWithFrame:CGRectMake(position, 5, 50, _middleScrollView.bounds.size.height - 10)];
        button.tag = tag;
        [button setItemWithData:dict];
        [_middleScrollView addSubview:button];
        tag++;
        position += 50;
    }
    [_middleScrollView setContentSize:CGSizeMake(position, 0)];
}

-(void)viewSafeAreaInsetsDidChange{
    [super viewSafeAreaInsetsDidChange];
    UIEdgeInsets safeAreaInsets = self.view.safeAreaInsets;
    UIView *bottomView = [[UIView alloc] initWithFrame:CGRectMake(0, self.view.bounds.size.height - safeAreaInsets.bottom, self.view.bounds.size.width, safeAreaInsets.bottom)];
    [bottomView setBackgroundColor:[UIColor colorWithRed:0.114 green:0.133 blue:0.137 alpha:1.000]];
    [self.view insertSubview:bottomView atIndex:0];
    
    CGRect scrollTemp = _imageScrollView.frame;
    scrollTemp.size.height = _imageScrollView.frame.size.height - safeAreaInsets.top - safeAreaInsets.bottom;
    _imageScrollView.frame = scrollTemp;
    [_imageView setFrame:_imageScrollView.bounds];
}

-(void)setOriginImage:(UIImage *)originImage{
    _oriImage = originImage;
    if (_imageView) {
        _imageView.image = _oriImage;
    }
}

-(IBAction)onSetting:(id)sender{
    SettingViewController *settingViewController = [[SettingViewController alloc] init];
    settingViewController.modalPresentationStyle = UIModalPresentationFullScreen;
    [self.navigationController pushViewController:settingViewController animated:YES];
}

-(IBAction)onBack:(id)sender{
    [self.navigationController popViewControllerAnimated:YES];
}

@end
