//
//  PCCollectionView.m
//  PhotoCollage
//
//  Created by 杜杜 on 16/4/22.
//  Copyright © 2016年 duruochuan. All rights reserved.
//

#import "PCCollectionView.h"
#import "DDPurchase.h"

@implementation PCCollectionView

+ (PCCollectionView *)collectionViewWithStartPoint:(CGPoint)startPoint
{
    PCCollectionView *collectionView = [[PCCollectionView alloc]initWithFrame:CGRectMake(startPoint.x, startPoint.y, 90.0f, 60.0f)];
    return collectionView;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.layer.borderColor = [UIColor whiteColor].CGColor;
        self.layer.borderWidth = 1.0f;
        self.layer.cornerRadius = 3.0f;
        
        _coverImageView = [[UIImageView alloc]initWithFrame:CGRectMake(0.0, 0.0, frame.size.width, frame.size.height)];
        _coverImageView.clipsToBounds = YES;
        _coverImageView.contentMode = UIViewContentModeScaleAspectFill;
        
        _purchaseImageView = [[UIImageView alloc]initWithFrame:CGRectMake(40.0f, 0.0f, 50.0f, 45.0f)];
        _purchaseImageView.clipsToBounds = YES;
        _purchaseImageView.contentMode = UIViewContentModeScaleAspectFill;
        _purchaseImageView.hidden = YES;
        _purchaseImageView.image = [UIImage imageNamed:@"purchase_pro_black"];
        
        _needPurchase = NO;
        
        [self addSubview:_coverImageView];
        [self addSubview:_purchaseImageView];
        
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapAction)];
        [self addGestureRecognizer:tapGesture];
    }
    return self;
}

- (void)tapAction
{
    if ([self.delegate respondsToSelector:@selector(collectionViewDidTapAction:)]) {
        [self.delegate collectionViewDidTapAction:self];
    }
}

#pragma mark - Set
- (void)setCoverFileName:(NSString *)coverFileName
{
    _coverFileName = [coverFileName copy];
    _coverImageView.image = [UIImage imageNamed:_coverFileName];
}

- (void)setNeedPurchase:(BOOL)needPurchase
{
    _needPurchase = needPurchase;
    _purchaseImageView.hidden = !_needPurchase;
}

- (void)setIapIdentifier:(NSString *)iapIdentifier
{
    _iapIdentifier = [iapIdentifier copy];
    if ([[DDPurchase purchase] isProductPurchased:kProfessionalIdentifier]) {
        self.needPurchase = NO;
    }
    else if ([[DDPurchase purchase]isProductPurchased:_iapIdentifier]) {
        self.needPurchase = NO;
    }
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
