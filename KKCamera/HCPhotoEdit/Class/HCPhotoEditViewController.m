//
//  CHPhotoEditViewController.m
//  GPUImageDemo
//
//  Created by chenhao on 16/12/6.
//  Copyright © 2016年 chenhao. All rights reserved.
//  


#import "HCPhotoEditViewController.h"
#import "HCPhotoEditCustomButton.h"
#import "HCPhotoEditColorFilterItemView.h"
#import "HCPhotoEditFuzzyItemView.h"
#import "HCPhotoEditBaseImageView.h"
#import "HCPhotoEditCutItemView.h"
#import "HCPhotoEditRotateItemView.h"
#import "HCPhotoEditLightItemView.h"
#import "HCPhotoEditFrameItemView.h"
#import "HCPhotoEditAdjustItemView.h"
#import "HCPhotoEditSpecialEffectsItemView.h"

#import "GPUImage.h"

#import "PhotoEditHaloItemView.h"
#import "PhotoEditFrameItemView.h"
#import "PhotoEditStickerItemView.h"
#import "PhotoEditAcvItemView.h"
#import "PCTextViewController.h"
#import "ProManager.h"
#import "AssetBuffer.h"
#import "StickerView.h"
#import "PCCollageItem.h"

//******************************************
//******************************************
@interface HCPhotoEditViewController ()<PCTextViewControllerDelegate, PCCollageItemDelegate>

@end

@implementation HCPhotoEditViewController
{
    UIView        *topView;
    UIScrollView  *bottomScrollView;
    HCPhotoEditBaseImageView   *mainImageView;
    NSMutableArray  *colorFilterIcons;
    NSMutableArray  *effectFilterIcons;
    NSMutableArray  *textViews;
}

- (void)viewDidLoad
{
    
    [super viewDidLoad];
    
    self.view.backgroundColor = COLOR_RGB(32, 32, 32);
    [self topView];
    [self mainImageView];
    [self bottomScrollView];
    [self loadIconImages];
    
    [self loadBuffer];
    
    [self mainImageView].tapGestureBlock = ^(CGPoint pt) {
        [StickerView setActiveStickerView:nil];
        
    };
}

-(void)loadIconImages
{
    
    NSArray *filters = @[@"FWHudsonFilter",@"FWBrannanFilter",@"FWEarlybirdFilter",@"FWHefeFilter",@"FWSutroFilter",@"FWLomofiFilter",@"FWLordKelvinFilter",@"FWNashvilleFilter",@"FWRiseFilter",@"FWSierraFilter",@"FWAmaroFilter",@"FWToasterFilter",@"FWValenciaFilter",@"FWWaldenFilter",@"FWXproIIFilter",@"FW1977Filter",@"FWInkwellFilter"];
    NSArray *filters2 = @[@"GPUImageKuwaharaFilter",@"GPUImageSketchFilter",@"GPUImageSmoothToonFilter",@"GPUImageGlassSphereFilter",@"GPUImageEmbossFilter",@"GPUImageSwirlFilter"];
    effectFilterIcons = [NSMutableArray array];
    colorFilterIcons = [NSMutableArray array];
    textViews = [NSMutableArray array];
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        
        UIGraphicsBeginImageContext(CGSizeMake(142, 142));
        [self.oriImage drawInRect:[self configRect:CGSizeMake(142, 142)]];
        UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        for (int index = 0; index < filters.count; index++)
        {
            GPUImagePicture *pic = [[GPUImagePicture alloc] initWithImage:image];
            GPUImageFilter *outFilter = [[[NSClassFromString(filters[index]) class] alloc] init];
            [pic addTarget:outFilter];
            [outFilter useNextFrameForImageCapture];
            [pic processImage];
            UIImage *image2 = [outFilter imageFromCurrentFramebuffer];
            [colorFilterIcons addObject:image2];
        }
        
        for (int index = 0; index < filters2.count; index++)
        {
            GPUImagePicture *pic = [[GPUImagePicture alloc] initWithImage:image];
            GPUImageFilter *outFilter = [[[NSClassFromString(filters2[index]) class] alloc] init];
            [pic addTarget:outFilter];
            if ([outFilter isKindOfClass:[GPUImageKuwaharaFilter class]]) {
                //水彩画滤镜
                GPUImageKuwaharaFilter *f = (GPUImageKuwaharaFilter*)outFilter;
                f.radius = 8;
            }
            [outFilter useNextFrameForImageCapture];
            [pic processImage];
            UIImage *image2 = [outFilter imageFromCurrentFramebuffer];
            [effectFilterIcons addObject:image2];
        }
        
    });
}

