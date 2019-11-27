//
//  PCPhotoCollageViewController.m
//  PhotoCollage
//
//  Created by 杜杜 on 16/4/20.
//  Copyright © 2016年 duruochuan. All rights reserved.
//

#import "PCPhotoCollageViewController.h"
#import "PCImageView.h"
#import "PCImageEditView.h"
#import "GPUImage.h"
#import "DDImage.h"
#import "DDImageMerger.h"
#import "PCFilterView.h"
#import "PCCollectionView.h"
#import "PCCollageItem.h"
#import "FXLabel.h"
#import "PCTextViewController.h"
#import "TKAlertCenter.h"
#import "PCShareViewController.h"
#import "DDPurchase.h"
#import "HCPhotoEditViewController.h"
#import "HCPhotoEditBaseItemView.h"
#define Is_iPhoneX ([UIScreen mainScreen].bounds.size.height == 812 || [UIScreen mainScreen].bounds.size.height == 896)

typedef enum {
    ShowTypeCollage,
    ShowTypeEffect,
    ShowTypeSticker,
    ShowTypeMark,
    ShowTypeNone
}PCScrollViewShowType;

@interface PCPhotoCollageViewController ()<PCImageEditViewDelegate,PCFilterViewDelegate,PCCollectionViewDelegate,PCCollageItemDelegate,PCTextViewControllerDelegate,DDPurchaseDelegate> {
    NSMutableArray *_imageEditViews;
    PCImageEditView *_currentSelectImageEditView;
    
    NSMutableDictionary *_selectImagesInfo;
    UIImage             *_effectOriginImage;
    PCScrollViewShowType  _showType;
    BOOL                  _isScrollViewHidden;
    PCFilterView        *_currentSelectFilterView;
    
    CGFloat _itemWidth;
    NSInteger _itemNumber;
    BOOL      _isTableViewShow;
    BOOL      _currentCollectionNeedPay;
    NSString   *_currentCollectionIdentifier;
    NSInteger _editIndex;
}

@property(nonatomic,strong)NSArray *collages;
@property(nonatomic,strong)NSArray *filters;
@property(nonatomic,strong)NSArray *stickers;
@property(nonatomic,strong)NSArray *marks;

@property(nonatomic,strong)NSArray *stickerFiles;
@property(nonatomic,strong)NSArray *markFiles;

@property(nonatomic,strong)NSMutableArray *collageViews;
@property(nonatomic,strong)PCCollageItem  *currentSelectCollageItem;

@end

@implementation PCPhotoCollageViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationController.navigationBarHidden = YES;
    if (Is_iPhoneX) {
        self.constraint.constant = 77;
    }
    CGFloat screenWidth = [UIScreen mainScreen].bounds.size.width;
    if (self.isPhone) {//间距为5
        _itemWidth = (screenWidth - 80.0f)/3;
        _itemNumber = 3;
    }
    else {
        _itemWidth = (screenWidth - 120.0f)/5;
        _itemNumber = 5;
    }
    
    // Do any additional setup after loading the view.
    _scrollView.backgroundColor = [UIColor colorWithHexString:kNavColor];
    _scrollView.translatesAutoresizingMaskIntoConstraints = YES;
    _scrollView.frame = CGRectMake(0.0f, self.screenSize.height, self.screenSize.width, 80.0f);
    
    self.maskView.hidden = YES;
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(hideScrollView)];
    [self.maskView addGestureRecognizer:tapGesture];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self drawCollage];
    });
    
    //self.effectButton.enabled = NO;
    _showType = ShowTypeNone;
    _isScrollViewHidden = YES;
    
    _isTableViewShow = NO;
    self.tableView.hidden = YES;
    self.tableView.translatesAutoresizingMaskIntoConstraints = YES;
    self.tableView.frame = CGRectMake(0.0, self.screenSize.height, self.screenSize.width, self.screenSize.height - 127.0f);
    self.tableView.backgroundColor = [UIColor colorWithHexString:kBgColor];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    _mainView.clipsToBounds = YES;
    
    //[DDPurchase purchase].delegate = self;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (void)removeAllViewFromScrollView
{
    for (UIView *view in _scrollView.subviews) {
        [view removeFromSuperview];
    }
}

