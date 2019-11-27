//
//  PCCollageItem.m
//  PhotoCollage
//
//  Created by 杜杜 on 16/4/22.
//  Copyright © 2016年 duruochuan. All rights reserved.
//

#import "PCCollageItem.h"

@implementation PCCollageItem

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        
        _mainFrame = CGRectMake(21.0f, 21.0f, frame.size.width - 21.0f, frame.size.height - 21.0f);
        _mainView = [[UIView alloc]initWithFrame:_mainFrame];
        
        _mainView.backgroundColor = [UIColor clearColor];
        _mainView.layer.borderColor = [UIColor whiteColor].CGColor;
        _mainView.layer.cornerRadius = 1.0f;
        _mainView.layer.borderWidth = 1.0f;
        
        _deleteButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _deleteButton.frame = CGRectMake(0.0f, 0.0f, 42.0f, 42.0f);
        [_deleteButton setImage:[UIImage imageNamed:@"cancel"] forState:UIControlStateNormal];
        [_deleteButton addTarget:self action:@selector(deleteAction:) forControlEvents:UIControlEventTouchUpInside];
        
        _selected = YES;
        
        [self addSubview:_mainView];
        [self addSubview:_deleteButton];
        
        UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(panAction:)];
//        panGesture.delegate = self;
        [self addGestureRecognizer:panGesture];
        
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapAction:)];
        [self addGestureRecognizer:tapGesture];
        
        UIRotationGestureRecognizer *rotationGesture = [[UIRotationGestureRecognizer alloc]initWithTarget:self action:@selector(rotateAction:)];
//        rotationGesture.delegate = self;
        [self addGestureRecognizer:rotationGesture];
        
        UIPinchGestureRecognizer *pinchGesture = [[UIPinchGestureRecognizer alloc]initWithTarget:self action:@selector(pinchAction:)];
//        pinchGesture.delegate = self;
        [self addGestureRecognizer:pinchGesture];
        
        UIImageView *rbView = [[UIImageView alloc]initWithFrame:CGRectMake(frame.size.width - 30, frame.size.height - 30, 30, 30)];//右下角的视图
        rbView.userInteractionEnabled = YES;
        [self addSubview:rbView];
        
        UIPanGestureRecognizer *gesture = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(panGestureBottom:)];
        [rbView addGestureRecognizer:gesture];
        
        //最右边的视图
        rView = [[UIImageView alloc]initWithFrame:CGRectMake(frame.size.width - 10.0f, frame.size.height/2 - 10.0f, 20.0f, 20.0f)];
        rView.layer.cornerRadius = 10.0f;
        rView.layer.borderColor = [UIColor whiteColor].CGColor;
        rView.layer.borderWidth = 1.0f;
        self.clipsToBounds = YES;
        [self addSubview:rView];
        
        rView.hidden = YES;
        gesture = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(panGestureRight:)];
        rView.userInteractionEnabled = YES;
        [rView addGestureRecognizer:gesture];
    }
    return self;
}

- (void)addImageViewWithImage:(UIImage *)image
{
    if (!_imageView) {
        _imageView = [[UIImageView alloc]initWithFrame:CGRectMake(0.0, 0.0, _mainFrame.size.width, _mainFrame.size.height)];
        _imageView.clipsToBounds = YES;
        _imageView.contentMode = UIViewContentModeScaleAspectFit;
        _imageView.image = image;
        [_mainView addSubview:_imageView];
    }
}

- (void)addLabel:(UILabel *)label
{
    rView.hidden = NO;
    _label = label;
    [_mainView addSubview:label];
}

- (void)deleteAction:(id)sender
{
    if ([self.delegate respondsToSelector:@selector(collageItemDidDeleteAction:)]) {
        [self.delegate collageItemDidDeleteAction:self];
    }
}

- (void)tapAction:(UITapGestureRecognizer *)tapGesture
{
    self.selected = !_selected;
    
    if ([self.delegate respondsToSelector:@selector(collageItemDidTapAction:)]) {
        [self.delegate collageItemDidTapAction:self];
    }
}

- (void)setSelected:(BOOL)selected
{
    _selected = selected;
    if (_selected) {
        _mainView.layer.borderWidth = 1.0f;
        _deleteButton.hidden = NO;
        rView.hidden = NO;
    }
    else {
        _mainView.layer.borderWidth = 0.0f;
        _deleteButton.hidden = YES;
        rView.hidden = YES;
    }
}

- (void)panAction:(UIPanGestureRecognizer *)panGesture
{
    CGPoint pt = [panGesture translationInView:self.superview];
    self.center = CGPointMake(self.center.x + pt.x, self.center.y + pt.y);
    [panGesture setTranslation:CGPointZero inView:self];
}

- (void)rotateAction:(UIRotationGestureRecognizer *)rotationGesture
{
    self.transform = CGAffineTransformRotate(self.transform, rotationGesture.rotation);
    rotationGesture.rotation = 0.0f;
}

- (void)pinchAction:(UIPinchGestureRecognizer *)pinchGesture
{
//    self.transform = CGAffineTransformScale(self.transform, pinchGesture.scale, pinchGesture.scale);
    CGAffineTransform transform = self.transform;
    self.transform = CGAffineTransformIdentity;
    
    CGPoint center = self.center;
    CGRect frame = CGRectMake(0, 0, self.frame.size.width * pinchGesture.scale, self.frame.size.height * pinchGesture.scale);
    _mainFrame = CGRectMake(21.0f, 21.0f, frame.size.width - 21.0f, frame.size.height - 21.0f);
    
    if (_imageView) {
        _imageView.frame = CGRectMake(0.0f, 0.0f, _mainFrame.size.width, _mainFrame.size.height);
    }
    else {
        CGPoint labelCenter = CGPointMake(_label.center.x * pinchGesture.scale, _label.center.y * pinchGesture.scale);
        _label.frame = CGRectMake(0.0, 0.0, _label.frame.size.width * pinchGesture.scale, _label.frame.size.height * pinchGesture.scale);
        _label.center = labelCenter;
        _label.font = [UIFont fontWithName:_label.font.fontName size:_label.font.pointSize * pinchGesture.scale];
        
        rView.center = CGPointMake(rView.center.x * pinchGesture.scale, rView.center.y * pinchGesture.scale);
    }
    _mainView.frame = _mainFrame;
    self.frame = frame;
    self.center = center;
    self.transform = transform;
    
    pinchGesture.scale = 1.0f;
}

- (void)panGestureBottom:(UIPanGestureRecognizer *)gestureRecognizer
{
    
}

- (void)panGestureRight:(UIPanGestureRecognizer *)gestureRecognizer
{
    CGAffineTransform transform = self.transform;
    self.transform = CGAffineTransformIdentity;
    
    CGPoint pt = [gestureRecognizer translationInView:self.superview];
    CGRect frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, self.frame.size.width + pt.x, self.frame.size.height);
    _mainFrame = CGRectMake(21.0f, 21.0f, frame.size.width - 21.0f, frame.size.height - 21.0f);
    self.frame = frame;
    _mainView.frame = _mainFrame;
    _label.frame = CGRectMake(_label.frame.origin.x, _label.frame.origin.y, _label.frame.size.width + pt.x, _label.frame.size.height);
    rView.center = CGPointMake(rView.center.x + pt.x, rView.center.y);
    
    self.transform = transform;
    [gestureRecognizer setTranslation:CGPointZero inView:self];
}
#pragma mark - UIGestureRecognizerDelegate
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    return YES;
}

@end