-(UIView*)topView
{
    if (!topView)
    {
        CGFloat offset = 0;
        UIView *view = nil;
        if (Is_iPhoneX) {
            view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 80)];
            offset = 15;
        }
        else
        {
            view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 45)];
        }
        view.backgroundColor = COLOR_RGB(25, 25, 25);
        [self.view addSubview:view];
        topView = view;
        
        UIButton *cancelBtn = [UIButton buttonWithType:UIButtonTypeSystem];
        [cancelBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        cancelBtn.titleLabel.font = [UIFont systemFontOfSize:15];
        cancelBtn.titleLabel.textAlignment = NSTextAlignmentCenter;
        cancelBtn.frame = CGRectMake(10, (view.frame.size.height-40)/2+offset, 40, 40);
        cancelBtn.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin;
        [cancelBtn setImage:[[UIImage imageNamed:@"cancel_back.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] forState:UIControlStateNormal];
        //[cancelBtn setTitle:@"返回" forState:UIControlStateNormal];
        [cancelBtn addTarget:self action:@selector(back) forControlEvents:UIControlEventTouchUpInside];
        [view addSubview:cancelBtn];
        
        
        UIButton *finishBtn = [UIButton buttonWithType:UIButtonTypeSystem];
        [finishBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        finishBtn.titleLabel.font = [UIFont systemFontOfSize:15];
        finishBtn.titleLabel.textAlignment = NSTextAlignmentCenter;
        finishBtn.frame = CGRectMake(self.view.bounds.size.width - 50, (view.frame.size.height-40)/2+offset, 40, 40);
        finishBtn.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin;
        if (self.fromPuzzle) {
            [finishBtn setTitle:@"Complete" forState:UIControlStateNormal];
        }
        else
        {
            [finishBtn setImage:[[UIImage imageNamed:@"save_share"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] forState:UIControlStateNormal];
        }
        //
        [finishBtn addTarget:self action:@selector(finish) forControlEvents:UIControlEventTouchUpInside];
        [view addSubview:finishBtn];
        self.shareBtn = finishBtn;
        
        UILabel  *title = [[UILabel alloc] initWithFrame:CGRectMake((self.view.bounds.size.width-50)/2, (view.frame.size.height-40)/2+offset, 50, 40)];
        //title.center = view.center;
        title.font = [UIFont boldSystemFontOfSize:17];
        title.textColor = [UIColor whiteColor];
        title.textAlignment = NSTextAlignmentCenter;
        title.text = @"";
        [view addSubview:title];
    }
    
    return topView;
}

-(UIView*)bottomScrollView
{
    if (!bottomScrollView)
    {
        CGFloat offset = 0;
        if (Is_iPhoneX) {
            offset = 10;
        }
        
        UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, self.view.bounds.size.height - 100 - offset, self.view.bounds.size.width, 100 + offset)];
        //scrollView
        scrollView.backgroundColor = COLOR_RGB(25, 25, 25);
        scrollView.showsHorizontalScrollIndicator = NO;
        [self.view addSubview:scrollView];
        bottomScrollView = scrollView;
        
        NSArray *titles = @[@"LAYOUT",@"ADJUST",@"LIGHT",@"FILTER",@"STICKER",@"ARTWORK",@"TEXT",@"FOCUS",@"ROTATE"];
        NSArray *images = @[@"size",@"adjust",@"light",
                            @"filter",@"sticker",
                            @"frame",@"text",
                            @"focus",@"rotate"];
        
        float width = 85;
        CGFloat btn_offset = 0;
        
        if (titles.count * width < scrollView.frame.size.width)
        {
            btn_offset = (scrollView.frame.size.width - titles.count * width) / 2;
        }
        for (int index = 0; index < titles.count; index++)
        {
            NSString *name = images[index];
            NSString *name2 = [name stringByAppendingString:@"_h"];
            HCPhotoEditCustomButton *btn = [[HCPhotoEditCustomButton alloc] initWithImage:IMAGE_WITHNAME(name) highlightedImage:IMAGE_WITHNAME(name2) title:titles[index] font:8 imageSize:0];
            btn.tag = index;
            //btn.backgroundColor = COLOR_RGB(35, 35, 35);
            [btn addTarget:self action:@selector(editButtonClick:) forControlEvents:UIControlEventTouchUpInside];
            btn.frame = CGRectMake(index * width + btn_offset, 0, width - 1, scrollView.bounds.size.height - offset);
            [scrollView addSubview:btn];
            scrollView.contentSize = CGSizeMake(CGRectGetMaxX(btn.frame), 0);
        }
    }
    
    return bottomScrollView;
}

-(HCPhotoEditBaseImageView*)mainImageView
{
    if (!mainImageView)
    {
        HCPhotoEditBaseImageView *imageView = [[HCPhotoEditBaseImageView alloc] initWithFrame:CGRectMake(10, [self topView].bounds.size.height + 10, self.view.bounds.size.width - 20, self.view.bounds.size.height - [self bottomScrollView].bounds.size.height - [self topView].bounds.size.height - 20)];
        imageView.clipsToBounds = YES;
        imageView.contentMode = UIViewContentModeScaleAspectFit;
        imageView.image = self.oriImage;
        [self.view addSubview:imageView];
        mainImageView = imageView;
    }
    return mainImageView;
}

#pragma mark editButton action
-(void)editButtonClick:(UIButton*)btn
{
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.02 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        
        [self hideTopView];
        
        switch (btn.tag)
        {
                
            case 0:
            {
                [self chooseCut];
            }
                break;
            case 1:
            {
                [self chooseAdjust];
            }
                break;
            case 2:
            {
                [self chooseLight];
            }
                break;
            case 3:
            {
                [self chooseAcv];
            }
                break;
            case 4:
            {
                [self chooseSticker];
            }
                break;
            case 5:
            {
                [self chooseBorder];
            }
                break;
            case 6:
            {
                [self chooseText];
            }
                break;
            case 7:
            {
                [self chooseFuzzy];
            }
                break;
            case 8:
            {
                [self chooseRotate];
            }
                break;
            default:
                break;
        }

    });
}