- (void)loadCollageData
{
    [self removeAllViewFromScrollView];
    _collages = [NSArray arrayWithContentsOfFile:[[NSBundle mainBundle]pathForResource:@"stylelist" ofType:@"plist"]];
    for (int index = 0; index < _collages.count; index++) {
        NSDictionary *info = [NSDictionary dictionaryWithContentsOfFile:[[NSBundle mainBundle]pathForResource:[_collages objectAtIndex:index] ofType:nil]];
        PCImageView *imageView = [[PCImageView alloc]initWithFrame:CGRectMake(10 + index * 70.0f, 10.0f, 60.0f, 60.0f) collageInfo:info];
        imageView.tag = index;
        [imageView addTarget:self action:@selector(collageChangeAction:) forControlEvents:UIControlEventTouchUpInside];
        [_scrollView addSubview:imageView];
    }
    _scrollView.contentSize = CGSizeMake(10 + _collages.count * 70.0f, 80.0f);
}

- (void)loadStickerData
{
    [self loadFile:@"stickers"];
}

- (void)loadMarkData
{
    [self loadFile:@"marks"];
}

- (void)loadFile:(NSString *)fileName
{
    [self removeAllViewFromScrollView];
    NSArray *items = [NSArray arrayWithContentsOfFile:[[NSBundle mainBundle]pathForResource:fileName ofType:@"plist"]];
    if ([fileName isEqualToString:@"stickers"]) {
        _stickers = items;
    }
    else if ([fileName isEqualToString:@"marks"]) {
        _marks = items;
    }
    NSInteger index = 0;
    for (NSDictionary *info in items) {
        PCCollectionView *view = [PCCollectionView collectionViewWithStartPoint:CGPointMake(10 + index * 100.0f, 10.0f)];
        view.coverFileName = [info valueForKey:@"cover"];
        view.needPurchase = [[info valueForKey:@"purchase"]boolValue];
        view.iapIdentifier = [info valueForKey:@"iap_identifier"];
        view.files = [info valueForKey:@"files"];
        view.tag = index;
        view.delegate = self;
        [_scrollView addSubview:view];
        index++;
    }
    _scrollView.contentSize = CGSizeMake(10 + items.count * 100.0f, 80.0f);
}

- (void)loadFilterData
{
    if (!_currentSelectImageEditView.image) {
        return;
    }
    UIImage *image = [DDImage scaleThumbnailWithImage:_currentSelectImageEditView.image outputSize:CGSizeMake(100.0f, 100.0f)];
    GPUImagePicture *picture = [[GPUImagePicture alloc]initWithImage:image];
    
    [self removeAllViewFromScrollView];
    _filters = [NSArray arrayWithContentsOfFile:[[NSBundle mainBundle]pathForResource:@"filter" ofType:@"plist"]];
    for (int index = 0; index < _filters.count; index++) {
        [picture removeAllTargets];
        
        NSDictionary *info = [_filters objectAtIndex:index];
        NSData *data = [NSData dataWithContentsOfFile:[[NSBundle mainBundle]pathForResource:[info valueForKey:@"file"] ofType:nil]];
        GPUImageToneCurveFilter *filter = [[GPUImageToneCurveFilter alloc]initWithACVData:data];
        
        PCFilterView *filterView = [[PCFilterView alloc]initWithFrame:CGRectMake(10 + index * 70.0f, 10.0f, 60.0f, 60.0f)];
        filterView.delegate = self;
        filterView.tag = index;
        [picture addTarget:filter];
        [filter addTarget:filterView.imageView];
        [picture processImage];
        filterView.filterName = [info valueForKey:@"name"];
        
        [_scrollView addSubview:filterView];
    }
    _scrollView.contentSize = CGSizeMake(10 + _filters.count * 70.0f, 80.0f);
}

- (void)hideScrollView
{
    self.maskView.hidden = YES;
    [UIView animateWithDuration:0.2f animations:^{
        _isScrollViewHidden = YES;
        _scrollView.frame = CGRectMake(0.0f, self.screenSize.height, self.screenSize.width, 80.0f);
    }];
}

