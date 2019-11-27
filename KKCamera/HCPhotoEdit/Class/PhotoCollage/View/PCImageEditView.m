//
//  PCImageEditView.m
//  PhotoCollage
//
//  Created by 杜杜 on 16/4/20.
//  Copyright © 2016年 duruochuan. All rights reserved.
//

#import "PCImageEditView.h"
#import "GHContextMenuView.h"
#import "DDImage.h"

@interface PCImageEditView ()<UIScrollViewDelegate,GHContextOverlayViewDataSource,GHContextOverlayViewDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate> {
    UIScrollView *_scrollView;
    UIImageView  *_imageView;
    
    UIView       *_selectView;
    UIView       *_imagePickerView;
    UIButton     *_albumButton;
    UIButton     *_cameraButton;
}

@end

@implementation PCImageEditView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        _scrollView = [[UIScrollView alloc]initWithFrame:CGRectMake(0.0f, 0.0f, frame.size.width, frame.size.height)];
        _scrollView.delegate = self;
        _scrollView.showsVerticalScrollIndicator = NO;
        _scrollView.showsHorizontalScrollIndicator = NO;
        [_scrollView setMinimumZoomScale:1.0f];
        [_scrollView setMaximumZoomScale:2.0f];
        [self addSubview:_scrollView];
        
        _imageView = [[UIImageView alloc]initWithFrame:CGRectMake(0.0f, 0.0f, frame.size.width, frame.size.height)];
        _imageView.userInteractionEnabled = YES;
        [_scrollView addSubview:_imageView];
        
        _selectView = [[UIView alloc]initWithFrame:CGRectMake(0.0f, 0.0f, frame.size.width, frame.size.height)];
        _selectView.backgroundColor = [UIColor colorWithWhite:0.0f alpha:0.4f];
        [self addSubview:_selectView];
        _selectView.hidden = YES;
        
        GHContextMenuView* overlay = [[GHContextMenuView alloc] init];
        overlay.dataSource = self;
        overlay.delegate = self;
        
        UILongPressGestureRecognizer* longGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:overlay action:@selector(longPressDetected:)];
        longGesture.minimumPressDuration = 0.3f;
        [_imageView addGestureRecognizer:longGesture];
        longGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:overlay action:@selector(longPressDetected:)];
        longGesture.minimumPressDuration = 0.3f;
        [_selectView addGestureRecognizer:longGesture];
        
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapAction:)];
        [_imageView addGestureRecognizer:tapGesture];
        tapGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapAction:)];
        [_selectView addGestureRecognizer:tapGesture];
        
        _imagePickerView = [[UIView alloc]initWithFrame:CGRectMake(0.0, 0.0, 120.0, 55.0)];
        _imagePickerView.backgroundColor = [UIColor clearColor];
        _imagePickerView.center = CGPointMake(frame.size.width/2, frame.size.height/2);
        
        _albumButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _albumButton.frame = CGRectMake(0.0, 0.0, 10.0, 10.0);
        [_albumButton setImage:[UIImage imageNamed:@"album"] forState:UIControlStateNormal];
        [_albumButton addTarget:self action:@selector(albumAction) forControlEvents:UIControlEventTouchUpInside];
        
        
        _cameraButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _cameraButton.frame = CGRectMake(0.0, 0.0, 10.0, 10.0);
        [_cameraButton setImage:[UIImage imageNamed:@"camera"] forState:UIControlStateNormal];
        [_cameraButton addTarget:self action:@selector(cameraAction) forControlEvents:UIControlEventTouchUpInside];
        
        [_imagePickerView addSubview:_albumButton];
        [_imagePickerView addSubview:_cameraButton];
        [self addSubview:_imagePickerView];
        _imagePickerView.hidden = YES;
    }
    return self;
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
    CGContextRef context = UIGraphicsGetCurrentContext();
    if (_maskPath) {
        CGContextBeginPath(context);
        CGContextAddPath(context, _maskPath.CGPath);
        CGContextSetStrokeColorWithColor(context, [UIColor lightGrayColor].CGColor);
        CGContextSetAlpha(context, 1.0f);
        CGContextSetLineWidth(context, 1.0f);
        CGFloat lengths[] = {3,3};
        CGContextSetLineDash(context, 1, lengths, 2);
        CGContextStrokePath(context);
    }
    if (_selected) {
        
    }
}

- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event
{
    BOOL inside = [_maskPath containsPoint:point];
    if ([self.delegate respondsToSelector:@selector(imageEditViewDidTapAction:)]) {
        [self.delegate imageEditViewDidTapAction:self];
    }
    return inside;
}

