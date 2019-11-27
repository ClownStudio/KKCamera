//
//  PCCollectionView.h
//  PhotoCollage
//
//  Created by 杜杜 on 16/4/22.
//  Copyright © 2016年 duruochuan. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol PCCollectionViewDelegate;

@interface PCCollectionView : UIView {
    UIImageView *_purchaseImageView;
    UIImageView *_coverImageView;
}

+ (PCCollectionView *)collectionViewWithStartPoint:(CGPoint)startPoint;


@property(nonatomic,assign)id<PCCollectionViewDelegate> delegate;
@property(nonatomic,copy)NSString *coverFileName;
@property(nonatomic,readwrite)BOOL needPurchase;
@property(nonatomic,copy)NSString *iapIdentifier;
@property(nonatomic,strong)NSArray *files;

@end

@protocol PCCollectionViewDelegate <NSObject>

@optional
- (void)collectionViewDidTapAction:(PCCollectionView*)collectionView;

@end