- (void)showScrollView
{
    self.maskView.hidden = NO;
    _scrollView.contentOffset = CGPointZero;
    [UIView animateWithDuration:0.3f animations:^{
        _isScrollViewHidden = NO;
        _scrollView.frame = CGRectMake(0.0f, self.screenSize.height - 80.0f, self.screenSize.width, 80.0f);
    }];
}

- (void)drawCollage
{
    for (UIView *view in self.mainView.subviews) {
        [view removeFromSuperview];
    }
    if (!_imageEditViews) {
        _imageEditViews = [NSMutableArray array];
    }
    [_imageEditViews removeAllObjects];
    
    NSDictionary *collageInfo = [AppManager sharedManager].collageInfo;
    
    CGSize contentSize = CGSizeFromString([collageInfo valueForKey:@"contentSize"]);
    CGFloat xScale = self.mainView.frame.size.width/contentSize.width;
    CGFloat yScale = self.mainView.frame.size.height/contentSize.height;
    
    NSArray *views = [collageInfo objectForKey:@"views"];
    for (int index = 0; index < views.count; index++) {
        NSArray *points = nil;
        if (index >= views.count) {
            points = [views objectAtIndex:0];
        }
        else {
            points = [views objectAtIndex:index];
        }
        CGPoint minPoint = CGPointMake(99999, 99999);
        CGPoint maxPoint = CGPointZero;
        
        UIBezierPath *path = [UIBezierPath bezierPath];
        for (int i = 0; i < points.count; i++) {
            NSDictionary *pInfo = [points objectAtIndex:i];
            NSString *pointStr = [pInfo valueForKey:@"point"];
            CGPoint point = CGPointFromString(pointStr);
            point = [self scalePoint:CGPointMake(point.x * xScale, point.y * yScale)];
            if (point.x < minPoint.x) {
                minPoint.x = point.x;
            }
            if (point.y < minPoint.y) {
                minPoint.y = point.y;
            }
            if (point.x > maxPoint.x) {
                maxPoint.x = point.x;
            }
            if (point.y > maxPoint.y) {
                maxPoint.y = point.y;
            }
        }
        
        for (int i = 0; i < points.count; i++) {
            NSDictionary *pInfo = [points objectAtIndex:i];
            NSString *pointStr = [pInfo valueForKey:@"point"];
            NSString *control1Str = [pInfo valueForKey:@"control1"];
            NSString *control2Str = [pInfo valueForKey:@"control2"];
            CGPoint point = CGPointFromString(pointStr);
            point = [self scalePoint:CGPointMake(point.x * xScale, point.y * yScale)];
            point = CGPointMake(point.x - minPoint.x, point.y - minPoint.y);
            
            if (0 == i) {
                [path moveToPoint:point];
            }
            else {
                if (control1Str) {
                    CGPoint control1 = CGPointFromString(control1Str);
                    [path addQuadCurveToPoint:point controlPoint:[self scalePoint:CGPointMake(control1.x * xScale, control1.y * yScale)]];
                }
                else if (control2Str) {
                    CGPoint control1 = CGPointFromString(control1Str);
                    CGPoint control2 = CGPointFromString(control2Str);
                    [path addCurveToPoint:point controlPoint1:[self scalePoint:CGPointMake(control1.x * xScale, control1.y * yScale)] controlPoint2:[self scalePoint:CGPointMake(control2.x * xScale, control2.y * yScale)]];
                }
                else {
                    [path addLineToPoint:point];
                }
            }
        }
        //画完一个视图 frame为矩形的位置 path为遮罩的区域
        [path closePath];
        CGRect frame = CGRectMake(minPoint.x, minPoint.y, maxPoint.x - minPoint.x, maxPoint.y - minPoint.y);
        PCImageEditView *editView = [[PCImageEditView alloc]initWithFrame:frame];
        editView.delegate = self;
        editView.maskPath = path;
        editView.tag = index;
        UIImage *image = [_selectImagesInfo valueForKey:[NSString stringWithFormat:@"%d",index]];
        if (image) {
            editView.filterImage = image;
        }
        else if ([AppManager sharedManager].selectImages.count > index) {
            editView.image = [[AppManager sharedManager].selectImages objectAtIndex:index];
        }
        
        [self.mainView addSubview:editView];
    }
}

