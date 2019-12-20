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
#import "UIImage+Rotate.h"
#import "GPUImage.h"
#import "PhotoXAcvFilter.h"
#import "HCTestFilter.h"
#import "FBGlowLabel.h"
#import "SettingModel.h"

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
    NSArray *_selectedMainContent;
    NSArray *_selectedMiddleContent;
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
        make.size.mas_equalTo(120);
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
    
    _imageScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, _settingBtn.bounds.size.height, self.contentView.frame.size.width, self.contentView.frame.size.height - (itemHeight + gap * 2 + 120) - _settingBtn.bounds.size.height)];
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
    _selectedMainContent = [[_effectContent objectAtIndex:index] objectForKey:_selectedType];
    for (UIView * view in _groupView.subviews) {
        [view removeFromSuperview];
    }
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
        for (NSDictionary *dict in _selectedMainContent) {
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
    if(isRandom){
        UIView *sliderView = [self getSliderView];
        [_groupView addSubview:sliderView];
    }else{
        
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
    
    for (UIView *view in _middleScrollView.subviews) {
        [view removeFromSuperview];
    }
    _selectedMiddleContent = [[_selectedMainContent objectAtIndex:index] objectForKey:@"effects"];
    int position = 0;
    int distance = 8;
    int tag = 1;
    for (NSDictionary *dict in _selectedMiddleContent) {
        position += distance;
        EffectItemView *button = [[EffectItemView alloc] initWithFrame:CGRectMake(position, 8, 80, _middleScrollView.bounds.size.height - 16)];
        button.tag = tag;
        [button addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onTap:)]];
        [button.layer setMasksToBounds:YES];
        [button.layer setCornerRadius:5];
        [button setItemWithData:dict];
        [_middleScrollView addSubview:button];
        tag++;
        position += button.bounds.size.width;
    }
    [_middleScrollView setContentSize:CGSizeMake(position, 0)];
}

- (void)onTap:(UIGestureRecognizer *)gesture{
    [self selectMiddleWithIndex:(int)gesture.view.tag];
}

- (void)selectMiddleWithIndex:(int)index{
    for (EffectItemView *btn in _middleScrollView.subviews) {
        if([btn isMemberOfClass:[EffectItemView class]] == NO){
            continue;
        }
        if (btn.tag == index) {
            [btn setItemSelected:YES];
        }else{
            [btn setItemSelected:NO];
        }
    }
    [self refreshImageViewWithContent:[_selectedMiddleContent objectAtIndex:index - 1]];
}

- (UIImage *)createFilterWithImage:(UIImage *)image andFilterName:(NSString *)filterName{
    GPUImagePicture *pic = [[GPUImagePicture alloc] initWithImage:image];
    if ([filterName hasSuffix:@".acv"]) {
        PhotoXAcvFilter *acvFilter = [[PhotoXAcvFilter alloc]initWithACVData:[NSData dataWithContentsOfFile:[[NSBundle mainBundle] pathForResource:filterName ofType:nil]]];
        acvFilter.mix = 1;
        [pic addTarget:acvFilter];
        [acvFilter useNextFrameForImageCapture];
        [pic processImage];
        UIImage *newImage = [acvFilter imageFromCurrentFramebuffer];
        if (newImage) {
            return newImage;
        }
    }else{
        GPUImageFilter *outFilter = [[[NSClassFromString(filterName) class] alloc] init];
        [pic addTarget:outFilter];
        [outFilter useNextFrameForImageCapture];
        [pic processImage];
        UIImage *newImage = [outFilter imageFromCurrentFramebuffer];
        if(newImage){
            return newImage;
        }
    }
    
    return image;
}