#pragma mark ITEM
//滤镜
-(void)chooseColorFilter
{
    if (colorFilterIcons.count == 0) {
        return;
    }
    HCPhotoEditBaseItemView *view = [HCPhotoEditColorFilterItemView showInView:self.view icons:colorFilterIcons];
    view.mainImageView = mainImageView;
    view.oriImage = mainImageView.image;
    [view setOkBlock:^{
        [self restoreMainView];
    }];
    [view setCancelBlock:^{
        [self restoreMainView];
    }];
    [view setSelectItemBlock:^(NSInteger index) {
        
    }];
}

//特效
-(void)chooseEffect
{
    if (effectFilterIcons.count == 0) {
        return;
    }
    HCPhotoEditBaseItemView *view = [HCPhotoEditSpecialEffectsItemView showInView:self.view icons:effectFilterIcons];
    view.mainImageView = mainImageView;
    view.oriImage = mainImageView.image;
    [view setOkBlock:^{
        [self restoreMainView];
    }];
    [view setCancelBlock:^{
        [self restoreMainView];
    }];
    [view setSelectItemBlock:^(NSInteger index) {
        
    }];
}

//虚化
-(void)chooseFuzzy
{
    HCPhotoEditBaseItemView *view = [HCPhotoEditFuzzyItemView showInView:self.view];
    view.mainImageView = mainImageView;
    view.oriImage = mainImageView.image;
    [view setOkBlock:^{
        [self restoreMainView];
    }];
    [view setCancelBlock:^{
        [self restoreMainView];
    }];
}