- (CGPoint)scalePoint:(CGPoint)pt
{
    CGFloat width = self.mainView.frame.size.width * 0.05f;
    return CGPointMake(pt.x * 0.95 + width/2, pt.y * 0.95 + width/2);
}

#pragma mark - PCImageEditViewDelegate
- (void)imageEditViewDidSelectedChange:(PCImageEditView *)imageEditView
{
//    if (imageEditView.selected) {
//        if (_currentSelectImageEditView != imageEditView) {
//            _currentSelectImageEditView.selected = NO;
//        }
//        _currentSelectImageEditView = imageEditView;
//
//        _effectButton.enabled = YES;
//
//        if (_showType != ShowTypeEffect || _isScrollViewHidden) {
//            _currentSelectCollageItem.selected = NO;
//            [self effectAction:nil];
//        }
//        _effectButton.enabled = YES;
//    }
//    else {
//        _currentSelectImageEditView = nil;
//        _effectButton.enabled = NO;
//    }
    
    UIImage *img = imageEditView.image;
    _editIndex = [[AppManager sharedManager].selectImages indexOfObject:img];
    [self beginEdit:img];
}

- (void)imageEditViewDidImageChange:(PCImageEditView *)imageEditView
{
    if (!_selectImagesInfo) {
        _selectImagesInfo = [NSMutableDictionary dictionary];
    }
    [_selectImagesInfo setObject:imageEditView.image forKey:[NSString stringWithFormat:@"%ld",(long)imageEditView.tag]];
}

#pragma mark - IBAction
- (IBAction)cancelAction:(id)sender
{
    if (_isTableViewShow) {
        [self hiddenTableView];
        return;
    }
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];
}

- (IBAction)resetAction:(id)sender
{
    [_selectImagesInfo removeAllObjects];
    [self drawCollage];
}

- (IBAction)doneAction:(id)sender
{
    if (_isTableViewShow) {
        [self hiddenTableView];
        return;
    }
    //
//    [DDWaitingView sharedView].text = @"Saving...";
    //[[DDWaitingView sharedView]startAnimation];
    
    _currentSelectCollageItem.selected = NO;
    _currentSelectImageEditView.selected = NO;
    UIImage *image = [DDImageMerger imageFromView2:_mainView];
    //to share view controlelr
    PCShareViewController *viewController = [[PCShareViewController alloc]init];
    viewController.image = image;
    [self presentViewController:viewController animated:YES completion:^{
        //[[DDWaitingView sharedView]stopAnimation];
    }];
//    UIImageWriteToSavedPhotosAlbum(image, self, @selector(image:didFinishSavingWithError:contextInfo:), nil);
}

- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo
{
    //[[DDWaitingView sharedView]stopAnimation];
    if (error) {
        [[TKAlertCenter defaultCenter]postAlertWithMessage:@"Save fail,Please try again!"];
    }
    else {
        [[TKAlertCenter defaultCenter]postAlertWithMessage:@"Save successfully!"];
        //to share view controller
    }
}

- (IBAction)shareAction:(id)sender
{
    
}

- (IBAction)collageAction:(id)sender
{
    CGFloat delay = 0.0f;
    if (_showType != ShowTypeCollage && _showType != ShowTypeNone) {
        [self hideScrollView];
        delay = 0.25;
    }
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delay * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self loadCollageData];
        [self showScrollView];
        
        _showType = ShowTypeCollage;
    });
}

- (IBAction)effectAction:(id)sender
{
    CGFloat delay = 0.0f;
    if (_showType != ShowTypeEffect && _showType != ShowTypeNone) {
        [self hideScrollView];
        delay = 0.25;
    }
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self loadFilterData];
        _currentSelectFilterView = nil;
        [self showScrollView];
        
        _showType = ShowTypeEffect;
    });
}

- (IBAction)stickerAction:(id)sender
{
    CGFloat delay = 0.0f;
    if (_showType != ShowTypeSticker && _showType != ShowTypeNone) {
        [self hideScrollView];
        delay = 0.25;
    }
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self loadStickerData];
        [self showScrollView];
        
        _showType = ShowTypeSticker;
    });
}