- (UIImage *)createTextureWithImage:(UIImage *)image andTextureName:(NSString *)textureName{
    GPUImagePicture *pic = [[GPUImagePicture alloc] initWithImage:image];
    UIImage *textureImage = [UIImage imageNamed:textureName];
    HCTestFilter *texture = [[HCTestFilter alloc] initWithTextureImage:textureImage];
    [pic addTarget:texture];
    [texture useNextFrameForImageCapture];
    [pic processImage];
    UIImage *newImage = [texture imageFromCurrentFramebuffer];
    if(image.size.width == newImage.size.height){
        newImage = [newImage imageRotatedByDegrees:270];
    }
    if (newImage) {
        UIGraphicsBeginImageContextWithOptions(CGSizeMake(newImage.size.width, newImage.size.height), NO, newImage.scale);
        [image drawInRect:CGRectMake(0, 0, newImage.size.width, newImage.size.height)];
        [newImage drawInRect:CGRectMake(0, 0, newImage.size.width, newImage.size.height) blendMode:kCGBlendModePlusLighter alpha:1.0];
        UIImage *resultImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        return resultImage;
    }
    return image;
}

-(void)refreshImageViewWithContent:(NSDictionary *)content{
    NSString *selectFilter = [content objectForKey:@"filter"];
    NSString *selectTexture = [content objectForKey:@"texture"];
    NSDictionary *fontProperty = [content objectForKey:@"FontProperty"];
    UIImage *image = _oriImage;
    image = [image fixOrientation];
    
    if ([@"" isEqualToString:selectFilter] == NO) {
        image = [self createFilterWithImage:image andFilterName:selectFilter];
    }
    
    if ([@"" isEqualToString:selectTexture] == NO) {
        image = [self createTextureWithImage:image andTextureName:selectTexture];
    }
    
    if ([[SettingModel sharedInstance] isStamp] && nil != fontProperty) {
        UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
        FBGlowLabel *label = [[FBGlowLabel alloc] init];
        
        CGFloat value = imageView.frame.size.width > imageView.frame.size.height ? imageView.frame.size.width : imageView.frame.size.height;
        CGFloat base = value/1920;
        
        UIFont *font = [UIFont fontWithName:[fontProperty objectForKey:@"fontName"] size:[[fontProperty objectForKey:@"fontSize"] floatValue] * base];
        if (font == nil) {
            font = [UIFont fontWithName:@"DS-Digital" size:[[fontProperty objectForKey:@"fontSize"] floatValue] * base];
        }
        [label setFont:font];
        //描边
        NSArray *strokes = [[fontProperty objectForKey:@"strokeColor"] componentsSeparatedByString:@","];
        if (strokes!=nil && [strokes count] == 4) {
            label.strokeColor = [UIColor colorWithRed:[strokes[0] floatValue]/255 green:[strokes[1] floatValue]/255 blue:[strokes[2] floatValue]/255 alpha:[strokes[3] floatValue]];
        }else{
            label.strokeColor = [UIColor colorWithRed:0.937 green:0.337 blue:0.157 alpha:0.7];
        }
        
        label.strokeWidth = [[fontProperty objectForKey:@"strokeWidth"] floatValue];
        //发光
        label.layer.shadowRadius = [[fontProperty objectForKey:@"shadowRadius"] floatValue];
        
        NSArray *shadows = [[fontProperty objectForKey:@"shadowColor"] componentsSeparatedByString:@","];
        if (shadows!=nil && [shadows count] == 4) {
            label.layer.shadowColor = [UIColor colorWithRed:[shadows[0] floatValue]/255 green:[shadows[1] floatValue]/255 blue:[shadows[2] floatValue]/255 alpha:[shadows[3] floatValue]].CGColor;
        }else{
            label.layer.shadowColor = [UIColor colorWithRed:0.937 green:0.337 blue:0.157 alpha:1].CGColor;
        }
        
        label.layer.shadowOffset = CGSizeFromString([fontProperty objectForKey:@"shadowOffset"]);
        label.layer.shadowOpacity = [[fontProperty objectForKey:@"shadowOpacity"] floatValue];
        
        NSArray *fontColors = [[fontProperty objectForKey:@"fontColor"] componentsSeparatedByString:@","];
        if (fontColors!=nil && [fontColors count] == 4) {
            [label setTextColor:[UIColor colorWithRed:[fontColors[0] floatValue]/255 green:[fontColors[1] floatValue]/255 blue:[fontColors[2] floatValue]/255 alpha:[fontColors[3] floatValue]]];
        }else{
            [label setTextColor:[UIColor colorWithRed:0.937 green:0.337 blue:0.157 alpha:0.7]];
        }
        
        NSMutableString *whiteSpace = [NSMutableString new];
        NSInteger count = [[fontProperty objectForKey:@"distance"] integerValue];
        for (int i = 0; i < count; i++) {
            [whiteSpace appendString:@" "];
        }
        
        NSMutableString *dateString = [NSMutableString new];
        if ([[SettingModel sharedInstance] isRandom]) {
            NSString *year = [self getRandomNumber:0 to:99];
            NSString *month = [self getRandomNumber:1 to:12];
            NSString *day = [self getRandomNumber:1 to:31];
            dateString = [[NSMutableString alloc]initWithString:@"'"];
            [dateString appendString:year];
            [dateString appendString:whiteSpace];
            [dateString appendString:month];
            [dateString appendString:whiteSpace];
            [dateString appendString:day];
        }else{
            NSString *dateStr = [[SettingModel sharedInstance] customDate];
            NSDateFormatter *dateFormat = [[NSDateFormatter alloc]init];
            [dateFormat setDateFormat:@"yyyy / MM / dd"];
            NSDate *date = [dateFormat dateFromString:dateStr];
            dateString = [[NSMutableString alloc] initWithString:[self getCurrentTimeWithDate:date andWhiteSpace:whiteSpace]];
        }
        [label setText:dateString];
        [imageView addSubview:label];
        CGSize size = [label.text sizeWithAttributes:@{NSFontAttributeName: font}];
        CGSize adaptionSize = CGSizeMake(ceilf(size.width), ceilf(size.height));
        CGSize gap = CGSizeFromString([fontProperty objectForKey:@"position"]);
        label.frame = CGRectMake(imageView.frame.size.width - adaptionSize.width - gap.width*base, imageView.frame.size.height - gap.height*base, adaptionSize.width, adaptionSize.height);
        UIImage *resultImage = [self convertViewToImage:imageView andScale:image.scale];
        image = resultImage;
    }
    
    BOOL isBonderRotate = NO;
    if(image.size.height > image.size.width){
        image = [image imageRotatedByDegrees:270];
        isBonderRotate = YES;
    }
    UIGraphicsBeginImageContextWithOptions(image.size, NO, image.scale);
    [image drawInRect:CGRectMake(0, 0, image.size.width, image.size.height)];
    NSString *bonderName = [content objectForKey:@"bonder"];
    UIImage *bonderImage = [UIImage imageNamed:bonderName];
    [bonderImage drawInRect:CGRectMake(0, 0, image.size.width, image.size.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    if (isBonderRotate) {
        newImage = [newImage imageRotatedByDegrees:90];
    }
    image = newImage;
    [_imageView setImage:image];
}

-(NSString *)getRandomNumber:(int)from to:(int)to
{
    int randomNum = (int)(from + (arc4random() % (to - from + 1)));
    NSLog(@"随机到的数值：%d",randomNum);
    if (randomNum < 10 && randomNum >= 0) {
        return [NSString stringWithFormat:@"0%d",randomNum];
    }
    return [NSString stringWithFormat:@"%d",randomNum];
}

- (UIImage*)convertViewToImage:(UIImageView *)view andScale:(CGFloat)scale{
    CGSize size = view.bounds.size;
    // 下面方法，第一个参数表示区域大小。第二个参数表示是否是非透明的。如果需要显示半透明效果，需要传NO，否则传YES。第三个参数就是屏幕密度了
    UIGraphicsBeginImageContextWithOptions(size, NO, scale);
    [view.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    UIImage *resultImage = [[UIImage alloc] initWithCGImage:image.CGImage scale:scale orientation:view.image.imageOrientation];
    return resultImage;
}

//获取当地时间
- (NSString *)getCurrentTimeWithDate:(NSDate *)date andWhiteSpace:(NSString *)whiteSpace{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:[NSString stringWithFormat:@"MM%@dd%@yy",whiteSpace,whiteSpace]];
    NSString *dateTime = [formatter stringFromDate:date];
    NSString *result = [NSString stringWithFormat:@"' %@",dateTime];
    return result;
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