#pragma mark - Action
- (void)tapAction:(UITapGestureRecognizer *)tapGesture
{
    if (!_image) {
        if (_imagePickerView.hidden) {
            _imagePickerView.hidden = NO;
            [UIView animateWithDuration:0.3f animations:^{
                _cameraButton.frame = CGRectMake(65.0, 0.0, 55.0, 55.0);
                _albumButton.frame = CGRectMake(0.0, 0.0, 55.0, 55.0);
            }];
        }
        else {
            [UIView animateWithDuration:0.2f animations:^{
                _cameraButton.frame = CGRectMake(0.0, 0.0, 10.0, 10.0);
                _albumButton.frame = CGRectMake(0.0, 0.0, 10.0, 10.0);
            } completion:^(BOOL finished) {
                _imagePickerView.hidden = YES;
            }];
        }
        return;
    }
    _selected = !_selected;
    _selectView.hidden = !_selected;
    if ([self.delegate respondsToSelector:@selector(imageEditViewDidSelectedChange:)]) {
        [self.delegate imageEditViewDidSelectedChange:self];
    }
}

#pragma mark - SET
- (void)setMaskPath:(UIBezierPath *)maskPath
{
    _maskPath = maskPath;
    
    @synchronized (self) {
        CAShapeLayer *maskLayer = [CAShapeLayer layer];
        maskLayer.path = [_maskPath CGPath];
        maskLayer.fillColor = [[UIColor whiteColor] CGColor];
        maskLayer.frame = self.bounds;
        self.layer.mask = maskLayer;
//        [self.layer addSublayer:maskLayer];
        
        [self setNeedsLayout];
    }
}

- (void)setSelected:(BOOL)selected
{
    _selected = selected;
    _selectView.hidden = !_selected;
}

- (void)setImage:(UIImage *)image
{
    _image = image;
    [self updateImage:_image];
}

- (void)setFilterImage:(UIImage *)filterImage
{
    _filterImage = filterImage;
//    [self updateImage:_filterImage];
    _imageView.image = _filterImage;
}

- (void)updateImage:(UIImage *)image
{
    CGFloat width = self.frame.size.width;
    CGFloat height = self.frame.size.height;
    if (image.size.width > image.size.height) {//图片的宽度大于图片的高度 高度不动
        CGFloat scale = self.frame.size.height/image.size.height;
        width = image.size.width * scale;
        
        if (width < self.frame.size.width) {
            width = self.frame.size.width;
            scale = self.frame.size.width/image.size.width;
            height = image.size.height * scale;
        }
    }
    else {
        CGFloat scale = self.frame.size.width/image.size.width;
        height = image.size.height * scale;
        if (height < self.frame.size.height) {
            height = self.frame.size.height;
            scale = self.frame.size.height/image.size.height;
            width = image.size.width * scale;
        }
    }
    _imageView.frame = CGRectMake(0.0f, 0.0f, width, height);
    _imageView.image = image;
    _scrollView.contentSize = CGSizeMake(width, height);
    if ([image isEqual:_image]) {
        if (image.size.width > image.size.height) {
            _scrollView.contentOffset = CGPointMake((width - self.frame.size.width)/2, 0.0f);
        }
        else {
            _scrollView.contentOffset = CGPointMake(0.0f, (height - self.frame.size.height)/2.0f);
        }
    }
}
#pragma mark - UIScrollViewDelegate
- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return _imageView;
}

- (void)scrollViewDidEndZooming:(UIScrollView *)scrollView withView:(UIView *)view atScale:(CGFloat)scale
{
    [scrollView setZoomScale:scale animated:NO];
}

#pragma mark - GHContextOverlayViewDataSource
- (NSInteger) numberOfMenuItems
{
    return 2;
}

-(UIImage*) imageForItemAtIndex:(NSInteger)index
{
    NSString* imageName = nil;
    switch (index) {
        case 0:
            imageName = @"album";
            break;
        case 1:
            imageName = @"camera";
            break;
            
        default:
            break;
    }
    return [UIImage imageNamed:imageName];
}

#pragma mark - GHContextOverlayViewDelegate
- (void) didSelectItemAtIndex:(NSInteger)selectedIndex forMenuAtPoint:(CGPoint)point
{
    _imagePickerView.hidden = YES;
    UIImagePickerController *imagePicker = [[UIImagePickerController alloc]init];
    imagePicker.delegate = self;
    if (selectedIndex == 1) {
        imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
    }
    [((UIViewController *)self.delegate) presentViewController:imagePicker animated:YES completion:^{
        
    }];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info
{
    @autoreleasepool {
        UIImage *image = [info valueForKey:UIImagePickerControllerOriginalImage];
        image = [DDImage scaleThumbnailWithImage:image outputSize:CGSizeMake(600, 600)];
        self.image = image;
    }
    if ([self.delegate respondsToSelector:@selector(imageEditViewDidImageChange:)]) {
        [self.delegate imageEditViewDidImageChange:self];
    }
    [picker dismissViewControllerAnimated:YES completion:^{
        
    }];
}

- (void)albumAction
{
    [self didSelectItemAtIndex:0 forMenuAtPoint:CGPointZero];
}

- (void)cameraAction
{
    [self didSelectItemAtIndex:1 forMenuAtPoint:CGPointZero];
}

@end