- (IBAction)markAction:(id)sender
{
    CGFloat delay = 0.0f;
    if (_showType != ShowTypeMark && _showType != ShowTypeNone) {
        [self hideScrollView];
        delay = 0.25;
    }
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self loadMarkData];
        [self showScrollView];
        
        _showType = ShowTypeMark;
    });
}


- (IBAction)textAction:(id)sender
{
    PCTextViewController *viewController = [[PCTextViewController alloc]init];
    viewController.delegate = self;
    [viewController show];
}

- (void)collageChangeAction:(PCImageView *)imageView
{
    [AppManager sharedManager].collageInfo = imageView.collageInfo;
    [self drawCollage];
}

#pragma mark - PCFilterViewDelegate
- (void)filterViewDidSelectedStatusChange:(PCFilterView *)filterView
{
    if (!_currentSelectImageEditView.image) {
        return;
    }
    if (!_selectImagesInfo) {
        _selectImagesInfo = [NSMutableDictionary dictionary];
    }
    if (filterView != _currentSelectFilterView) {
        _currentSelectFilterView.selected = NO;
        _currentSelectFilterView = filterView;
        
        NSDictionary *info = [_filters objectAtIndex:filterView.tag];
        NSData *data = [NSData dataWithContentsOfFile:[[NSBundle mainBundle]pathForResource:[info valueForKey:@"file"] ofType:nil]];
        GPUImageToneCurveFilter *filter = [[GPUImageToneCurveFilter alloc]initWithACVData:data];
        
        GPUImagePicture *picture = [[GPUImagePicture alloc]initWithImage:_currentSelectImageEditView.image];
        [picture addTarget:filter];
        [filter useNextFrameForImageCapture];
        [picture processImage];
        UIImage *resultImage = [filter imageFromCurrentFramebuffer];
        _currentSelectImageEditView.filterImage = resultImage;
        [_selectImagesInfo setValue:resultImage forKey:[NSString stringWithFormat:@"%ld",(long)_currentSelectImageEditView.tag]];
    }
}

#pragma mark - PCCollectionViewDelegate
- (void)collectionViewDidTapAction:(PCCollectionView *)collectionView
{
    _currentCollectionNeedPay = collectionView.needPurchase;
    _currentCollectionIdentifier = collectionView.iapIdentifier;
    
    
    if (_showType == ShowTypeSticker) {
        _stickerFiles = collectionView.files;
    }
    else if (_showType == ShowTypeMark) {
        _markFiles = collectionView.files;
    }
    [self.tableView reloadData];
    if (!_isTableViewShow) {
        [self showTableView];
    }
    else {
        [self.tableView setContentOffset:CGPointZero animated:YES];
    }
}

- (void)showTableView
{
    self.tableView.contentOffset = CGPointZero;
    self.resetButton.enabled = NO;
    self.tableView.hidden = NO;
    [UIView animateWithDuration:0.4f animations:^{
        self.tableView.frame = CGRectMake(0.0, 47.0f, self.screenSize.width, self.screenSize.height - 127.0f);
    } completion:^(BOOL finished) {
        _isTableViewShow = YES;
    }];
}

- (void)hiddenTableView
{
    self.resetButton.enabled = YES;
    [UIView animateWithDuration:0.3f animations:^{
        self.tableView.frame = CGRectMake(0.0f, self.screenSize.height, self.screenSize.width, self.screenSize.height - 127.0f);
    } completion:^(BOOL finished) {
        _isTableViewShow = NO;
    }];
}

#pragma mark - UITableViewDelegate