//裁剪
-(void)chooseCut
{
    HCPhotoEditBaseItemView *view = [HCPhotoEditCutItemView showInView:self.view];
    view.mainImageView = mainImageView;
    [view setOkBlock:^{
        [self restoreMainView];
    }];
    [view setCancelBlock:^{
        [self restoreMainView];
    }];
    [view setSelectItemBlock:^(NSInteger index) {
        
    }];
}

//旋转
-(void)chooseRotate
{
    HCPhotoEditBaseItemView *view = [HCPhotoEditRotateItemView showInView:self.view];
    view.mainImageView = mainImageView;
    [view setOkBlock:^{
        [self restoreMainView];
    }];
    [view setCancelBlock:^{
        [self restoreMainView];
    }];
    [view setSelectItemBlock:^(NSInteger index) {
        
    }];
}

//光影
-(void)chooseLight
{
//    HCPhotoEditBaseItemView *view = [HCPhotoEditLightItemView showInView:self.view];
    PhotoEditHaloItemView *view = [PhotoEditHaloItemView showInView:self.view];
    view.parentController = self;
    view.scrollView.parentController = self;
    view.mainImageView = mainImageView;
    [view setOkBlock:^{
        [self restoreMainView];
    }];
    [view setCancelBlock:^{
        [self restoreMainView];
    }];
    [view setSelectItemBlock:^(NSInteger index) {
        
    }];
    
    if (![ProManager isProductPaid:kProDeluxeId]) {
        [view.scrollView purchase];
    }
}

//边框
-(void)chooseBorder
{
    PhotoEditFrameItemView *view = [PhotoEditFrameItemView showInView:self.view];
    view.parentController = self;
    view.scrollView.parentController = self;
    view.mainImageView = mainImageView;
    [view setOkBlock:^{
        [self restoreMainView];
    }];
    [view setCancelBlock:^{
        [self restoreMainView];
    }];
    [view setSelectItemBlock:^(NSInteger index) {
        
    }];
    
    if (![ProManager isProductPaid:kProDeluxeId]) {
        [view.scrollView purchase];
    }
}

//调整
-(void)chooseAdjust
{
    HCPhotoEditBaseItemView *view = [HCPhotoEditAdjustItemView showInView:self.view];
    view.mainImageView = mainImageView;
    [view setOkBlock:^{
        [self restoreMainView];
        
    }];
    [view setCancelBlock:^{
        [self restoreMainView];
    }];
    [view setSelectItemBlock:^(NSInteger index) {
        
    }];
}

//贴纸
-(void)chooseSticker
{
    PhotoEditStickerItemView *view = [PhotoEditStickerItemView showInView:self.view];
    view.parentController = self;
    view.scrollView.parentController = self;
    view.mainImageView = mainImageView;
    [view setOkBlock:^{
        [self restoreMainView];
    }];
    [view setCancelBlock:^{
        [self restoreMainView];
    }];
    [view setSelectItemBlock:^(NSInteger index) {
        
    }];
    
    if (![ProManager isProductPaid:kProDeluxeId]) {
        [view.scrollView purchase];
    }
}

//ACV滤镜
- (void)chooseAcv
{
    PhotoEditAcvItemView *view = [PhotoEditAcvItemView showInView:self.view];
    view.parentController = self;
    view.scrollView.parentController = self;
    view.mainImageView = mainImageView;
    [view setOkBlock:^{
        [self restoreMainView];
    }];
    [view setCancelBlock:^{
        [self restoreMainView];
    }];
    [view setSelectItemBlock:^(NSInteger index) {
        
    }];
    
    if (![ProManager isProductPaid:kProDeluxeId]) {
        [view.scrollView purchase];
    }
}