#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSArray *files = _markFiles;
    if (_showType == ShowTypeSticker) {
        files = _stickerFiles;
    }
    NSInteger filesCount = files.count;
    return filesCount/_itemNumber + (filesCount%_itemNumber==0?0:1);
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSArray *files = _markFiles;
    if (_showType == ShowTypeSticker) {
        files = _stickerFiles;
    }
    
    static NSString *identifier = @"cell.sticker.mark.identifier";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (!cell) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
        cell.backgroundColor = [UIColor clearColor];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    for (UIView *view in cell.subviews) {
        if ([view isKindOfClass:[UIImageView class]]) {
            [view removeFromSuperview];
        }
    }
    
    for (int index = 0; index < _itemNumber; index++) {
        if (indexPath.row * _itemNumber + index >= files.count) {
            break;
        }
        UIImageView *imageView = [[UIImageView alloc]initWithFrame:CGRectMake(20.0 + (_itemWidth + 20.0) * index, 20.0f, _itemWidth, _itemWidth)];
        imageView.tag = indexPath.row * _itemNumber + index;
        imageView.contentMode = UIViewContentModeScaleAspectFit;
        imageView.clipsToBounds = YES;
        imageView.image = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle]pathForResource:[files objectAtIndex:imageView.tag] ofType:nil]];
        imageView.userInteractionEnabled = YES;
        
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(imageViewTapAction:)];
        [imageView addGestureRecognizer:tapGesture];
        
        [cell addSubview:imageView];
    }
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return _itemWidth + 20.0f;
}

- (void)imageViewTapAction:(UITapGestureRecognizer *)tapGesture
{
    if (_currentCollectionNeedPay) {
        BOOL professional = [[DDPurchase purchase]isProductPurchased:kProfessionalIdentifier];
        if (!professional) {//没有购买专业版本
            BOOL isPayed = [[DDPurchase purchase]isProductPurchased:_currentCollectionIdentifier];
            if (!isPayed) {//没有购买
                //[[DDWaitingView sharedView]setText:@"Waiting..."];
                //[[DDWaitingView sharedView]startAnimation];
                [[DDPurchase purchase]validateProductIdentifiers:@[_currentCollectionIdentifier]];
                return;
            }
        }
    }
    [self hiddenTableView];
    
    if (!_collageViews) {
        _collageViews = [NSMutableArray array];
    }
    
    UIImageView *imageView = (UIImageView *)tapGesture.view;
    PCCollageItem *item = [[PCCollageItem alloc]initWithFrame:CGRectMake(0, 0, imageView.image.size.width, imageView.image.size.height)];
    item.delegate = self;
    [item addImageViewWithImage:imageView.image];
    item.center = CGPointMake(_mainView.frame.size.width/2, _mainView.frame.size.height/2);
    [_mainView addSubview:item];
    
    [_collageViews addObject:item];
    _currentSelectCollageItem.selected = NO;
    _currentSelectCollageItem = item;
    
    [self hideScrollView];
}

#pragma mark - PCCollageItemDelegate
- (void)collageItemDidTapAction:(PCCollageItem *)item
{
    _currentSelectCollageItem.selected = NO;
    if (item.selected) {
        _currentSelectCollageItem = item;
    }
    else {
        _currentSelectCollageItem = nil;
    }
}

- (void)collageItemDidDeleteAction:(PCCollageItem *)item
{
    [item removeFromSuperview];
    if ([_collageViews containsObject:item]) {
        [_collageViews removeObject:item];
    }
}

#pragma mark - PCTextViewController
- (void)textViewControllerDidDoneAction:(PCTextViewController *)viewController
{
    NSString *text = viewController.label.text;
    CGSize size = CGSizeZero;
    
    UITextView *textView = [[UITextView alloc]initWithFrame:CGRectMake(0, 0, 150, 0)];
    
    UILabel *label = nil;
    if (!viewController.fxLabel.hidden) {
        textView.font = [UIFont systemFontOfSize:26.0f];
        textView.text = text;
        size = [textView sizeThatFits:CGSizeMake(150,CGFLOAT_MAX)];
        if (size.width < 150) {
            size.width = 150;
        }
        if (size.height < 100) {
            size.height = 100;
        }
        
        FXLabel *l = [[FXLabel alloc]initWithFrame:CGRectMake(10.0f, 0.0f, size.width + 10, size.height)];
        l.font = textView.font;
        l.textAlignment = NSTextAlignmentCenter;
        l.text = text;
        l.numberOfLines = 8;
        l.shadowBlur = viewController.fxLabel.shadowBlur;
        l.shadowOffset = viewController.fxLabel.shadowOffset;
        l.shadowColor = viewController.fxLabel.shadowColor;
        l.innerShadowBlur = viewController.fxLabel.innerShadowBlur;
        l.innerShadowOffset = viewController.fxLabel.innerShadowOffset;
        l.innerShadowColor = viewController.fxLabel.innerShadowColor;
        l.gradientStartColor = viewController.fxLabel.gradientStartColor;
        l.gradientEndColor = viewController.fxLabel.gradientEndColor;
        l.gradientColors = viewController.fxLabel.gradientColors;
        l.gradientStartPoint = viewController.fxLabel.gradientStartPoint;
        l.gradientEndPoint = viewController.fxLabel.gradientEndPoint;
        l.oversampling = viewController.fxLabel.oversampling;
        l.lineSpacing = viewController.fxLabel.lineSpacing;
        l.characterSpacing = viewController.fxLabel.characterSpacing;
        l.baselineOffset = viewController.fxLabel.baselineOffset;
        l.allowOrphans = viewController.fxLabel.allowOrphans;
        l.backgroundColor = [UIColor clearColor];
        
        label = l;
    }
    else {
        textView.font = [UIFont fontWithName:viewController.label.font.fontName size:26.0f];
        textView.text = text;
        size = [textView sizeThatFits:CGSizeMake(150,CGFLOAT_MAX)];
        if (size.width < 150) {
            size.width = 150;
        }
        if (size.height < 100) {
            size.height = 100;
        }
        
        label = [[UILabel alloc]initWithFrame:CGRectMake(10.0, 0.0, size.width + 10, size.height)];
        label.numberOfLines = 8;
        label.text = text;
        label.font = [UIFont fontWithName:viewController.label.font.fontName size:22.0f];
        label.textColor = viewController.label.textColor;
    }
    
    label.textAlignment = NSTextAlignmentCenter;
    
    PCCollageItem *item = [[PCCollageItem alloc]initWithFrame:CGRectMake(0, 0, size.width + 40.0f, size.height + 30)];
    item.delegate = self;
    [item addLabel:label];
    item.center = CGPointMake(_mainView.frame.size.width/2, _mainView.frame.size.height/2);
    [_mainView addSubview:item];

    [_collageViews addObject:item];
    _currentSelectCollageItem.selected = NO;
    _currentSelectCollageItem = item;
}

#pragma mark - DDPurchaseDelegate
- (void)purchaseDidFail:(DDPurchase *)purchase
{
    //[[DDWaitingView sharedView]stopAnimation];
    [[TKAlertCenter defaultCenter]postAlertWithMessage:@"Purchase failed!"];
}

- (void)purchaseDidSuccess:(DDPurchase *)purchase
{
    //[[DDWaitingView sharedView]stopAnimation];
    [[TKAlertCenter defaultCenter]postAlertWithMessage:@"Purchase successfully!"];
}

- (void)purchaseDidGetProductInfo:(DDPurchase *)purchase
{
    if (purchase.products.count > 0) {
        SKProduct *product = [purchase.products objectAtIndex:0];
        [[DDPurchase purchase]payForProduct:product];
    }
    else {
        [self purchaseDidFail:purchase];
    }
}

-(void)beginEdit:(UIImage*)img
{
    HCPhotoEditViewController *editController = [[HCPhotoEditViewController alloc] init];
    editController.fromPuzzle = YES;
    editController.oriImage = img;
    editController.delegate = self;
    [self.navigationController pushViewController:editController animated:YES];
}


#pragma mark HCPhotoEditViewControllerDelegate

-(void)didClickFinishButtonWithEditController:(HCPhotoEditViewController *)controller newImage:(UIImage *)newImage
{
    NSMutableArray *ma = [NSMutableArray arrayWithArray:[AppManager sharedManager].selectImages];
    [ma replaceObjectAtIndex:_editIndex withObject:newImage];
    [AppManager sharedManager].selectImages = ma;
    [self drawCollage];
    [controller.navigationController popViewControllerAnimated:YES];
}

-(void)didClickCancelButtonWithEditController:(HCPhotoEditViewController *)controller
{
    [controller.navigationController popViewControllerAnimated:YES];
}
@end