//恢复到主视图模式
-(void)restoreMainView
{
    [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        topView.transform = CGAffineTransformIdentity;
        mainImageView.frame = CGRectMake(10, topView.bounds.size.height + 10, self.view.bounds.size.width-20, self.view.bounds.size.height - bottomScrollView.bounds.size.height - topView.bounds.size.height - 20);
            bottomScrollView.alpha = 1;
    } completion:^(BOOL finished) {
        
    }];
}

-(void)hideTopView
{
    [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        topView.transform = CGAffineTransformMakeTranslation(0, -topView.bounds.size.height);
        mainImageView.frame = CGRectMake(10, 25, self.view.bounds.size.width - 20, self.view.bounds.size.height - 185);
        bottomScrollView.alpha = 0;
    } completion:^(BOOL finished) {
        
    }];
}

#pragma mark button action
-(void)back
{
    if ([self.delegate respondsToSelector:@selector(didClickCancelButtonWithEditController:)]) {
        [self.delegate didClickCancelButtonWithEditController:self];
    }
}

-(void)finish
{
    if ([self.delegate respondsToSelector:@selector(didClickFinishButtonWithEditController:newImage:)]) {
//        [self.delegate didClickFinishButtonWithEditController:self newImage:mainImageView.image];
        [self.delegate didClickFinishButtonWithEditController:self newImage:[self captureMainView]];
    }
}

- (UIImage*)captureMainView
{
    CGRect r;
    CGSize image_size = mainImageView.realImageSize;
    CGSize container_size = mainImageView.frame.size;
    r.origin.x = (container_size.width - image_size.width)/2 * [UIScreen mainScreen].scale;
    r.origin.y = (container_size.height - image_size.height)/2 * [UIScreen mainScreen].scale;
    r.size.width = image_size.width * [UIScreen mainScreen].scale;
    r.size.height = image_size.height * [UIScreen mainScreen].scale;
    [StickerView setActiveStickerView:nil];
    for (int i=0; i<textViews.count; i++) {
        PCCollageItem *item = textViews[i];
        item.selected = NO;
    }
    return [self imageFromView:mainImageView rect:r];
}

-(UIImage*) imageFromView:(UIView *) v rect:(CGRect) rect{
    UIGraphicsBeginImageContextWithOptions(v.frame.size, YES, [UIScreen mainScreen].scale);  //NO，YES 控制是否透明
    [v.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    CGRect myImageRect = rect;
    CGImageRef imageRef = image.CGImage;
    CGImageRef subImageRef = CGImageCreateWithImageInRect(imageRef,myImageRect );
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextDrawImage(context, myImageRect, subImageRef);
    UIImage* smallImage = [UIImage imageWithCGImage:subImageRef];
    CGImageRelease(subImageRef);
    UIGraphicsEndImageContext();
    
    return smallImage;
}

//- (UIImage *)captureMainView:(UIView *)mainView
//{
//    UIImage* image = nil;
//    UIGraphicsBeginImageContextWithOptions(mainView.frame.size, NO, [UIScreen mainScreen].scale);
//
////    CGPoint savedContentOffset = scrollView.contentOffset;
////    CGRect savedFrame = scrollView.frame;
////    scrollView.contentOffset = CGPointZero;
////    scrollView.frame = CGRectMake(0, 0, scrollView.contentSize.width, scrollView.contentSize.height);
//
//    [mainView.layer renderInContext: UIGraphicsGetCurrentContext()];
//    image = UIGraphicsGetImageFromCurrentImageContext();
//
////    scrollView.contentOffset = savedContentOffset;
////    scrollView.frame = savedFrame;
//
//    UIGraphicsEndImageContext();
//
//    if (image != nil)
//    {
//        return image;
//    }
//
//    return nil;
//}

-(BOOL)prefersStatusBarHidden
{
    return YES;
}

+(UIImage*)resourceImageWithName:(NSString*)name
{
    NSString *path;
    if ([[name pathExtension] isEqualToString:@"jpg"]) {
        NSString *aBundleSourcePath = [[NSBundle mainBundle] pathForResource:@"CHPhotoEditResource" ofType:@"bundle"];
        NSBundle *bundle = [NSBundle bundleWithPath:aBundleSourcePath];
        path = [bundle pathForResource:name ofType:@"" inDirectory:@"icon"];
    }else{
        NSString *aBundleSourcePath = [[NSBundle mainBundle] pathForResource:@"CHPhotoEditResource" ofType:@"bundle"];
        NSBundle *bundle = [NSBundle bundleWithPath:aBundleSourcePath];
        path = [bundle pathForResource:[name stringByAppendingString:@"@2x"] ofType:@"png" inDirectory:@"icon"];
    }
    
    return [UIImage imageWithContentsOfFile:path];
    
}

+(UIImage*)textureImageWithName:(NSString*)name
{
    NSString *path;
    if ([[name pathExtension] isEqualToString:@"jpg"]) {
        NSString *aBundleSourcePath = [[NSBundle mainBundle] pathForResource:@"CHPhotoEditResource" ofType:@"bundle"];
        NSBundle *bundle = [NSBundle bundleWithPath:aBundleSourcePath];
        
        path = [bundle pathForResource:name ofType:@"" inDirectory:@"texture/halo_54"];
    }else{
        NSString *aBundleSourcePath = [[NSBundle mainBundle] pathForResource:@"CHPhotoEditResource" ofType:@"bundle"];
        NSBundle *bundle = [NSBundle bundleWithPath:aBundleSourcePath];
        path = [bundle pathForResource:[name stringByAppendingString:@"@2x"] ofType:@"png" inDirectory:@"icon"];
    }
    
    return [UIImage imageWithContentsOfFile:path];

}

-(CGRect)configRect:(CGSize)size
{
    float scale = self.oriImage.size.width / size.width;
    float H = self.oriImage.size.height / scale;
    if (H >= size.height) {
        float W = size.width;
        float X = 0;
        float Y = size.height/2.0 - H/2.0;
        return CGRectMake(X, Y, W, H);
    }
    scale = self.oriImage.size.height / size.height;
    float W = self.oriImage.size.width / scale;
    H = size.height;
    float X = size.width/2.0 - W/2.0;
    float Y = 0;
    return CGRectMake(X, Y, W, H);
}

-(void)setOriImage:(UIImage *)oriImage
{
    if (oriImage.size.width == 0 || oriImage.size.height == 0) {
        return;
    }
    float max = 1920.0 * 1080.0; //设置支持最大像素
    float scale = sqrtf(max/(oriImage.size.width*oriImage.size.height));
    if (scale < 1.0)
    {
        //缩小
        UIGraphicsBeginImageContext(CGSizeMake(oriImage.size.width*scale, oriImage.size.height*scale));
        [oriImage drawInRect:CGRectMake(0, 0, oriImage.size.width*scale, oriImage.size.height*scale)];
        oriImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
    }
    
    _oriImage = oriImage;
}

- (void)loadBuffer
{
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        
        AssetBuffer *buffer = [AssetBuffer sharedInstance];
        [buffer loadHalo];
        [buffer loadBorder];
    });
}

//文本
- (void)chooseText
{
    PCTextViewController *viewController = [[PCTextViewController alloc]init];
    viewController.delegate = self;
    [viewController show];
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
    
    item.center = CGPointMake(mainImageView.frame.size.width/2, mainImageView.frame.size.height/2);
    [mainImageView addSubview:item];
    
    [self restoreMainView];
    [textViews addObject:item];
//    [_collageViews addObject:item];
//    _currentSelectCollageItem.selected = NO;
//    _currentSelectCollageItem = item;
}

- (void)collageItemDidDeleteAction:(PCCollageItem *)item
{
    [item removeFromSuperview];
    [textViews removeObject:item];
}
@end
